# mosdns-homeconf
适用于家庭网络 DNS 管理的 mosdns 配置，实现局域网客户端按需分流、不同网关的设备共用一个 DNS 转发器、不同上游服务器的缓存分离、快速处理 PTR 查询、防止 DNS 污染等功能


### 特性：
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


### 使用前必读：
1.	确保已安装 mosdns v5.3+（安装方法见: https://irine-sistiana.gitbook.io/mosdns-wiki/mosdns-v5#an-zhuang-zhi-xi-tong-fu-wu ）；
2.	了解 mosdns v5 配置中的基本参数与用法（官方文档: https://irine-sistiana.gitbook.io/mosdns-wiki/mosdns-v5/ru-he-pei-zhi-mosdns ）；
3.	理解 geosite 的基本用法（官方文档: https://xtls.github.io/config/routing.html#%E9%A2%84%E5%AE%9A%E4%B9%89%E5%9F%9F%E5%90%8D%E5%88%97%E8%A1%A8 ），了解 geosite 中的数据标签（ https://github.com/v2fly/domain-list-community/tree/master/data ）；
4.	理解 DNS 定义与基本原理，了解 A/AAAA/PTR 等常见 DNS 查询类型；
5.	了解自己正在使用的路由系统（RouterOS/iKuai/OpenWrt 等）如何给局域网客户端分配不同的网关和DNS。


### 使用方法：
1.	安装 mosdns v5.3+，不同系统安装方式不同：OpenWrt 系统安装 luci-app-mosdns 插件；iKuai 系统通过 docker 安装；Debian 等 Linux 系统需从 GitHub 下载程序文件并安装至系统服务，然后设置开机自启；
2.	下载并运行初始化脚本 mosdns_initial.sh，默认配置目录是 /etc/mosdns（如需更改，请修改脚本的第 24 行），默认解压的数据标签有 geoip:private, geoip:cn, geosite:private, geosite:google, geosite:cn, geosite:geolocation!cn（如需更改，请修改脚本的第 80~86 行）；
3.	将 DHCP server 的局域网 IP 填入 01_dns_server.yaml 第 10 行的相应位置；
4.	如果已通过 passwall2/openclash 等插件实现了局域网透明代理，那么请保留 01_dns_server.yaml 第 48、53、58、63 行的注释符号或整行删除；否则需要去掉注释符号，给每个国外的上游 DNS 服务器指定 socks 代理，避免因网络不通导致查询中断；
5.	如果修改了初始化脚本 mosdns_initial.sh 中的默认配置目录，那么需要修改 02_data_set.yaml、03_cache_plugin.yaml 和 config_main.yaml 中的相应路径；
6.	将运行 mosdns 的设备 IP 填入 config_main.yaml 第 8 行的相应位置，将 DDNS 域名填入第 69 行的相应位置；
7.	直连查询时发送 ECS，需要在 config_main.yaml 第 91、153 行填入 家庭宽带公网 IP 并取消注释；代理查询时发送 ECS，需要在第 102、166 行填入 代理节点落地 IP 并取消注释；
8.	将需要进行 DNS 分流的客户端 (通常是被代理的客户端) IP加入列表，例如：
```
echo “192.168.10.6” >> /etc/mosdns/proxy_clients.txt
```
9.	将主配置文件 config_main.yaml 上传至 /etc/mosdns，子配置文件 01_dns_server.yaml、02_data_set.yaml、03_cache_plugin.yaml、04_local_service.yaml 上传至 /etc/mosdns/plugin ；
10.	运行 mosdns


### 最佳实践：
&emsp;&emsp;PVE 安装 RouterOS+OpenWrt+Debian，RouterOS 作为主路由 (192.168.10.1)，OpenWrt 作为旁路网关 (192.168.10.2)，给 Debian 分配 IP 192.168.10.3。<br/>
&emsp;&emsp;RouterOS/OpenWrt 任选其一作为 DHCP server，并将需要被代理的客户端指定网关为 192.168.10.2，直连的客户端网关为 192.168.10.1，所有客户端的 DNS 均为 192.168.10.3（以上操作无论 RouterOS/OpenWrt/iKuai 都可以实现，请自行搜索）。
另外记得将 DHCP server 的 IP 填入 01_dns_server.yaml 第 10 行的相应位置。<br/>
&emsp;&emsp;在上述场景中，即便是 OpenWrt 系统崩溃也 不影响 直连的客户端，对于 被代理的客户端，局域网域名、国内域名等需要直连的网站仍可以正常进行 DNS 查询（即便 OpenWrt 是 DHCP server，设备在 DHCP 有效期内也能正常获取 DNS）。<br/>
&emsp;&emsp;由于局域网所有客户端共用一个 DNS 转发器，因此可以让 AdGuardHome 接管局域网所有的 DNS。比如将 AdGuardHome 和 mosdns 都安装在 Debian 上，AdGuardHome 监听 192.168.10.3:53，mosdns 监听 127.0.0.1:10053，在 AdGuadHome 面板中将 上游 DNS 服务器 和 私人反向 DNS 服务器 设置为 127.0.0.1:10053。



