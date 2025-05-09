#!/bin/bash
BASE=/opt
WRITE_ENV=${BASE}/tongji-undergrad-thesis
COMPILE_CMD="latexmk -xelatex -interaction=nonstopmode -file-line-error -halt-on-error -shell-escape main"

function get-cid() {
    echo $(sudo docker ps -qf "name=tut-env")
}

function compile() {
    cid=$(get-cid)
    if [ -z "$cid" ]; then
        echo "错误：未能找到容器 tut-env 或容器未运行。"
        return 1
    fi
    echo "容器 ID: $cid"

    local target_compile_dir="${WRITE_ENV}"

    echo "正在从 $(pwd) 复制文件到容器 ${cid}:${target_compile_dir}/"
    if sudo docker cp "$(pwd)/." "${cid}:${target_compile_dir}/"; then
        echo "文件成功复制到 ${cid}:${target_compile_dir}/"
    else
        echo "错误：复制文件到容器失败。"
        return 1
    fi

    # 构建在容器内执行的清理和编译命令
    # 1. 清理之前编译产生的文件 (latexmk -C)
    # 2. 设置 TEXINPUTS 以便找到 style 目录下的 .cls 文件
    # 3. 执行编译命令
    local docker_exec_cmd="cd ${target_compile_dir} && latexmk -C && TEXINPUTS=.:./style: ${COMPILE_CMD}"

    echo "在容器内执行清理和编译: ${docker_exec_cmd}"
    if sudo docker exec -i ${cid} bash -c "${docker_exec_cmd}"; then
        echo "编译成功。"
    else
        echo "错误：在容器内编译失败。"
        echo "尝试复制 main.log 日志文件到 $(pwd)/compile_error_main.log ..."
        # 尝试复制日志文件，忽略可能的错误（例如文件不存在）
        sudo docker cp "${cid}:${target_compile_dir}/main.log" "$(pwd)/compile_error_main.log" >/dev/null 2>&1
        if [ -f "$(pwd)/compile_error_main.log" ]; then
            echo "已复制 main.log。请检查 compile_error_main.log 获取详细错误信息。"
        else
            echo "未能复制 main.log。"
        fi
        return 1
    fi

    echo "正在从容器复制 main.pdf 到 $(pwd)/main.pdf"
    if sudo docker cp "${cid}:${target_compile_dir}/main.pdf" "$(pwd)/main.pdf"; then
        echo "成功复制 main.pdf。"
    else
        echo "错误：复制 main.pdf 失败。可能文件未生成。"
        return 1
    fi
}

function tlmgr-install() {
    local pkgs_to_install=""
    for pkg_name in "$@"
    do
        pkgs_to_install+=" $pkg_name"
    done

    if [ -z "$pkgs_to_install" ]; then
        echo "用法: tlmgr-install <package_name> [package_name...]"
        return 1
    fi

    cid=$(get-cid)
    if [ -z "$cid" ]; then
        echo "错误：未能找到容器 tut-env 或容器未运行。"
        return 1
    fi

    echo "正在容器 ${cid} 中准备更新 tlmgr 并安装宏包: ${pkgs_to_install}"

    local tlmgr_update_script_url="https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh"
    local downloaded_script_path="/tmp/update-tlmgr-latest.sh"

    # 构建在容器内执行的命令字符串
    # 1. 检查 update-tlmgr-latest.sh 是否存在，如果不存在则尝试下载
    # 2. 执行 update-tlmgr-latest.sh --update (允许失败，用 || true)
    # 3. 执行 tlmgr update --self
    # 4. 执行 tlmgr install <packages>
    local docker_exec_script_content="
        # Part 1: Ensure update-tlmgr-latest.sh is runnable
        UTL_RUNNER_CMD='update-tlmgr-latest.sh'; # Default to one in PATH
        if ! command -v \$UTL_RUNNER_CMD &> /dev/null; then
            echo 'update-tlmgr-latest.sh not found in PATH. Attempting to download to ${downloaded_script_path}...';
            DL_TOOL_FOUND=false;
            if command -v wget &> /dev/null; then
                DL_TOOL_FOUND=true;
                # Try to download. If wget fails (e.g. network error), the file might not be executable.
                if wget -q \"${tlmgr_update_script_url}\" -O \"${downloaded_script_path}\" && chmod +x \"${downloaded_script_path}\"; then
                    echo 'wget download successful.'
                else
                    echo 'wget download or chmod failed.'
                fi;
            elif command -v curl &> /dev/null; then
                DL_TOOL_FOUND=true;
                if curl -sSL \"${tlmgr_update_script_url}\" -o \"${downloaded_script_path}\" && chmod +x \"${downloaded_script_path}\"; then
                     echo 'curl download successful.'
                else
                    echo 'curl download or chmod failed.'
                fi;
            fi;

            if ! \$DL_TOOL_FOUND; then
                echo '错误：容器内没有 wget 或 curl，无法下载 update-tlmgr-latest.sh。';
                exit 1; # Critical failure, cannot proceed
            fi;

            if [ -x \"${downloaded_script_path}\" ]; then
                UTL_RUNNER_CMD=\"${downloaded_script_path}\"; # Use downloaded script
                echo '已成功下载并使 ${downloaded_script_path} 可执行。';
            else
                echo '错误：下载或使 ${downloaded_script_path} 可执行失败 (来自 ${tlmgr_update_script_url})。';
                exit 1; # Critical failure
            fi;
        fi;

        echo \"将使用 \$UTL_RUNNER_CMD 更新 tlmgr 本身...\";
        # Part 2: Execute the update script, allowing it to 'fail' (mimicking original || true)
        (\$UTL_RUNNER_CMD --update) || true;

        # Part 3: Update tlmgr itself and install packages (original logic)
        echo '正在执行: tlmgr update --self';
        tlmgr update --self && (
            echo 'tlmgr update --self 成功。';
            echo '正在执行: tlmgr install ${pkgs_to_install}';
            tlmgr install ${pkgs_to_install}
        )
    "

    if sudo docker exec -i ${cid} bash -c "${docker_exec_script_content}"; then
        echo "宏包安装/更新命令已成功在容器内执行。"
    else
        echo "错误：在容器内更新 tlmgr 或安装宏包时发生错误。"
        return 1
    fi
}