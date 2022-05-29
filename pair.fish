set -x DISPLAY :0

Xephyr -ac -screen 2510x1340 :99 &

set -x DISPLAY :99
sleep 1
awesome -c ~/repos/misc/awesome/rc.lua &
xfce4-terminal &
