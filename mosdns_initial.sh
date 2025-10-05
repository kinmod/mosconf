#!/bin/bash
set -euo pipefail
LOGFILE="/var/log/mosdns_setup.log"

exec > >(tee -a "$LOGFILE") 2>&1

echo "================= MosDNS & v2dat 一键初始化 ================="

# 检查 root 权限
if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 请使用 root 权限运行此脚本 (e.g., sudo $0)"
    exit 1
fi

# 检查依赖
for cmd in wget v2dat; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "错误: $cmd 命令未找到，请先安装 $cmd"
        exit 1
    fi
done

# 配置目录
CONF_DIR="/etc/mosdns"
GEODATA_DIR="$CONF_DIR/geodata"
IP_SET_DIR="$CONF_DIR/ip_set"
DOMAIN_SET_DIR="$CONF_DIR/domain_set"
CACHE_DIR="$CONF_DIR/cache"
PLUGIN_DIR="$CONF_DIR/plugin"
PROXY_CLIENTS="$CONF_DIR/proxy_clients.txt"

# 创建目录
for dir in "$CONF_DIR" "$GEODATA_DIR" "$IP_SET_DIR" "$DOMAIN_SET_DIR" "$CACHE_DIR" "$PLUGIN_DIR"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "已创建目录: $dir"
    else
        echo "目录已存在: $dir"
    fi
done

# 下载 geodata 文件
V2RAY_RULES="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download"
declare -A FILES=( ["geoip.dat"]="$V2RAY_RULES/geoip.dat" ["geosite.dat"]="$V2RAY_RULES/geosite.dat" )

for file in "${!FILES[@]}"; do
    echo "下载 $file..."
    wget -nv -L -P "$GEODATA_DIR" -N "${FILES[$file]}" || { echo "下载 $file 失败"; exit 1; }
done

echo "所有 geodata 文件已下载完成"

# 解包 geodata
declare -A UNPACK_TASKS=(
    ["geoip:private"]="$IP_SET_DIR"
    ["geoip:cn"]="$IP_SET_DIR"
    ["geosite:private"]="$DOMAIN_SET_DIR"
    ["geosite:google"]="$DOMAIN_SET_DIR"
    ["geosite:cn"]="$DOMAIN_SET_DIR"
    ["geosite:geolocation-!cn"]="$DOMAIN_SET_DIR"
)

for task in "${!UNPACK_TASKS[@]}"; do
    IFS=':' read -r type tag <<< "$task"
    SRC_FILE="$GEODATA_DIR/${type}.dat"
    OUT_DIR="${UNPACK_TASKS[$task]}"
    echo "解包 $type:$tag 到 $OUT_DIR ..."
    v2dat unpack "$type" -o "$OUT_DIR" -f "$tag" "$SRC_FILE" || { echo "解包 $type:$tag 失败"; exit 1; }
done

echo "所有 geodata 已解包完成"

# 创建客户端列表文件
if [ ! -f "$PROXY_CLIENTS" ]; then
    touch "$PROXY_CLIENTS"
    echo "客户端列表文件已创建: $PROXY_CLIENTS"
else
    echo "客户端列表文件已存在: $PROXY_CLIENTS"
fi

# 创建缓存文件
for cache in "$CACHE_DIR/cache_dns_local.dump" "$CACHE_DIR/cache_dns_direct.dump" "$CACHE_DIR/cache_dns_proxy.dump"; do
    if [ ! -f "$cache" ]; then
        touch "$cache"
        chmod 600 "$cache"
        echo "已创建缓存文件: $cache"
    else
        echo "缓存文件已存在: $cache"
    fi
done

echo "================= MosDNS 初始化完成 ================="
echo "日志文件: $LOGFILE"
