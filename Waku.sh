#!/bin/bash

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
        echo "2. 修复错误"
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

    # 安装Docker
    sudo apt install -y docker.io

    # 检测Docker安装是否成功
    if docker --version | grep -q "Docker version"; then
        echo "Docker安装成功。"
    else
        echo "Docker安装失败，请检查安装过程中的错误信息。"
        exit 1
    fi

    # 检查是否需要安装Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        # 下载并安装Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        # 检测Docker Compose安装是否成功
        if docker-compose --version | grep -q "docker-compose version 1.29.2"; then
            echo "Docker Compose安装成功。"
        else
            echo "Docker Compose安装失败，请检查安装过程中的错误信息。"
            exit 1
        fi
    fi

    # 安装Waku
    git clone https://github.com/waku-org/nwaku-compose
    cd nwaku-compose
    cp .env.example .env

    # 获取用户输入
    read -rp "请输入 ETH_CLIENT_ADDRESS（Sepolia ETH 的 RPC 地址）:" ETH_CLIENT_ADDRESS
    read -rp "请输入 ETH_TESTNET_KEY（有测试网 ETH 的私钥）:" ETH_TESTNET_KEY
    read -rp "请输入 RLN_RELAY_CRED_PASSWORD（设置密码）:" RLN_RELAY_CRED_PASSWORD

    # 替换.env文件中的内容
    sed -i "s|ETH_CLIENT_ADDRESS=.*|RLN_RELAY_ETH_CLIENT_ADDRESS=$ETH_CLIENT_ADDRESS|" .env
    sed -i "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$ETH_TESTNET_KEY|" .env
    sed -i "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=$RLN_RELAY_CRED_PASSWORD|" .env

    echo "已将以下内容写入 .env 文件："
    echo "RLN_RELAY_ETH_CLIENT_ADDRESS=$ETH_CLIENT_ADDRESS"
    echo "ETH_TESTNET_KEY=$ETH_TESTNET_KEY"
    echo "RLN_RELAY_CRED_PASSWORD=$RLN_RELAY_CRED_PASSWORD"

    echo "请继续编辑.env文件（如果需要）："
    echo "nano .env"

    # 注册节点
    ./register_rln.sh

    # 启动 Docker Compose
    docker-compose up -d

    echo "Waku安装完成，并已注册节点并启动。"
}

# 修复错误函数
function fix_errors() {
    # 停止 Docker Compose 服务
    docker-compose down

    # 执行 git stash 和 git pull 操作
    git stash push --include-untracked
    git pull https://github.com/waku-org/nwaku-compose.git

    # 删除 keystore 和 rln_tree 目录
    rm -rf keystore rln_tree

    # 从 origin/master 分支拉取最新代码
    git pull origin master

    # 编辑 .env 文件
    nano .env  # 请修改 ETH_CLIENT_ADDRESS 为 RLN_RELAY_ETH_CLIENT_ADDRESS

    # 注册节点
    ./register_rln.sh

    # 启动 Docker Compose
    docker-compose up -d

    echo "错误修复完成。"
}

# 主程序开始
main_menu
