#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# cd $WORK_PATH 目录下,先运行的 public.h -> 设备.h -> scripts/feeds install -a
# 必须的文件

USER_NAME='admin'        # 用户名 admin
device_name='G-DOCK'      # 设备名
wifi_name="OpenWrt"       # Wifi 名字 
WIFI_PASSWORD="1234567890"              # wifi密码，切记密码最少8位 admin
VERSION_name='KYGS'                     # 系统版本名称 KYGS
VERSION_TIME=$(date "+%Y%m%d")          # 自动时间更新时版本号: 20200320
lan_ip='192.168.2.1'                                                        # Lan Ip地址
utc_name='Asia\/Shanghai'                                                   # 时区
delete_bootstrap=true                                                       # 是否删除默认主题 true 、false
default_theme='argon'                                                       # 默认主题 结合主题文件夹名字
theme_argon='https://github.com/sypopo/luci-theme-argon-mc.git'             # 主题地址
openClash_url='https://github.com/vernesong/OpenClash.git'                  # OpenClash包地址
adguardhome_url='https://github.com/rufengsuixing/luci-app-adguardhome.git' # adguardhome 包地址
lienol_url='https://github.com/Lienol/openwrt-package.git'                  # Lienol 包地址
vssr_url_rely='https://github.com/jerrykuku/lua-maxminddb.git'              # vssr lua-maxminddb依赖
vssr_url='https://github.com/jerrykuku/luci-app-vssr.git'                   # vssr地址
vssr_plus_rely='https://github.com/Leo-Jo-My/my.git'                        # vssr_plus 依赖
vssr_plus='https://github.com/Leo-Jo-My/luci-app-vssr-plus.git'             # vssr_plus 地址
filter_url='https://github.com/destan19/OpenAppFilter.git'                  # AppFilter 地址
DEFAULT_PATH="./user/shared/defaults.h" # 默认文件配置目录
# 命令


# echo '修改用户名'
# sed -i 's/#define\s*SYS_USER_ROOT\s*"admin"/#define  SYS_USER_ROOT     "'$USER_NAME'"/g' $DEFAULT_PATH

# 设置密码为空（安装固件时无需密码登陆，然后自己修改想要的密码）
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

# 修改想要的root密码
#sed -i 's/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/root:你的密码/g' package/lean/default-settings/files/zzz-default-settings

# echo "修改机器名称"
sed -i "s/OpenWrt/$device_name/g" package/base-files/files/bin/config_generate


# echo "修改wifi名称"
sed -i "s/OpenWrt/$wifi_name/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# echo "修改Wif密码"
sed -i "s/1234567890/$WIFI_PASSWORD/g" $DEFAULT_PATH

echo "更新版本号时间"
sed -i "s/FIRMWARE_BUILDS_REV=[0-9]*/FIRMWARE_BUILDS_REV="$VERSION_namez$VERSION_TIME"/g" ./versions.inc

echo "设置lan ip"
sed -i "s/192.168.1.1/$lan_ip/g" package/base-files/files/bin/config_generate

echo "修改时区"
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='$utc_name'/g" package/base-files/files/bin/config_generate

#echo "修改默认主题"
#sed -i "s/bootstrap/$default_theme/g" feeds/luci/modules/luci-base/root/etc/config/luci

# ===============================================
# 添加 luci-theme-istore（iStoreOS 蓝白主题）
# ===============================================
rm -rf package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

rm -rf package/luci-app-argon-config
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# ===============================================
# 添加 luci-app-run（悟空Daily）
# ===============================================
echo ">>> [part2] 添加 luci-app-run"
rm -rf package/luci-app-run
git clone --depth=1 https://github.com/wukongdaily/luci-app-run.git package/luci-app-run

echo ">>> [part2] 完成"
# -------- luci-app-run （一个RUN插件安装小工具）--------
echo 'CONFIG_PACKAGE_luci-app-run=y' >>.config



#--------------------passwall科学上网-----------------

#----------------PassWall 最小可用-------------------------------------------------功能说明（中文）---------------------------------------------对固件体积影响----
echo 'CONFIG_PACKAGE_luci-app-passwall=y' >> .config     #  安装 LuCI 主程序（Web界面+规则生成+nft/ipt管理），不含任何代理二进制    +≈300 KB​ ✅必须
echo 'CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y' >> .config   # 可选：中文	安装 PassWall 简体中文语言包（仅 po/lua 文本）         +≈60 KB​ ⬆可选

echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client=y' >> .config   # ssr客户端（最轻量 SS 实现）    ≈900 KB–1 MB​ ✅关（最小代理开）


# 核心依赖（通常自动选，但保险起见显式写）
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray=n' >> .config   # ❌ Xray-core（VMess/VLESS/Trojan/Reality），这是大体积项    ≈6.5–7 MB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=n' >> .config   # ❌ V2Ray（Go 版），功能类似 Xray 但更大    ≈8–9 MB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Geodata=n' >> .config   # ❌ GeoIP / GeoSite 数据库（大陆/国外分流用）    ≈1.5–2 MB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Simple_Obfs=n' >> .config   # ❌ Simple-Obfs 混淆插件（SS 用）    ≈150–200 KB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan=n' >> .config   # ❌ Trojan-GFW / Trojan-Go​    ≈2–3 MB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaCl=n' >> .config   # ❌ NaCl 加密库（老 SS chacha20 依赖）    ≈200–300 KB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=n' >> .config   # ❌ dns2socks（TCP DNS → SOCKS5 转换）    ≈120–150 KB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd-alt=n' >> .config   # ❌ pdnsd-alt（本地 DNS 缓存/离线解析）    ≈250 KB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_tcping=n' >> .config   # ❌ tcping（TCP 延迟测试工具）    ≈80–100 KB​ ✅关
echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_chinadns-ng=n' >> .config   # ❌ ChinaDNS-NG（国内外 DNS 分流防污染）    ≈130–160 KB​ ✅关


# 可选（Trojan / Hysteria / Naive / Sing-box 按需加）
# echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=y' >> .config
# echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Hysteria=y' >> .config
# echo 'CONFIG_PACKAGE_luci-app-passwall_INCLUDE_singbox=y' >> .config


#-------------------iStore 商店系列（iStoreOS / 配置项-功能说明）---------------------	

echo 'CONFIG_PACKAGE_luci-app-istorex=y' >>.config	              # iStoreX 基础框架（iStore 应用商店后端/前端壳）
echo 'CONFIG_PACKAGE_app-meta-istorex=y' >>.config	              # iStoreX 元数据包（分类信息、图标、依赖汇总）
echo 'CONFIG_PACKAGE_luci-app-store=y' >>.config      	      # iStore 应用商店，可在 Web 界面在线安装/卸载 ipk 应用
echo 'CONFIG_PACKAGE_luci-i18n-store-zh-cn=y' >>.config	      # iStore 简体中文语言包
echo 'CONFIG_PACKAGE_luci-app-istoreos-upgrade=y' >>.config       # iStoreOS 固件在线升级/检查更新工具
echo 'CONFIG_PACKAGE_luci-app-design-config=y' >>.config	      # iStoreOS 主题/设计配置（Logo、配色、页脚等）

#-------------------iStore 商店系列（QuickStart 向导）---------------------	

echo 'CONFIG_PACKAGE_luci-app-quickstart=y' >>.config	          #  LuCI 快速入门向导，首次登录引导配置 WAN/LAN/密码/时区等
echo 'CONFIG_PACKAGE_luci-i18n-quickstart-zh-cn=y' >>.config      # QuickStart 简体中文语言包

#-------------------iStore 商店系列（磁盘 & 分区管理）---------------------	
	
# echo 'CONFIG_PACKAGE_luci-app-diskman=y' >>.config	              # 磁盘管理（查看/格式化/挂载 EXT4/NTFS/exFAT 等）
# echo 'CONFIG_PACKAGE_luci-app-partexp=y' >>.config                # 分区扩展工具，把 overlay/rootfs 扩展到整个存储分区（常用于 U 盘/SSD）
	
#-------------------iStore 商店系列（ 终端 / 文件 / 服务工具）---------------------	
	
echo 'CONFIG_PACKAGE_luci-app-ttyd=y' >>.config	                  # 浏览器内嵌 TTY 终端（直接网页 SSH 进路由器）
echo 'CONFIG_PACKAGE_luci-app-filetransfer=y' >>.config	          # LuCI 文件上传/下载（SCP 替代，方便传 ipk/配置文件）
# echo 'CONFIG_PACKAGE_luci-app-samba4=y' >>.config	              # Samba 4 文件共享（局域网 Windows 访问路由器磁盘）
echo 'CONFIG_PACKAGE_luci-app-upnp=y' >>.config	                  # UPnP / NAT-PMP（BT/PT/游戏自动映射端口）
echo 'CONFIG_PACKAGE_luci-app-wol=y' >>.config	                  # Wake on LAN（网页点按钮唤醒局域网电脑）
	
