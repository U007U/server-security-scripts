#!/bin/bash# еременная для нового пользователя
NEW_USER=""mynewuser""

# еременная для нового порта SSH
NEW_SSH_PORT=""2222""

# бновляем систему
echo ""Updating system...""
sudo apt update && sudo apt full-upgrade -y

# станавливаем необходимые пакеты
echo ""Installing required packages...""
sudo apt install unattended-upgrades ufw -y

# астраиваем SSH
echo ""Configuring SSH...""
sudo sed -i 's/^PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i ""s/^Port.*$/Port /"" /etc/ssh/sshd_config
sudo service ssh restart

# астраиваем Firewall (UFW)
echo ""Configuring Firewall (UFW)...""
sudo ufw default deny incoming
sudo ufw allow """"/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Создаем нового пользователя
echo ""Creating new user ''...""
sudo adduser """"
sudo usermod -aG sudo """"

# втоматические обновления
echo ""Enabling automatic updates...""
sudo dpkg-reconfigure -plow unattended-upgrades

# авершение
echo ""Security setup completed!""
