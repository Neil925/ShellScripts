EFFECTS=($(ps -e | grep easyeffects))
PID=${EFFECTS[0]}

kill $PID

systemctl --user restart pipewire-pulse
systemctl --user restart pipewire