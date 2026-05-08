#!/bin/bash

# Переменная для нового пользователя
NEW_USER="mynewuser"

# Переменная для нового порта SSH
NEW_SSH_PORT="2222"

# Обновляем систему
echo ""
echo "Updating system..."
sudo apt update && sudo apt full-upgrade -y

# Устанавливаем необходимые пакеты
echo ""
echo "Installing required packages..."
sudo apt install unattended-upgrades ufw -y

# Настраиваем SSH
echo ""
echo "Configuring SSH..."
sudo sed -i 's/^PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i "s/^Port.*$/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
sudo service ssh restart

# Настраиваем Firewall (UFW)
echo ""
echo "Configuring Firewall (UFW)..."
sudo ufw default deny incoming
sudo ufw allow "$NEW_SSH_PORT"/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Создаем нового пользователя
echo ""
echo "Creating new user '$NEW_USER'..."
echo "Please enter the following details:"
echo "- Username: $NEW_USER"
echo "- Password: (will be prompted)"
echo "- Full Name: (optional)"
echo "- Room Number: (optional)"
echo "- Work Phone: (optional)"
echo "- Home Phone: (optional)"
echo "- Other: (optional)"

read -sp "Enter password for $NEW_USER: " PASSWORD
echo ""

sudo adduser "$NEW_USER" << EOF
$PASSWORD
$PASSWORD
test
EOF

# Автоматические обновления
echo ""
echo "Enabling automatic updates..."
sudo dpkg-reconfigure -plow unattended-upgrades

# Завершение
echo ""
echo "Security setup completed successfully!"
sleep 5

# Самоудаление скрипта после выполнения
rm -- "$0"