#-------------------iStore 商店系列-Docker & 私有云相关（x86 / 大闪存设备）---------------------	
	
# echo 'CONFIG_PACKAGE_luci-app-dockerman=y' >>.config	          # Docker 容器管理界面（需底层 dockerd + 足够空间）
# echo 'CONFIG_PACKAGE_luci-app-linkease=y' >>.config	          # 易有云 / Linkease（内网文件私有云 + 远程访问，需账号）
# echo 'CONFIG_PACKAGE_luci-app-ddnsto=y' >>.config	              # DDNSTO（第三方内网穿透 + 远程管理，需官网注册 Token）


# -----------------主题（iStoreOS 官方紫调 Argon）-----------------------
echo 'CONFIG_PACKAGE_luci-theme-istore=y' >>.config             # Argon 主题本体（好看、动画、毛玻璃）
echo 'CONFIG_PACKAGE_luci-app-argon-config=y' >>.config         # Argon 的主题配置工具（Web 页面）​
echo 'CONFIG_LUCI_LANG_zh_Hans=y' >>.config                     # 启用 LuCI 的简体中文语言包

# quickstart 依赖的 iptables / 内核模块（ImmortalWrt 24.10 是 nftables 底，按需）
echo 'CONFIG_PACKAGE_iptables-nft-compat=y' >>.config

# -----------------1. 默认主题切 Argon-----------------
mkdir -p files/etc/config
cat > files/etc/config/luci <<'EOF'
config luci 'main'
    option mediaurlbase '/luci-static/argon'
    option lang 'zh_cn'
EOF

