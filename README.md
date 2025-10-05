# **mosdns-homeconf**
从 Benjamin1919/mosdns-homeconf 复制过来，适应自用平台，自用。
<br/>
适用于家庭网络 DNS 管理的 mosdns 配置，使不同网关的客户端共用一个 DNS，实现客户端按需分流、直连和代理的缓存分离、防止DNS污染、快速查询PTR等功能
原初始命令路径不合适，变更为UNRAID下 的MOSDNS根目录 /user/appdata/mosdns
<br/>
（特别适合 All in One 玩家 或 使用旁路网关的用户）
<br/>
<br/>
## 特性：
1.	网关不同的客户端使用同一个 mosdns ，便于统一监控和管理；
2.	代理节点/插件（甚至旁路网关系统）失效 不影响 直连域名/设备的 DNS 查询；
3.	本地/国内/国外服务器的查询缓存分离，避免因 域名分流规则更改 或 节点变更 导致的缓存污染；
4.	直接从正向查询（A/AAAA）缓存中查找 PTR 结果，大幅提升 PTR 查询速度；
5.	为不在 geosite 列表中的域名提供正确解析，快速解析国内小众网站、准确解析国外小众网站，真正做到 DNS 防污染；
6.	提供解压 geoip & geosite 数据的一键脚本；
7.	有效应对苹果设备 网络发现服务 查询时间过长的问题；
8.	屏蔽 HTTPS (type65) 和 ANY (type255) 查询，提高查询速度；
9.	对 PTR 查询进行本地/国内/国外分流；
10.	本地/国内/国外的 DNS 查询可以灵活地 启用/禁用缓存、单栈/双栈查询、指定 ECS IP。
<br/>

## 使用前必读：
1.	确保已安装 mosdns v5.3+（安装方法见: https://irine-sistiana.gitbook.io/mosdns-wiki/mosdns-v5#an-zhuang-zhi-xi-tong-fu-wu ）；
2.	了解 mosdns v5 配置中的基本参数与用法（官方文档: https://irine-sistiana.gitbook.io/mosdns-wiki/mosdns-v5/ru-he-pei-zhi-mosdns ）；
3.	理解 geosite 的基本用法（官方文档: https://xtls.github.io/config/routing.html#%E9%A2%84%E5%AE%9A%E4%B9%89%E5%9F%9F%E5%90%8D%E5%88%97%E8%A1%A8 ），了解 geosite 中的数据标签（ https://github.com/v2fly/domain-list-community/tree/master/data ）；
4.	理解 DNS 定义与基本原理，了解 A/AAAA/PTR 等常见 DNS 查询类型；
5.	了解自己正在使用的路由系统（RouterOS/iKuai/OpenWrt 等）如何给局域网客户端分配不同的网关和DNS。
<br/>

## 使用方法：
1.	安装 mosdns v5.3+，不同系统安装方式不同：OpenWrt 系统安装 luci-app-mosdns 插件；iKuai 系统通过 docker 安装；Debian 等 Linux 系统需从 GitHub 下载程序文件并安装至系统服务，然后设置开机自启；
2.	下载并运行初始化脚本 mosdns_initial.sh，默认配置目录是 /etc/mosdns（如需更改，请修改脚本的第 24 行），默认解压的数据标签有 geoip:private, geoip:cn, geosite:private, geosite:google, geosite:cn, geosite:geolocation!cn（如需更改，请修改脚本的第 80~86 行）；
```
sudo bash -c 'curl -LO https://raw.githubusercontent.com/kinmod/mosconf/main/mosdns_initial.sh && chmod +x mosdns_initial.sh && ./mosdns_initial.sh'
```
3.	将 DHCP server 的局域网 IP 填入 01_dns_server.yaml 第 10 行的相应位置；
4.	如果已通过 passwall2/openclash 等插件实现了局域网透明代理，那么请保留 01_dns_server.yaml 第 48、53、58、63 行的注释符号或整行删除；否则需要去掉注释符号，给每个国外的上游 DNS 服务器指定 socks 代理，避免因网络不通导致查询中断；
5.	如果修改了初始化脚本 mosdns_initial.sh 中的默认配置目录，那么需要修改 02_data_set.yaml、03_cache_plugin.yaml 和 config_main.yaml 中的相应路径；
6.	将运行 mosdns 的设备 IP 填入 config_main.yaml 第 9 行的相应位置，将 DDNS 域名填入第 72 行的相应位置；
7.	直连查询时发送 ECS，需要在 config_main.yaml 第 94、156 行填入 家庭宽带公网 IP 并取消注释；代理查询时发送 ECS，需要在第 105、169 行填入 代理节点落地 IP 并取消注释；
8.	将需要进行 DNS 分流的客户端 (通常是被代理的客户端) IP加入列表，例如：
```
echo “192.168.10.6” >> /etc/mosdns/proxy_clients.txt
```
9.	将主配置文件 config_main.yaml 上传至 /etc/mosdns，子配置文件 01_dns_server.yaml、02_data_set.yaml、03_cache_plugin.yaml、04_local_service.yaml 上传至 /etc/mosdns/plugin ；
10.	运行 mosdns
<br/>

