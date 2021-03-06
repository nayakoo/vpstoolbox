#!/usr/bin/env bash
# VPSTOOLBOX

# 一键安装Trojan-GFW代理,Hexo博客,Nextcloud等應用程式.
# One click install Trojan-gfw Hexo Nextcloud and so on.

# MIT License
#
# Copyright (c) 2019-2020 JohnRosen

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#如果你在使用VPSToolBox时遇到任何问题,请仔细阅读README.md/code或者**通过 [Telegram](https://t.me/vpstoolbox_chat)请求支援** !                                  

clear

set +e

#System Requirement
if [[ $(id -u) != 0 ]]; then
  echo -e "请使用root或者sudo用户运行,Please run this script as root or sudoer."
  exit 1
fi

if [[ $(uname -m 2> /dev/null) != x86_64 ]]; then
  echo -e "本程式仅适用于x86_64机器,Please run this script on x86_64 machine."
  exit 1
fi

if [[ $(free -m  | grep Mem | awk '{print $2}' 2> /dev/null) -le "100" ]]; then
  echo -e "本程式需要至少100MB记忆体才能正常运作,Please run this script on machine with more than 100MB total ram."
  exit 1
fi

if [[ $(df $PWD | awk '/[0-9]%/{print $(NF-2)}' 2> /dev/null) -le "3000000" ]]; then
  echo -e "本程式需要至少3GB磁碟空间才能正常运作,Please run this script on machine with more than 3G free disk space."
  exit 1
fi

#Do not show user interface for apt
export DEBIAN_FRONTEND=noninteractive

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
###Legacy Defined Colors
ERROR="31m"      # Error message
SUCCESS="32m"    # Success message
WARNING="33m"   # Warning message
INFO="36m"     # Info message
LINK="92m"     # Share Link Message

#Trojan Server and Client cipher
cipher_server="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
cipher_client="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA"

#Predefined install,do not change!!!
install_bbr=1
install_nodejs=1
install_trojan=1
trojanport="443"
tcp_fastopen="false"

#predefined env,do not change!!!
export COMPOSER_ALLOW_SUPERUSER=1

if [[ -d /usr/local/qcloud ]]; then
  #disable tencent cloud process
  rm -rf /usr/local/sa
  rm -rf /usr/local/agenttools
  rm -rf /usr/local/qcloud
  #disable huawei cloud process
  rm -rf /usr/local/telescope
fi

#Disable cloud-init
rm -rf /lib/systemd/system/cloud*

colorEcho(){
  set +e
  COLOR=$1
  echo -e "\033[${COLOR}${@:2}\033[0m"
}

#Remove Aliyun aegis
if [[ -f /etc/init.d/aegis ]] || [[ -f /etc/systemd/system/aliyun.service ]]; then
  TERM=ansi whiptail --title "阿里云监控卸载" --infobox "检测到阿里云恶意监控服务，开始卸载..." 7 68
colorEcho ${INFO} "Uninstall Aliyun aegis ing"
iptables -I INPUT -s 140.205.201.0/28 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.201.16/29 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.201.32/28 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.192/29 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.200/30 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.184/29 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.183/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.206/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.205/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.195/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.204/32 -j DROP &>/dev/null
systemctl stop aegis
systemctl stop CmsGoAgent.service
systemctl stop aliyun
systemctl stop cloud-config
systemctl stop cloud-final
systemctl stop cloud-init-local.service
systemctl stop cloud-init
systemctl stop ecs_mq
systemctl stop exim4
systemctl stop apparmor
systemctl stop sysstat
systemctl disable aegis
systemctl disable CmsGoAgent.service
systemctl disable aliyun
systemctl disable cloud-config
systemctl disable cloud-final
systemctl disable cloud-init-local.service
systemctl disable cloud-init
systemctl disable ecs_mq
systemctl disable exim4
systemctl disable apparmor
systemctl disable sysstat
killall -9 aegis_cli >/dev/null 2>&1
killall -9 aegis_update >/dev/null 2>&1
killall -9 aegis_cli >/dev/null 2>&1
killall -9 AliYunDun >/dev/null 2>&1
killall -9 AliHids >/dev/null 2>&1
killall -9 AliHips >/dev/null 2>&1
killall -9 AliYunDunUpdate >/dev/null 2>&1
rm -rf /etc/init.d/aegis
rm -rf /etc/systemd/system/CmsGoAgent*
rm -rf /etc/systemd/system/aliyun*
rm -rf /lib/systemd/system/cloud*
rm -rf /lib/systemd/system/ecs_mq*
rm -rf /usr/local/aegis
rm -rf /usr/local/cloudmonitor
rm -rf /usr/sbin/aliyun*
rm -rf /sbin/ecs_mq_rps_rfs
for ((var=2; var<=5; var++)) do
  if [ -d "/etc/rc${var}.d/" ];then
    rm -rf "/etc/rc${var}.d/S80aegis"
  elif [ -d "/etc/rc.d/rc${var}.d" ];then
    rm -rf "/etc/rc.d/rc${var}.d/S80aegis"
  fi
done
apt-get purge sysstat exim4 chrony aliyun-assist -y
systemctl daemon-reload
echo "nameserver 1.1.1.1" > '/etc/resolv.conf'
fi

install_rocketchat(){
    cat > 'docker-compose.yml' << EOF
version: '2'

services:
  rocketchat:
    image: rocketchat/rocket.chat:latest
    command: >
      bash -c
        "for i in `seq 1 30`; do
          node main.js &&
          s=$$? && break || s=$$?;
          echo \"Tried $$i times. Waiting 5 secs...\";
          sleep 5;
        done; (exit $$s)"
    restart: always
    volumes:
      - ./uploads:/app/uploads
    environment:
      - ROOT_URL=https://${domain}/rocketchat
      - Accounts_UseDNSDomainCheck=False
      - MONGO_URL=mongodb://mongo:27017/rocketchat
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local
      - MAIL_URL=smtp://127.0.0.1
#       - HTTP_PROXY=http://proxy.domain.com
#       - HTTPS_PROXY=http://proxy.domain.com
    depends_on:
      - mongo
    ports:
      - 127.0.0.1:3000:3000
    labels:
      - "traefik.backend=rocketchat"
      - "traefik.frontend.rule=Host: ${domain}"

  mongo:
    image: mongo:4.0
    restart: always
    volumes:
     - ./data/db:/data/db
     #- ./data/dump:/dump
    command: mongod --smallfiles --oplogSize 128 --replSet rs0 --storageEngine=mmapv1
    labels:
      - "traefik.enable=false"

  # this container's job is just run the command to initialize the replica set.
  # it will run the command and remove himself (it will not stay running)
  mongo-init-replica:
    image: mongo:4.0
    command: >
      bash -c
        "for i in `seq 1 30`; do
          mongo mongo/rocketchat --eval \"
            rs.initiate({
              _id: 'rs0',
              members: [ { _id: 0, host: 'localhost:27017' } ]})\" &&
          s=$$? && break || s=$$?;
          echo \"Tried $$i times. Waiting 5 secs...\";
          sleep 5;
        done; (exit $$s)"
    depends_on:
      - mongo

  # hubot, the popular chatbot (add the bot user first and change the password before starting this image)
  hubot:
    image: rocketchat/hubot-rocketchat:latest
    restart: always
    environment:
      - ROCKETCHAT_URL=rocketchat:3000
      - ROCKETCHAT_ROOM=GENERAL
      - ROCKETCHAT_USER=bot
      - ROCKETCHAT_PASSWORD=botpassword
      - BOT_NAME=bot
  # you can add more scripts as you'd like here, they need to be installable by npm
      - EXTERNAL_SCRIPTS=hubot-help,hubot-seen,hubot-links,hubot-diagnostics
    depends_on:
      - rocketchat
    labels:
      - "traefik.enable=false"
    volumes:
      - ./scripts:/home/hubot/scripts
  # this is used to expose the hubot port for notifications on the host on port 3001, e.g. for hubot-jenkins-notifier
    ports:
      - 127.0.0.1:3001:8080

  #traefik:
  #  image: traefik:latest
  #  restart: always
  #  command: >
  #    traefik
  #     --docker
  #     --acme=true
  #     --acme.domains='your.domain.tld'
  #     --acme.email='your@email.tld'
  #     --acme.entrypoint=https
  #     --acme.storagefile=acme.json
  #     --defaultentrypoints=http
  #     --defaultentrypoints=https
  #     --entryPoints='Name:http Address::80 Redirect.EntryPoint:https'
  #     --entryPoints='Name:https Address::443 TLS.Certificates:'
  #  ports:
  #    - 80:80
  #    - 443:443
  #  volumes:
  #    - /var/run/docker.sock:/var/run/docker.sock
EOF
docker-compose up -d
}

