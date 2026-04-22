#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
fi
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(hostname)
fi

read -p "请输入对端服务器地址: " REMOTE_HOST
if [ -z "$REMOTE_HOST" ]; then
    echo "对端服务器地址不能为空"
    exit 1
fi

echo "请选择端口类型:"
echo "  1) 单个端口"
echo "  2) 端口区间"
read -p "请输入选项 [1/2]: " PORT_TYPE

test_port() {
    local host=$1
    local port=$2
    if nc -z -w 3 "$host" "$port" >/dev/null 2>&1; then
        echo -e "${GREEN}${LOCAL_IP} -> ${host}:${port} 访问成功${NC}"
    else
        echo -e "${RED}${LOCAL_IP} -> ${host}:${port} 访问失败${NC}"
    fi
}

case "$PORT_TYPE" in
    1)
        read -p "请输入端口号: " PORT
        if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
            echo "端口号无效，必须是 1-65535 之间的整数"
            exit 1
        fi
        test_port "$REMOTE_HOST" "$PORT"
        ;;
    2)
        read -p "请输入起始端口: " START_PORT
        read -p "请输入终止端口: " END_PORT
        if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] || ! [[ "$END_PORT" =~ ^[0-9]+$ ]]; then
            echo "端口号必须是整数"
            exit 1
        fi
        if [ "$START_PORT" -lt 1 ] || [ "$END_PORT" -gt 65535 ] || [ "$START_PORT" -gt "$END_PORT" ]; then
            echo "端口区间无效，起始端口需 >=1，终止端口需 <=65535，且起始端口 <= 终止端口"
            exit 1
        fi
        for ((p=START_PORT; p<=END_PORT; p++)); do
            test_port "$REMOTE_HOST" "$p"
        done
        ;;
    *)
        echo "无效的选项"
        exit 1
        ;;
esac