## 最佳实践：
&emsp;&emsp;PVE 安装 RouterOS+OpenWrt+Debian，RouterOS 作为主路由 (192.168.10.1)，OpenWrt 作为旁路网关 (192.168.10.2)，给 Debian 分配 IP 192.168.10.3。<br/>
&emsp;&emsp;RouterOS/OpenWrt 任选其一作为 DHCP server，并将需要被代理的客户端指定网关为 192.168.10.2，直连的客户端网关为 192.168.10.1，所有客户端的 DNS 均为 192.168.10.3（以上操作无论 RouterOS/OpenWrt/iKuai 都可以实现，请自行搜索）。
另外记得将 DHCP server 的 IP 填入 01_dns_server.yaml 第 10 行的相应位置。<br/>
&emsp;&emsp;在上述场景中，即便是 OpenWrt 系统崩溃也 不影响 直连的客户端，对于 被代理的客户端，局域网域名、国内域名等需要直连的网站仍可以正常进行 DNS 查询（即便 OpenWrt 是 DHCP server，设备在 DHCP 有效期内也能正常获取 DNS）。<br/>
&emsp;&emsp;由于局域网所有客户端共用一个 DNS 转发器，因此可以让 AdGuardHome 接管局域网所有的 DNS。比如将 AdGuardHome 和 mosdns 都安装在 Debian 上，AdGuardHome 监听 192.168.10.3:53，mosdns 监听 127.0.0.1:10053，在 AdGuadHome 面板中将 上游 DNS 服务器 和 私人反向 DNS 服务器 设置为 127.0.0.1:10053。

<br/>

## 补充说明：
### 域名分流逻辑：
```
局域网域名：直连，本地 (DHCP server) 直接解析；
谷歌域名：代理，由国外DNS服务器进行解析；
国内域名：直连，由国内DNS服务器进行解析；
国外域名：代理，由国外DNS服务器进行解析；
不在geosite.dat中的域名：先由国内DNS服务器解析，如果得到的不是国内IP，则由国外DNS服务器再解析一次。
```
为什么谷歌域名的代理规则要放在国内域名直连规则的前面？因为 geosite:google 包含 geosite:google@cn，geosite:cn 同样包含 geosite:google@cn，如果 geosite:google@cn 走直连 (由国内 DNS 服务器解析)，许多谷歌系网站的连接速度将会非常慢。详情可见：https://github.com/v2fly/domain-list-community/tree/master/data

<br/>

### DNS防污染  vs  DNS防泄漏
&emsp;&emsp;大家想要实现 DNS 分流的初衷是什么？主要原因是许多国外域名在国内受到 DNS 污染，无法解析到正确的 IP。不知道从什么时候开始，越来越多的人执着于解决 DNS 泄漏。检测 DNS 泄漏的方法一般是打开 dnsleak 或类似网站，网站会发起大量二级域名的 DNS 查询，并显示这些查询使用了哪些服务器。其实只要将该网站的一级域名加入代理列表就能保证网站只显示国外服务器，从而实现 DNS “防泄漏”。
<br/>
&emsp;&emsp;实际上对大部分人来说这样的“防泄漏”没什么用，真正有用的每个域名都能解析到正确的 IP。Geosite 收录的域名数量与全世界域名数量相比不过是沧海一粟，因此正确解析 geosite 之外的域名才最重要。首先由国内 DNS 解析一次，如果得到国内 IP 则保留解析结果；如果得到的不是国内 IP 则由国外 DNS 再解析一次。这样既能保证不在 geosite 中的国内域名有较快的解析速度，又能保证不在 geosite 中的国外域名解析得到正确的结果。

<br/>

