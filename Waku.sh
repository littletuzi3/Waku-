#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Waku.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组: https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道: https://t.me/niuwuriji"
        echo "节点社区 Discord 社群: https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘Ctrl+C退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装节点"
        echo "2. 修复错误（暂不可用，官方脚本有问题）"
        echo "3. 退出"
        read -rp "请输入操作选项：" choice

        case $choice in
            1)
                install_node
                ;;
            2)
                fix_errors
                ;;
            3)
                echo "退出脚本，谢谢使用！"
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入。"
                sleep 2
                ;;
        esac
    done
}

# 安装节点函数
function install_node() {
    # 更新软件源并升级系统软件
    sudo apt update && sudo apt upgrade -y

    # 安装必要的软件和工具
    sudo apt install -y curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev

    # 克隆或更新 nwaku-compose 项目
    if [ -d "nwaku-compose" ]; then
        echo "更新 nwaku-compose 项目..."
        cd nwaku-compose || { echo "进入 nwaku-compose 目录失败，请检查错误信息。"; exit 1; }
        git stash push --include-untracked
        git pull origin master
        cd ..
    else
        echo "克隆 nwaku-compose 项目 ..."
        git clone https://github.com/waku-org/nwaku-compose
    fi

    # 进入 nwaku-compose 目录
    cd nwaku-compose || {
        echo "进入 nwaku-compose 目录失败，请检查错误信息。"
        exit 1
    }

    echo "成功进入 nwaku-compose 目录。"

    # 复制 .env.example 到 .env
    cp .env.example .env

    echo "成功复制 .env.example 到 .env 文件。"

    # 使用 nano 编辑 .env 文件
    echo "现在开始编辑 .env 文件，请完成后按 Ctrl+X 保存并退出。"
    nano .env

    echo ".env 文件编辑完成。"

    # 执行 register_rln.sh 脚本
    echo "正在执行 register_rln.sh 脚本..."
    ./register_rln.sh

    echo "register_rln.sh 脚本执行完成。"

    # 启动 Docker Compose 服务
    echo "启动 Docker Compose 服务..."
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }

    echo "Docker Compose 服务启动完成。"
}

# 修复错误函数
function fix_errors() {
    # 停止 Docker Compose 服务
    docker-compose down

    # 进入 nwaku-compose 目录
    cd nwaku-compose || { echo "进入 nwaku-compose 目录失败，请检查错误信息。"; exit 1; }

    # 执行 git stash 和 git pull 操作
    git stash push --include-untracked
    git pull origin master

    # 删除 keystore 和 rln_tree 目录
    rm -rf keystore rln_tree

    # 编辑 .env 文件
    nano -i .env  # 请修改 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS

    # 启动 Docker Compose
    docker-compose up -d || { echo "启动 Docker Compose 失败，请检查错误信息。"; exit 1; }

    echo "错误修复完成。"
    read -rp "按 Enter 返回菜单。"
}

# 主程序开始
main_menu
