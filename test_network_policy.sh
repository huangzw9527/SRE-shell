#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -z "$LOCAL_IP" ] && LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
[ -z "$LOCAL_IP" ] && LOCAL_IP="unknown"

# 收集目标 IP
echo "请依次输入需要测试的目标 IP（每行一个，输入空行结束）："
IPS=()
while true; do
    read -r ip
    [ -z "$ip" ] && break
    IPS+=("$ip")
done

if [ ${#IPS[@]} -eq 0 ]; then
    echo "未输入任何 IP，退出。"
    exit 1
fi

# 选择端口模式
echo ""
echo "请选择端口模式："
echo "  1) 单个端口"
echo "  2) 端口区间"
read -r -p "请输入选项 [1/2]: " mode

case "$mode" in
    1)
        read -r -p "请输入端口号: " port
        PORTS=("$port")
        ;;
    2)
        read -r -p "请输入起始端口: " port_start
        read -r -p "请输入结束端口: " port_end
        PORTS=()
        for ((p = port_start; p <= port_end; p++)); do
            PORTS+=("$p")
        done
        ;;
    *)
        echo "无效选项，退出。"
        exit 1
        ;;
esac

echo ""
echo "========== 测试开始 =========="

for ip in "${IPS[@]}"; do
    for port in "${PORTS[@]}"; do
        if nc -z -w 3 "$ip" "$port" 2>/dev/null; then
            echo -e "${GREEN}${LOCAL_IP} -> ${ip}:${port} 访问成功${NC}"
        else
            echo -e "${RED}${LOCAL_IP} -> ${ip}:${port} 访问失败${NC}"
        fi
    done
done

echo "========== 测试结束 =========="
