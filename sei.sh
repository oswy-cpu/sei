#!/bin/bash

echo "=================================================="

echo -e "\e[1m\e[32m1. Записываю переменные \e[0m" && sleep 1
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=atlantic-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo "=================================================="

echo -e "\e[1m\e[32m2. Введите ваш моникер (имя ноды) \e[0m"
read -p "Address: " NODE_NAME

echo "=================================================="

echo -e "\e[1m\e[32m3. Введите ваш email \e[0m"
read -p "Address: " EMAIL

echo "=================================================="

echo -e "\e[1m\e[92m Moniker: \e[0m" $NODE_NAME
echo -e "\e[1m\e[92m EMAIL: \e[0m" $EMAIL

echo "=================================================="

echo -e "\e[1m\e[32m4. Обновляю пакеты \e[0m" && sleep 1
sudo apt update && sudo apt upgrade -y

echo "=================================================="

echo -e "\e[1m\e[32m5. Устанавливаю зависимости \e[0m" && sleep 1
sudo apt-get install make build-essential gcc git jq chrony -y

echo "=================================================="

echo -e "\e[1m\e[32m6. Устанавливаю GO \e[0m" && sleep 1
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile

echo "=================================================="

echo -e "\e[1m\e[32m7. Устанавливаю SEI NODE \e[0m" && sleep 1
cd $HOME
git clone https://github.com/sei-protocol/sei-chain.git && cd $HOME/sei-chain
git checkout 1.0.6beta
make install
sleep 10
seid config chain-id $CHAIN_ID
seid config keyring-backend test
sleep 10
seid init $NODE_NAME --chain-id $CHAIN_ID
sleep 5 
seid keys add $WALLET
sleep 5
WALLET_ADDRESS=$(seid keys show $WALLET -a)
seid add-genesis-account $WALLET_ADDRESS 10000000usei

echo "=================================================="

echo -e "\e[1m\e[32mЗапишите mnemonic фразу, которая находится выше \e[0m" && sleep 1

echo "=================================================="

echo -e "\e[1m\e[32m8. Генерирую GENTX \e[0m" && sleep 1
seid gentx $WALLET 10000000usei \
--chain-id $CHAIN_ID \
--moniker=$NODE_NAME \
--commission-max-change-rate=0.01 \
--commission-max-rate=0.20 \
--commission-rate=0.05 \
--details="-" \
--security-contact="$EMAIL" \
--website="-"

echo "=================================================="

echo -e "\e[1m\e[32mКопируйте GENTX, который находится ниже \e[0m" && sleep 1
cat ~/.sei/config/gentx/gentx-*

echo "=================================================="
