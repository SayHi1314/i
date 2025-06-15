#!/bin/bash

Xvfb :99 -ac -screen 0 1280x1024x24 &
export DISPLAY=:99
fluxbox &
rm -f /var/run/xrdp/xrdp.pid
# 修改 xrdp.ini 中的监听端口
if [ -n "$XRDP_PORT" ]; then
  sed -i "/^\[Globals\]/,/^\[/ s/^port=.*/port=${XRDP_PORT}/" /etc/xrdp/xrdp.ini
fi
# 启动 xrdp 服务
service xrdp start
x11vnc -display :99 -nopw -forever
# 保持容器运行（或启动你需要的服务）

