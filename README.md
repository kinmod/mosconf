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

