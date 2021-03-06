#!/user/env/bin bash

usermod --add-subuids 165536-231072 --add-subgids 165536-231072 "$(whoami)"

echo "$(whoami):100000:65536" | sudo tee /etc/subuid
echo "$(whomai):100000:65536" | sudo tee /etc/subgid