# ----------------2. 让"首页"在左侧菜单排第一（ImmortalWrt 下 quickstart controller 权重有时不对）---------------------
sed -i 's/entry({"admin", "quickstart"/entry({"admin", "quickstart", order = 1}/' package/*/luci-app-quickstart/luasrc/controller/quickstart.lua 2>/dev/null || true

# ----------------3. 清掉 wizard_finished 标记，强制 QuickStart 向导首次弹出（可选，看你喜欢不喜欢自动弹）--------------------
mkdir -p files/etc/config
cat > files/etc/config/quickstart <<'EOF'
config quickstart 'main'
	option wizard_finished '0'
EOF
if [ -f "package/feeds/nas_luci/luci-app-quickstart/Makefile" ]; then
    sed -i 's/DEPENDS:=+luci-base/DEPENDS:=+luci-base\nNO_MINIFY=1/' \
        package/feeds/nas_luci/luci-app-quickstart/Makefile
fi
#-------------------------------------------------------------------------------------
# -----------------------一线多播----------------------------
echo 'CONFIG_PACKAGE_kmod-macvlan=y' >> .config    # 同一物理 WAN 口上虚拟出多个 MAC 地址不同的子接口    	≈20 KB
echo 'CONFIG_PACKAGE_ppp=y' >> .config    # PPP 协议核心程序（原配置已集成）     ≈120 KB
echo 'CONFIG_PACKAGE_ppp-mod-pppoe=y' >> .config    # PPPoE 内核模块 + 用户态插件（原配置已集成）     ≈30 KB​

# ---------------------可选：多线负载均衡----------------------
echo 'CONFIG_PACKAGE_mwan3=y' >> .config     # 多 WAN 负载均衡框架--管理多条出口（wan / wan2 / wan3…）   ≈150 KB​
echo 'CONFIG_PACKAGE_luci-app-mwan3=y' >> .config    # LuCI Web 管理界面 Web 中可视化配置      ≈80 KB​
      

# -------- Docker --------
# echo 'CONFIG_PACKAGE_docker=y' >>.config
# echo 'CONFIG_PACKAGE_dockerd=y' >>.config
# echo 'CONFIG_PACKAGE_luci-app-dockerman=y' >>.config
# echo 'CONFIG_PACKAGE_luci-lib-docker=y' >>.config

#if [ $delete_bootstrap ]; then
#  echo "去除默认bootstrap主题"
#  sed -i '/\+luci-theme-bootstrap/d' feeds/luci/collections/luci/Makefile
#  sed -i '/\+luci-theme-bootstrap/d' package/feeds/luci/luci/Makefile
#  sed -i '/CONFIG_PACKAGE_luci-theme-bootstrap=y/d' .config
#  sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
#fi

#echo '添加主题argon'
#(git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon && {
#    [ -d package/luci-theme-argon ] && echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config 
#}) 
# 添加主题argon-设置
#(git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config && {
#    [ -d package/luci-app-argon-config ] && echo "CONFIG_PACKAGE_luci-app-argon-config=y" >> .config 
#})

# echo '添加OpenClash'
# git clone $openClash_url package/lean/luci-app-openclash

#  OpenClash
# echo 'CONFIG_PACKAGE_luci-app-openclash=n' >>.config
# echo 'CONFIG_PACKAGE_luci-i18n-openclash-zh-cn=n' >>.config

#echo '添加Lienol包' #？？？？？？？？？？？？？？？？？？？？、
#git clone $lienol_url package/Lienol

# echo '添加文件浏览器'
# echo 'CONFIG_PACKAGE_luci-app-filebrowser=y' >>.config
# echo 'CONFIG_PACKAGE_luci-i18n-filebrowser-zh-cn=y' >>.config

# echo '添加adguardhome'
# git clone $adguardhome_url package/lean/luci-app-adguardhome
# echo 'CONFIG_PACKAGE_luci-app-adguardhome=y' >> .config
# echo 'CONFIG_PACKAGE_luci-i18n-adguardhome-zh-cn=y'  >> .config

# echo '添加HelloWord,并使用包默认的配置'  # TODO 这个的配置文件和SSP 冲突
# git clone $vssr_url_rely package/lean/lua-maxminddb
# git clone $vssr_url package/lean/luci-app-vssr
# echo 'CONFIG_PACKAGE_luci-app-vssr=y' >> .config
# echo 'CONFIG_PACKAGE_luci-i18n-vssr-zh-cn=y'  >> .config

# echo '添加OpenAppFilter过滤器'
# git clone $filter_url package/OpenAppFilter
# echo 'CONFIG_PACKAGE_luci-app-oaf=y' >>.config
# echo 'CONFIG_PACKAGE_kmod-oaf=y' >>.config
# echo 'CONFIG_PACKAGE_appfilter=y' >>.config
# echo 'CONFIG_PACKAGE_luci-i18n-oaf-zh-cn=y' >>.config

# echo '添加Leo-Jo-My的Hello World,并且使用默认包配置'
# git clone $vssr_plus_rely package/lean/luci-vssr-plus-rely
# git clone $vssr_plus_rely package/lean/luci-app-vssr-plus
# echo 'CONFIG_PACKAGE_luci-app-vssr-plus=y' >> .config
# echo 'CONFIG_PACKAGE_luci-i18n-vssr-plus-zh-cn=y'  >> .config




# 修改插件名字（修改名字后不知道会不会对插件功能有影响，自己多测试）
# sed -i 's/"BaiduPCS Web"/"百度网盘"/g' package/lean/luci-app-baidupcs-web/luasrc/controller/baidupcs-web.lua
# sed -i 's/cbi("qbittorrent"),_("qBittorrent")/cbi("qbittorrent"),_("BT下载")/g' package/lean/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua
# sed -i 's/"aMule设置"/"电驴下载"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-amule/po/zh-cn/amule.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-flowoffload/po/zh-cn/flowoffload.po
# sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' package/lean/luci-app-sfe/po/zh-cn/sfe.po
# sed -i 's/"实时流量监测"/"流量"/g' package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
# sed -i 's/"KMS 服务器"/"KMS激活"/g' package/lean/luci-app-vlmcsd/po/zh-cn/vlmcsd.zh-cn.po
# sed -i 's/"TTYD 终端"/"命令窗"/g' package/lean/luci-app-ttyd/po/zh-cn/terminal.po
# sed -i 's/"USB 打印服务器"/"打印服务"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/"网络存储"/"存储"/g' package/lean/luci-app-usb-printer/po/zh-cn/usb-printer.po
# sed -i 's/"Web 管理"/"Web管理"/g' package/lean/luci-app-webadmin/po/zh-cn/webadmin.po
# sed -i 's/"管理权"/"改密码"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
# sed -i 's/"带宽监控"/"监视"/g' feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po

#sed -i 's/"aMule设置"/"电驴下载"/g' `grep "aMule设置" -rl ./`
#sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./`
#sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
#sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
# sed -i 's/"KMS 服务器"/"KMS激活"/g' `grep "KMS 服务器" -rl ./`
# sed -i 's/"TTYD 终端"/"命令窗"/g' `grep "TTYD 终端" -rl ./`
#sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
# sed -i 's/"Web 管理"/"Web"/g' `grep "Web 管理" -rl ./`
#sed -i 's/"管理权"/"密码设置"/g' `grep "管理权" -rl ./`
#sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
# sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`

# 2. 添加公共自定义功能，设备单个的到设备 sh文件中添加
######################################################################
#以下选项是定义你需要的功能（y=集成,n=忽略），重新写入到 .config 文件
######################################################################
# $WORK_DIR/trunk 执行在这个目录下
#set -u

# 是否超频(多选一）
# echo "CONFIG_FIRMWARE_CPU_900MHZ=n" >>.config
# echo "CONFIG_FIRMWARE_CPU_600MHZ=n" >>.config

# ----------------ssr-科学-在 OpenWrt 23.05+ / ImmortalWrt 24.x / OpenWrt 主线的 feeds 里已经被废弃删除，原因是协议停止维护 + 安全隐患。-------
# echo "CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS=y" >>.config # SS plus+
# echo "CONFIG_FIRMWARE_INCLUDE_SSSERVER=n" >>.config    # SS server
# echo "CONFIG_FIRMWARE_INCLUDE_SSOBFS=y" >>.config      # simple-obfs混淆插件,SS 开了才可以打开
# echo "CONFIG_FIRMWARE_INCLUDE_V2RAY=n" >>.config  # 集成v2ray执行文件（3.8M左右)，如果不集成，会从网上下载下来执行，不影响正常使用
# echo "CONFIG_FIRMWARE_INCLUDE_TROJAN=n" >>.config # 集成trojan执行文件(1.1M左右)，如果不集成，会从网上下载下来执行，不影响正常使用

# echo 'CONFIG_PACKAGE_CONFIG_PACKAGE_luci=y' >>.config
# echo 'CONFIG_PACKAGE_luci-app-ssr-plus=y' >>.config
# echo 'CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y' >>.config
# echo 'CONFIG_PACKAGE_chinadns-ng=y' >>.config
# echo 'CONFIG_PACKAGE_dns2socks=y' >>.config
# echo 'CONFIG_PACKAGE_simple-obfs=y' >>.config
# echo 'CONFIG_PACKAGE_v2ray-plugin=n' >>.config
# 文件
# echo "CONFIG_FIRMWARE_INCLUDE_CADDY=y" >>.config    # 在线文件管理服务
# echo "CONFIG_FIRMWARE_INCLUDE_CADDYBIN=n" >>.config # 集成 caddu执行文件，此文件有13M,请注意固件大小。如果不集成，会从网上下载下来执行，不影响正常使用

# 广告
#echo "CONFIG_FIRMWARE_INCLUDE_KOOLPROXY=n" >>.config   # KP 广告过滤
#echo "CONFIG_FIRMWARE_INCLUDE_ADGUARDHOME=n" >>.config # ADGUARD 广告拦截
#echo "CONFIG_FIRMWARE_INCLUDE_ADBYBY=n" >>.config      # adbyby plus+

# 代理
#echo "CONFIG_FIRMWARE_INCLUDE_KUMASOCKS=y" >>.config # KUMA
#echo "CONFIG_FIRMWARE_INCLUDE_SRELAY=n" >>.config    # SOCKS proxy
#echo "CONFIG_FIRMWARE_INCLUDE_TUNSAFE=n" >>.config   # TUNSAFE
#echo "CONFIG_FIRMWARE_INCLUDE_SRELAY=n" >>.config    # srelay
#echo "CONFIG_FIRMWARE_INCLUDE_IPT2SOCKS=n" >>.config # IPT2

# 穿透
#echo "CONFIG_FIRMWARE_INCLUDE_FRPC=n" >>.config    # 内网穿透FRPC
#echo "CONFIG_FIRMWARE_INCLUDE_FRPS=n" >>.config    # 内网穿透FRPS
#echo "CONFIG_FIRMWARE_INCLUDE_ALIDDNS=n" >>.config # 阿里DDNS

#网易云解锁
#echo "CONFIG_FIRMWARE_INCLUDE_WYY=n" >>.config
#网易云解锁GO版本执行文件（4M多）注意固件超大小
#echo "CONFIG_FIRMWARE_INCLUDE_WYYBIN=n" >>.config

# DNS 有关
echo "CONFIG_FIRMWARE_INCLUDE_DNSFORWARDER=n" >>.config # DNS-FORWARDER
echo "CONFIG_FIRMWARE_INCLUDE_SMARTDNS=y" >>.config     # smartdns
echo "CONFIG_FIRMWARE_INCLUDE_SMARTDNSBIN=y" >>.config  # smartdns二进制文件

# 其他
#echo "CONFIG_FIRMWARE_INCLUDE_MENTOHUST=n" >>.config  # MENTOHUST
#echo "CONFIG_FIRMWARE_INCLUDE_SCUTCLIENT=n" >>.config # SCUTCLIENT
#echo "CONFIG_FIRMWARE_INCLUDE_CADDY=n" >>.config      # 在线文件管理服务
#echo "CONFIG_FIRMWARE_INCLUDE_MENTOHUST=n" >>.config  # MENTOHUST 锐捷认证
#echo "CONFIG_FIRMWARE_INCLUDE_SCUTCLIENT=n" >>.config # SCUT校园网客户端
#echo "CONFIG_FIRMWARE_INCLUDE_CADDYBIN=n" >>.config   # 集成caddu执行文件，此文件有13M,请注意固件大小。如果不集成，会从网上下载下来执行，不影响正常使用
#echo "CONFIG_FIRMWARE_INCLUDE_ZEROTIER=n" >>.config   # zerotier ~1.3M

# 3. 删除预设项
################################################################################################
# 因不同型号配置功能不一样，所以先把配置项删除，如果你自己要添加其他的，也要写上删除这一条，切记！！！
################################################################################################
# Default
# sed -i "/CONFIG_FIRMWARE_INCLUDE_DROPBEAR/d" .config           # 删除配置项 dropbear SSH
# sed -i "/CONFIG_FIRMWARE_INCLUDE_DROPBEAR_FAST_CODE/d" .config # 删除配置项 dropbear symmetrica
# sed -i "/CONFIG_FIRMWARE_INCLUDE_OPENSSH/d" .config            # 删除配置项 OpenSSH
# sed -i "/CONFIG_FIRMWARE_INCLUDE_DDNS_SSL/d" .config           # HTTPS support for DDNS client
# sed -i "/CONFIG_FIRMWARE_INCLUDE_HTTPS/d" .config              # HTTPS support

# C大
# sed -i "/CONFIG_FIRMWARE_INCLUDE_MENTOHUST/d" .config    # 删除配置项 MENTOHUST
# sed -i "/CONFIG_FIRMWARE_INCLUDE_SCUTCLIENT/d" .config   # 删除配置项 SCUTCLIENT
# sed -i "/CONFIG_FIRMWARE_INCLUDE_SHADOWSOCKS/d" .config  # 删除配置项 SS plus+
# sed -i "/CONFIG_FIRMWARE_INCLUDE_SSSERVER/d" .config     # 删除配置项 SS server
# sed -i "/CONFIG_FIRMWARE_INCLUDE_DNSFORWARDER/d" .config # 删除配置项 DNS-FORWARDER
# sed -i "/CONFIG_FIRMWARE_INCLUDE_ADBYBY/d" .config       # 删除配置项 adbyby plus+
# sed -i "/CONFIG_FIRMWARE_INCLUDE_TUNSAFE/d" .config      # 删除配置项 TUNSAFE
# sed -i "/CONFIG_FIRMWARE_INCLUDE_ALIDDNS/d" .config      # 删除配置项 阿里 DDNS
# sed -i "/CONFIG_FIRMWARE_INCLUDE_SMARTDNS/d" .config     # 删除配置项 smartDns
# sed -i "/CONFIG_FIRMWARE_INCLUDE_SRELAY/d" .config       # 删除配置项 srelay 代理
# sed -i "/CONFIG_FIRMWARE_INCLUDE_WYY/d" .config          # 删除配置项 网易云解锁
# sed -i "/CONFIG_FIRMWARE_INCLUDE_WYYBIN/d" .config       # 删除配置项 网易云解锁GO版本执行文件（4M多）注意固件超大小


#--------------------------------------------------------------------------------------------------------------
