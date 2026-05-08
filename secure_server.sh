#!/bin/bash

# Переменная для нового пользователя
NEW_USER="mynewuser"

# Переменная для нового порта SSH
NEW_SSH_PORT="2222"

# Выбор языка
LANGUAGE=""

while true; do
    read -rp "Выберите язык (рус/eng): " lang
    case $lang in
        рус )
            LANGUAGE="rus"
            break;;
        eng )
            LANGUAGE="eng"
            break;;
        * )
            echo "Недопустимый выбор. Пожалуйста, выберите 'рус' или 'eng'."
            ;;
    esac
done

# Функции для вывода сообщений на разных языках
msg_rus() {
    case $1 in
        "Updating system..." )
            echo "Обновление системы..."
            ;;
        "Installing required packages..." )
            echo "Установка необходимых пакетов..."
            ;;
        "Configuring SSH..." )
            echo "Настройка SSH..."
            ;;
        "Configuring Firewall (UFW)..." )
            echo "Настройка Firewall (UFW)..."
            ;;
        "Creating new user '$NEW_USER'..." )
            echo "Создание нового пользователя '$NEW_USER'..."
            ;;
        "Enabling automatic updates..." )
            echo "Включение автоматических обновлений..."
            ;;
        "Security setup completed successfully!" )
            echo "Настройка безопасности завершена успешно!"
            ;;
        * )
            echo "$1"
            ;;
    esac
}

msg_eng() {
    case $1 in
        "Updating system..." )
            echo "Updating system..."
            ;;
        "Installing required packages..." )
            echo "Installing required packages..."
            ;;
        "Configuring SSH..." )
            echo "Configuring SSH..."
            ;;
        "Configuring Firewall (UFW)..." )
            echo "Configuring Firewall (UFW)..."
            ;;
        "Creating new user '$NEW_USER'..." )
            echo "Creating new user '$NEW_USER'..."
            ;;
        "Enabling automatic updates..." )
            echo "Enabling automatic updates..."
            ;;
        "Security setup completed successfully!" )
            echo "Security setup completed successfully!"
            ;;
        * )
            echo "$1"
            ;;
    esac
}

# Определение функции для выбранного языка
case $LANGUAGE in
    rus )
        msg=$msg_rus
        ;;
    eng )
        msg=$msg_eng
        ;;
esac

# Обновляем систему
echo ""
$msg "Updating system..."
sudo apt update && sudo apt full-upgrade -y

# Устанавливаем необходимые пакеты
echo ""
$msg "Installing required packages..."
sudo apt install unattended-upgrades ufw fail2ban -y

# Настраиваем SSH
echo ""
$msg "Configuring SSH..."
sudo sed -i 's/^PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i "s/^Port.*$/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo service ssh restart

# Настраиваем Firewall (UFW)
echo ""
$msg "Configuring Firewall (UFW)..."
sudo ufw default deny incoming
sudo ufw allow "$NEW_SSH_PORT"/tcp
sudo ufw reload

# Создаем нового пользователя
echo ""
$msg "Creating new user '$NEW_USER'..."
echo "Пожалуйста, введите следующие данные:"
echo "- Username: $NEW_USER"
echo "- Password: (будет запрошено)"
echo "- Full Name: (необязательно)"
echo "- Room Number: (необязательно)"
echo "- Work Phone: (необязательно)"
echo "- Home Phone: (необязательно)"
echo "- Other: (необязательно)"

read -sp "Введите пароль для $NEW_USER: " PASSWORD
echo ""

sudo adduser "$NEW_USER" << EOF
$PASSWORD
$PASSWORD
test
EOF

# Автоматические обновления
echo ""
$msg "Enabling automatic updates..."
sudo dpkg-reconfigure -plow unattended-upgrades

# Настройка Fail2Ban
echo ""
$msg "Installing and configuring Fail2Ban..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime = 600/bantime = 3600/' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Завершение
echo ""
$msg "Security setup completed successfully!"
sleep 5

# Самоудаление скрипта после выполнения
rm -- "$0"
