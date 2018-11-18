#!/bin/bash
torrentid=$1
torrentname=$2
torrentpath=$3

##############################################################
# Define these vars to the path where they are located
##############################################################
# deluge-console位置
dc=/usr/bin/deluge-console

# XMR-RPC路徑
xmlrpc=/usr/bin/xmlrpc
xmlrpc_endpoint=127.0.0.1
xmlrpc_command="${xmlrpc} ${xmlrpc_endpoint}"

# Racing Mode，設定之rtorren上傳速限(KB/s)，建議設定大於1024KB/s
Racing_limit_upspeed=20480

##############################################################

# 獲取Tracker資訊
tracker_line=$($dc info $torrentid | grep "^Tracker" | awk -F: '{print $2}' | tr -d " ")

# 特定Tracker執行腳本，執行rtorrent限速腳本
case "$tracker_line" in
  *flacsfor*|*hdbits*|*dmhy*|*passthepopcorn*)
#    $xmlrpc_command throttle.global_up.max_rate.set_kb "" $Racing_limit_upspeed

# 如果當前限速比設定速限高時，將速限減半
    global_up_max_rate=$($xmlrpc_command throttle.global_up.max_rate | grep integer | awk -F "64-bit integer: " '{print $2}')
    let max_rate = global_up_max_rate/1024
    if [ $max_rate = 0 ] || [ $max_rate -gt $Racing_limit_upspeed ]; then
       $xmlrpc_command throttle.global_up.max_rate.set_kb "" $Racing_limit_upspeed
       echo $(date +"%Y-%m-%d %H:%M:%S") >> ~/rtspeed.log
       echo "Start Torrent: $torrentname($torrentid)" >> ~/rtspeed.log	 
       echo "rTorrent global upload speed: $Racing_limit_upspeed KB/s" >> ~/rtspeed.log	
    else
       let Racing_Mode_limit2_upspeed = max_rate/2
       $xmlrpc_command throttle.global_up.max_rate.set_kb "" $Racing_Mode_limit2_upspeed
       echo $(date +"%Y-%m-%d %H:%M:%S") >> ~/rtspeed.log
       echo "Start Torrent: $torrentname($torrentid)" >> ~/rtspeed.log	 
       echo "rTorrent global upload speed: $Racing_Mode_limit2_upspeed KB/s" >> ~/rtspeed.log	
    fi
    ;;
esac
exit 0