### 相同逻辑的 xray 客户端配置示例
几个关键参数：<br/>
- dnsObject 中的 `"expectIPs": ["geoip:cn"]` 、 `"disableFallbackIfMatch": true` 以及 每个server 的 `"skipFallback": true/false` <br/>
- routingObject 中的 `"domainStrategy": "IPIfNonMatch"`
```
{
  "dns": {
    "hosts": {
      "dns.alidns.com": ["223.5.5.5", "223.6.6.6"],
      "doh.pub": ["1.12.12.12", "120.53.53.53"],
      "dns.google": ["8.8.8.8", "8.8.4.4"],
      "dns11.quad9.net": ["9.9.9.11", "149.112.112.11"]
    },
    "servers": [
      {
        "address": "localhost",
        "domains": ["geosite:private"],
        "skipFallback": true
      },
      {
        "address": "https://dns11.quad9.net/dns-query",
        "domains": ["geosite:google"],
        "skipFallback": true,
        "clientIP": "节点落地IP"
      },
      {
        "address": "https://dns.alidns.com/dns-query",
        "domains": ["geosite:cn"],
        "skipFallback": true,
        "clientIP": "宽带公网IP",
        "queryStrategy": "UseIPv4"
      },
      {
        "address": "https://dns.google/dns-query",
        "domains": ["geosite:geolocation-!cn"],
        "skipFallback": true,
        "clientIP": "节点落地IP"
      },
      {
        "address": "https://doh.pub/dns-query",
        "expectIPs": ["geoip:cn"],
        "skipFallback": false,
        "queryStrategy": "UseIPv4"
      },
      {
        "address": "https://dns.google/dns-query",
        "skipFallback": false,
        "clientIP": "节点落地IP"
      }
    ],
    "queryStrategy": "UseIP",
    "disableCache": false,
    "disableFallback": false,
    "disableFallbackIfMatch": true
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "domainMatcher": "hybrid",
    "rules": [
      {
        "type": "field",
        "domain": [
          "geosite:private"
        ],
        "network": "tcp,udp",
        "outboundTag": "FREE"
      },
      {
        "type": "field",
        "domain": [
          "geosite:google"
        ],
        "network": "tcp,udp",
        "outboundTag": "PROXY"
      },
      {
        "type": "field",
        "domain": [
          "geosite:cn"
        ],
        "network": "tcp,udp",
        "outboundTag": "DIRECT"
      },
      {
        "type": "field",
        "domain": [
          "geosite:geolocation-!cn"
        ],
        "network": "tcp,udp",
        "outboundTag": "PROXY"
      },
      {
        "type": "field",
        "ip": [
          "geoip:private",
          "geoip:cn"
        ],
        "network": "tcp,udp",
        "outboundTag": "FREE"
      },
      {
        "type": "field",
        "ip": [
          "geoip:!cn"
        ],
        "network": "tcp,udp",
        "outboundTag": "PROXY"
      }
    ]
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 1080,
      "protocol": "socks",
      "settings": {
        //入站设置省略
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "domainsExcluded": [],
        "routeOnly": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "AsIs"
      },
      "tag": "FREE"
    },
    {
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4"
      },
      "tag": "DIRECT"
    },
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            //节点设置省略
          }
        ]
      },
      "tag": "PROXY",
      "streamSettings": {
        //节点传输方式设置省略
      }
    }
  ]
}
```
注意：Xray 内置的 DNS 只支持 A/AAAA 查询，其他类型的 DNS 查询会直接丢弃。

<br/>

### mosdns 缓存分离的优势
mosdns 可以设置多个缓存池，本项目将局域网本地(DHCP server)/国内服务器/国外服务器的查询缓存分开，这样做的好处：
1.	直连的客户端即便查询国外网站的 DNS，也只会被存储在国内服务器的缓存池中，不会污染国外服务器的缓存池，从而保证走代理的客户端始终能获得正确的 DNS 解析；
2.	代理节点变更后，可以只清除国外服务器的缓存池，不影响直连的域名或客户端；以上文“最佳实践”中的场景为例，清除国外服务器的缓存可以使用命令行：
`curl http://192.168.10.3:9091/plugins/Cache_Proxy/flush` 或用浏览器直接访问 `http://192.168.10.3:9091/plugins/Cache_Proxy/flush` (该操作只会清除内存中的缓存，不会删除存盘 dump 文件；只要不重启 mosdns 或不重启设备，mosdns 不会主动加载存盘 dump 文件；如果距离上次 dump 有 1024 次更新，则内存缓存会存盘并覆盖旧的记录)；
3.	如果经常变更代理节点，只需删除 config_main.yaml 第 102、103、166、167 行，即禁用国外服务器的查询缓存。

注意：AdGuardhome 有缓存功能，但是无法进行缓存分离。如果 AdGuardHome 和 mosdns 搭配使用，建议禁用 AdGuardHome 的乐观缓存，只启用 mosdns 的缓存，避免缓存池污染。

<br/>

### mosdns 上游服务器的选择
- 建议使用支持 ECS 的公共 DNS 服务器，获取离自己最近的 IP，从而有更好的连接速度
- 建议通过 DOH (DNS over HTTPS) 进行查询，确保 ECS 中的 IP 信息不被中间人看到
- 国内既支持 DOH 又支持 ECS 的公共 DNS 服务器有：阿里、腾讯、360
- 国外支持 DOH 的公共 DNS 服务器有很多，但是支持 ECS 的也不多，大名鼎鼎的 Cloudflare 就不支持 ECS
- 目前已知 谷歌、AdGuard 都支持 ECS；Quad9 的 9.9.9.9 不支持，但是 9.9.9.11 支持
- 其他公共 DNS 服务器请自行搜索；建议大家选择公共 DNS 服务器时，打开其官网看一下相关介绍

<br/>

## 参考项目
- [mosdns](https://github.com/IrineSistiana/mosdns)
- [Xray-core](https://github.com/XTLS/Xray-core)
- [domain-list-community](https://github.com/v2fly/domain-list-community)
- [v2ray-rules-dat](https://github.com/Loyalsoldier/v2ray-rules-dat)
- [AdGuardHome](https://github.com/AdguardTeam/AdGuardHome)
