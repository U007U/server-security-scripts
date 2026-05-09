#!/bin/bash
# ==============================================
# Безопасная настройка сервера Ubuntu
# ==============================================

# Выбор языка
echo "Choose language / Выберите язык:"
echo "1) English"
echo "2) Русский"
read -p "Enter 1 or 2 / Введите 1 или 2: " LANG_CHOICE

if [ "$LANG_CHOICE" = "2" ]; then
    TXT_USER="Создадим нового пользователя (вместо root). Введите имя:"
    TXT_PORT="Изменим порт SSH (сейчас 22). Рекомендуется 2222. Введите порт или Enter:"
    TXT_KEY="У вас есть SSH-ключ? (yes/no/да/нет):"
    TXT_KEY_NOW="Хотите добавить публичный ключ сейчас? (yes/no):"
    TXT_PASTE="Вставьте публичный ключ (одна строка):"
    TXT_KEY_ADD="Ключ добавлен. Пароли будут отключены."
    TXT_PWD_ON="Пароли остаются включенными. Позже настройте ключи вручную."
    TXT_START="Начинаем настройку..."
    TXT_UPDATE="Обновление системы..."
    TXT_PACKAGES="Установка пакетов..."
    TXT_AUTOUP="Настройка автообновлений..."
    TXT_SSH="Настройка SSH (порт, запрет root)..."
    TXT_FW="Настройка фаервола (разрешён только SSH)..."
    TXT_FAIL2BAN="Настройка Fail2Ban..."
    TXT_DONE="✅ Готово! Подключайтесь: ssh $NEW_USER@$SERVER_IP -p $SSH_PORT"
    TXT_ROOT_DISABLED="⚠️ Root по SSH отключён."
else
    TXT_USER="Create a new user (instead of root). Enter username:"
    TXT_PORT="Change SSH port (currently 22). Recommended 2222. Enter port or press Enter:"
    TXT_KEY="Do you have an SSH key? (yes/no):"
    TXT_KEY_NOW="Do you want to add your public key now? (yes/no):"
    TXT_PASTE="Paste your public key (one line):"
    TXT_KEY_ADD="Key added. Passwords will be disabled."
    TXT_PWD_ON="Passwords remain enabled. Set up keys manually later."
    TXT_START="Starting setup..."
    TXT_UPDATE="Updating system..."
    TXT_PACKAGES="Installing packages..."
    TXT_AUTOUP="Setting up auto-upgrades..."
    TXT_SSH="Configuring SSH (port, disable root)..."
    TXT_FW="Configuring firewall (allow only SSH)..."
    TXT_FAIL2BAN="Configuring Fail2Ban..."
    TXT_DONE="✅ Done! Connect via: ssh $NEW_USER@$SERVER_IP -p $SSH_PORT"
    TXT_ROOT_DISABLED="⚠️ Root SSH disabled."
fi

SERVER_IP=$(curl -s ifconfig.me)

echo "$TXT_USER"
read -p "Username: " NEW_USER
while [ -z "$NEW_USER" ]; do
    read -p "Username cannot be empty. Enter username: " NEW_USER
done

echo "$TXT_PORT"
read -p "Port [2222]: " SSH_PORT
SSH_PORT=${SSH_PORT:-2222}

echo "$TXT_KEY"
read -p "(yes/no): " HAS_KEY
HAS_KEY=$(echo "$HAS_KEY" | tr '[:upper:]' '[:lower:]')
if [[ "$HAS_KEY" =~ ^(yes|y|да|д)$ ]]; then
    echo "$TXT_KEY_NOW"
    read -p "(yes/no): " ADD_KEY_NOW
    ADD_KEY_NOW=$(echo "$ADD_KEY_NOW" | tr '[:upper:]' '[:lower:]')
    if [[ "$ADD_KEY_NOW" =~ ^(yes|y|да|д)$ ]]; then
        echo "$TXT_PASTE"
        read -r SSH_KEY
        if [ -n "$SSH_KEY" ]; then
            ADD_KEY=1
            DISABLE_PASSWORD=1
            echo "$TXT_KEY_ADD"
        fi
    fi
fi

echo "$TXT_START"
export DEBIAN_FRONTEND=noninteractive

echo "$TXT_UPDATE"
apt update && apt full-upgrade -y

echo "$TXT_PACKAGES"
apt install -y unattended-upgrades ufw fail2ban

echo "$TXT_AUTOUP"
dpkg-reconfigure --priority=low unattended-upgrades -f noninteractive

echo "$TXT_SSH"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i "s/^#Port 22/Port $SSH_PORT/; s/^Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin yes/PermitRootLogin no/; s/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
grep -q "^PermitRootLogin no" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
if [ "$DISABLE_PASSWORD" = "1" ]; then
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/; s/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi
systemctl restart sshd

echo "$TXT_FW"
ufw --force disable
ufw default deny incoming
ufw default allow outgoing
ufw allow "$SSH_PORT"/tcp comment 'SSH'
ufw --force enable

echo "$TXT_FAIL2BAN"
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local 2>/dev/null
sed -i 's/bantime = 600/bantime = 3600/; s/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

adduser "$NEW_USER"
usermod -aG sudo "$NEW_USER"

if [ "$ADD_KEY" = "1" ]; then
    mkdir -p /home/$NEW_USER/.ssh
    echo "$SSH_KEY" > /home/$NEW_USER/.ssh/authorized_keys
    chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
    chmod 700 /home/$NEW_USER/.ssh
    chmod 600 /home/$NEW_USER/.ssh/authorized_keys
fi

echo ""
echo "$TXT_DONE"
echo "$TXT_ROOT_DISABLED"
echo ""
rm -- "$0"
