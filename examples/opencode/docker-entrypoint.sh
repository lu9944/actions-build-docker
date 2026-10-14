#!/usr/bin/env bash
#
# OpenCode + OpenChamber 容器入口脚本
#
# 默认行为（docker run <镜像>）：
#   1. 监听 0.0.0.0，保证端口映射可访问（可用 -e OPENCHAMBER_HOST 覆盖）
#   2. 未指定 UI 密码时自动生成并持久化，避免以无认证方式对外暴露
#   3. 首次启动生成 SSH 密钥（供 OpenChamber 的 SSH/远程功能使用）
#   4. 启动 OpenChamber Web 服务（openchamber serve --foreground）
#
# 也可以直接指定命令：
#   docker run -d -p 3000:3000 <镜像>              # OpenChamber Web（默认）
#   docker run -it --rm <镜像> opencode            # opencode TUI
#   docker run -it --rm <镜像> bash                # 进入 shell
#   docker run -it --rm <镜像> --port 8080         # 透传给默认命令
set -euo pipefail

# 容器内需要监听所有网卡，端口映射才能访问
export OPENCHAMBER_HOST="${OPENCHAMBER_HOST:-0.0.0.0}"

# ---------------- UI 密码 ----------------
# 未定义 OPENCHAMBER_UI_PASSWORD 时自动生成并持久化；
# 显式传入（包括传空值以关闭认证）则不干预。
if [ -z "${OPENCHAMBER_UI_PASSWORD+defined}" ]; then
    password_dir="${OPENCHAMBER_DATA_DIR:-${HOME}/.config/openchamber}"
    password_file="${password_dir}/ui-password"
    mkdir -p "${password_dir}"
    if [ ! -s "${password_file}" ]; then
        # 32 个十六进制字符的随机密码
        od -An -N16 -tx1 /dev/urandom | tr -d ' \n' > "${password_file}"
        chmod 600 "${password_file}"
    fi
    OPENCHAMBER_UI_PASSWORD="$(cat "${password_file}")"
    export OPENCHAMBER_UI_PASSWORD
    echo "[entrypoint] OpenChamber UI 密码: ${OPENCHAMBER_UI_PASSWORD}"
    echo "[entrypoint] 已保存到 ${password_file}（可用 -e OPENCHAMBER_UI_PASSWORD=你的密码 覆盖）"
fi

# ---------------- SSH 密钥 ----------------
# OpenChamber 的远程/SSH 功能会用到；生成失败不影响启动
if [ ! -f "${HOME}/.ssh/id_ed25519" ]; then
    mkdir -p "${HOME}/.ssh"
    chmod 700 "${HOME}/.ssh" 2>/dev/null || true
    if ssh-keygen -t ed25519 -N "" -f "${HOME}/.ssh/id_ed25519" >/dev/null 2>&1; then
        echo "[entrypoint] 已生成 SSH 公钥（挂载 ${HOME}/.ssh 可持久化）:"
        cat "${HOME}/.ssh/id_ed25519.pub"
    else
        echo "[entrypoint] 警告: SSH 密钥生成失败（不影响启动）" >&2
    fi
fi

# ---------------- 默认命令 ----------------
# 无参数（docker run 默认）或参数以 - 开头（如 --port 8080）时，补全为默认命令
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- openchamber serve --foreground "$@"
fi

exec "$@"