installstunserver(){
  set +e
  cd
  TERM=ansi whiptail --title "安装中" --infobox "安装stunserver中..." 7 68
  apt-get install libboost-all-dev -y
  git clone https://github.com/jselbie/stunserver
  cd stunserver
  make
  cp -f stunserver /usr/sbin
  cp -f stunclient /usr/sbin
    cat > '/etc/systemd/system/stunserver.service' << EOF
[Unit]
Description=stunserver
Documentation=https://github.com/jselbie/stunserver
After=network.target network-online.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/sbin/stunserver --configfile /etc/stunserver/stun.conf --verbosity 1
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
mkdir /etc/stunserver
    cat > '/etc/stunserver/stun.conf' << EOF
{
    "configurations" : [

        {
           "_description" : "STUN over UDP on IPv4 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "4",
           "protocol" : "udp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        },

        {
           "_description" : "STUN over TCP on IPv4 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "4",
           "protocol" : "tcp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        },

        {
           "_description" : "STUN over UDP on IPv6 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "6",
           "protocol" : "udp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        },

        {
           "_description" : "STUN over TCP on IPv6 on default ports (basic mode)",
           "mode" : "basic",
           "primaryinterface" : "",
           "altinterface" : "",
           "primaryport" : "3478",
           "altport" : "3479",
           "family" : "6",
           "protocol" : "tcp",
           "maxconn" : "",
           "primaryadvertised" : "",
           "altadvertised" : "",
           "ddp" : "1"
        }
    ]
}
EOF
systemctl restart stunserver
systemctl enable stunserver
cd
rm -rf stunserver
}

install_mongodb(){
  apt-get install gnupg -y
  wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    cat > '/etc/apt/sources.list.d/mongodb-org-4.4.list' << EOF
deb http://repo.mongodb.org/apt/debian $(lsb_release -cs)/mongodb-org/4.4 main
EOF
  apt-get update
  apt-get install -y mongodb-org
  apt-get install -y python-pymongo
  systemctl start mongod
  systemctl enable mongod
}

installredis(){
  set +e
  cd
  TERM=ansi whiptail --title "安装中" --infobox "安装redis中..." 7 68
  redisver=$(curl -s "https://api.github.com/repos/redis/redis/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  if [[ -f /usr/local/bin/redis-server ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新redis中..." 7 68
    curl -LO https://github.com/redis/redis/archive/${redisver}.zip
    unzip -o ${redisver}.zip
    rm ${redisver}.zip
    cd redis-${redisver}
    apt-get install libsystemd-dev pkg-config -y
    make USE_SYSTEMD=yes -j $(nproc --all)
    make install
  else
  curl -LO https://github.com/redis/redis/archive/${redisver}.zip
  unzip -o ${redisver}.zip
  rm ${redisver}.zip
  cd redis-${redisver}
  apt-get install libsystemd-dev pkg-config -y
  make USE_SYSTEMD=yes -j $(nproc --all)
  make install
  chmod +x /usr/local/bin/redis-server
  chmod +x /usr/local/bin/redis-cli
  useradd -m -s /sbin/nologin redis
  groupadd redis
  usermod -a -G redis redis
  usermod -a -G redis nginx
  usermod -a -G redis netdata
  mkdir /var/lib/redis
  mkdir /var/log/redis/
  mkdir /etc/redis
  chown -R redis:redis /var/lib/redis
  chown -R redis:redis /etc/redis
  chown -R redis:redis /var/log/redis
  cat > '/etc/systemd/system/redis.service' << EOF
[Unit]
Description=Advanced key-value store
After=network.target
Documentation=http://redis.io/documentation, man:redis-server(1)

[Service]
Type=notify
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
TimeoutStopSec=0
Restart=always
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=2755

UMask=007
PrivateTmp=yes
LimitNOFILE=65535
PrivateDevices=yes
ProtectHome=yes
ReadOnlyDirectories=/
ReadWriteDirectories=-/var/lib/redis
ReadWriteDirectories=-/var/log/redis
ReadWriteDirectories=-/var/run/redis

NoNewPrivileges=true
CapabilityBoundingSet=CAP_SETGID CAP_SETUID CAP_SYS_RESOURCE
MemoryDenyWriteExecute=true
ProtectKernelModules=true
ProtectKernelTunables=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictNamespaces=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX

ProtectSystem=full
ReadWriteDirectories=-/etc/redis

[Install]
WantedBy=multi-user.target
Alias=redis.service
EOF
systemctl daemon-reload
fi
  cat > '/etc/redis/redis.conf' << EOF
bind 127.0.0.1 ::1
protected-mode no
port 6379
tcp-backlog 511
unixsocket /var/run/redis/redis.sock
unixsocketperm 770
timeout 0
tcp-keepalive 300
daemonize no
supervised systemd
loglevel notice
logfile /var/log/redis/redis-server.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
EOF
systemctl restart redis
systemctl enable redis
}

installnextcloud(){
  set +e
  TERM=ansi whiptail --title "安装中" --infobox "安装nextcloud中..." 7 68
  apt-get install php7.4-redis -y
  cd /usr/share/nginx
  cloudver=$(curl -s "https://api.github.com/repos/nextcloud/server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  cloudver1=$(curl -s "https://api.github.com/repos/nextcloud/server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-20)
  if [[ -d /usr/share/nginx/nextcloud/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新nextcloud中..." 7 68
    wget https://github.com/nextcloud/server/releases/download/${cloudver}/nextcloud-${cloudver1}.zip
    unzip -o nextcloud*
    rm nextcloud*.zip
    cd
  else
  mysql -u root -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -u root -e "create user 'nextcloud'@'localhost' IDENTIFIED BY '${password1}';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* to nextcloud@'localhost';"
  mysql -u root -e "flush privileges;"
  wget https://github.com/nextcloud/server/releases/download/${cloudver}/nextcloud-${cloudver1}.zip
  unzip -o nextcloud*
  rm nextcloud*.zip
  mkdir /usr/share/nginx/nextcloud_data
  cd /usr/share/nginx/nextcloud/config
  cat > "autoconfig.php" << EOF
<?php
\$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => "nextcloud",
  "dbuser"        => "nextcloud",
  "dbpass"        => "${password1}",
  "dbhost"        => "localhost:/run/mysqld/mysqld.sock",
  "dbtableprefix" => "",
  "adminlogin"    => "admin",
  "adminpass"     => "${password1}",
  "directory"     => "/usr/share/nginx/nextcloud_data",
);
EOF
  chown -R nginx:nginx /usr/share/nginx/
  chown -R nginx:nginx /etc/nginx/
  crontab -l > mycron
  echo "*/5 * * * * sudo -u nginx php -f /usr/share/nginx/nextcloud/cron.php" >> mycron
  crontab mycron
  rm mycron
  chmod +x /usr/share/nginx/nextcloud/occ
  cd
  #sudo -u nginx ./occ db:add-missing-indices
  #sudo -u nginx ./occ db:convert-filecache-bigint
fi
}

#Show simple system info 
systeminfo(){
echo -e "-------------------------------System Information----------------------------"
echo -e "Hostname:\t\t"`hostname`
echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
echo -e "Manufacturer:\t\t"`cat /sys/class/dmi/id/chassis_vendor`
echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`
echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`
echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`
echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "Kernel:\t\t\t"`uname -r`
echo -e "Architecture:\t\t"`arch`
echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
echo -e "System Main IP:\t\t"`hostname -I`
echo -e "-------------------------------IP Information--------------------------------"
echo -e "ip:\t\t"`jq -r '.ip' "/root/.trojan/ip.json"`
echo -e "city:\t\t"`jq -r '.city' "/root/.trojan/ip.json"`
echo -e "region:\t\t"`jq -r '.region' "/root/.trojan/ip.json"`
echo -e "country:\t"`jq -r '.country' "/root/.trojan/ip.json"`
echo -e "loc:\t\t"`jq -r '.loc' "/root/.trojan/ip.json"`
echo -e "org:\t\t"`jq -r '.org' "/root/.trojan/ip.json"`
echo -e "postal:\t\t"`jq -r '.postal' "/root/.trojan/ip.json"`
echo -e "timezone:\t"`jq -r '.timezone' "/root/.trojan/ip.json"`
echo -e "-----------------------------------------------------------------------------"
if [[ -f /root/.trojan/ipv6.json ]]; then
echo -e "-------------------------------IPv6 Information------------------------------"
echo -e "ip:\t\t"$(jq -r '.ip' "/root/.trojan/ipv6.json")
echo -e "city:\t\t"$(jq -r '.city' "/root/.trojan/ipv6.json")
echo -e "region:\t\t"$(jq -r '.region' "/root/.trojan/ipv6.json")
echo -e "country:\t"$(jq -r '.country' "/root/.trojan/ipv6.json")
echo -e "loc:\t\t"$(jq -r '.loc' "/root/.trojan/ipv6.json")
echo -e "org:\t\t"$(jq -r '.org' "/root/.trojan/ipv6.json")
echo -e "postal:\t\t"$(jq -r '.postal' "/root/.trojan/ipv6.json")
echo -e "timezone:\t"$(jq -r '.timezone' "/root/.trojan/ipv6.json")
fi
}

#install i2pd
install_i2pd(){
  if [[ ${dist} == debian ]]; then
wget -q -O - https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -
apt-get update
apt-get install i2pd -y
 elif [[ ${dist} == ubuntu ]]; then
  add-apt-repository ppa:purplei2p/i2pd -y
  apt-get update
  apt-get install i2pd -y
 else
  echo "fail"
 fi
  cat > '/etc/i2pd/i2pd.conf' << EOF
## Configuration file for a typical i2pd user
## See https://i2pd.readthedocs.io/en/latest/user-guide/configuration/
## for more options you can use in this file.

## Lines that begin with "## " try to explain what's going on. Lines
## that begin with just "#" are disabled commands: you can enable them
## by removing the "#" symbol.

## Tunnels config file
## Default: ~/.i2pd/tunnels.conf or /var/lib/i2pd/tunnels.conf
# tunconf = /var/lib/i2pd/tunnels.conf

## Tunnels config files path
## Use that path to store separated tunnels in different config files.
## Default: ~/.i2pd/tunnels.d or /var/lib/i2pd/tunnels.d
# tunnelsdir = /var/lib/i2pd/tunnels.d

## Where to write pidfile (default: i2pd.pid, not used in Windows)
# pidfile = /run/i2pd.pid

## Logging configuration section
## By default logs go to stdout with level 'info' and higher
##
## Logs destination (valid values: stdout, file, syslog)
##  * stdout - print log entries to stdout
##  * file - log entries to a file
##  * syslog - use syslog, see man 3 syslog
log = syslog
## Path to logfile (default - autodetect)
# logfile = /var/log/i2pd/i2pd.log
## Log messages above this level (debug, info, *warn, error, none)
## If you set it to none, logging will be disabled
loglevel = error
## Write full CLF-formatted date and time to log (default: write only time)
# logclftime = true

## Daemon mode. Router will go to background after start
# daemon = true

## Specify a family, router belongs to (default - none)
# family =

## External IP address to listen for connections
## By default i2pd sets IP automatically
# host = 1.2.3.4

## Port to listen for connections
## By default i2pd picks random port. You MUST pick a random number too,
## don't just uncomment this
# port = 4567

## Enable communication through ipv4
ipv4 = true
## Enable communication through ipv6
ipv6 = true

## Network interface to bind to
# ifname =
## You can specify different interfaces for IPv4 and IPv6
# ifname4 = 
# ifname6 = 

## Enable NTCP transport (default = true)
# ntcp = true
## If you run i2pd behind a proxy server, you can only use NTCP transport with ntcpproxy option 
## Should be http://address:port or socks://address:port
# ntcpproxy = http://127.0.0.1:8118
## Enable SSU transport (default = true)
# ssu = true

## Should we assume we are behind NAT? (false only in MeshNet)
# nat = true

## Bandwidth configuration
## L limit bandwidth to 32KBs/sec, O - to 256KBs/sec, P - to 2048KBs/sec,
## X - unlimited
## Default is X for floodfill, L for regular node
bandwidth = X
## Max % of bandwidth limit for transit. 0-100. 100 by default
# share = 100

## Router will not accept transit tunnels, disabling transit traffic completely
## (default = false)
# notransit = true

## Router will be floodfill
floodfill = true

[http]
## Web Console settings
## Uncomment and set to 'false' to disable Web Console
# enabled = true
## Address and port service will listen on
address = 127.0.0.1
port = 7070
strictheaders = false
## Path to web console, default "/"
webroot = /${password1}_i2p/
## Uncomment following lines to enable Web Console authentication 
# auth = true
# user = i2pd
# pass = changeme

[httpproxy]
## Uncomment and set to 'false' to disable HTTP Proxy
# enabled = true
## Address and port service will listen on
address = 127.0.0.1
port = 4444
## Optional keys file for proxy local destination
# keys = http-proxy-keys.dat
## Enable address helper for adding .i2p domains with "jump URLs" (default: true)
# addresshelper = true
## Address of a proxy server inside I2P, which is used to visit regular Internet
outproxy = http://false.i2p
## httpproxy section also accepts I2CP parameters, like "inbound.length" etc.

[socksproxy]
## Uncomment and set to 'false' to disable SOCKS Proxy
# enabled = true
## Address and port service will listen on
address = 127.0.0.1
port = 4447
## Optional keys file for proxy local destination
# keys = socks-proxy-keys.dat
## Socks outproxy. Example below is set to use Tor for all connections except i2p
## Uncomment and set to 'true' to enable using of SOCKS outproxy
# outproxy.enabled = false
## Address and port of outproxy
# outproxy = 127.0.0.1
# outproxyport = 9050
## socksproxy section also accepts I2CP parameters, like "inbound.length" etc.

[sam]
## Uncomment and set to 'true' to enable SAM Bridge
enabled = true
## Address and port service will listen on
# address = 127.0.0.1
# port = 7656

[bob]
## Uncomment and set to 'true' to enable BOB command channel
# enabled = true
## Address and port service will listen on
# address = 127.0.0.1
# port = 2827

[i2cp]
## Uncomment and set to 'true' to enable I2CP protocol
enabled = true
singlethread = false
## Address and port service will listen on
# address = 127.0.0.1
# port = 7654

[i2pcontrol]
## Uncomment and set to 'true' to enable I2PControl protocol
# enabled = on
## Address and port service will listen on
# address = 127.0.0.1
# port = 7650
## Authentication password. "itoopie" by default
password = ${password1}

[precomputation]
## Enable or disable elgamal precomputation table
## By default, enabled on i386 hosts
# elgamal = true

[upnp]
## Enable or disable UPnP: automatic port forwarding (enabled by default in WINDOWS, ANDROID)
enabled = true
## Name i2pd appears in UPnP forwardings list (default = I2Pd)
# name = I2Pd

[reseed]
## Options for bootstrapping into I2P network, aka reseeding
## Enable or disable reseed data verification.
verify = true
## URLs to request reseed data from, separated by comma
## Default: "mainline" I2P Network reseeds
# urls = https://reseed.i2p-projekt.de/,https://i2p.mooo.com/netDb/,https://netdb.i2p2.no/
## Path to local reseed data file (.su3) for manual reseeding
# file = /path/to/i2pseeds.su3
## or HTTPS URL to reseed from
# file = https://legit-website.com/i2pseeds.su3
## Path to local ZIP file or HTTPS URL to reseed from
# zipfile = /path/to/netDb.zip
## If you run i2pd behind a proxy server, set proxy server for reseeding here
## Should be http://address:port or socks://address:port
# proxy = http://127.0.0.1:8118
## Minimum number of known routers, below which i2pd triggers reseeding. 25 by default
# threshold = 25

[addressbook]
## AddressBook subscription URL for initial setup
## Default: inr.i2p at "mainline" I2P Network
defaulturl = http://xk6ypey2az23vtdkitjxvanlshztmjs2ekd6sp77m4obszf6ocfq.b32.i2p/hosts.txt
## Optional subscriptions URLs, separated by comma
subscriptions = http://xk6ypey2az23vtdkitjxvanlshztmjs2ekd6sp77m4obszf6ocfq.b32.i2p/alive-hosts.txt,http://kqypgjpjwrphnzebod5ev3ts2vtii6e5tntrg4rnfijqc7rypldq.b32.i2p/cgi-bin/newhosts.txt,http://gh6655arkncnbrzq5tmq4xpn36734d4tdza6flbw5xppye2dt6ga.b32.i2p/hosts.txt

[limits]
## Maximum active transit sessions (default:2500)
# transittunnels = 2500
## Limit number of open file descriptors (0 - use system limit)  
# openfiles = 0
## Maximum size of corefile in Kb (0 - use system limit) 
# coresize = 0
## Threshold to start probabalistic backoff with ntcp sessions (0 - use system limit) 
# ntcpsoft = 0
## Maximum number of ntcp sessions (0 - use system limit) 
# ntcphard = 0

[trust]
## Enable explicit trust options. false by default
# enabled = true
## Make direct I2P connections only to routers in specified Family.
# family = MyFamily
## Make direct I2P connections only to routers specified here. Comma separated list of base64 identities.
# routers = 
## Should we hide our router from other routers? false by default
# hidden = true

[exploratory]
## Exploratory tunnels settings with default values
inbound.length = 2 
inbound.quantity = 6
outbound.length = 2
outbound.quantity = 6

[ntcp2]

enabled = true
published = true

[persist]
## Save peer profiles on disk (default: true)
# profiles = true

[cpuext]
## Use CPU AES-NI instructions set when work with cryptography when available (default: true)
# aesni = true
## Use CPU AVX instructions set when work with cryptography when available (default: true)
# avx = true
## Force usage of CPU instructions set, even if they not found
## DO NOT TOUCH that option if you really don't know what are you doing!
# force = false
EOF
    cat > '/etc/i2pd/tunnels.conf.d/mywebsite.conf' << EOF
[my-website]
type = http
host = 127.0.0.1
port = 80
keys = my-website.dat
EOF
    cat > '/etc/i2pd/tunnels.conf.d/ssh.conf' << EOF
[SSH-SERVER]
type = server
host = 127.0.0.1
port = 22
inbound.length = 1
outbound.length = 1
inbound.quantity = 6
outbound.quantity = 6
inbound.backupQuantity = 3
outbound.backupQuantity = 3
keys = ssh-in.dat
EOF
    cat > '/etc/i2pd/tunnels.conf.d/proxy.conf' << EOF
[PROXY-SERVER]
type = server
host = 127.0.0.1
port = 1024
inbound.length = 1
outbound.length = 1
inbound.quantity = 6
outbound.quantity = 6
inbound.backupQuantity = 3
outbound.backupQuantity = 3
keys = ssh-in.dat
EOF
systemctl restart i2pd
}

#Set system language
setlanguage(){
  set +e
  if [[ ! -d /root/.trojan/ ]]; then
    mkdir /root/.trojan/
    mkdir /etc/certs/
  fi
  if [[ -f /root/.trojan/language.json ]]; then
    language="$( jq -r '.language' "/root/.trojan/language.json" )"
  fi
  while [[ -z $language ]]; do
  export LANGUAGE="C.UTF-8"
  export LANG="C.UTF-8"
  export LC_ALL="C.UTF-8"
  if (whiptail --title "System Language Setting" --yes-button "中文" --no-button "English" --yesno "使用中文或英文(Use Chinese or English)?" 8 68); then
  chattr -i /etc/locale.gen
  cat > '/etc/locale.gen' << EOF
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
language="cn"
locale-gen
update-locale
chattr -i /etc/default/locale
  cat > '/etc/default/locale' << EOF
LANGUAGE="zh_TW.UTF-8"
LANG="zh_TW.UTF-8"
LC_ALL="zh_TW.UTF-8"
EOF
#apt-get install manpages-zh -y
  cat > '/root/.trojan/language.json' << EOF
{
  "language": "$language"
}
EOF
  else
  chattr -i /etc/locale.gen
  cat > '/etc/locale.gen' << EOF
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
language="en"
locale-gen
update-locale
chattr -i /etc/default/locale
  cat > '/etc/default/locale' << EOF
LANGUAGE="en_US.UTF-8"
LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOF
  cat > '/root/.trojan/language.json' << EOF
{
  "language": "$language"
}
EOF
fi
done
if [[ $language == "cn" ]]; then
export LANGUAGE="zh_TW.UTF-8"
export LANG="zh_TW.UTF-8"
export LC_ALL="zh_TW.UTF-8"
  else
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
fi
}

#install acme.sh
installacme(){
  set +e
  curl -s https://get.acme.sh | sh
  if [[ $? != 0 ]]; then
    colorEcho ${ERROR} "安装acme.sh失败，请自行检查网络连接及DNS配置!"
    colorEcho ${ERROR} "Install acme.sh fail,please check your internet availability!!!"
    exit 1
  fi
  ~/.acme.sh/acme.sh --upgrade --auto-upgrade
}

#Issue Let's Encrypt Certificate by http
httpissue(){
openfirewall
  http_issue=1
  installacme
  installnginx
  rm -rf /etc/nginx/sites-available/*
  rm -rf /etc/nginx/sites-enabled/*
  rm -rf /etc/nginx/conf.d/*
  touch /etc/nginx/conf.d/default.conf
  cat > '/etc/nginx/conf.d/default.conf' << EOF
server {
  listen       80;
  listen       [::]:80;
  server_name  $domain;
  root   /usr/share/nginx/html;
}
EOF
  systemctl restart nginx
  clear
  colorEcho ${INFO} "正式证书申请ing(issuing) let\'s encrypt certificate"
  ~/.acme.sh/acme.sh --issue --nginx --cert-home /etc/certs -d $domain -k ec-256 --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
  if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
    :
    else
    colorEcho ${ERROR} "证书申请失败，请**检查VPS控制面板防火墙是否完全关闭**,DNS是否解析完成!!!"
    colorEcho ${ERROR} "请访问https://letsencrypt.status.io/检测Let's encrypt服务是否正常!!!"
    colorEcho ${ERROR} "Cert issue fail,Pleae Open all ports on VPS panel !!!"
    exit 1
  fi
  chmod +r /etc/certs/${domain}_ecc/fullchain.cer
  chmod +r /etc/certs/${domain}_ecc/${domain}.key
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
}

#Issue Let's Encrypt Certificate by DNS API
dnsissue(){
whiptail --title "Warning" --msgbox "若你的域名厂商(或者准确来说你的域名的NS)不在下列列表中,请在上一个yes/no选项中选否(需要保证域名A解析已成功)或者open an github issue/pr" 8 68
    APIOPTION=$(whiptail --nocancel --clear --ok-button "吾意已決 立即執行" --title "API choose" --menu --separate-output "域名(domain)API：請按方向键來選擇(Use Arrow key to choose)" 15 68 6 \
"1" "Cloudflare(不支援免费域名)" \
"2" "Namesilo" \
"3" "Aliyun" \
"4" "DNSPod.cn" \
"5" "CloudXNS.com" \
"6" "GoDaddy" \
"http" "使用HTTP申请"  3>&1 1>&2 2>&3)

    case $APIOPTION in
        1)
        while [[ -z ${CF_Key} ]] || [[ -z ${CF_Email} ]]; do
        CF_Key=$(whiptail --passwordbox --nocancel "https://dash.cloudflare.com/profile/api-tokens，快輸入你CF Global Key併按回車" 8 68 --title "CF_Key input" 3>&1 1>&2 2>&3)
        CF_Email=$(whiptail --inputbox --nocancel "https://dash.cloudflare.com/profile，快輸入你CF_Email併按回車" 8 68 --title "CF_Key input" 3>&1 1>&2 2>&3)
        done
        export CF_Key="$CF_Key"
        export CF_Email="$CF_Email"
        openfirewall
        installacme
        ~/.acme.sh/acme.sh --issue --force --dns dns_cf --cert-home /etc/certs -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        2)
        while [[ -z $Namesilo_Key ]]; do
        Namesilo_Key=$(whiptail --passwordbox --nocancel "https://www.namesilo.com/account_api.php，快輸入你的Namesilo_Key併按回車" 8 68 --title "Namesilo_Key input" 3>&1 1>&2 2>&3)
        done
        export Namesilo_Key="$Namesilo_Key"
        openfirewall
        installacme
        ~/.acme.sh/acme.sh --issue --force --dns dns_namesilo --cert-home /etc/certs --dnssleep 1800 -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        3)
        while [[ -z $Ali_Key ]] || [[ -z $Ali_Secret ]]; do
        Ali_Key=$(whiptail --passwordbox --nocancel "https://ak-console.aliyun.com/#/accesskey，快輸入你的Ali_Key併按回車" 8 68 --title "Ali_Key input" 3>&1 1>&2 2>&3)
        Ali_Secret=$(whiptail --passwordbox --nocancel "https://ak-console.aliyun.com/#/accesskey，快輸入你的Ali_Secret併按回車" 8 68 --title "Ali_Secret input" 3>&1 1>&2 2>&3)
        done
        export Ali_Key="$Ali_Key"
        export Ali_Secret="$Ali_Secret"
        openfirewall
        installacme
        ~/.acme.sh/acme.sh --issue --force --dns dns_ali --cert-home /etc/certs -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        4)
        while [[ -z $DP_Id ]] || [[ -z $DP_Key ]]; do
        DP_Id=$(whiptail --passwordbox --nocancel "DNSPod.cn，快輸入你的DP_Id併按回車" 8 68 --title "DP_Id input" 3>&1 1>&2 2>&3)
        DP_Key=$(whiptail --passwordbox --nocancel "DNSPod.cn，快輸入你的DP_Key併按回車" 8 68 --title "DP_Key input" 3>&1 1>&2 2>&3)
        done
        export DP_Id="$DP_Id"
        export DP_Key="$DP_Key"
        openfirewall
        installacme
        ~/.acme.sh/acme.sh --issue --force --dns dns_dp --cert-home /etc/certs -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        5)
        while [[ -z $CX_Key ]] || [[ -z $CX_Secret ]]; do
        CX_Key=$(whiptail --passwordbox --nocancel "CloudXNS.com，快輸入你的CX_Key併按回車" 8 68 --title "CX_Key input" 3>&1 1>&2 2>&3)
        CX_Secret=$(whiptail --passwordbox --nocancel "CloudXNS.com，快輸入你的CX_Secret併按回車" 8 68 --title "CX_Secret input" 3>&1 1>&2 2>&3)
        done
        export CX_Key="$CX_Key"
        export CX_Secret="$CX_Secret"
        openfirewall
        installacme
        ~/.acme.sh/acme.sh --issue --force --dns dns_cx --cert-home /etc/certs -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        6)
        while [[ -z $CX_Key ]] || [[ -z $CX_Secret ]]; do
        CX_Key=$(whiptail --passwordbox --nocancel "https://developer.godaddy.com/keys/，快輸入你的GD_Key" 8 68 --title "GD_Key input" 3>&1 1>&2 2>&3)
        CX_Secret=$(whiptail --passwordbox --nocancel "https://developer.godaddy.com/keys/，快輸入你的GD_Secret" 8 68 --title "GD_Secret input" 3>&1 1>&2 2>&3)
        done
        export GD_Key="$CX_Key"
        export GD_Secret="$CX_Secret"
        openfirewall
        installacme
        ~/.acme.sh/acme.sh --issue --force --dns dns_gd --cert-home /etc/certs -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan postfix dovecot nginx || true"
crontab -l > mycron
echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
crontab mycron
rm mycron
        ;;
        http)
    upgradesystem
        httpissue
        ;;
        *)
        ;;
    esac

if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
    :
    else
    colorEcho ${ERROR} "DNS申请证书失败，尝试HTTP申请中."
    httpissue
  fi
}

#Install Trojan-panel
install_tjp(){
  TERM=ansi whiptail --title "安装中" --infobox "安装Trojan-panel中..." 7 68
  colorEcho ${INFO} "Install Trojan-panel ing"
cd /usr/share/nginx/
git clone https://github.com/trojan-gfw/trojan-panel.git
chown -R nginx:nginx /usr/share/nginx/trojan-panel
cd trojan-panel
composer install
npm install
npm audit fix
cp .env.example .env
php artisan key:generate
sed -i "s/example.com/${domain}/;" /usr/share/nginx/trojan-panel/.env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=${password1}/;" /usr/share/nginx/trojan-panel/.env
#sed -i "s/MAIL_PORT=2525/MAIL_PORT=25/;" /usr/share/nginx/trojan-panel/.env
clear
php artisan migrate --force
chown -R nginx:nginx /usr/share/nginx/
cd
}

#Set json file before and after installation
prasejson(){
  set +e
  cat > '/root/.trojan/config.json' << EOF
{
  "installed": "1",
  "domain": "$domain",
  "password1": "$password1",
  "password2": "$password2",
  "qbtpath": "$qbtpath",
  "trackerpath": "$trackerpath",
  "trackerstatuspath": "$trackerstatuspath",
  "ariapath": "$ariapath",
  "ariapasswd": "$ariapasswd",
  "filepath": "$filepath",
  "check_trojan": "$check_trojan",
  "check_tjp": "$check_tjp",
  "check_dns": "$check_dns",
  "check_rss": "$check_rss",
  "check_qbt": "$check_qbt",
  "check_aria": "$check_aria",
  "check_file": "$check_file",
  "check_speed": "$check_speed",
  "check_mariadb": "$check_mariadb",
  "check_fail2ban": "$check_fail2ban",
  "check_mail": "$check_mail",
  "check_qbt_origin": "$check_qbt_origin",
  "check_tracker": "$check_tracker",
  "check_cloud": "$check_cloud",
  "check_tor": "$check_tor",
  "check_i2p": "$check_i2p",
  "fastopen": "${fastopen}",
  "tor_name": "$tor_name"
}
EOF
}

#Read var from json
readconfig(){
  domain="$( jq -r '.domain' "/root/.trojan/config.json" )"
  password2="$( jq -r '.password2' "/root/.trojan/config.json" )"
  password1="$( jq -r '.password1' "/root/.trojan/config.json" )"
  qbtpath="$( jq -r '.qbtpath' "/root/.trojan/config.json" )"
  trackerpath="$( jq -r '.trackerpath' "/root/.trojan/config.json" )"
  trackerstatuspath="$( jq -r '.username' "/root/.trojan/config.json" )"
  ariapath="$( jq -r '.ariapath' "/root/.trojan/config.json" )"
  ariapasswd="$( jq -r '.ariapasswd' "/root/.trojan/config.json" )"
  filepath="$( jq -r '.filepath' "/root/.trojan/config.json" )"
  netdatapath="$( jq -r '.netdatapath' "/root/.trojan/config.json" )"
  tor_name="$( jq -r '.tor_name' "/root/.trojan/config.json" )"
  check_trojan="$( jq -r '.check_trojan' "/root/.trojan/config.json" )"
  check_tjp="$( jq -r '.check_tjp' "/root/.trojan/config.json" )"
  check_dns="$( jq -r '.check_dns' "/root/.trojan/config.json" )"
  check_rss="$( jq -r '.check_rss' "/root/.trojan/config.json" )"
  check_qbt="$( jq -r '.check_qbt' "/root/.trojan/config.json" )"
  check_aria="$( jq -r '.check_aria' "/root/.trojan/config.json" )"
  check_file="$( jq -r '.check_file' "/root/.trojan/config.json" )"
  check_speed="$( jq -r '.check_speed' "/root/.trojan/config.json" )"
  check_mariadb="$( jq -r '.check_mariadb' "/root/.trojan/config.json" )"
  check_fail2ban="$( jq -r '.check_fail2ban' "/root/.trojan/config.json" )"
  check_mail="$( jq -r '.check_mail' "/root/.trojan/config.json" )"
  check_qbt_origin="$( jq -r '.check_qbt_origin' "/root/.trojan/config.json" )"
  check_tracker="$( jq -r '.check_tracker' "/root/.trojan/config.json" )"
  check_cloud="$( jq -r '.check_cloud' "/root/.trojan/config.json" )"
  check_tor="$( jq -r '.check_tor' "/root/.trojan/config.json" )"
  check_chat="$( jq -r '.check_chat' "/root/.trojan/config.json" )"
  check_i2p="$( jq -r '.check_i2p' "/root/.trojan/config.json" )"
  fastopen="$( jq -r '.fastopen' "/root/.trojan/config.json" )"
}

#User input
userinput(){
set +e
clear
if [[ ${install_status} == 1 ]]; then
  if (whiptail --title "Installed" --yes-button "读取" --no-button "修改" --yesno "检测到现有配置，读取/修改现有配置?(Installed,read configuration?)" 8 68); then
    readconfig
    else
    check_trojan="on"
    check_tjp="off"
    check_dns="off"
    check_rss="off"
    check_qbt="off"
    check_aria="off"
    check_file="off"
    check_speed="off"
    check_mariadb="off"
    check_fail2ban="off"
    check_mail="off"
    check_qbt_origin="off"
    check_tracker="off"
    check_cloud="off"
    check_tor="off"
    check_chat="off"
    fastopen="on"
    stun="off"
  fi
fi

if [[ -z ${check_trojan} ]]; then
  check_trojan="on"
fi
if [[ -z ${check_dns} ]]; then
  check_dns="off"
fi
if [[ -z ${check_rss} ]]; then
  check_rss="off"
fi
if [[ -z ${check_chat} ]]; then
  check_chat="off"
fi
if [[ -z ${check_qbt} ]]; then
  check_qbt="off"
fi
if [[ -z ${check_aria} ]]; then
  check_aria="off"
fi
if [[ -z ${check_file} ]]; then
  check_file="off"
fi
if [[ -z ${check_speed} ]]; then
  check_speed="off"
fi
if [[ -z ${check_mariadb} ]]; then
  check_mariadb="off"
fi
if [[ -z ${check_fail2ban} ]]; then
  check_fail2ban="off"
fi
if [[ -z ${check_mail} ]]; then
  check_mail="off"
fi
if [[ -z ${check_qbt_origin} ]]; then
  check_qbt_origin="off"
fi
if [[ -z ${check_tracker} ]]; then
  check_tracker="off"
fi
if [[ -z ${check_cloud} ]]; then
  check_cloud="off"
fi
if [[ -z ${check_tor} ]]; then
  check_tor="off"
fi
if [[ -z ${check_i2p} ]]; then
  check_i2p="off"
fi
if [[ -z ${check_tjp} ]]; then
  check_tjp="off"
fi
if [[ -z ${fastopen} ]]; then
  fastopen="on"
fi
if [[ -z ${stun} ]]; then
  stun="off"
fi

whiptail --clear --ok-button "下一步" --backtitle "Hi,请按空格以及方向键来选择需要安装/更新的软件,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "Install checklist" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的软件。" 24 65 16 \
"Back" "返回上级菜单(Back to main menu)" off \
"trojan" "Trojan-GFW+TCP-BBR+Hexo Blog" on \
"net" "Netdata(监测伺服器运行状态)" on \
"fast" "TCP Fastopen" ${fastopen} \
"tjp" "Trojan-panel" ${check_tjp} \
"nextcloud" "Nextcloud(私人网盘)" ${check_cloud} \
"rss" "RSSHUB + TT-RSS(RSS生成器+RSS阅读器)" ${check_rss} \
"mail" "Mail service(邮箱服务,需2g+内存)" ${check_mail} \
"chat" "Rocket Chat" ${check_chat} \
"qbt" "Qbittorrent增强版(可全自动屏蔽吸血行为)" ${check_qbt} \
"aria" "Aria2下载器" ${check_aria} \
"file" "Filebrowser(用于拉回Qbt/aria下载完成的文件)" ${check_file} \
"speed" "Speedtest(测试本地网络到VPS的延迟及带宽)" ${check_speed} \
"fail2ban" "Fail2ban(防SSH爆破用)" ${check_fail2ban} \
"i2p" "自建i2p网站" ${check_i2p} \
"tor" "自建onion网站" ${check_tor} \
"stun" "stunserver(用于测试nat类型)" ${stun} \
"dns" "Dnscrypt-proxy(Doh客户端)" ${check_dns} \
"7" "MariaDB数据库" ${check_mariadb} \
"redis" "Redis缓存数据库" off \
"其他" "以下选项请勿选中,除非必要(Others)" off  \
"port" "自定义Trojan端口(除nat机器外请勿选中)" ${check_qbt_origin} \
"10" "Bt-Tracker(Bittorrent-tracker服务)" ${check_tracker} \
"13" "Qbt原版(除PT站指明要求,请勿选中)" ${check_qbt_origin} \
"test-only" "test-only" off 2>results

while read choice
do
  case $choice in
    Back) 
    advancedMenu
    break
    ;;
    trojan)
    install_trojan=1
    install_bbr=1
    ;;
    stun)
    install_stun="1"
    ;;
    dns)
    dnsmasq_install=1
    ;;
    fast)
    tcp_fastopen="true"
    ;;
    chat)
    install_chat=1
    install_docker=1
    ;;
    tjp)
    install_tjp=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    net)
    install_netdata=1
    ;;
    nextcloud)
    install_nextcloud=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    redis)
    install_redis=1
    ;;
    rss)
    check_rss="on"
    install_rsshub=1
    install_redis=1
    install_php=1
    install_mariadb=1
    ;;
    qbt)
    check_qbt="on"
    install_qbt=1
    ;;
    aria)
    check_aria="on"
    install_aria=1
    ;;
    file)
    check_file="on"
    install_file=1
    ;;
    speed)
    check_speed="on"
    install_speedtest=1
    install_php=1
    ;;
    7)
    check_mariadb="on"
    install_mariadb=1
    ;;
    fail2ban)
    check_fail2ban="on"
    install_fail2ban=1
    ;;
    mail)
    check_mail="on"
    install_mail=1
    install_php=1
    install_mariadb=1
    ;;
    10)
    check_tracker="on"
    install_tracker=1
    ;;
    11) 
    install_tjp=1
    install_php=1
    install_nodejs=1
    install_mariadb=1
    ;;
    tor)
    install_tor=1
    ;;
    i2p)
    install_i2p=1
    ;;
    13)
    check_qbt_origin="on"
    install_qbt_origin=1
    ;;
    port)
    trojan_other_port=1
    ;;
    *)
    ;;
  esac
done < results

if [[ ${trojan_other_port} == 1 ]]; then
  trojanport=$(whiptail --inputbox --nocancel "Trojan-GFW 端口(若不確定，請直接回車)" 8 68 443 --title "port input" 3>&1 1>&2 2>&3)
  if [[ -z ${trojanport} ]]; then
  trojanport="443"
  fi
fi

system_upgrade=1
if [[ ${system_upgrade} == 1 ]]; then
  if [[ $(lsb_release -cs) == jessie ]]; then
      debian9_install=1
  fi
  if [[ $(lsb_release -cs) == xenial ]]; then
      ubuntu18_install=1
  fi
fi

#if [[ ${install_mail} == 1 ]]; then
#whiptail --title "Warning" --msgbox "Warning!!!:邮件服务仅推荐使用根域名(only recommend root domain),不推荐使用www等前缀(no www allowed),否则后果自负!!!" 8 68
#whiptail --title "Warning" --msgbox "Warning!!!:邮件服务需要MX and PTR(reverse dns record) DNS Record,请自行添加,否则后果自负!!" 8 68
#fi

while [[ -z ${domain} ]]; do
domain=$(whiptail --inputbox --nocancel "请輸入你的域名,例如 example.com(请先完成A/AAAA解析) | Please enter your domain" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
TERM=ansi whiptail --title "检测中" --infobox "检测域名是否合法中..." 7 68
colorEcho ${INFO} "Checking if domain is vaild."
host ${domain}
if [[ $? != 0 ]]; then
  whiptail --title "Warning" --msgbox "Warning: Invaild Domain" 8 68
  domain=""
  clear
fi
done
clear
hostnamectl set-hostname ${domain}
echo "${domain}" > /etc/hostname
rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
if [[ ${install_trojan} = 1 ]]; then
  while [[ -z ${password1} ]]; do
password1=$(whiptail --passwordbox --nocancel "Trojan-GFW Password One(推荐自定义密码,***请勿添加特殊符号***)" 8 68 --title "password1 input" 3>&1 1>&2 2>&3)
if [[ -z ${password1} ]]; then
password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
fi
done
while [[ -z ${password2} ]]; do
password2=$(whiptail --passwordbox --nocancel "Trojan-GFW Password Two(若不確定，請直接回車，会随机生成)" 8 68 --title "password2 input" 3>&1 1>&2 2>&3)
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
done
fi
if [[ ${password1} == ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password1} ]]; then
  password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
  if [[ ${install_mail} == 1 ]]; then
  mailuser=$(whiptail --inputbox --nocancel "Please enter your desired mailusername(邮箱用户名)" 8 68 admin --title "Mail user input" 3>&1 1>&2 2>&3)
  if [[ -z ${mailuser} ]]; then
  mailuser=$(head /dev/urandom | tr -dc a-z | head -c 4 ; echo '' )
  fi
fi
  if [[ $install_qbt = 1 ]]; then
    while [[ -z $qbtpath ]]; do
    qbtpath=$(whiptail --inputbox --nocancel "Qbittorrent Nginx Path(路径)" 8 68 /qbt/ --title "Qbittorrent path input" 3>&1 1>&2 2>&3)
    done
  fi
  if [[ ${install_aria} == 1 ]]; then
    ariaport=$(shuf -i 13000-19000 -n 1)
    while [[ -z ${ariapath} ]]; do
    ariapath=$(whiptail --inputbox --nocancel "Aria2 RPC Nginx Path(路径)" 8 68 /aria2/ --title "Aria2 path input" 3>&1 1>&2 2>&3)
    done
    while [[ -z $ariapasswd ]]; do
    ariapasswd=$(whiptail --passwordbox --nocancel "Aria2 rpc token(密码)" 8 68 --title "Aria2 rpc token input" 3>&1 1>&2 2>&3)
    if [[ -z ${ariapasswd} ]]; then
    ariapasswd=$(head /dev/urandom | tr -dc 0-9 | head -c 10 ; echo '' )
    fi
    done
  fi
  if [[ ${install_file} = 1 ]]; then
    while [[ -z ${filepath} ]]; do
    filepath=$(whiptail --inputbox --nocancel "Filebrowser Nginx 路径" 8 68 /file/ --title "Filebrowser path input" 3>&1 1>&2 2>&3)
    done
  fi
  if [[ ${install_netdata} = 1 ]]; then
    while [[ -z ${netdatapath} ]]; do
    netdatapath=$(whiptail --inputbox --nocancel "Netdata Nginx 路径" 8 68 /${password1}_netdata/ --title "Netdata path input" 3>&1 1>&2 2>&3)
    done
  fi
}
###############OS detect####################
initialize(){
set +e
TERM=ansi whiptail --title "初始化中(initializing)" --infobox "初始化中...(initializing)" 7 68
if [[ -f /etc/sysctl.d/60-disable-ipv6.conf ]]; then
  mv /etc/sysctl.d/60-disable-ipv6.conf /etc/sysctl.d/60-disable-ipv6.conf.bak
fi
if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
  dist=ubuntu
  enablebbr
  if [[ -f /etc/sysctl.d/60-disable-ipv6.conf.bak ]]; then
    sed -i 's/#//g' /etc/netplan/01-netcfg.yaml
    netplan apply
  fi
  apt-get update
  apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
 elif cat /etc/*release | grep ^NAME | grep -q Debian; then
  dist=debian
  enablebbr
  apt-get update
  apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
 else
  whiptail --title "OS not supported(操作系统不支援)" --msgbox "Please use Debian or Ubuntu to run this project.(请使用Debian或者Ubuntu运行本项目)" 8 68
  echo "OS not supported(操作系统不支援),Please use Debian or Ubuntu to run this project.(请使用Debian或者Ubuntu运行本项目)"
  exit 1;
fi
}

#Run apt upgrade
upgradesystem(){
  set +e
if [[ $(lsb_release -cs) == stretch ]]; then
  debian10_install=1
fi
 if [[ $dist == ubuntu ]]; then
  if [[ $ubuntu18_install == 1 ]]; then
    cat > '/etc/apt/sources.list' << EOF
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#

###### Ubuntu Main Repos
deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse 
#deb-src http://us.archive.ubuntu.com/ubuntu/ bionic main restricted universe multiverse 

###### Ubuntu Update Repos
deb http://us.archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse 
#deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse 
#deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted universe multiverse 
EOF
fi
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq -y'
  clear
 elif [[ $dist == debian ]]; then
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  if [[ ${debian10_install} == 1 ]]; then
    cat > '/etc/apt/sources.list' << EOF
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ stable main contrib non-free
#deb-src http://deb.debian.org/debian/ stable main contrib non-free

deb http://deb.debian.org/debian/ stable-updates main contrib non-free
#deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free

deb http://deb.debian.org/debian-security stable/updates main
#deb-src http://deb.debian.org/debian-security stable/updates main

deb http://ftp.debian.org/debian buster-backports main
#deb-src http://ftp.debian.org/debian buster-backports main
EOF
fi
  if [[ ${debian9_install} == 1 ]]; then
    cat > '/etc/apt/sources.list' << EOF
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ oldstable main contrib non-free
#deb-src http://deb.debian.org/debian/ oldstable main contrib non-free

deb http://deb.debian.org/debian/ oldstable-updates main contrib non-free
#deb-src http://deb.debian.org/debian/ oldstable-updates main contrib non-free

deb http://deb.debian.org/debian-security oldstable/updates main
#deb-src http://deb.debian.org/debian-security oldstable/updates main

deb http://ftp.debian.org/debian stretch-backports main
#deb-src http://ftp.debian.org/debian stretch-backports main
EOF
fi
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq -y'
  clear
 else
  clear
  TERM=ansi whiptail --title "error can't upgrade system" --infobox "error can't upgrade system" 8 68
  exit 1;
 fi

if [[ -f /etc/apt/sources.list.d/nginx.list ]]; then
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
#deb-src https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
EOF
apt-get update
fi
}

#Install Nginx
installnginx(){
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装NGINX中..." 7 68
  colorEcho ${INFO} "Install Nginx ing"
  apt-get install ca-certificates lsb-release -y
  apt-get install gnupg gnupg2 -y
  apt-get install gpg-agent -y
  touch /etc/apt/sources.list.d/nginx.list
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
#deb-src https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
EOF
  curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
  apt-key fingerprint ABF5BD827BD9BF62
  apt-get purge nginx -qq -y
  apt-get update
  #apt-get install nginx -q -y
  sh -c 'echo "y\n\ny\ny\ny\n" | apt-get install nginx -y'
  id -u nginx
if [[ $? != 0 ]]; then
useradd -r nginx --shell=/usr/sbin/nologin
apt-get install nginx -y
fi
  cat > '/lib/systemd/system/nginx.service' << EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
Before=netdata.service trojan.service
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nginx
mkdir /usr/share/nginx/cache
mkdir /usr/share/nginx/php_cache
  cat > '/etc/nginx/nginx.conf' << EOF
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
  worker_connections 51200;
  use epoll;
  multi_accept on;
}

http {

  proxy_cache_path /usr/share/nginx/cache levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m use_temp_path=off;
  proxy_cache_valid 200 302 10m;
  proxy_cache_valid 404      1m;
  proxy_cache_bypass \$http_pragma    \$http_authorization    \$http_cache_control;
  proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
  proxy_cache_revalidate on;
  proxy_cache_background_update on;
  proxy_cache_lock on;
  proxy_cache my_cache;

  fastcgi_cache_path /usr/share/nginx/php_cache levels=1:2 keys_zone=phpcache:10m max_size=100m inactive=60m use_temp_path=off;
  fastcgi_cache_valid 200 302 10m;
  fastcgi_cache_valid 404      1m;
  fastcgi_cache_bypass \$http_pragma    \$http_authorization    \$http_cache_control;
  fastcgi_cache_use_stale error timeout updating invalid_header http_500 http_503;
  fastcgi_cache_revalidate on;
  fastcgi_cache_background_update on;
  fastcgi_cache_lock on;
  fastcgi_cache phpcache;
  fastcgi_cache_key "\$scheme\$proxy_host\$request_uri";

  autoindex_exact_size off;
  http2_push_preload on;
  aio threads;
  charset UTF-8;
  tcp_nodelay on;
  tcp_nopush on;
  server_tokens off;
  
  proxy_intercept_errors on;
  proxy_socket_keepalive off;
  proxy_http_version 1.1;
  proxy_ssl_protocols TLSv1.2 TLSv1.3;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log /var/log/nginx/access.log;

  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status \$body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" "\$http_x_forwarded_for"';

  sendfile on;
  gzip on;
  gzip_proxied any;
  gzip_types *;
  gzip_comp_level 9;

  include /etc/nginx/conf.d/default.conf;
}
EOF
clear
timedatectl set-timezone Asia/Hong_Kong
timedatectl set-ntp off
}

#Open ports
openfirewall(){
  set +e
  TERM=ansi whiptail --title "配置中" --infobox "配置防火墙中..." 7 68
  colorEcho ${INFO} "设置 firewall"
  #policy
  iptables -P INPUT ACCEPT &>/dev/null
  iptables -P FORWARD ACCEPT &>/dev/null
  iptables -P OUTPUT ACCEPT &>/dev/null
  ip6tables -P INPUT ACCEPT &>/dev/null
  ip6tables -P FORWARD ACCEPT &>/dev/null
  ip6tables -P OUTPUT ACCEPT &>/dev/null
  #flash
  iptables -F &>/dev/null
  ip6tables -F &>/dev/null
  #tcp
  iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT  &>/dev/null #HTTPS
  iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT &>/dev/null #HTTP
  #udp
  iptables -A INPUT -p udp -m udp --dport 443 -j ACCEPT &>/dev/null
  iptables -A INPUT -p udp -m udp --dport 80 -j ACCEPT &>/dev/null
  iptables -A OUTPUT -j ACCEPT &>/dev/null
  #iptables -I FORWARD -j DROP
  #tcp6
  ip6tables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT &>/dev/null #HTTPSv6
  ip6tables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT &>/dev/null #HTTPv6
  #udp6
  ip6tables -A INPUT -p udp -m udp --dport 443 -j ACCEPT &>/dev/null
  ip6tables -A INPUT -p udp -m udp --dport 80 -j ACCEPT &>/dev/null
  ip6tables -A OUTPUT -j ACCEPT &>/dev/null
  #ip6tables -I FORWARD -j DROP
  if [[ $install_qbt == 1 ]]; then
    iptables -A INPUT ! -s 127.0.0.1 -p tcp -m tcp --dport 8080 -j DROP &>/dev/null
    iptables -A INPUT ! -s 127.0.0.1 -p udp -m udp --dport 8080 -j DROP &>/dev/null
  fi
  if [[ ${install_mail} == 1 ]]; then
    iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT &>/dev/null
    iptables -A INPUT -p udp -m udp --dport 25 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT &>/dev/null
    iptables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p udp -m udp --dport 25 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 143 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 465 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 587 -j ACCEPT &>/dev/null
    ip6tables -A INPUT -p tcp -m tcp --dport 993 -j ACCEPT &>/dev/null
  fi
 apt-get install nftables -y
 systemctl enable nftables.service
}
##########install dependencies#############
installdependency(){
  set +e
  TERM=ansi whiptail --title "安装中" --infobox "安装所有必备软件中..." 7 68
colorEcho ${INFO} "Updating system"
apt-get update
clear
colorEcho ${INFO} "Installing all necessary Software"
apt-get install sudo git curl xz-utils wget apt-transport-https gnupg lsb-release python-pil unzip resolvconf ntpdate systemd dbus ca-certificates locales iptables software-properties-common cron e2fsprogs less haveged neofetch -q -y
apt-get install python3-qrcode python-dnspython -q -y
sh -c 'echo "y\n\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get install ntp -q -y'
clear

if [[ $http_issue != 1 ]]; then
installnginx
fi

#Install docker
if [[ $install_docker == 1 ]]; then
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装Docker中..." 7 68
  colorEcho ${INFO} "安装Docker(Install Docker ing)"
  if [[ ${dist} == debian ]]; then
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  apt-key fingerprint 0EBFCD88
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io -y
 elif [[ ${dist} == ubuntu ]]; then
  apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  apt-key fingerprint 0EBFCD88
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io -y
 else
  echo "fail"
  fi
  cat > '/etc/docker/daemon.json' << EOF
{
  "metrics-addr" : "127.0.0.1:9323",
  "experimental" : true
}
EOF
systemctl restart docker
fi

#Install Speedtest
if [[ ${install_speedtest} == 1 ]]; then
cd /usr/share/nginx/
git clone https://github.com/librespeed/speedtest.git
wget -P /usr/share/nginx/speedtest/ https://raw.githubusercontent.com/librespeed/speedtest/master/backend/empty.php -q --show-progress
wget -P /usr/share/nginx/speedtest/ https://raw.githubusercontent.com/librespeed/speedtest/master/backend/garbage.php -q --show-progress
wget -P /usr/share/nginx/speedtest/ https://raw.githubusercontent.com/librespeed/speedtest/master/backend/getIP.php -q --show-progress
  cat > '/usr/share/nginx/speedtest/index.html' << EOF
<!DOCTYPE html>
<html lang="zh-tw">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no />
<title>LibreSpeed</title>
<link rel="shortcut icon" href="favicon.ico">
<script type="text/javascript" src="speedtest.js"></script>
<script type="text/javascript">

//INITIALIZE SPEEDTEST
var s=new Speedtest(); //create speedtest object
s.onupdate=function(data){ //callback to update data in UI
    I("ip").textContent=data.clientIp;
    I("dlText").textContent=(data.testState==1&&data.dlStatus==0)?"...":data.dlStatus;
    I("ulText").textContent=(data.testState==3&&data.ulStatus==0)?"...":data.ulStatus;
    I("pingText").textContent=data.pingStatus;
    I("jitText").textContent=data.jitterStatus;
    var prog=(Number(data.dlProgress)*2+Number(data.ulProgress)*2+Number(data.pingProgress))/5;
    I("progress").style.width=(100*prog)+"%";
}
s.onend=function(aborted){ //callback for test ended/aborted
    I("startStopBtn").className=""; //show start button again
    if(aborted){ //if the test was aborted, clear the UI and prepare for new test
    initUI();
    }
}

function startStop(){ //start/stop button pressed
  if(s.getState()==3){
    //speedtest is running, abort
    s.abort();
  }else{
    //test is not running, begin
    s.start();
    I("startStopBtn").className="running";
  }
}

//function to (re)initialize UI
function initUI(){
  I("dlText").textContent="";
  I("ulText").textContent="";
  I("pingText").textContent="";
  I("jitText").textContent="";
  I("ip").textContent="";
}

function I(id){return document.getElementById(id);}
</script>

<style type="text/css">
  html,body{
    border:none; padding:0; margin:0;
    background:#FFFFFF;
    color:#202020;
  }
  body{
    text-align:center;
    font-family:"Roboto",sans-serif;
  }
  h1{
    color:#404040;
  }
  #startStopBtn{
    display:inline-block;
    margin:0 auto;
    color:#6060AA;
    background-color:rgba(0,0,0,0);
    border:0.15em solid #6060FF;
    border-radius:0.3em;
    transition:all 0.3s;
    box-sizing:border-box;
    width:8em; height:3em;
    line-height:2.7em;
    cursor:pointer;
    box-shadow: 0 0 0 rgba(0,0,0,0.1), inset 0 0 0 rgba(0,0,0,0.1);
  }
  #startStopBtn:hover{
    box-shadow: 0 0 2em rgba(0,0,0,0.1), inset 0 0 1em rgba(0,0,0,0.1);
  }
  #startStopBtn.running{
    background-color:#FF3030;
    border-color:#FF6060;
    color:#FFFFFF;
  }
  #startStopBtn:before{
    content:"Start";
  }
  #startStopBtn.running:before{
    content:"Abort";
  }
  #test{
    margin-top:2em;
    margin-bottom:12em;
  }
  div.testArea{
    display:inline-block;
    width:14em;
    height:9em;
    position:relative;
    box-sizing:border-box;
  }
  div.testName{
    position:absolute;
    top:0.1em; left:0;
    width:100%;
    font-size:1.4em;
    z-index:9;
  }
  div.meterText{
    position:absolute;
    bottom:1.5em; left:0;
    width:100%;
    font-size:2.5em;
    z-index:9;
  }
  #dlText{
    color:#6060AA;
  }
  #ulText{
    color:#309030;
  }
  #pingText,#jitText{
    color:#AA6060;
  }
  div.meterText:empty:before{
    color:#505050 !important;
    content:"0.00";
  }
  div.unit{
    position:absolute;
    bottom:2em; left:0;
    width:100%;
    z-index:9;
  }
  div.testGroup{
    display:inline-block;
  }
  @media all and (max-width:65em){
    body{
      font-size:1.5vw;
    }
  }
  @media all and (max-width:40em){
    body{
      font-size:0.8em;
    }
    div.testGroup{
      display:block;
      margin: 0 auto;
    }
  }
  #progressBar{
    width:90%;
    height:0.3em;
    background-color:#EEEEEE;
    position:relative;
    display:block;
    margin:0 auto;
    margin-bottom:2em;
  }
  #progress{
    position:absolute;
    top:0; left:0;
    height:100%;
    width:0%;
    transition: width 2s;
    background-color:#90BBFF;
  }

</style>
</head>
<body>
<h1>LibreSpeed ${domain}</h1>
<div id="startStopBtn" onclick="startStop()"></div>
<div id="test">
    <div id="progressBar"><div id="progress"></div></div>
  <div class="testGroup">
    <div class="testArea">
      <div class="testName">Download(下载速度)</div>
      <div id="dlText" class="meterText"></div>
      <div class="unit">Mbps</div>
    </div>
    <div class="testArea">
      <div class="testName">Upload(上传速度)</div>
      <div id="ulText" class="meterText"></div>
      <div class="unit">Mbps</div>
    </div>
  </div>
  <div class="testGroup">
    <div class="testArea">
      <div class="testName">Ping(延迟)</div>
      <div id="pingText" class="meterText"></div>
      <div class="unit">ms</div>
    </div>
    <div class="testArea">
      <div class="testName">Jitter(波动)</div>
      <div id="jitText" class="meterText"></div>
      <div class="unit">ms</div>
    </div>
  </div>
  <div id="ipArea">
    <h2>推荐关闭代理测速 !</h2>
    IP Address: <span id="ip"></span>
  </div>
</div>
<a href="https://github.com/librespeed/speedtest">Source code</a>
<script type="text/javascript">
    initUI();
</script>
</body>
</html>
EOF
fi

if [[ ${install_rsshub} == 1 ]]; then
cd /usr/share/nginx/
if [[ -d /usr/share/nginx/RSSHub ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新rsshub中..." 7 68
    cd /usr/share/nginx/RSSHub
    git pull
    npm update
    npm install --production
    npm prune
  else
    git clone https://github.com/DIYgod/RSSHub.git
    cd /usr/share/nginx/RSSHub
    npm update
    npm install --production
    npm prune
    touch .env
cat > '.env' << EOF
CACHE_TYPE=redis
#REDIS_URL=redis://127.0.0.1:6379/
REDIS_URL=/var/run/redis/redis.sock
CACHE_EXPIRE=600
LISTEN_INADDR_ANY=0
EOF

cat > '/etc/systemd/system/rsshub.service' << EOF
[Unit]
Description=Rsshub
Documentation=https://docs.rsshub.app/
After=network.target
Wants=network.target

[Service]
Type=simple
WorkingDirectory=/usr/share/nginx/RSSHub
ExecStart=/bin/bash -c 'npm start'
Restart=on-failure
LimitNOFILE=51200
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
systemctl enable rsshub
fi

cd /usr/share/nginx/
if [[ -d /usr/share/nginx/tt-rss/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新tt-rss中..." 7 68
    cd /usr/share/nginx/tt-rss/
    git pull
  else
    TERM=ansi whiptail --title "安装中" --infobox "安装tt-rss中..." 7 68
    git clone https://git.tt-rss.org/fox/tt-rss.git tt-rss
  cat > '/usr/share/nginx/tt-rss/config.php' << EOF
<?php
  // *******************************************
  // *** Database configuration (important!) ***
  // *******************************************

  define('DB_TYPE', 'mysql');
  define('DB_HOST', '127.0.0.1');
  define('DB_USER', 'ttrss');
  define('DB_NAME', 'ttrss');
  define('DB_PASS', '${password1}');
  define('DB_PORT', '3306');
  define('MYSQL_CHARSET', 'UTF8');

  // ***********************************
  // *** Basic settings (important!) ***
  // ***********************************

  define('SELF_URL_PATH', 'https://${domain}/${password1}_ttrss//');
  define('SINGLE_USER_MODE', false);
  define('SIMPLE_UPDATE_MODE', false);

  // *****************************
  // *** Files and directories ***
  // *****************************

  define('PHP_EXECUTABLE', '/usr/bin/php');
  define('LOCK_DIRECTORY', 'lock');
  define('CACHE_DIR', 'cache');
  define('ICONS_DIR', "feed-icons");
  define('ICONS_URL', "feed-icons");

  // **********************
  // *** Authentication ***
  // **********************

  define('AUTH_AUTO_CREATE', true);
  define('AUTH_AUTO_LOGIN', true);

  // *********************
  // *** Feed settings ***
  // *********************

  define('FORCE_ARTICLE_PURGE', 0);

  // ****************************
  // *** Sphinx search plugin ***
  // ****************************

  define('SPHINX_SERVER', 'localhost:9312');
  define('SPHINX_INDEX', 'ttrss, delta');

  // ***********************************
  // *** Self-registrations by users ***
  // ***********************************

  define('ENABLE_REGISTRATION', false);
  define('REG_NOTIFY_ADDRESS', 'root@${domain}');
  define('REG_MAX_USERS', 10);

  // **********************************
  // *** Cookies and login sessions ***
  // **********************************

  define('SESSION_COOKIE_LIFETIME', 86400);
  define('SMTP_FROM_NAME', 'Tiny Tiny RSS');
  define('SMTP_FROM_ADDRESS', 'noreply@${domain}');
  define('DIGEST_SUBJECT', '[tt-rss] New headlines for last 24 hours');

  // ***************************************
  // *** Other settings (less important) ***
  // ***************************************

  define('CHECK_FOR_UPDATES', true);
  define('ENABLE_GZIP_OUTPUT', true);
  define('PLUGINS', 'auth_internal, note, fever, af_readability');
  define('LOG_DESTINATION', 'sql');
  define('CONFIG_VERSION', 26);
  define('_SKIP_SELF_URL_PATH_CHECKS', true);
EOF
cd
rm -rf /usr/share/nginx/tt-rss/install
cd /usr/share/nginx/tt-rss/plugins.local/
git clone https://github.com/DigitalDJ/tinytinyrss-fever-plugin fever
cd
  cat > '/etc/systemd/system/rssfeed.service' << EOF
[Unit]
Description=ttrss_backend
Documentation=https://tt-rss.org/
After=network.target mysql.service

[Service]
User=nginx
ExecStart=/usr/share/nginx/tt-rss/update_daemon2.php
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl enable rssfeed
#tt-rss themes
mkdir /usr/share/nginx/themes/
cd /usr/share/nginx/themes/
git clone https://github.com/levito/tt-rss-feedly-theme.git feedly
cd /usr/share/nginx/themes/feedly/
cp -r feedly* /usr/share/nginx/tt-rss/themes.local
cd
  fi
fi

if [[ ${install_fail2ban} == 1 ]]; then
apt-get install fail2ban -y
fi

if [[ $install_nodejs == 1 ]]; then
  if [[ ${dist} == debian ]]; then
  curl -sL https://deb.nodesource.com/setup_15.x | bash -
 elif [[ ${dist} == ubuntu ]]; then
  curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
 else
  echo "fail"
 fi
apt-get update
apt-get install -q -y nodejs
fi

clear

if [[ $install_qbt == 1 ]]; then
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装Qbt加强版中..." 7 68
  colorEcho ${INFO} "安装增强版Qbittorrent(Install Qbittorrent ing)"
  apt-get remove qbittorrent-nox -y
  cd
  mkdir qbt
  cd qbt
  qbtver=$(curl -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  wget https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/${qbtver}/qbittorrent-nox_x86_64-linux-musl_static.zip
  unzip -o qbittorrent*.zip
  cp -f qbittorrent-nox /usr/bin/
  chmod +x /usr/bin/qbittorrent-nox
  cd
  rm -rf qbt
  cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --profile=/usr/share/nginx/
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable qbittorrent.service
mkdir /usr/share/nginx/qBittorrent/
mkdir /usr/share/nginx/qBittorrent/downloads/
mkdir /usr/share/nginx/qBittorrent/data/
mkdir /usr/share/nginx/qBittorrent/data/GeoIP/
cd /usr/share/nginx/qBittorrent/data/GeoIP/
curl -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/GeoLite2-Country.mmdb
cd
chmod 755 /usr/share/nginx/
chown -R nginx:nginx /usr/share/nginx/
systemctl restart qbittorrent.service
fi
clear
###################################################
if [[ $install_qbt_origin == 1 ]]; then
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装Qbt原版中..." 7 68
  colorEcho ${INFO} "安装原版Qbittorrent(Install Qbittorrent ing)"
  if [[ ${dist} == debian ]]; then
  apt-get update
  apt-get install qbittorrent-nox -y
 elif [[ ${dist} == ubuntu ]]; then
  add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
  apt-get update
  apt-get install qbittorrent-nox -y
 else
  echo "fail"
 fi
 #useradd -r qbittorrent --shell=/usr/sbin/nologin
  cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --profile=/usr/share/nginx/
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable qbittorrent.service
mkdir /usr/share/nginx/qBittorrent/
mkdir /usr/share/nginx/qBittorrent/downloads/
mkdir /usr/share/nginx/qBittorrent/data/
mkdir /usr/share/nginx/qBittorrent/data/GeoIP/
cd /usr/share/nginx/qBittorrent/data/GeoIP/
curl -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/GeoLite2-Country.mmdb
cd
chmod 755 /usr/share/nginx/
chown -R nginx:nginx /usr/share/nginx/
systemctl restart qbittorrent.service
fi
clear
###########Install Bittorrent-tracker##############
if [[ $install_tracker = 1 ]]; then
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Bittorrent-tracker中" 7 68
colorEcho ${INFO} "Install Bittorrent-tracker ing"
apt-get install libowfat-dev make git build-essential zlib1g-dev libowfat-dev make git -y
useradd -r opentracker --shell=/usr/sbin/nologin
git clone git://erdgeist.org/opentracker opentracker
cd opentracker
sed -i 's/#FEATURES+=-DWANT_V6/FEATURES+=-DWANT_V6/' Makefile
sed -i 's/#FEATURES+=-DWANT_IP_FROM_QUERY_STRING/FEATURES+=-DWANT_IP_FROM_QUERY_STRING/' Makefile
sed -i 's/#FEATURES+=-DWANT_COMPRESSION_GZIP/FEATURES+=-DWANT_COMPRESSION_GZIP/' Makefile
sed -i 's/#FEATURES+=-DWANT_IP_FROM_PROXY/FEATURES+=-DWANT_IP_FROM_PROXY/' Makefile
sed -i 's/#FEATURES+=-DWANT_LOG_NUMWANT/FEATURES+=-DWANT_LOG_NUMWANT/' Makefile
sed -i 's/#FEATURES+=-DWANT_SYSLOGS/FEATURES+=-DWANT_SYSLOGS/' Makefile
sed -i 's/#FEATURES+=-DWANT_FULLLOG_NETWORKS/FEATURES+=-DWANT_FULLLOG_NETWORKS/' Makefile
make
cp -f opentracker /usr/sbin/opentracker
  cat > '/etc/systemd/system/tracker.service' << EOF
[Unit]
Description=Bittorrent-Tracker Daemon Service
Documentation=https://erdgeist.org/arts/software/opentracker/
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=opentracker
Group=opentracker
RemainAfterExit=yes
ExecStart=/usr/sbin/opentracker
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable tracker
systemctl restart tracker
cd /usr/share/nginx/
mkdir tracker
cd /usr/share/nginx/tracker/
  cat > 'stats.js' << EOF
function addDataToPage(xmlDocument, type) {
  const torrents = xmlDocument.querySelector("torrents count_mutex").textContent;
  const peers = xmlDocument.querySelector("peers count").textContent;
  const seeds = xmlDocument.querySelector("seeds count").textContent;
  const uptime = xmlDocument.querySelector("uptime").textContent;

  document.getElementById("torrents" + type + "Count").textContent = torrents;
  document.getElementById("peers" + type + "Count").textContent = peers;
  document.getElementById("seeds" + type + "Count").textContent = seeds;
  document.getElementById("uptime" + type).textContent = uptime;
}

function refreshData(type) {
  const url = "https://${domain}/tracker_stats/stats?mode=everything";

  fetch(url)
    .then(response => response.text())
    // https://stackoverflow.com/a/41009103
    .then(xml => (new window.DOMParser()).parseFromString(xml, "application/xml"))
    .then(xmlDocument => addDataToPage(xmlDocument, type))
    .catch(console.error);
}

refreshData(4);
refreshData(6);

window.setInterval(function(){
  refreshData(4);
  refreshData(6);
}, 1000);
EOF

  cat > 'index.html' << EOF

<!doctype html>
<html lang="zh-tw">
<head>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>My opentracker</title>
<meta name="description" content="My bittorrent tracker instance powered by opentracker">
<link rel="stylesheet" href="/libs/normalize/normalize.css">
<!-- <link rel="stylesheet" href="/assets/fonts.css"> -->

<style>
body {
  margin: 20px;
  font-family: 'Open Sans', sans-serif;
}
</style>

</head>
<body>


<h1>opentracker</h1>
<hr>

<p>My <a href="https://erdgeist.org/arts/software/opentracker/">erdgeist opentracker</a> instance.</p>

<a name="stats"><h3>Stats (IPv4)</h3>

<ul>
  <li>Torrents: <code id="torrents4Count"></code></li>
  <li>Peers: <code id="peers4Count"></code></li>
  <li>Seeds: <code id="seeds4Count"></code></li>

  <li>Uptime: <code id="uptime4"></code></li>
</ul>

<p><a href="https://${domain}/tracker_stats/stats?mode=everything">everything</a> | <a href="https://${domain}/tracker_stats/stats?mode=top100">top100</a></p>

<a name="stats6"><h3>Stats (IPv6)</h3>

<ul>
  <li>Torrents: <code id="torrents6Count"></code></li>
  <li>Peers: <code id="peers6Count"></code></li>
  <li>Seeds: <code id="seeds6Count"></code></li>

  <li>Uptime: <code id="uptime6"></code></li>
</ul>

<p><a href="https://${domain}/tracker_stats/stats?mode=everything">everything</a> | <a href="https://${domain}/tracker_stats/stats?mode=top100">top100</a></p>

<h3>Usage</h3>

<p>Add these trackers to the tracker list of a torrent in your torrent client (such as <a href="https://tixati.com/">tixati</a>, <a href="https://www.qbittorrent.org/">qbittorrent</a>, <a href="https://www.deluge-torrent.org/">deluge</a>):</p>

<pre>
udp://${domain}:6969/announce
</pre>

<p>A plaintext HTTP version is also available, but use of it is discouraged. Please don't add both to help keep load lower on the tracker.</p>

<p>Read more about trackers at <a href="https://support.tixati.com/edit%20trackers">Tixati support</a>.</p>

<h3>Other trackers you may want to use</h3>

<pre>
udp://tracker.iamhansen.xyz:2000/announce

udp://tracker.torrent.eu.org:451/announce

udp://tracker.coppersurfer.tk:6969/announce
</pre>

<p>Other trackers can be found from <a href="https://github.com/ngosang/trackerslist">here</a>.</p>

<h3>Problems?</h3>

<p>You can contact me at <a href="mailto:admin@${domain}">admin@${domain}</a>.</p>
<p>For copyright, etc., contact me at <a href="mailto:admin@${domain}">admin@${domain}</a>.</p>

<hr>

<a href="/">${domain}</a>

<script src="./stats.js"></script>
</body>
</html>
EOF
wget https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css
cd
rm -rf opentracker
fi
clear

if [[ $install_file = 1 ]]; then
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Filebrowser中..." 7 68
colorEcho ${INFO} "Install Filebrowser ing"
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
  cat > '/etc/systemd/system/filebrowser.service' << EOF
[Unit]
Description=filebrowser browser
Documentation=https://github.com/filebrowser/filebrowser
After=network.target

[Service]
User=root
Group=root
RemainAfterExit=yes
ExecStart=/usr/local/bin/filebrowser -r /usr/share/nginx/ -d /etc/filebrowser/database.db -b ${filepath} -p 8081
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=51200
LimitNPROC=51200
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable filebrowser
mkdir /etc/filebrowser/
touch /etc/filebrowser/database.db
chmod -R 755 /etc/filebrowser/
fi
clear

if [[ $install_aria = 1 ]]; then
  TERM=ansi whiptail --title "安装中" --infobox "安装Aria2中..." 7 68
  trackers_list=$(wget --no-check-certificate -qO- https://trackerslist.com/all_aria2.txt)
  cat > '/etc/systemd/system/aria2.service' << EOF
[Unit]
Description=Aria2c download manager
Documentation=https://aria2.github.io/manual/en/html/index.html
Requires=network.target
After=network.target

[Service]
Type=forking
User=root
RemainAfterExit=yes
ExecStart=/usr/local/bin/aria2c --conf-path=/etc/aria2.conf
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=51200
LimitNPROC=51200
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
  cat > '/etc/aria2.conf' << EOF
#!!! Do not change these settings unless you know what you are doing !!!
#Global Settings###
daemon=true
async-dns=true
#enable-async-dns6=true
log-level=warn
console-log-level=info
human-readable=true
log=/var/log/aria2.log
rlimit-nofile=51200
event-poll=epoll
min-tls-version=TLSv1.2
dir=/usr/share/nginx/aria2/
file-allocation=falloc
check-integrity=true
conditional-get=false
disk-cache=64M #Larger is better,but should be smaller than available RAM !
enable-color=true
continue=true
always-resume=true
max-concurrent-downloads=50
content-disposition-default-utf8=true
#split=16
##Http(s) Settings#######
enable-http-keep-alive=true
http-accept-gzip=true
min-split-size=10M
max-connection-per-server=16
lowest-speed-limit=0
disable-ipv6=false
max-tries=0
#retry-wait=0
input-file=/usr/local/bin/aria2.session
save-session=/usr/local/bin/aria2.session
save-session-interval=60
force-save=true
metalink-preferred-protocol=https
##Rpc Settings############
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=false
rpc-secure=false
rpc-listen-port=6800
rpc-secret=$ariapasswd
#Bittorrent Settings######
follow-torrent=true
listen-port=$ariaport
enable-dht=true
enable-dht6=true
enable-peer-exchange=true
seed-ratio=0
bt-enable-lpd=true
bt-hash-check-seed=true
bt-seed-unverified=false
bt-save-metadata=true
bt-load-saved-metadata=true
bt-require-crypto=true
bt-force-encryption=true
bt-min-crypto-level=arc4
bt-max-peers=0
bt-tracker=$trackers_list
EOF
  if [[ ! -f /usr/local/bin/aria2c ]]; then
  clear
  apt-get install nettle-dev libgmp-dev libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev libssl-dev libuv1-dev -q -y
  curl -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/aria2c.xz
  xz --decompress aria2c.xz
  cp -f aria2c /usr/local/bin/aria2c
  chmod +x /usr/local/bin/aria2c
  rm -rf aria2c
  apt-get autoremove -q -y
  touch /var/log/aria2.log
  touch /usr/local/bin/aria2.session
  mkdir /usr/share/nginx/aria2/
  chmod 755 /usr/share/nginx/aria2/
  fi
systemctl daemon-reload
systemctl enable aria2
systemctl restart aria2
fi

if [[ ${dnsmasq_install} == 1 ]]; then
  if [[ ! -d /etc/dnscrypt-proxy/ ]]; then
    mkdir /etc/dnscrypt-proxy/
  fi
ipv6_true="false"
block_ipv6="true"
if [[ -n ${myipv6} ]]; then
  ping -6 ipv6.google.com -c 2 || ping -6 2620:fe::10 -c 2
  if [[ $? -eq 0 ]]; then
    ipv6_true="true"
    block_ipv6="false"
  fi
fi
    cat > '/etc/dnscrypt-proxy/dnscrypt-proxy.toml' << EOF
#!!! Do not change these settings unless you know what you are doing !!!
listen_addresses = ['127.0.0.1:53','[::1]:53']
#user_name = 'nobody'
max_clients = 51200
ipv4_servers = true
ipv6_servers = $ipv6_true
dnscrypt_servers = true
doh_servers = true
require_dnssec = false
require_nolog = true
require_nofilter = true
#disabled_server_names = ['cisco', 'cisco-ipv6', 'cisco-familyshield']
force_tcp = false
timeout = 5000
keepalive = 30
lb_estimator = true
lb_strategy = 'ph'
log_level = 2
use_syslog = true
#log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
cert_refresh_delay = 1440
tls_disable_session_tickets = false
#tls_cipher_suite = [4865]
fallback_resolvers = ['1.1.1.1:53', '8.8.8.8:53']
ignore_system_dns = true
netprobe_timeout = 60
netprobe_address = '1.1.1.1:53'
# Maximum log files size in MB - Set to 0 for unlimited.
log_files_max_size = 0
# How long to keep backup files, in days
log_files_max_age = 7
# Maximum log files backups to keep (or 0 to keep all backups)
log_files_max_backups = 0
block_ipv6 = false
## Immediately respond to A and AAAA queries for host names without a domain name
block_unqualified = true
## Immediately respond to queries for local zones instead of leaking them to
## upstream resolvers (always causing errors or timeouts).
block_undelegated = true
## TTL for synthetic responses sent when a request has been blocked (due to
## IPv6 or blacklists).
reject_ttl = 600
cache = true
cache_size = 4096
cache_min_ttl = 2400
cache_max_ttl = 86400
cache_neg_min_ttl = 60
cache_neg_max_ttl = 600

#[local_doh]
#
#listen_addresses = ['127.0.0.1:3001']
#path = "/dns-query"
#cert_file = "/etc/certs/${domain}_ecc/fullchain.cer"
#cert_key_file = "/etc/certs/${domain}_ecc/${domain}.key"

[query_log]

  #file = '/var/log/dnscrypt-proxy/query.log'
  format = 'tsv'

#[blacklist]

  #blacklist_file = '/etc/dnscrypt-proxy/blacklist.txt'

[sources]

  ## An example of a remote source from https://github.com/DNSCrypt/dnscrypt-resolvers

  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
  cache_file = 'public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 12
  prefix = ''

  [sources.'opennic']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/opennic.md', 'https://download.dnscrypt.info/dnscrypt-resolvers/v3/opennic.md']
  cache_file = 'opennic.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 12
  prefix = ''

  ## Anonymized DNS relays

  [sources.'relays']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md', 'https://download.dnscrypt.info/resolvers-list/v3/relays.md']
  cache_file = 'relays.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 12
  prefix = ''
EOF
  cat > '/etc/systemd/system/dnscrypt-proxy.service' << EOF
[Unit]
Description=DNSCrypt client proxy
Documentation=https://github.com/DNSCrypt/dnscrypt-proxy/wiki
After=network.target
Before=nss-lookup.target netdata.service
Wants=nss-lookup.target

[Service]
#User=nobody
NonBlocking=true
ExecStart=/usr/sbin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
ProtectHome=yes
ProtectControlGroups=yes
ProtectKernelModules=yes
CacheDirectory=dnscrypt-proxy
LogsDirectory=dnscrypt-proxy
RuntimeDirectory=dnscrypt-proxy
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable dnscrypt-proxy.service
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Dnscrypt-proxy中..." 7 68
colorEcho ${INFO} "Install dnscrypt-proxy ing"
if [[ $(systemctl is-active dnsmasq) == active ]]; then
  systemctl disable dnsmasq
fi
if [[ $(systemctl is-active systemd-resolved) == active ]]; then
  systemctl stop systemd-resolved
  systemctl disable systemd-resolved
  chattr -i /etc/resolvconf.conf
  echo "nameserver 1.1.1.1" >> /etc/resolv.conf
  echo "nameserver 1.0.0.1" >> /etc/resolv.conf
  echo "nameserver 8.8.8.8" >> /etc/resolv.conf  
fi
dnsver=$(curl -s "https://api.github.com/repos/DNSCrypt/dnscrypt-proxy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -LO --progress-bar https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${dnsver}/dnscrypt-proxy-linux_x86_64-${dnsver}.tar.gz
tar -xvf dnscrypt-proxy-linux_x86_64-${dnsver}.tar.gz
rm dnscrypt-proxy-linux_x86_64-${dnsver}.tar.gz
cd linux-x86_64
cp -f dnscrypt-proxy /usr/sbin/dnscrypt-proxy
chmod +x /usr/sbin/dnscrypt-proxy
cd ..
rm -rf linux-x86_64
setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/dnscrypt-proxy
wget --no-check-certificate -P /etc/dnscrypt-proxy/ https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md -q --show-progress
wget --no-check-certificate -P /etc/dnscrypt-proxy/ https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/opennic.md -q --show-progress
wget --no-check-certificate -P /etc/dnscrypt-proxy/ https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md -q --show-progress
fi
chmod -R 755 /etc/dnscrypt-proxy/
clear

if [[ $install_tor = 1 ]]; then
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Tor relay中..." 7 68
colorEcho ${INFO} "Install Tor Relay ing"
touch /etc/apt/sources.list.d/tor.list
  cat > '/etc/apt/sources.list.d/tor.list' << EOF
deb https://deb.torproject.org/torproject.org $(lsb_release -cs) main
#deb-src https://deb.torproject.org/torproject.org $(lsb_release -cs) main
EOF
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
apt-get update
apt-get install tor tor-geoipdb nyx -y
apt-get install python-stem -y
ipv4_prefer_1="0"
if [[ -n $myipv6 ]]; then
    ping -6 ipv6.google.com -c 2 || ping -6 2620:fe::10 -c 2
    if [[ $? -eq 0 ]]; then
      ipv4_prefer_1="1"
    fi
fi
  cat > '/etc/tor/torrc' << EOF
ClientUseIPv6 ${ipv4_prefer_1}
ClientPreferIPv6ORPort ${ipv4_prefer_1}
ControlPort 127.0.0.1:9051
CookieAuthentication 0
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:8888
HiddenServicePort 443 127.0.0.1:443
EOF
torhostname=$(cat /var/lib/tor/hidden_service/hostname)
systemctl restart tor@default
fi

if [[ $install_php = 1 ]]; then
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装PHP中..." 7 68
  colorEcho ${INFO} "Install PHP ing"
  apt-get purge php* -y
  mkdir /usr/log/
  if [[ ${dist} == debian ]]; then
    wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
    apt-get update
 elif [[ ${dist} == ubuntu ]]; then
    add-apt-repository ppa:ondrej/php -y
    apt-get update
 else
  echo "fail"
 fi
  apt-get install php7.4-fpm -y
  apt-get install php7.4-apcu php7.4-gmp php7.4-common php7.4-mysql php7.4-ldap php7.4-xml php7.4-json php7.4-readline php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl php7.4-bcmath -y
  apt-get purge apache2* -y
  sed -i "s/;date.timezone.*/date.timezone = Asia\/Hong_Kong/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.enable=1/opcache.enable=1/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/" /etc/php/7.4/fpm/php.ini
  sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 2000G/" /etc/php/7.4/fpm/php.ini
  sed -i "s/post_max_size = 8M/post_max_size = 0/" /etc/php/7.4/fpm/php.ini
  sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=192/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=16/" /etc/php/7.4/fpm/php.ini
  if grep -q "opcache.fast_shutdown" /etc/php/7.4/fpm/php.ini
    then
    :
    else
    echo "" >> /etc/php/7.4/fpm/php.ini
    echo "opcache.fast_shutdown=1" >> /etc/php/7.4/fpm/php.ini
  fi
  if grep -q "env[PATH]" /etc/php/7.4/fpm/php-fpm.conf
    then
    :
    else
    echo "" >> /etc/php/7.4/fpm/php-fpm.conf
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin:/usr/local/php/bin" >> /etc/php/7.4/fpm/php-fpm.conf
  fi
  if grep -q "apc.enabled_cli=1" /etc/php/7.4/cli/conf.d/20-apcu.ini
    then
    :
    else
    echo "" >> /etc/php/7.4/cli/conf.d/20-apcu.ini
    echo "apc.enabled_cli=1" >> /etc/php/7.4/cli/conf.d/20-apcu.ini
  fi
  cd /etc/php/7.4/
  curl -sS https://getcomposer.org/installer -o composer-setup.php
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer --force
  cd
cat > '/etc/php/7.4/fpm/pool.d/www.conf' << EOF
[www]

;prefix = /path/to/pools/$pool

user = nginx
group = nginx

listen = /run/php/php7.4-fpm.sock
; Set listen(2) backlog.
; Default Value: 511 (-1 on FreeBSD and OpenBSD)
;listen.backlog = 511

; Set permissions for unix socket, if one is used. In Linux, read/write
; permissions must be set in order to allow connections from a web server. Many
; BSD-derived systems allow connections regardless of permissions. The owner
; and group can be specified either by name or by their numeric IDs.
; Default Values: user and group are set as the running user
;                 mode is set to 0660
listen.owner = nginx
listen.group = nginx
;listen.mode = 0660
;listen.acl_users =
;listen.acl_groups =

; List of addresses (IPv4/IPv6) of FastCGI clients which are allowed to connect.
; Equivalent to the FCGI_WEB_SERVER_ADDRS environment variable in the original
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
; must be separated by a comma. If this value is left blank, connections will be
; accepted from any ip address.
; Default Value: any
; listen.allowed_clients = 127.0.0.1

pm = dynamic

pm.max_children = $(($(nproc --all)*5))

pm.start_servers = $(($(nproc --all)*4))

pm.min_spare_servers = $(($(nproc --all)*2))

pm.max_spare_servers = $(($(nproc --all)*4))

; The number of requests each child process should execute before respawning.
; This can be useful to work around memory leaks in 3rd party libraries. For
; endless request processing specify '0'. Equivalent to PHP_FCGI_MAX_REQUESTS.
; Default Value: 0
;pm.max_requests = 500

pm.status_path = /status

ping.path = /ping

catch_workers_output = no

; Default Value: nothing is defined by default except the values in php.ini and
;                specified at startup with the -d argument
;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
php_flag[display_errors] = on
php_admin_value[error_log] = /var/log/fpm-php.www.log
php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 32M
EOF
touch /var/log/fpm-php.www.log
systemctl restart php7.4-fpm
fi

if [[ $install_netdata == 1 ]]; then
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装Netdata中..." 7 68
  colorEcho ${INFO} "Install netdata ing"
  bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh) --dont-wait --allow-duplicate-install
  sed -i "s/SEND_EMAIL=\"YES\"/SEND_EMAIL=\"NO\"/" /opt/netdata/etc/netdata/health_alarm_notify.conf
  sed -i "s/Restart=on-failure/Restart=always/" /lib/systemd/system/netdata.service
  systemctl daemon-reload
  systemctl stop netdata
  killall netdata
    cat > '/opt/netdata/etc/netdata/python.d/nginx.conf' << EOF
localhost:

localipv4:
  name : 'local'
  url  : 'http://127.0.0.1:81/stub_status'
EOF
    cat > '/opt/netdata/etc/netdata/python.d/web_log.conf' << EOF
nginx_log:
  name  : 'nginx_log'
  path  : '/var/log/nginx/access.log'
EOF
    cat > '/opt/netdata/etc/netdata/go.d/docker_engine.conf' << EOF
jobs:
  - name: local
    url : http://127.0.0.1:9323/metrics
EOF
    cat > '/opt/netdata/etc/netdata/go.d/x509check.conf' << EOF
update_every : 60

jobs:

  - name   : ${domain}_${password1}_file_cert
    source : file:///etc/certs/${domain}_ecc/fullchain.cer
EOF
if [[ ${install_php} == 1 ]]; then
cat > '/opt/netdata/etc/netdata/python.d/phpfpm.conf' << EOF
local:
  url     : 'http://127.0.0.1:81/status?full&json'
EOF
fi
if [[ ${install_tor} == 1 ]]; then
apt-get install python-pip -y
pip install stem
cat > '/opt/netdata/etc/netdata/python.d/tor.conf' << EOF
update_every : 1
priority     : 60001

local_tcp:
 name: 'local'
 control_port: 9051
EOF
fi
if [[ ${install_redis} == 1 ]]; then
cat > '/opt/netdata/etc/netdata/python.d/redis.conf' << EOF
socket:
  name     : 'local'
  socket   : '/var/run/redis/redis.sock'
EOF
fi
systemctl restart netdata
fi
clear

if [[ $install_trojan = 1 ]]; then
  if [[ ! -f /usr/local/bin/trojan ]]; then
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装Trojan中..." 7 68
  colorEcho ${INFO} "Install Trojan-GFW ing"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
  systemctl daemon-reload
  clear
  colorEcho ${INFO} "configuring trojan-gfw"
  setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/trojan
  fi
  ipv4_prefer="true"
  if [[ -n $myipv6 ]]; then
    ping -6 ipv6.google.com -c 2 || ping -6 2620:fe::10 -c 2
    if [[ $? -eq 0 ]]; then
      ipv4_prefer="false"
    fi
  fi
  cat > '/etc/systemd/system/trojan.service' << EOF
[Unit]
Description=trojan
Documentation=https://trojan-gfw.github.io/trojan/config https://trojan-gfw.github.io/trojan/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
CPUSchedulingPolicy=rr
CPUSchedulingPriority=99
ExecStart=/usr/local/bin/trojan /usr/local/etc/trojan/config.json
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable trojan
if [[ ${install_mariadb} == 1 ]]; then
    cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": ${trojanport},
    "remote_addr": "127.0.0.1",
    "remote_port": 8888,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "key_password": "",
        "cipher": "$cipher_server",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
          "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": $ipv4_prefer,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": ${tcp_fastopen},
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": true,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
  else
    cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": ${trojanport},
    "remote_addr": "127.0.0.1",
    "remote_port": 8888,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/certs/${domain}_ecc/fullchain.cer",
        "key": "/etc/certs/${domain}_ecc/${domain}.key",
        "key_password": "",
        "cipher": "$cipher_server",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
          "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": $ipv4_prefer,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": ${tcp_fastopen},
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
fi

if [[ ${othercert} == 1 ]]; then
  if [[ ${install_mariadb} == 1 ]]; then
    cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": ${trojanport},
    "remote_addr": "127.0.0.1",
    "remote_port": 8888,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/trojan/trojan.crt",
        "key": "/etc/trojan/trojan.key",
        "key_password": "",
        "cipher": "$cipher_server",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
          "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": $ipv4_prefer,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": ${tcp_fastopen},
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": true,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
    else
    cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": ${trojanport},
    "remote_addr": "127.0.0.1",
    "remote_port": 8888,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 2,
    "ssl": {
        "cert": "/etc/trojan/trojan.crt",
        "key": "/etc/trojan/trojan.key",
        "key_password": "",
        "cipher": "$cipher_server",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
          "h2",
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 82
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    },
    "tcp": {
        "prefer_ipv4": $ipv4_prefer,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": ${tcp_fastopen},
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": "${password1}",
        "key": "",
        "cert": "",
        "ca": ""
    }
}
EOF
  fi
fi
  chmod -R 755 /usr/local/etc/trojan/
  touch /usr/share/nginx/html/client1-$password1.json
  touch /usr/share/nginx/html/client2-$password2.json
  cat > "/usr/share/nginx/html/client1-$password1.json" << EOF
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "$myip",
  "remote_port": ${trojanport},
  "password": [
    "$password1"
  ],
  "log_level": 1,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "",
    "cipher": "$cipher_client",
    "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
    "sni": "$domain",
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "reuse_session": true,
    "session_ticket": false,
    "curves": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "fast_open": ${tcp_fastopen},
    "fast_open_qlen": 20
  }
}
EOF
  cat > "/usr/share/nginx/html/client2-$password2.json" << EOF
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "$myip",
  "remote_port": ${trojanport},
  "password": [
    "$password2"
  ],
  "log_level": 1,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "",
    "cipher": "$cipher_client",
    "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
    "sni": "$domain",
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "reuse_session": true,
    "session_ticket": false,
    "curves": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "fast_open": ${tcp_fastopen},
    "fast_open_qlen": 20
  }
}
EOF
if [[ -n $myipv6 ]]; then
  touch /usr/share/nginx/html/clientv6-$password1.json
  cat > "/usr/share/nginx/html/clientv6-$password1.json" << EOF
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "$myipv6",
  "remote_port": ${trojanport},
  "password": [
    "$password1"
  ],
  "log_level": 1,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "",
    "cipher": "$cipher_client",
    "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
    "sni": "$domain",
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "reuse_session": true,
    "session_ticket": false,
    "curves": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "fast_open": ${tcp_fastopen},
    "fast_open_qlen": 20
  }
}
EOF
fi
fi
  clear
}
##########Install Mariadb#############
install_mariadb(){
  curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
  apt-get install mariadb-server -y
  apt-get install python-mysqldb -y
  apt-get -y install expect

  SECURE_MYSQL=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Switch to unix_socket authentication\"
send \"n\r\"

expect \"Change the root password?\"
send \"n\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

echo "$SECURE_MYSQL"

apt-get -y purge expect

    cat > '/etc/mysql/my.cnf' << EOF
# MariaDB-specific config file.
# Read by /etc/mysql/my.cnf

[client]

default-character-set = utf8mb4 

[mysqld]

character-set-server  = utf8mb4 
collation-server      = utf8mb4_unicode_ci
character_set_server   = utf8mb4 
collation_server       = utf8mb4_unicode_ci
# Import all .cnf files from configuration directory
!includedir /etc/mysql/mariadb.conf.d/
bind-address=127.0.0.1

[mariadb]

userstat = 1
tls_version = TLSv1.2,TLSv1.3
ssl_cert = /etc/certs/${domain}_ecc/fullchain.cer
ssl_key = /etc/certs/${domain}_ecc/${domain}.key
EOF

if [[ ${othercert} == 1 ]]; then
    cat > '/etc/mysql/my.cnf' << EOF
# MariaDB-specific config file.
# Read by /etc/mysql/my.cnf

[client]

default-character-set = utf8mb4 

[mysqld]

character-set-server  = utf8mb4 
collation-server      = utf8mb4_unicode_ci
character_set_server   = utf8mb4 
collation_server       = utf8mb4_unicode_ci
# Import all .cnf files from configuration directory
!includedir /etc/mysql/mariadb.conf.d/
bind-address=127.0.0.1

[mariadb]

userstat = 1
tls_version = TLSv1.2,TLSv1.3
ssl_cert = /etc/trojan/trojan.crt
ssl_key = /etc/trojan/trojan.key
EOF
fi

mysql -u root -e "create user 'netdata'@'localhost';"
mysql -u root -e "grant usage on *.* to 'netdata'@'localhost';"
mysql -u root -e "flush privileges;"

mysql -u root -e "CREATE DATABASE trojan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "create user 'trojan'@'localhost' IDENTIFIED BY '${password1}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON trojan.* to trojan@'localhost';"
mysql -u root -e "flush privileges;"

if [[ ${install_rsshub} == 1 ]]; then
mysql -u root -e "CREATE DATABASE ttrss CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "create user 'ttrss'@'localhost' IDENTIFIED BY '${password1}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON ttrss.* to ttrss@'localhost';"
mysql -u root -e "flush privileges;"
mysql -u ttrss -p"${password1}" -D ttrss < /usr/share/nginx/tt-rss/schema/ttrss_schema_mysql.sql
fi
    cat > '/opt/netdata/etc/netdata/python.d/mysql.conf' << EOF
update_every : 10
priority     : 90100

local:
  user     : 'netdata'
  update_every : 1
EOF
##############Install Mail Service###############
if [[ $install_mail = 1 ]]; then
  if [[ ! -f /usr/sbin/postfix ]]; then
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装邮件服务中..." 7 68
  colorEcho ${INFO} "Install Mail Service ing"
  apt-get install postfix postfix-pcre -y
  apt-get install postfix-policyd-spf-python -y
  apt-get install opendmarc -y
  systemctl enable opendmarc
  sed -i 's/Socket local:\/var\/run\/opendmarc\/opendmarc.sock/Socket local:\/var\/spool\/postfix\/opendmarc\/opendmarc.sock/' /etc/opendmarc.conf
  sed -i 's/SOCKET=local:\$RUNDIR\/opendmarc.sock/SOCKET=local:\/var\/spool\/postfix\/opendmarc\/opendmarc.sock/' /etc/default/opendmarc
  mkdir -p /var/spool/postfix/opendmarc
  chown opendmarc:opendmarc /var/spool/postfix/opendmarc -R
  chmod 750 /var/spool/postfix/opendmarc/ -R
  adduser postfix opendmarc
  systemctl restart opendmarc
  echo ${domain} > /etc/mailname
  cat > '/etc/postfix/main.cf' << EOF
home_mailbox = Maildir/
smtpd_banner = \$myhostname ESMTP \$mail_name (Debian/GNU)
biff = no
append_dot_mydomain = no
readme_directory = no
compatibility_level = 2
smtpd_tls_loglevel = 1
smtpd_tls_security_level = may
smtpd_tls_received_header = yes
smtpd_tls_eccert_file = /etc/certs/${domain}_ecc/fullchain.cer
smtpd_tls_eckey_file = /etc/certs/${domain}_ecc/${domain}.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtpd_tls_mandatory_ciphers = high
smtpd_tls_mandatory_exclude_ciphers = aNULL
smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_dns_support_level=dnssec
smtp_host_lookup = native
smtp_tls_loglevel = 1
smtp_tls_security_level = dane
smtp_tls_mandatory_exclude_ciphers = aNULL, ECDHE-ECDSA-AES256-SHA384, ECDHE-ECDSA-AES128-SHA256, ECDHE-ECDSA-CAMELLIA256-SHA384, ECDHE-ECDSA-AES256-SHA, ECDHE-ECDSA-CAMELLIA128-SHA256, ECDHE-ECDSA-AES128-SHA
smtp_tls_connection_reuse = no
smtp_tls_eccert_file = /etc/certs/${domain}_ecc/fullchain.cer
smtp_tls_eckey_file = /etc/certs/${domain}_ecc/${domain}.key
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
smtp_tls_mandatory_ciphers = high
smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_sasl_type = dovecot
smtpd_sasl_security_options = noanonymous
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_authenticated_header = no
myhostname = ${domain}
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = /etc/mailname
mydestination = \$myhostname, ${domain}, localhost.${domain}, localhost
relayhost = 
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 ${myip}/32
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4, ipv6
message_size_limit = 52428800
smtpd_helo_required = yes
disable_vrfy_command = yes
policyd-spf_time_limit = 3600
smtpd_helo_restrictions = permit_mynetworks permit_sasl_authenticated reject_non_fqdn_helo_hostname reject_invalid_helo_hostname reject_unknown_helo_hostname
smtpd_sender_restrictions = permit_mynetworks permit_sasl_authenticated reject_unknown_sender_domain reject_unknown_client_hostname
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
smtpd_recipient_restrictions = permit_mynetworks,permit_sasl_authenticated,reject_unauth_destination,check_policy_service unix:private/policyd-spf
milter_default_action = accept
milter_protocol = 6
smtpd_milters = local:opendkim/opendkim.sock,local:opendmarc/opendmarc.sock,local:spamass/spamass.sock
non_smtpd_milters = local:opendkim/opendkim.sock,local:opendmarc/opendmarc.sock,local:spamass/spamass.sock
smtp_header_checks = regexp:/etc/postfix/smtp_header_checks
mailbox_transport = lmtp:unix:private/dovecot-lmtp
smtputf8_enable = no
tls_ssl_options = no_ticket, no_compression
tls_preempt_cipherlist = yes
smtpd_tls_auth_only = no
postscreen_access_list = permit_mynetworks cidr:/etc/postfix/postscreen_access.cidr
postscreen_blacklist_action = drop
EOF
  cat > '/etc/postfix/postscreen_access.cidr' << EOF
#permit my own IP addresses.
${myip}/32             permit
EOF
  cat > '/etc/aliases' << EOF
# See man 5 aliases for format
postmaster:    root
root:   ${mailuser}
EOF
  cat > '/etc/postfix/master.cf' << EOF
#
# Postfix master process configuration file.  For details on the format
# of the file, see the master(5) manual page (command: "man 5 master" or
# on-line: http://www.postfix.org/master.5.html).
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (no)    (never) (100)
# ==========================================================================
smtp      inet  n       -       y       -       -       smtpd
smtp      inet  n       -       y       -       1       postscreen
smtpd     pass  -       -       y       -       -       smtpd
dnsblog   unix  -       -       y       -       0       dnsblog
tlsproxy  unix  -       -       y       -       0       tlsproxy
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
smtps     inet  n       -       y       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
#628       inet  n       -       y       -       -       qmqpd
pickup    unix  n       -       y       60      1       pickup
cleanup   unix  n       -       y       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
#qmgr     unix  n       -       n       300     1       oqmgr
tlsmgr    unix  -       -       y       1000?   1       tlsmgr
rewrite   unix  -       -       y       -       -       trivial-rewrite
bounce    unix  -       -       y       -       0       bounce
defer     unix  -       -       y       -       0       bounce
trace     unix  -       -       y       -       0       bounce
verify    unix  -       -       y       -       1       verify
flush     unix  n       -       y       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       y       -       -       smtp
relay     unix  -       -       y       -       -       smtp
        -o syslog_name=postfix/\$service_name
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       y       -       -       showq
error     unix  -       -       y       -       -       error
retry     unix  -       -       y       -       -       error
discard   unix  -       -       y       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       y       -       -       lmtp
anvil     unix  -       -       y       -       1       anvil
scache    unix  -       -       y       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
#
# ====================================================================
# Interfaces to non-Postfix software. Be sure to examine the manual
# pages of the non-Postfix software to find out what options it wants.
#
# Many of the following services use the Postfix pipe(8) delivery
# agent.  See the pipe(8) man page for information about \${recipient}
# and other message envelope options.
# ====================================================================
#
# maildrop. See the Postfix MAILDROP_README file for details.
# Also specify in main.cf: maildrop_destination_recipient_limit=1
#
maildrop  unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail argv=/usr/bin/maildrop -d \${recipient}
#
# ====================================================================
#
# Recent Cyrus versions can use the existing "lmtp" master.cf entry.
#
# Specify in cyrus.conf:
#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4
#
# Specify in main.cf one or more of the following:
#  mailbox_transport = lmtp:inet:localhost
#  virtual_transport = lmtp:inet:localhost
#
# ====================================================================
#
# Cyrus 2.1.5 (Amos Gouaux)
# Also specify in main.cf: cyrus_destination_recipient_limit=1
#
#cyrus     unix  -       n       n       -       -       pipe
#  user=cyrus argv=/cyrus/bin/deliver -e -r \${sender} -m \${extension} \${user}
#
# ====================================================================
# Old example of delivery via Cyrus.
#
#old-cyrus unix  -       n       n       -       -       pipe
#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m \${extension} \${user}
#
# ====================================================================
#
# See the Postfix UUCP_README file for configuration details.
#
uucp      unix  -       n       n       -       -       pipe
  flags=Fqhu user=uucp argv=uux -r -n -z -a\$sender - \$nexthop!rmail (\$recipient)
#
# Other external delivery methods.
#
ifmail    unix  -       n       n       -       -       pipe
  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r \$nexthop (\$recipient)
bsmtp     unix  -       n       n       -       -       pipe
  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t\$nexthop -f\$sender \$recipient
scalemail-backend unix  - n n - 2 pipe
  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store \${nexthop} \${user} \${extension}
mailman   unix  -       n       n       -       -       pipe
  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
  \${nexthop} \${user}

policyd-spf  unix  -       n       n       -       0       spawn
    user=policyd-spf argv=/usr/bin/policyd-spf
EOF
newaliases
echo "/^Received: .*/     IGNORE" > /etc/postfix/smtp_header_checks
echo "/^User-Agent.*Roundcube Webmail/            IGNORE" >> /etc/postfix/smtp_header_checks
curl https://repo.dovecot.org/DOVECOT-REPO-GPG | gpg --import
gpg --export ED409DA1 > /etc/apt/trusted.gpg.d/dovecot.gpg
echo "deb https://repo.dovecot.org/ce-2.3-latest/${dist}/$(lsb_release -cs) $(lsb_release -cs) main" > /etc/apt/sources.list.d/dovecot.list
apt-get update
apt-get install dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sieve -y
adduser dovecot mail
adduser netdata mail
systemctl enable dovecot
apt-get install spamassassin spamc spamass-milter -y
adduser debian-spamd mail
adduser spamass-milter mail
sed -i 's/CRON=0/CRON=1/' /etc/default/spamassassin
  cat > '/etc/default/spamass-milter' << EOF
# spamass-milt startup defaults

# OPTIONS are passed directly to spamass-milter.
# man spamass-milter for details

# Non-standard configuration notes:
# See README.Debian if you use the -x option with sendmail
# You should not pass the -d option in OPTIONS; use SOCKET for that.

# Default, use the spamass-milter user as the default user, ignore
# messages from localhost
OPTIONS="-u spamass-milter -i 127.0.0.1"

# Reject emails with spamassassin scores > 15.
OPTIONS="\${OPTIONS} -r 8"

# Do not modify Subject:, Content-Type: or body.
#OPTIONS="\${OPTIONS} -m"

######################################
# If /usr/sbin/postfix is executable, the following are set by
# default. You can override them by uncommenting and changing them
# here.
######################################
SOCKET="/var/spool/postfix/spamass/spamass.sock"
SOCKETOWNER="postfix:postfix"
SOCKETMODE="0660"
######################################
EOF
systemctl enable spamassassin
systemctl restart spamassassin
cd /usr/share/nginx/
mailver=$(curl -s "https://api.github.com/repos/roundcube/roundcubemail/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -d /usr/share/nginx/roundcubemail ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新roundcube中..." 7 68
    wget --no-check-certificate https://github.com/roundcube/roundcubemail/releases/download/${mailver}/roundcubemail-${mailver}-complete.tar.gz
    tar -xvf roundcubemail*.tar.gz
    rm -rf roundcubemail*.tar.gz
    cd /usr/share/nginx/roundcubemail-1.*/bin/
    ./installto.sh /usr/share/nginx/roundcubemail
    cd /usr/share/nginx/
    rm -rf /usr/share/nginx/roundcubemail-1.*
    cd /usr/share/nginx/roundcubemail
    php /usr/local/bin/composer update --no-dev
    chown -R nginx:nginx /usr/share/nginx/roundcubemail/
    rm -rf /usr/share/nginx/roundcubemail/installer/
  else
    wget --no-check-certificate https://github.com/roundcube/roundcubemail/releases/download/${mailver}/roundcubemail-${mailver}-complete.tar.gz
    tar -xvf roundcubemail-${mailver}-complete.tar.gz
    rm -rf roundcubemail-${mailver}-complete.tar.gz
    mv /usr/share/nginx/roundcubemail*/ /usr/share/nginx/roundcubemail/
    chown -R nginx:nginx /usr/share/nginx/roundcubemail/
    cd /usr/share/nginx/roundcubemail/
    curl -s https://getcomposer.org/installer | php
    cp -f composer.json-dist composer.json
    php /usr/local/bin/composer update --no-dev
    rm -rf /usr/share/nginx/roundcubemail/installer/
    cd
    mysql -u root -e "CREATE DATABASE roundcubemail DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -e "CREATE USER roundcube@localhost IDENTIFIED BY '${password1}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcube@localhost;"
    mysql -u root -e "flush privileges;"
    mysql -u roundcube -p"${password1}" -D roundcubemail < /usr/share/nginx/roundcubemail/SQL/mysql.initial.sql  
fi
mkdir /usr/share/nginx/pgp/
deskey=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_#&!*%?' | fold -w 24 | head -n 1)
  cat > '/usr/share/nginx/roundcubemail/config/config.inc.php' << EOF
<?php

\$config['language'] = 'zh_TW';
\$config['db_dsnw'] = 'mysql://roundcube:${password1}@unix(/run/mysqld/mysqld.sock)/roundcubemail';
\$config['default_host'] = '${domain}';
\$config['default_port'] = 143;
\$config['smtp_server'] = '127.0.0.1';
\$config['smtp_port'] = 25;
\$config['support_url'] = 'https://github.com/johnrosen1/vpstoolbox';
\$config['product_name'] = 'Roundcube Webmail For VPSTOOLBOX';
\$config['des_key'] = '${deskey}';
\$config['ip_check'] = true;
\$config['enable_installer'] = false;
\$config['identities_level'] = 3;

// ----------------------------------
// PLUGINS
// ----------------------------------
// List of active plugins (in plugins/ directory)
\$config['plugins'] = array('archive','emoticons','enigma','markasjunk','newmail_notifier','zipdownload');
\$config['newmail_notifier_basic'] = true;
\$config['newmail_notifier_desktop'] = true;
\$config['enigma_pgp_homedir'] = '/usr/share/nginx/pgp/';
\$config['enigma_encryption'] = true;
\$config['enigma_signatures'] = true;
\$config['enigma_decryption'] = true;
\$config['enigma_sign_all'] = true;
EOF
useradd -m -s /sbin/nologin ${mailuser}
echo -e "${password1}\n${password1}" | passwd ${mailuser}
apt-get install opendkim opendkim-tools -y
gpasswd -a postfix opendkim
  cat > '/etc/opendkim.conf' << EOF
Syslog      yes
UMask     007
Canonicalization  relaxed/simple
Mode      sv
SubDomains    no
AutoRestart         yes
AutoRestartRate     10/1M
Background          yes
DNSTimeout          5
SignatureAlgorithm  rsa-sha256
Socket    local:/var/spool/postfix/opendkim/opendkim.sock
PidFile               /var/run/opendkim/opendkim.pid
OversignHeaders   From
TrustAnchorFile       /usr/share/dns/root.key
UserID                opendkim
KeyTable           refile:/etc/opendkim/key.table
SigningTable       refile:/etc/opendkim/signing.table
ExternalIgnoreList  /etc/opendkim/trusted.hosts
InternalHosts       /etc/opendkim/trusted.hosts
Nameservers 127.0.0.1
EOF
  cat > '/etc/default/opendkim' << EOF
RUNDIR=/var/run/opendkim
SOCKET="local:/var/spool/postfix/opendkim/opendkim.sock"
USER=opendkim
GROUP=opendkim
PIDFILE=\$RUNDIR/\$NAME.pid
EXTRAAFTER=
EOF
mkdir /etc/opendkim/
mkdir /etc/opendkim/keys/
chown -R opendkim:opendkim /etc/opendkim
chmod go-rw /etc/opendkim/keys
echo "*@${domain}    default._domainkey.${domain}" > /etc/opendkim/signing.table
echo "default._domainkey.${domain}     ${domain}:default:/etc/opendkim/keys/${domain}/default.private" > /etc/opendkim/key.table
  cat > '/etc/opendkim/trusted.hosts' << EOF
127.0.0.1
localhost
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16

*.${domain}
EOF
mkdir /etc/opendkim/keys/${domain}/
opendkim-genkey -b 2048 -d ${domain} -D /etc/opendkim/keys/${domain} -s default -v
chown opendkim:opendkim /etc/opendkim/keys/${domain}/default.private
mkdir /var/spool/postfix/opendkim/
chown opendkim:postfix /var/spool/postfix/opendkim
systemctl restart opendkim
usermod -a -G dovecot netdata
usermod -a -G mail postfix
fi
  cat > '/etc/dovecot/conf.d/10-auth.conf' << EOF
auth_username_format = %Ln
disable_plaintext_auth = no
auth_mechanisms = plain
!include auth-system.conf.ext
EOF
  cat > '/etc/dovecot/conf.d/10-ssl.conf' << EOF
ssl = required
ssl_cert = </etc/certs/${domain}_ecc/fullchain.cer
ssl_key = </etc/certs/${domain}_ecc/${domain}.key
ssl_cipher_list = ${cipher_server}
ssl_min_protocol = TLSv1.2
ssl_prefer_server_ciphers = yes
ssl_options = no_ticket
EOF
  cat > '/etc/dovecot/conf.d/10-master.conf' << EOF
service imap-login {
  inet_listener imap {
    #port = 143
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }
}

service submission-login {
  inet_listener submission {
    #port = 587
  }
}

service imap {
  # Most of the memory goes to mmap()ing files. You may need to increase this
  # limit if you have huge mailboxes.
  #vsz_limit = $default_vsz_limit

  # Max. number of IMAP processes (connections)
  #process_limit = 1024
}

service lmtp {
 unix_listener /var/spool/postfix/private/dovecot-lmtp {
   mode = 0600
   user = postfix
   group = postfix
  }
}

service submission {
  # Max. number of SMTP Submission processes (connections)
  #process_limit = 1024
}

service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }

}

service auth-worker {
  #user = root
}

service dict {
  unix_listener dict {
    #mode = 0600
    #user = 
    #group = 
  }
}

service stats {
  unix_listener stats {
    user = netdata
    group = netdata
    mode = 0666
  }
}
EOF
  cat > '/etc/dovecot/conf.d/10-mail.conf' << EOF

mail_location = maildir:~/Maildir

namespace inbox {
  inbox = yes
}

mail_privileged_group = mail

protocol !indexer-worker {
  #mail_vsize_bg_after_count = 0
}
EOF
  cat > '/etc/dovecot/conf.d/15-mailboxes.conf' << EOF
namespace inbox {
  mailbox Archive {
    auto = subscribe
    special_use = \Archive
  }
  mailbox Drafts {
    auto = subscribe
    special_use = \Drafts
  }
  mailbox Junk {
    auto = subscribe
    special_use = \Junk
  }
  mailbox Trash {
    auto = subscribe
    special_use = \Trash
  }
  mailbox Sent {
    auto = subscribe
    special_use = \Sent
  }
}
EOF
  cat > '/etc/dovecot/conf.d/15-lda.conf' << EOF
protocol lda {
  # Space separated list of plugins to load (default is global mail_plugins).
  mail_plugins = \$mail_plugins sieve
}
EOF
  cat > '/etc/dovecot/conf.d/20-lmtp.conf' << EOF
protocol lmtp {
  # Space separated list of plugins to load (default is global mail_plugins).
  mail_plugins = \$mail_plugins quota sieve
}
EOF
  cat > '/etc/dovecot/conf.d/90-sieve.conf' << EOF
plugin {
  sieve = file:~/sieve;active=~/.dovecot.sieve
  sieve_before = /var/mail/SpamToJunk.sieve
}
EOF
  cat > '/var/mail/SpamToJunk.sieve' << EOF
require "fileinto";

if header :contains "X-Spam-Flag" "YES"
{
   fileinto "Junk";
   stop;
}
EOF
  cat > '/etc/fail2ban/filter.d/dovecot-pop3imap.conf' << EOF
[Definition]
failregex = (?: pop3-login|imap-login): .*(?:Authentication failure|Aborted login \(auth failed|Aborted login \(tried to use disabled|Disconnected \(auth failed|Aborted login \(\d+ authentication attempts).*rip=`<HOST>`
EOF

if grep -q "dovecot-pop3imap" /etc/fail2ban/jail.conf
then
:
else
echo "[dovecot-pop3imap]" >> /etc/fail2ban/jail.conf
echo "enabled = true" >> /etc/fail2ban/jail.conf
echo "filter = dovecot-pop3imap" >> /etc/fail2ban/jail.conf
echo "action = iptables-multiport[name=dovecot-pop3imap, port="pop3,imap", protocol=tcp]" >> /etc/fail2ban/jail.conf
echo "logpath = /var/log/mail.log" >> /etc/fail2ban/jail.conf
echo "maxretry = 8" >> /etc/fail2ban/jail.conf
echo "findtime = 1200" >> /etc/fail2ban/jail.conf
echo "bantime = 1200" >> /etc/fail2ban/jail.conf
fi
systemctl restart fail2ban
sievec /var/mail/SpamToJunk.sieve
chown -R mail:mail /var/mail/*
systemctl restart postfix dovecot
fi
clear
}
########Nginx config##############
nginxtrojan(){
  set +e
  clear
TERM=ansi whiptail --title "安装中" --infobox "配置NGINX中..." 7 68
  colorEcho ${INFO} "配置(configing) nginx"
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/conf.d/*
touch /etc/nginx/conf.d/default.conf
  cat > '/etc/nginx/conf.d/default.conf' << EOF
#!!! Do not change these settings unless you know what you are doing !!!
server {
  listen 127.0.0.1:80 fastopen=20 reuseport default_server;
  listen 127.0.0.1:8888 fastopen=20 reuseport default_server;
  listen 127.0.0.1:82 http2 fastopen=20 reuseport default_server;
  server_name $domain _;
  resolver 127.0.0.1;
  resolver_timeout 10s;
  #if (\$http_user_agent ~* (360|Tencent|MicroMessenger|Maxthon|TheWorld|UC|OPPO|baidu|Sogou|2345|) ) { return 403; }
  #if (\$http_user_agent ~* (wget|curl) ) { return 403; }
  #if (\$http_user_agent = "") { return 403; }
  #if (\$host != "$domain") { return 404; }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Cache-Status \$upstream_cache_status;
  location / {
    proxy_pass http://127.0.0.1:4000/;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    #error_page 404  /404.html;
    http2_push /css/main.css;
        http2_push /lib/font-awesome/css/all.min.css;
        http2_push /lib/anime.min.js;
        http2_push /lib/velocity/velocity.min.js;
        http2_push /lib/velocity/velocity.ui.min.js;
        http2_push /js/utils.js;
        http2_push /js/motion.js;
        http2_push /js/schemes/muse.js;
        http2_push /js/next-boot.js;
  }
  location /${password1}.png {
    root /usr/share/nginx/html/;
  }
  location /${password2}.png {
    root /usr/share/nginx/html/;
  }
  location /client1-${password1}.json {
    root /usr/share/nginx/html/;
  }
  location /client2-${password2}.json {
    root /usr/share/nginx/html/;
  }
EOF
if [[ $install_nextcloud == 1 ]]; then
mkdir /usr/share/nginx/tmp/
echo "    include /etc/nginx/conf.d/nextcloud.conf;" >> /etc/nginx/conf.d/default.conf
cat > '/etc/nginx/conf.d/nextcloud.conf' << EOF
    location /.well-known {
        rewrite ^/\.well-known/host-meta\.json  /nextcloud/public.php?service=host-meta-json    last;
        rewrite ^/\.well-known/host-meta        /nextcloud/public.php?service=host-meta         last;
        rewrite ^/\.well-known/webfinger        /nextcloud/public.php?service=webfinger         last;
        rewrite ^/\.well-known/nodeinfo         /nextcloud/public.php?service=nodeinfo          last;

        try_files \$uri \$uri/ =404;
    }

    location = /.well-known/carddav { return 301 https://\$host:443/nextcloud/remote.php/dav; }
    location = /.well-known/caldav { return 301 https://\$host:443/nextcloud/remote.php/dav; }

    location ^~ /nextcloud/ {
        root /usr/share/nginx/;
        client_body_temp_path /usr/share/nginx/tmp/ 1 2;
        client_max_body_size 0;
        fastcgi_buffers 64 4K;
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;
        add_header Referrer-Policy                      "no-referrer"   always;
        add_header X-Content-Type-Options               "nosniff"       always;
        add_header X-Download-Options                   "noopen"        always;
        add_header X-Frame-Options                      "SAMEORIGIN"    always;
        add_header X-Permitted-Cross-Domain-Policies    "none"          always;
        add_header X-Robots-Tag                         "none"          always;
        add_header X-XSS-Protection                     "1; mode=block" always;
        #fastcgi_hide_header X-Powered-By;
        index index.php index.html /nextcloud/index.php\$request_uri;

        expires 1m;

        location = /nextcloud/ {
            if ( \$http_user_agent ~ ^DavClnt ) {
                return 302 /nextcloud/remote.php/webdav/\$is_args\$args;
            }
        }

        location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)(?:\$|/)    { return 404; }
        location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

        location ~ \.php(?:\$|/) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
            set \$path_info \$fastcgi_path_info;

            try_files \$fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            fastcgi_param PATH_INFO \$path_info;
            fastcgi_param HTTPS on;

            fastcgi_param modHeadersAvailable true;
            fastcgi_param front_controller_active true;
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;

            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;
            fastcgi_read_timeout 600s;
        }

        location ~ \.(?:css|js|svg|gif)\$ {
            try_files \$uri /nextcloud/index.php\$request_uri;
            expires 6M;
            access_log off;
        }

        location ~ \.woff2?\$ {
            try_files \$uri /nextcloud/index.php\$request_uri;
            expires 7d;
            access_log off;
        }

        location /nextcloud/ {
            try_files \$uri \$uri/ /nextcloud/index.php\$request_uri;
        }
    }
EOF
fi
if [[ $install_tjp == 1 ]]; then
echo "    location /config/ {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        #http2_push /${password1}_config/css/app.css;" >> /etc/nginx/conf.d/default.conf
echo "        #http2_push /${password1}_config/js/app.js;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/trojan-panel/public/;" >> /etc/nginx/conf.d/default.conf
echo "        try_files \$uri \$uri/ @config;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location @config {" >> /etc/nginx/conf.d/default.conf
echo "        rewrite /config/(.*)\$ /config/index.php?/\$1 last;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /config {" >> /etc/nginx/conf.d/default.conf
echo "        return 301 https://${domain}/config/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_chat == 1 ]]; then
echo "    location /rocketchat {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_no_cache 1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_cache_bypass 1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        proxy_http_version 1.1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Nginx-Proxy true;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /file-upload/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat/file-upload/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /avatar/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat/avatar/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /assets/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat/assets/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /home {" >> /etc/nginx/conf.d/default.conf
echo "        return 301 https://${domain}/rocketchat/home/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_mail == 1 ]]; then
echo "    location /${password1}_webmail/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/roundcubemail/;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $dnsmasq_install == 1 ]]; then
echo "    #location /dns-query {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_pass https://127.0.0.1:3001/dns-query;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        #error_page 502 = @errpage;" >> /etc/nginx/conf.d/default.conf
echo "        #}" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_speedtest == 1 ]]; then
echo "    location /${password1}_speedtest/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/speedtest/;" >> /etc/nginx/conf.d/default.conf
echo "        http2_push /${password1}_speedtest/speedtest.js;" >> /etc/nginx/conf.d/default.conf
echo "        http2_push /${password1}_speedtest/favicon.ico;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass   unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_rsshub == 1 ]]; then
echo "    location /${password1}_rsshub/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:1200/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /ttrss/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/tt-rss/;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param modHeadersAvailable true;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param front_controller_active true;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /${password1}_ttrss/cache/ {" >> /etc/nginx/conf.d/default.conf
echo "        deny all;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /${password1}_ttrss/config.php {" >> /etc/nginx/conf.d/default.conf
echo "        deny all;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_aria == 1 ]]; then
echo "    location $ariapath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6800/jsonrpc;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_qbt == 1 ]]; then
echo "    location $qbtpath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass              http://127.0.0.1:8080/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header        X-Forwarded-Host        \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_file == 1 ]]; then
echo "    location $filepath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8081/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_i2p == 1 ]]; then
echo "    location /${password1}_i2p/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:7070/;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_tracker == 1 ]]; then
echo "    location /tracker/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.html;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/tracker/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /tracker_stats/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/announce$ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_netdata == 1 ]]; then
echo "    location ~ $netdatapath(?<ndpath>.*) {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_cache off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Server \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo '        proxy_set_header Connection "keep-alive";' >> /etc/nginx/conf.d/default.conf
echo "        proxy_store off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://netdata/\$ndpath\$is_args\$args;" >> /etc/nginx/conf.d/default.conf
echo "        gzip on;" >> /etc/nginx/conf.d/default.conf
echo "        gzip_proxied any;" >> /etc/nginx/conf.d/default.conf
echo "        gzip_types *;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
echo "}" >> /etc/nginx/conf.d/default.conf
echo "" >> /etc/nginx/conf.d/default.conf
echo "server {" >> /etc/nginx/conf.d/default.conf
echo "    listen 80 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    listen [::]:80 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    server_name $domain;" >> /etc/nginx/conf.d/default.conf
echo "    if (\$http_user_agent ~* (360|Tencent|MicroMessenger|MetaSr|Xiaomi|Maxthon|TheWorld|QQ|UC|OPPO|baidu|Sogou|2345) ) { return 403; }" >> /etc/nginx/conf.d/default.conf
echo "    return 301 https://$domain\$request_uri;" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
echo "" >> /etc/nginx/conf.d/default.conf
if [[ $install_netdata == 1 ]]; then
echo "server { #For Netdata only !" >> /etc/nginx/conf.d/default.conf
echo "    listen 127.0.0.1:81 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    location /stub_status {" >> /etc/nginx/conf.d/default.conf
echo "    access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    stub_status;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/(status|ping)\$ {" >> /etc/nginx/conf.d/default.conf
echo "    access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    allow 127.0.0.1;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "    include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_pass   unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
echo "upstream netdata {" >> /etc/nginx/conf.d/default.conf
echo "    server 127.0.0.1:19999;" >> /etc/nginx/conf.d/default.conf
echo "    keepalive 64;" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
fi
chown -R nginx:nginx /usr/share/nginx/
systemctl restart nginx
}

start(){
  set +e
TERM=ansi whiptail --title "安装中" --infobox "启动Trojan-gfw中..." 7 68
  colorEcho ${INFO} "启动(starting) trojan-gfw ing..."
  systemctl daemon-reload
  if [[ $install_mariadb == 1 ]]; then
    systemctl restart mariadb
  fi
  if [[ $install_file == 1 ]]; then
    systemctl restart filebrowser
  fi
  if [[ $install_rsshub == 1 ]]; then
    systemctl restart rsshub
    systemctl restart rssfeed
  fi
  if [[ $install_trojan == 1 ]]; then
    systemctl restart trojan
    systemctl restart netdata
  fi
}

installhexo(){
TERM=ansi whiptail --title "安装中" --infobox "安装Hexo中..." 7 68
  colorEcho ${INFO} "Install Hexo ing..."
  cd /usr/share/nginx
  npm install -g npm
  npm install hexo-cli -g
  npm update
  hexo init hexo
  cd /usr/share/nginx/hexo
  npm audit fix
  npm prune
  hexo new page ${password1}
  cd /usr/share/nginx/hexo/themes
  git clone https://github.com/theme-next/hexo-theme-next next
  cd /usr/share/nginx/hexo
  npm install hexo-generator-feed --save
  npm i hexo-filter-nofollow --save
    cat > '/usr/share/nginx/hexo/_config.yml' << EOF
#title: xxx's Blog
#author: xxx
language: zh-tw
url: https://${domain}
theme: next
post_asset_folder: true
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content: true
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date
  icon: icon.png
  autodiscovery: true
  template:
nofollow:
  enable: true
  field: site
  exclude:
    - 'exclude1.com'
    - 'exclude2.com'
EOF
cd /usr/share/nginx/hexo/source/${password1}
if [[ -f index.md ]]; then
  rm index.md
fi
cat > "index.md" << EOF
---
title: VPS Toolbox Result
---
Welcome to [VPSToolBox](https://github.com/johnrosen1/vpstoolbox)! This page is generated by [Hexo](https://hexo.io/zh-tw/docs/) and you can ask me on [Telegram](https://t.me/vpstoolbox_chat).

欢迎使用[VPSToolBox](https://github.com/johnrosen1/vpstoolbox) ! 此页面由[Hexo](https://hexo.io/zh-tw/docs/)全自动生成,如果你在使用VPSToolBox时遇到任何问题,请仔细阅读以下所有链接以及信息或者**通过 [Telegram](https://t.me/vpstoolbox_chat)请求支援** !

> *如果你安装的时候没有选择相应的软件，请自行忽略相关内容 ❗*

**以下所有链接以及信息都是有用的，请在提任何问题或者issue前仔细阅读相关内容,否则你的issue将会被立即关闭 ❗**

***⚠️WARNING⚠️请不要自行修改默认配置,除非你知道你在做什么 ❗❗❗***

---

### Trojan-GFW

*默认安装: ✅*

> Introduction: An unidentifiable mechanism that helps you bypass GFW.

PS: ***不支援Cloudflare CDN ❗***

#### Trojan-GFW client config profiles(客户端配置文件)

1. <a href="https://$domain/client1-$password1.json" target="_blank" rel="noreferrer">Profile 1</a>
2. <a href="https://$domain/client2-$password2.json" target="_blank" rel="noreferrer">Profile 2</a>

#### Trojan-GFW Share Links

1. trojan://$password1@$domain:443
2. trojan://$password2@$domain:443

#### Trojan-GFW QR codes(二维码) (不支援python3-qrcode的系统会404!)

1. <a href="https://$domain/$password1.png" target="_blank">QR code 1</a>
2. <a href="https://$domain/$password2.png" target="_blank">QR code 2</a>

#### 相关链接(重要!)

1. <a href="https://github.com/trojan-gfw/igniter/releases" target="_blank" rel="noreferrer">Android client</a> 安卓客户端
2. <a href="https://apps.apple.com/us/app/shadowrocket/id932747118" target="_blank" rel="noreferrer">ios client</a>苹果客户端
3. <a href="https://github.com/trojan-gfw/trojan/releases/latest" target="_blank" rel="noreferrer">windows client</a>windows客户端
4. <a href="https://github.com/NetchX/Netch" target="_blank" rel="noreferrer">https://github.com/NetchX/Netch</a>推荐的**游戏**客户端
5. <a href="https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif" target="_blank" rel="noreferrer">Proxy SwitchyOmega</a>
6. <a href="https://github.com/gfwlist/gfwlist/blob/master/gfwlist.txt" target="_blank" rel="noreferrer">Gfwlist(请配合SwichyOmega食用)</a>

---

### Nextcloud

*默认安装: ❎*

<a href="https://$domain/nextcloud/" target="_blank" rel="noreferrer">https://$domain/nextcloud/</a>
- 用户名(username): **admin**
- 密碼(password): **${password1}**

PS: 推荐自行参考GitHub相关内容修正Nextcloud配置文件。

---

### Hexo

*默认安装: ✅*

> 简介: 快速、簡單且強大的網誌框架。

#### Hexo location

{% blockquote %}
cd /usr/share/nginx/hexo/source/_posts/
{% endblockquote %}

{% blockquote %}
hexo new post title(标题)
{% endblockquote %}

{% blockquote %}
hexo g && hexo d
{% endblockquote %}

#### Docs

1. <a href="https://hexo.io/zh-tw/docs/" target="_blank" rel="noreferrer">Hexo docs</a>
2. <a href="https://www.typora.io" target="_blank" rel="noreferrer">A new way to read & write Markdown</a>

---
### Rsshub + TT-RSS

*默认安装: ❎*

> 简介: RSSHUB + Tiny Tiny RSS。

#### RSSHUB

<a href="https://$domain/${password1}_rsshub/" target="_blank" rel="noreferrer">https://$domain/${password1}_rsshub/</a>

#### Tiny Tiny RSS

- <a href="https://$domain/ttrss/" target="_blank" rel="noreferrer">https://$domain/ttrss/</a>
- 用户名(username): **admin**
- 密碼(password): **password**

> *请自行修改初始密码！*

---

### Qbittorrent Enhanced Version

*默认安装: ❎*

> 简介: 一款用于 **下载bt资源到你的VPS上** 的软件

Introduction: download resources you want to your vps(support bt only but extremely fast)

- <a href="https://$domain$qbtpath" target="_blank" rel="noreferrer">https://$domain$qbtpath</a>
- 用户名(username): admin
- 密碼(password): adminadmin

> *请自行修改初始用户名和密码！*

#### Tips:

1. 请将Bittorrent加密選項改为 ***強制加密(Require encryption)***！
2. 请手动修改Trackers源为 <a href="https://trackerslist.com/all.txt" target="_blank" rel="noreferrer">https://trackerslist.com/all.txt</a>

---

### Aria2

*默认安装: ❎*

> 简介: 将任何你想下载的东西(支援http/https/ftp/bt等,不支援emule/ed2k)**下载到你的VPS**上的软件。

PS: 推荐使用**Ariang**连接(aria2没有官方web interface!)

#### Aria2

- https://$domain:443$ariapath
- 密碼(token): **$ariapasswd**
- **<a href="https://github.com/mayswind/AriaNg/releases" target="_blank" rel="noreferrer">AriaNG</a>**
- <a href="https://play.google.com/store/apps/details?id=com.gianlu.aria2app" target="_blank" rel="noreferrer">Aria2 for Android</a>

---

### Filebrowser

*默认安装: ❎*

> 简介: 一款 **从VPS上下载资源(在aria2/qbt下载完成后)到本地网络** 的软件。

Introduction: download any resources(formaly downloaded by qbt or aria2) from your vps to your local network

#### Filebrowser

- <a href="https://$domain:443$filepath" target="_blank" rel="noreferrer">https://$domain$filepath</a>
- 用户名(username): **admin**
- 密碼(token): **admin**

> *请自行修改初始用户名和密码！*

---

### Speedtest

*默认安装: ❎*

> 简介: 一款 **测试本地网络到VPS的延迟及带宽** 的应用。

Introduction: test download and upload speed from vps to your local network.

#### Speedtest

- <a href="https://$domain:443/${password1}_speedtest/" target="_blank" rel="noreferrer">https://$domain/${password1}_speedtest/</a>

---

### Netdata

*默认安装: ✅*

> 简介: 一款 **实时效能监测工具** 应用。

> Introduction: Open-source, distributed, real-time, performance and health monitoring for systems and applications.

#### Netdata

- <a href="https://$domain:443$netdatapath" target="_blank" rel="noreferrer">https://${domain}${netdatapath}</a>

---

### Rocket Chat

*默认安装: ❎*

> 简介: 聊天应用。

Introduction: just like discord.

- <a href="https://$domain:443/rocketchat/" target="_blank" rel="noreferrer">https://$domain/rocketchat/</a>

---

### Tor Service

*默认安装: ❎*

> 简介: 自建的onion站点。

> Introduction: self-build onion site.

${torhostname}

---

### i2p Service

*默认安装: ❎*

> 简介: 自建的i2p站点。

> Introduction: self-build onion site.

- <a href="https://$domain:443/${password1}_i2p/" target="_blank" rel="noreferrer">https://$domain/${password1}_i2p/</a>

---

### Mail Service

*默认安装: ❎*

***⚠️WARNING⚠️请不要自行修改任何邮件配置,除非你知道你在做什么 ❗❗❗***

> 简介: 邮件软件。

> Introduction: Mail Service

PS: 不支援自定义证书,仅支援全自动申请的let证书!

#### Roundcube Webmail

- <a href="https://${domain}/${password1}_webmail/" target="_blank" rel="noreferrer">Roundcube Webmail</a>
- 用户名(username): **${mailuser}**
- 密碼(password): **${password1}**
- 收件地址: **${mailuser}@${domain}**

#### Tips:

1. 阿里云，gcp等厂商默认不开放25(包括对外访问)端口，不能发邮件，请注意。
2. 请自行添加SPF(TXT) RECORD: v=spf1 mx ip4:${myip} a ~all
3. 请自行运行sudo cat /etc/opendkim/keys/${domain}/default.txt 来获取生成的DKIM(TXT) RECORD

---

### Bittorrent-trackers

*默认安装: ❎*

> 简介: Bittorrent-tracker , 可作为私人或公开Bt-tracker。

> Introduction: Bittorrent-tracker as private or public.

#### Bittorrent-trackers

udp://$domain:6969/announce

#### Info link

<a href="https://$domain/tracker/" target="_blank" rel="noreferrer">https://$domain/tracker/</a>

#### Tips:

1. 请手动将此Tracker添加于你的BT客户端中，发布种子时记得填上即可。
2. 请记得将此Tracker分享给你的朋友们。

---

### MariaDB

*默认安装: ❎*

> 简介: MariaDB 数据库。

> Introduction: MariaDB Database.

无默认root密码,为了安全起见,外网访问已禁用,请直接使用以下命令访问数据库！

{% blockquote %}
mysql -u root
{% endblockquote %}

如果需要外网访问,请自行注释掉/etc/mysql/my.cnf中的bind-address选项并重启mariadb！

Please edit /etc/mysql/my.cnf and restart mariadb if you need remote access !

---

### 相关链接

##### Qbt相关链接

1. <a href="https://www.qbittorrent.org/download.php" target="_blank" rel="noreferrer">win等平台下载页面</a>
2. <a href="https://github.com/qbittorrent/qBittorrent" target="_blank" rel="noreferrer">Github页面</a>
3. <a href="https://play.google.com/store/apps/details?id=com.lgallardo.qbittorrentclientpro" target="_blank" rel="noreferrer">Android远程操控客户端</a>
4. <a href="https://www.qbittorrent.org/" target="_blank" rel="noreferrer">https://www.qbittorrent.org/</a>
1. <a href="https://thepiratebay.org/" target="_blank" rel="noreferrer">https://thepiratebay.org/</a>
2. <a href="https://sukebei.nyaa.si/" target="_blank" rel="noreferrer">https://sukebei.nyaa.si/</a></li>
3. <a href="https://rarbgprx.org/torrents.php" target="_blank" rel="noreferrer">https://rarbgprx.org/torrents.php</a>

##### Rsshub相关链接

1. <a href="https://docs.rsshub.app/" target="_blank" rel="noreferrer">RSSHUB docs</a>
2. <a href="https://github.com/DIYgod/RSSHub-Radar" target="_blank" rel="noreferrer">RSSHub Radar</a>(推荐自行将默认的rsshub.app换成上述自建的)
3. <a href="https://docs.rsshub.app/social-media.html" target="_blank" rel="noreferrer">RSSHUB路由</a>
4. <a href="https://wzfou.com/tt-rss/" target="_blank" rel="noreferrer">自建RSS阅读器Tiny Tiny RSS安装和配置自动更新</a>(仅供参考 !)

*[提问的智慧](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md)*

##### Aria相关链接

1. <a href="https://github.com/aria2/aria2" target="_blank" rel="noreferrer">https://github.com/aria2/aria2</a>
2. <a href="https://aria2.github.io/manual/en/html/index.html" target="_blank" rel="noreferrer">https://aria2.github.io/manual/en/html/index.html</a> 官方文档

##### Filebrowser相关链接

1. <a href="https://github.com/filebrowser/filebrowser" target="_blank" rel="noreferrer">https://github.com/filebrowser/filebrowser</a>
2. <a href="https://filebrowser.xyz/" target="_blank" rel="noreferrer">https://filebrowser.xyz/</a>


##### Speedtest相关链接

1. <a href="https://github.com/librespeed/speedtest" target="_blank" rel="noreferrer">https://github.com/librespeed/speedtest</a>

##### Netdata相关链接

1. <a href="https://play.google.com/store/apps/details?id=com.kpots.netdata" target="_blank" rel="noreferrer">https://play.google.com/store/apps/details?id=com.kpots.netdata</a>安卓客户端
2. <a href="https://github.com/netdata/netdata" target="_blank" rel="noreferrer">https://github.com/netdata/netdata</a>

##### Mail服务相关链接

1. <a href="https://www.mail-tester.com/" target="_blank" rel="noreferrer">https://www.mail-tester.com/</a>
2. <a href="https://lala.im/6838.html" target="_blank" rel="noreferrer">Debian10使用Postfix+Dovecot+Roundcube搭建邮件服务器</a>(仅供参考!)
EOF
cd
hexo_location=$(which hexo)
    cat > '/etc/systemd/system/hexo.service' << EOF
[Unit]
Description=Hexo Server Service
Documentation=https://hexo.io/zh-tw/docs/
After=network.target

[Service]
WorkingDirectory=/usr/share/nginx/hexo
ExecStart=${hexo_location} server -i 127.0.0.1
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable hexo
systemctl restart hexo
}

sharelink(){
  set +e
  cd
  clear
  if [[ $install_trojan = 1 ]]; then
    curl -LO --progress-bar https://github.com/trojan-gfw/trojan-url/raw/master/trojan-url.py
    chmod +x trojan-url.py
  cat > "/usr/share/nginx/client1.json" << EOF
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "$domain",
  "remote_port": ${trojanport},
  "password": [
    "$password1"
  ],
  "log_level": 1,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "",
    "cipher": "$cipher_client",
    "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
    "sni": "",
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "reuse_session": true,
    "session_ticket": false,
    "curves": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "fast_open": false,
    "fast_open_qlen": 20
  }
}
EOF
  cat > "/usr/share/nginx/client2.json" << EOF
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "$domain",
  "remote_port": ${trojanport},
  "password": [
    "$password2"
  ],
  "log_level": 1,
  "ssl": {
    "verify": true,
    "verify_hostname": true,
    "cert": "",
    "cipher": "$cipher_client",
    "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
    "sni": "",
    "alpn": [
      "h2",
      "http/1.1"
    ],
    "reuse_session": true,
    "session_ticket": false,
    "curves": ""
  },
  "tcp": {
    "no_delay": true,
    "keep_alive": true,
    "reuse_port": false,
    "fast_open": false,
    "fast_open_qlen": 20
  }
}
EOF
  ./trojan-url.py -q -i /usr/share/nginx/client1.json -o /usr/share/nginx/html/$password1.png
  ./trojan-url.py -q -i /usr/share/nginx/client2.json -o /usr/share/nginx/html/$password2.png
  rm /usr/share/nginx/client1.json
  rm /usr/share/nginx/client2.json
  rm -rf trojan-url.py
  fi
}

uninstall(){
  set +e
  cd
  if [[ -f /usr/local/bin/trojan ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) trojan?" 8 68); then
    systemctl stop trojan
    systemctl disable trojan
    rm -rf /etc/systemd/system/trojan*
    rm -rf /usr/local/etc/trojan/*
    rm -rf /root/.trojan/autoupdate.sh
    fi
  fi
  if [[ -f /usr/sbin/nginx ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) nginx?" 8 68); then
    systemctl stop nginx
    systemctl disable nginx
    apt-get -y remove nginx
    rm -rf /etc/apt/sources.list.d/nginx.list
    rm -rf /usr/share/nginx/html/
    fi
  fi
  if [[ -f /usr/sbin/dnscrypt-proxy ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) dnscrypt-proxy?" 8 68); then
      systemctl stop dnscrypt-proxy
      systemctl disable dnscrypt-proxy
      rm -rf /usr/sbin/dnscrypt-proxy
      rm /etc/systemd/system/dnscrypt-proxy.service
      echo "nameserver 1.1.1.1" >> /etc/resolv.conf
      iptables -t nat -F
    fi
  fi
  if [[ -f /usr/bin/qbittorrent-nox ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) qbittorrent?" 8 68); then
    systemctl stop qbittorrent
    systemctl disable qbittorrent
    apt-get -y remove qbittorrent-nox
    rm /etc/systemd/system/qbittorrent.service
    fi
  fi
  if [[ -f /usr/bin/bittorrent-tracker ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) bittorrent-tracker?" 8 68); then
    systemctl stop tracker
    systemctl disable tracker
    rm -rf /usr/bin/bittorrent-tracker
    rm /etc/systemd/system/tracker.service
    fi
  fi
  if [[ -f /usr/local/bin/aria2c ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) aria2?" 8 68); then
    systemctl stop aria
    systemctl disable aria
    rm -rf /etc/aria.conf
    rm -rf /usr/local/bin/aria2c
    rm /etc/systemd/system/aria2.service
    fi
  fi
  if [[ -f /usr/local/bin/filebrowser ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) filebrowser?" 8 68); then
    systemctl stop filebrowser
    systemctl disable filebrowser
    rm /usr/local/bin/filebrowser
    rm /etc/systemd/system/filebrowser.service
    fi
  fi
  if [[ -f /usr/bin/tor ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) tor?" 8 68); then
    systemctl stop tor
    systemctl disable tor
    systemctl stop tor@default
    apt-get -y remove tor
    rm -rf /etc/apt/sources.list.d/tor.list
    fi
  fi
  if [[ -f /opt/netdata/usr/sbin/netdata ]]; then
    if (whiptail --title "api" --yesno "卸载 (uninstall) Netdata?" 8 68); then
    systemctl stop netdata
    systemctl disable netdata
    fi
  fi
  if (whiptail --title "api" --yesno "卸载 (uninstall) acme.sh?" 8 68); then
    ~/.acme.sh/acme.sh --uninstall
  fi
  rm -rf /root/.trojan/
  apt-get update
  systemctl daemon-reload
  colorEcho ${INFO} "卸载完成"
}

autoupdate(){
  set +e
  if [[ $install_trojan == 1 ]]; then
cat > '/root/.trojan/autoupdate.sh' << EOF
#!/bin/bash
apt-get update
apt-get upgrade -y
trojanversion=\$(curl -fsSL https://api.github.com/repos/trojan-gfw/trojan/releases/latest | grep tag_name | sed -E 's/.*"v(.*)".*/\1/')
/usr/local/bin/trojan -v &> /root/.trojan/trojan_version.txt
if cat /root/.trojan/trojan_version.txt | grep \$trojanversion > /dev/null; then
    echo "no update required" >> /root/.trojan/update.log
    else
    echo "update required" >> /root/.trojan/update.log
    wget -q https://github.com/trojan-gfw/trojan/releases/download/v\$trojanversion/trojan-\$trojanversion-linux-amd64.tar.xz
    tar -xf trojan-\$trojanversion-linux-amd64.tar.xz
    rm -rf trojan-\$trojanversion-linux-amd64.tar.xz
    cd trojan
    chmod +x trojan
    cp -f trojan /usr/local/bin/trojan
    systemctl restart trojan
    cd
    rm -rf trojan
    echo "Update complete" >> /root/.trojan/update.log
fi
EOF
touch /root/.trojan/update.log
crontab -l > mycron
echo "0 0 1 * * bash /root/.trojan/autoupdate.sh >> /root/.trojan/update.log 2>&1" >> mycron
crontab mycron
rm mycron
  fi
}

logcheck(){
  set +e
  readconfig
  clear
  if [[ -f /usr/local/bin/trojan ]]; then
    colorEcho ${INFO} "Trojan Log"
    journalctl -a -u trojan.service
    less /root/.trojan/update.log
  fi
  if [[ -f /usr/sbin/dnscrypt-proxy ]]; then
    colorEcho ${INFO} "dnscrypt-proxy Log"
    journalctl -a -u dnscrypt-proxy.service
  fi
  if [[ -f /usr/local/bin/aria2c ]]; then
    colorEcho ${INFO} "Aria2 Log"
    less /var/log/aria2.log
  fi
  colorEcho ${INFO} "Nginx Log"
  less /var/log/nginx/error.log
  less /var/log/nginx/access.log
}

advancedMenu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用VPSTOOLBOX。有關錯誤報告或更多信息，請訪問以下鏈接: https://github.com/johnrosen1/vpstoolbox 或者 https://t.me/vpstoolbox_chat。" --title "VPS ToolBox Menu" --menu --nocancel "Welcome to VPS Toolbox main menu,Please Choose an option 欢迎使用VPSTOOLBOX,请选择一个选项" 14 68 5 \
  "Install/Update" "安裝/更新/覆盖安装" \
  "Benchmark" "效能测试"\
  "Log" "日志" \
  "Uninstall" "卸載" \
  "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Install/Update)
    clear
    install_status="$( jq -r '.installed' "/root/.trojan/config.json" )"
    if [[ $install_status != 1 ]]; then
    cp /etc/resolv.conf /etc/resolv.conf.bak1
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    echo "nameserver 1.0.0.1" >> /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /etc/resolvconf/resolv.conf.d/base
    echo "nameserver 1.0.0.1" >> /etc/resolvconf/resolv.conf.d/base
    echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base
    resolvconf -u
    #predefine install options
      check_trojan="on"
      check_dns="off"
      check_rss="off"
      check_qbt="off"
      check_aria="off"
      check_file="off"
      check_speed="off"
      check_mariadb="off"
      check_fail2ban="off"
      check_mail="off"
      check_qbt_origin="off"
      check_tracker="off"
      check_cloud="off"
      prasejson
      if [[ $(systemctl is-active caddy) == active ]]; then
      systemctl stop caddy
      systemctl disable caddy
      fi
      if [[ $(systemctl is-active apache2) == active ]]; then
      systemctl stop apache2
      systemctl disable apache2
      fi
      if [[ $(systemctl is-active httpd) == active ]]; then
      systemctl stop httpd
      systemctl disable httpd
      fi
    fi
    userinput
    prasejson
    if [[ ${install_ddns} == 1 ]]; then
    install_ddns
    fi
    #检测是否为自定义证书
    if [ -f /etc/trojan/*.crt ] && [ -f /etc/trojan/*.key ]; then
      othercert=1
      cp /etc/trojan/*.crt /etc/trojan/trojan.crt
      cp /etc/trojan/*.key /etc/trojan/trojan.key
      apt-get install gnutls-bin -y
      openfirewall
      certtool -i < /etc/trojan/trojan.crt --verify --verify-hostname=${domain}
      if [[ $? != 0 ]]; then
        whiptail --title "ERROR" --msgbox "无效的自定义证书,可能为自签,过期或者域名不正确,启动证书覆写" 8 68
        rm -rf /etc/trojan/trojan.crt
        rm -rf /etc/trojan/trojan.key
        othercert=0
        fi
    fi
    curl -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ip.json
    myip="$( jq -r '.ip' "/root/.trojan/ip.json" )"
    localip=$(ip -4 a | grep inet | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
    myipv6=$(ip -6 a | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
    if [[ -n ${myipv6} ]]; then
    curl -s https://ipinfo.io/${myipv6}?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ipv6.json
    fi
    #检测证书是否已有

    if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
      apt-get install gnutls-bin -y
      openfirewall
      certtool -i < /etc/certs/${domain}_ecc/fullchain.cer --verify --verify-hostname=${domain}
      if [[ $? != 0 ]]; then
        whiptail --title "ERROR" --msgbox "无效的证书,可能过期或者域名不正确,启动证书续签程序" 8 68
        /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1
        fi
        crontab -l | grep acme.sh
        if [[ $? != 0 ]]; then
        colorEcho ${INFO} "CRON(证书续签模块)缺失,添加中..."
        crontab -l > mycron
        echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
        crontab mycron
        rm mycron        
        fi
    fi

    if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]] || [[ ${othercert} == 1 ]]; then
      colorEcho ${INFO} "证书已有,跳过申请(skipping cert issue)"
      else
        if (whiptail --title "Issue TLS Cert" --yes-button "HTTP申请" --no-button "DNS API申请" --yesno "使用 (use) API/HTTP申请证书(to issue certificate)?" 8 68); then
        httpissue=1
        else
        dnsissue
        fi
      fi
    TERM=ansi whiptail --title "开始安装" --infobox "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!" 7 68
    colorEcho ${INFO} "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!"
    upgradesystem
    if [[ ${httpissue} == 1 ]]; then
      httpissue
    fi
    systeminfo
    installdependency
    if [[ $install_mariadb == 1 ]]; then
      install_mariadb
    fi
    if [[ $install_redis == 1 ]]; then
      installredis
    fi
    if [[ $install_nextcloud == 1 ]]; then
      installnextcloud
    fi
    if [[ $install_i2p == 1 ]]; then
      install_i2pd
    fi
    if [[ ${install_stun} == 1 ]]; then
    installstunserver
    fi
    if [[ ${install_tjp} == 1 ]]; then
    install_tjp
    fi
    if [[ ${install_chat} == 1 ]]; then
    install_rocketchat
    fi
    installhexo
    nginxtrojan
    start
    sharelink
    rm results
    prasejson
    autoupdate
    apt-get purge python-pil python3-qrcode -q -y
    apt-get autoremove -y
    if [[ $install_netdata = 1 ]]; then
    #wget -O /opt/netdata/etc/netdata/netdata.conf http://127.0.0.1:19999/netdata.conf
    #sed -i 's/# bind to = \*/bind to = 127.0.0.1/g' /opt/netdata/etc/netdata/netdata.conf
    cd /opt/netdata/bin
    bash netdata-claim.sh -token=llFcKa-42N035f4WxUYZ5VhSnKLBYQR9Se6HIrtXysmjkMBHiLCuiHfb9aEJmXk0hy6V_pZyKMEz_QN30o2s7_OsS7sKEhhUTQGfjW0KAG5ahWhbnCvX8b_PW_U-256otbL5CkM -rooms=38e38830-7b2c-4c34-a4c7-54cacbe6dbb9 -url=https://app.netdata.cloud &>/dev/null
    cd
    fi
    if [[ ${dnsmasq_install} == 1 ]]; then
      if [[ ${dist} = ubuntu ]]; then
        systemctl stop systemd-resolved
        systemctl disable systemd-resolved
      fi
      if [[ $(systemctl is-active dnsmasq) == active ]]; then
        systemctl stop dnsmasq
      fi
    rm /etc/resolv.conf
    touch /etc/resolv.conf
    echo "nameserver 127.0.0.1" > '/etc/resolv.conf'
    echo "" >> /etc/hosts
    echo "$(jq -r '.ip' "/root/.trojan/ip.json") ${domain}" >> /etc/hosts
    systemctl restart dnscrypt-proxy
    #iptables -t nat -I OUTPUT ! -d 127.0.0.1/32 -p udp -m udp --dport 53 -j DNAT --to 127.0.0.1:53
    #ip6tables -t nat -I OUTPUT ! -d ::1 -p udp -m udp --dport 53 -j DNAT --to [::1]:53
    iptables-save > /etc/iptables/rules.v4
    fi
    clear
    cat > '/etc/profile.d/mymotd.sh' << EOF
#!/usr/bin/env bash
#!!! Do not change these settings unless you know what you are doing !!!
bold=\$(tput bold)
normal=\$(tput sgr0)
# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
###
domain="$( jq -r '.domain' "/root/.trojan/config.json" )"
password1="$( jq -r '.password1' "/root/.trojan/config.json" )"
password2="$( jq -r '.password2' "/root/.trojan/config.json" )"
neofetch
echo -e " --- 如果您想要关闭本报告，请使用以下命令"
echo -e " --- mv /etc/profile.d/mymotd.sh /etc/"
echo -e " --- 再次启用 mv /etc/mymotd.sh /etc/profile.d/mymotd.sh"
echo -e " --- \${BLUE}IP信息(IP Information)\${NOCOLOR} ---"
echo -e "ip:\t\t"\$(jq -r '.ip' "/root/.trojan/ip.json")
echo -e "city:\t\t"\$(jq -r '.city' "/root/.trojan/ip.json")
echo -e "region:\t\t"\$(jq -r '.region' "/root/.trojan/ip.json")
echo -e "country:\t"\$(jq -r '.country' "/root/.trojan/ip.json")
#echo -e "loc:\t\t"\$(jq -r '.loc' "/root/.trojan/ip.json")
echo -e "org:\t\t"\$(jq -r '.org' "/root/.trojan/ip.json")
#echo -e "postal:\t\t"\$(jq -r '.postal' "/root/.trojan/ip.json")
echo -e "timezone:\t"\$(jq -r '.timezone' "/root/.trojan/ip.json")
if [[ -f /root/.trojan/ipv6.json ]]; then
echo -e " --- \${BLUE}IPv6信息(IPv6 Information)\${NOCOLOR} ---"
echo -e "ip:\t\t"\$(jq -r '.ip' "/root/.trojan/ipv6.json")
echo -e "city:\t\t"\$(jq -r '.city' "/root/.trojan/ipv6.json")
echo -e "region:\t\t"\$(jq -r '.region' "/root/.trojan/ipv6.json")
echo -e "country:\t"\$(jq -r '.country' "/root/.trojan/ipv6.json")
#echo -e "loc:\t\t"\$(jq -r '.loc' "/root/.trojan/ipv6.json")
echo -e "org:\t\t"\$(jq -r '.org' "/root/.trojan/ipv6.json")
#echo -e "postal:\t\t"\$(jq -r '.postal' "/root/.trojan/ipv6.json")
echo -e "timezone:\t"\$(jq -r '.timezone' "/root/.trojan/ipv6.json")
fi
echo -e " --- \${BLUE}服務狀態(Service Status)\${NOCOLOR} ---"
  if [[ -f /usr/local/bin/trojan ]]; then
echo -e "Trojan-GFW:\t\t"\$(systemctl is-active trojan)
  fi
  if [[ -f /usr/sbin/nginx ]]; then
echo -e "Nginx:\t\t\t"\$(systemctl is-active nginx)
  fi
  if [[ -f /usr/bin/hexo ]]; then
echo -e "Hexo:\t\t\t"\$(systemctl is-active hexo)
  fi
  if [[ -f /usr/sbin/dnscrypt-proxy ]]; then
echo -e "Dnscrypt-proxy:\t\t"\$(systemctl is-active dnscrypt-proxy)
  fi
  if [[ -f /usr/bin/qbittorrent-nox ]]; then
echo -e "Qbittorrent:\t\t"\$(systemctl is-active qbittorrent)
  fi
  if [[ -f /usr/sbin/opentracker ]]; then
echo -e "Bittorrent-tracker:\t"\$(systemctl is-active tracker)
  fi
  if [[ -f /usr/local/bin/aria2c ]]; then
echo -e "Aria2c:\t\t\t"\$(systemctl is-active aria2)
  fi
  if [[ -f /usr/local/bin/filebrowser ]]; then
echo -e "Filebrowser:\t\t"\$(systemctl is-active filebrowser)
  fi
  if [[ -f /opt/netdata/usr/sbin/netdata ]]; then
echo -e "Netdata:\t\t"\$(systemctl is-active netdata)
  fi
  if [[ -f /usr/bin/dockerd ]]; then
echo -e "Docker:\t\t\t"\$(systemctl is-active docker)
  fi
  if [[ -f /usr/sbin/mysqld ]]; then
echo -e "MariaDB:\t\t"\$(systemctl is-active mariadb)
  fi
  if [[ -f /usr/sbin/php-fpm7.4 ]]; then
echo -e "PHP:\t\t\t"\$(systemctl is-active php7.4-fpm)
  fi
  if [[ -f /usr/sbin/dovecot ]]; then
echo -e "Dovecot:\t\t"\$(systemctl is-active dovecot)
  fi
  if [[ -f /usr/sbin/postfix ]]; then
echo -e "Postfix:\t\t"\$(systemctl is-active postfix)
  fi
  if [[ -f /usr/bin/fail2ban-server ]]; then
echo -e "Fail2ban:\t\t"\$(systemctl is-active fail2ban)
  fi
  if [[ -f /usr/bin/tor ]]; then
echo -e "Tor:\t\t"\$(systemctl is-active tor)
  fi
  if [[ -f /usr/sbin/i2pd ]]; then
echo -e "i2p:\t\t"\$(systemctl is-active i2pd)
  fi
echo -e " --- \${BLUE}帶寬使用(Bandwith Usage)\${NOCOLOR} ---"
echo -e "         接收(Receive)    发送(Transmit)"
tail -n +3 /proc/net/dev | awk '{print \$1 " " \$2 " " \$10}' | numfmt --to=iec --field=2,3
#echo -e " --- \${GREEN}證書狀態(Certificate Status)\${NOCOLOR} ---"
#ssl_date=\$(echo |openssl s_client -connect ${domain}:443 -tls1_3 2>&1 |sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'|openssl x509 -text)
#tmp_last_date=\$(echo "\${ssl_date}" | grep 'Not After :' | awk -F' : ' '{print \$NF}')
#last_date=\$(date -ud "\${tmp_last_date}" +%Y-%m-%d" "%H:%M:%S)
#day_count=\$(( (\$(date -d "\${last_date}" +%s) - \$(date +%s))/(24*60*60) ))
#echo -e "\e[40;33;1m The [${domain}] expiration date is : \${last_date} && [\${day_count} days] \e[0m"
#echo -e "--------------------------------------------------------------------------"
echo -e " --- \${BLUE}Trojan-GFW快速链接\${NOCOLOR}(Trojan links) ---"
echo -e " --- 请在VPS控制面板上彻底禁用防火墙(firewall)以达到最佳效果(allow all ports) ---"
###
echo -e "    \${YELLOW}trojan://$password1@$domain:${trojanport}\${NOCOLOR}"
echo -e "    \${YELLOW}trojan://$password2@$domain:${trojanport}\${NOCOLOR}"
###
if [[ -d /usr/share/nginx/nextcloud/ ]]; then
echo -e " --- \${BLUE}Nextcloud快速链接\${NOCOLOR}(Nextcloud links) ---"
###
echo -e "    \${YELLOW}https://$domain/nextcloud/\${NOCOLOR}"
echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
echo -e "    \${YELLOW}密码: ${password1}\${NOCOLOR}"
###
fi
if [[ -d /usr/share/nginx/trojan-panel/ ]]; then
echo -e " --- \${BLUE}Trojan-panel快速链接\${NOCOLOR}(Trojan-panel links) ---"
###
echo -e "    \${YELLOW}https://$domain/config/\${NOCOLOR}"
#echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
#echo -e "    \${YELLOW}密码: ${password1}\${NOCOLOR}"
###
fi
if [[ -f /usr/bin/tor ]]; then
echo -e " --- \${BLUE}Onion快速链接\${NOCOLOR}(onion link) ---"
echo -e "${torhostname}"
fi
echo -e " --- 請\${bold}訪問以下鏈接\${normal}以獲得更多详细結果(Please visit the following link to get more info) "
echo -e "    \${YELLOW}https://$domain/${password1}/\${NOCOLOR}"
echo -e " --- 有關錯誤報告或更多信息，請訪問以下鏈接"
echo -e " --- https://github.com/johnrosen1/vpstoolbox"
echo -e " --- \${YELLOW}https://t.me/vpstoolbox_chat\${NOCOLOR}"
echo -e "*********************"
EOF
    chmod +x /etc/profile.d/mymotd.sh
    clear
    echo "" > /etc/motd
    echo "Install complete!"
    whiptail --title "Success" --msgbox "安装成功(Install Success),欢迎使用VPSTOOLBOX !" 8 68
    bash /etc/profile.d/mymotd.sh
    exit 0
    ;;
    Benchmark)
    clear
    if (whiptail --title "测试模式" --yes-button "快速测试" --no-button "完整测试" --yesno "效能测试方式(fast or full)?" 8 68); then
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
        else
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s full
    fi
    exit 0
    ;;
    Log)
    clear
    logcheck
    exit 0
    ;;
    Uninstall)
    clear
    uninstall
    colorEcho ${SUCCESS} "Remove complete"
    exit 0
    ;;
    Exit)
    whiptail --title "Bash Exited" --msgbox "Goodbye" 8 68
    exit 0
    ;;
    esac
}

sshoptimize(){
if grep -q "DebianBanner" /etc/ssh/sshd_config
then
:
else
ssh-keygen -A
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/^HostKey \/etc\/ssh\/ssh_host_\(dsa\|ecdsa\)_key$/\#HostKey \/etc\/ssh\/ssh_host_\1_key/g' /etc/ssh/sshd_config
#sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/g' /etc/ssh/sshd_config
sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config
sed -i 's/#PermitTunnel no/PermitTunnel no/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/#GatewayPorts no/GatewayPorts no/' /etc/ssh/sshd_config
#sed -i 's/#StrictModes yes/StrictModes yes/' /etc/ssh/sshd_config
sed -i 's/#AllowAgentForwarding yes/AllowAgentForwarding no/' /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/' /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config
#echo "Protocol 2" >> /etc/ssh/sshd_config
echo "DebianBanner no" >> /etc/ssh/sshd_config
#echo "AllowStreamLocalForwarding no" >> /etc/ssh/sshd_config
systemctl reload sshd
fi
}

enablebbr(){
if [[ $install_bbr == 1 ]]; then
  TERM=ansi whiptail --title "初始化中" --infobox "启动BBR中..." 7 68
  colorEcho ${INFO} "Enabling TCP-BBR boost"
  modprobe ip_conntrack
  cat > '/etc/sysctl.d/99-sysctl.conf' << EOF
#!!! Do not change these settings unless you know what you are doing !!!
#net.ipv4.conf.all.route_localnet=1
#net.ipv4.ip_forward = 1
#net.ipv4.conf.all.forwarding = 1
#net.ipv4.conf.default.forwarding = 1
################################
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.lo.forwarding = 1
################################
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
################################
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
################################
net.core.netdev_max_backlog = 100000
net.core.netdev_budget = 50000
net.core.netdev_budget_usecs = 5000
#fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 67108864
net.core.wmem_default = 67108864
net.core.optmem_max = 65536
net.core.somaxconn = 10000
################################
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.ip_local_port_range = 10000 65001
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
net.ipv4.tcp_mtu_probing = 0
##############################
net.ipv4.conf.all.arp_ignore = 2
net.ipv4.conf.default.arp_ignore = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.default.arp_announce = 2
##############################
net.ipv4.tcp_autocorking = 0
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_max_syn_backlog = 30000
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_ecn_fallback = 1
net.ipv4.tcp_frto = 0
##############################
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
vm.swappiness = 1
vm.overcommit_memory = 1
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv4.neigh.default.gc_thresh2=4096
net.ipv4.neigh.default.gc_thresh1=2048
net.ipv6.neigh.default.gc_thresh3=8192
net.ipv6.neigh.default.gc_thresh2=4096
net.ipv6.neigh.default.gc_thresh1=2048
net.ipv4.tcp_max_syn_backlog = 262144
net.netfilter.nf_conntrack_max = 262144
net.nf_conntrack_max = 262144
EOF
  sysctl --system
  echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
  cat > '/etc/systemd/system.conf' << EOF
[Manager]
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=30s
#DefaultRestartSec=100ms
DefaultLimitCORE=infinity
DefaultLimitNOFILE=51200
DefaultLimitNPROC=51200
EOF
    cat > '/etc/security/limits.conf' << EOF
* soft nofile 51200
* hard nofile 51200
* soft nproc 51200
* hard nproc 51200
EOF
if grep -q "ulimit" /etc/profile
then
  :
else
echo "ulimit -SHn 51200" >> /etc/profile
echo "ulimit -SHu 51200" >> /etc/profile
fi
if grep -q "pam_limits.so" /etc/pam.d/common-session
then
  :
else
echo "session required pam_limits.so" >> /etc/pam.d/common-session
fi
systemctl daemon-reload
fi
}
clear
cd
initialize
#sshoptimize
setlanguage
clear
advancedMenu
