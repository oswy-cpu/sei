#!/bin/bash

echo "=================================================="

echo -e "\e[1m\e[32m1. Качаю генезис \e[0m" && sleep 1
wget -O $HOME/.sei/config/genesis.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-incentivized-testnet/genesis.json"
seid tendermint unsafe-reset-all --home $HOME/.sei

echo "=================================================="

echo -e "\e[1m\e[32m2. Качаю addrbook \e[0m" && sleep 1
wget -O $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/sei-protocol/testnet/master/sei-incentivized-testnet/addrbook.json"

echo "=================================================="

echo -e "\e[1m\e[32m3. Настраиваю конфиг \e[0m" && sleep 1
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025usei\"/;" ~/.sei/config/app.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.sei/config/config.toml

echo "=================================================="

echo -e "\e[1m\e[32m4. Добавляю пиры \e[0m" && sleep 1
peers="e3b5da4caea7370cd85d7738eedaec8f56c5be28@144.76.224.246:36656,a37d65086e78865929ccb7388146fb93664223f7@18.144.13.149:26656,8ff4bd654d7b892f33af5a30ada7d8239d6f467b@91.223.3.190:51656,c4e8c9b1005fe6459a922f232dd9988f93c71222@65.108.227.133:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.sei/config/config.toml
seeds=""
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.sei/config/config.toml
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 100/g' $HOME/.sei/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 100/g' $HOME/.sei/config/config.toml

echo "=================================================="

echo -e "\e[1m\e[32m5. Создаю сервисный файл \e[0m" && sleep 1

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=seid
After=network-online.target

[Service]
User=$USER
ExecStart=$(which seid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/seid.service

echo "=================================================="

echo -e "\e[1m\e[32m5. Оптимизирую \e[0m" && sleep 1

wget -qO optimize-configs.sh "https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-testnet-2/optimize-configs.sh"
sudo chmod +x optimize-configs.sh && ./optimize-configs.sh
sudo systemctl restart seid

mv $HOME/seid* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable seid
sudo systemctl restart seid
sleep 20
echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service seid status | grep active` =~ "running" ]]; then
  echo -e "Your Sei node \e[32minstalled and works\e[39m!"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Sei node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
