#!/bin/bash
# ==============================================
# Безопасная настройка сервера Ubuntu v2.0
# ==============================================

# Проверка Ubuntu
if ! command -v lsb_release &> /dev/null || ! lsb_release -d 2>&1 | grep -q Ubuntu; then
    echo "❌ Только для Ubuntu! Выход."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Лог
LOGFILE="setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE")
exec 2>&1
echo "✅ Ubuntu OK. v2.0 ($(date))"

# Выбор языка
echo "Choose language / Выберите язык:"
echo "1) English"
echo "2) Русский"
read -p "Enter 1 or 2 / Введите 1 или 2: " LANG_CHOICE

if [ "$LANG_CHOICE" = "2" ]; then
    TXT_USER="Создадим нового пользователя. Введите имя:"
    TXT_PORT="Изменим порт SSH. Рекомендуется 2222. Введите порт или Enter:"
    TXT_PASS="Введите пароль для пользователя (минимум 6 символов):"
    TXT_KEY="У вас есть SSH-ключ? (yes/no):"
    TXT_KEY_PASTE="Вставьте публичный ключ (одна строка):"
    TXT_KEY_ADDED="✅ Ключ добавлен"
    TXT_START="Начинаем настройку..."
    TXT_UPDATE="Обновление системы..."
    TXT_PACKAGES="Установка пакетов..."
    TXT_SSH="Настройка SSH..."
    TXT_FW="Настройка фаервола..."
    TXT_USER_CREATE="Создание пользователя..."
    TXT_DONE="✅ НАСТРОЙКА ЗАВЕРШЕНА"
    TXT_RESULT="РЕЗУЛЬТАТ"
else
    TXT_USER="Create a new user. Enter username:"
    TXT_PORT="Change SSH port. Recommended 2222. Enter port or press Enter:"
    TXT_PASS="Enter password for user (min 6 characters):"
    TXT_KEY="Do you have an SSH key? (yes/no):"
    TXT_KEY_PASTE="Paste your public key (one line):"
    TXT_KEY_ADDED="✅ Key added"
    TXT_START="Starting setup..."
    TXT_UPDATE="Updating system..."
    TXT_PACKAGES="Installing packages..."
    TXT_SSH="Configuring SSH..."
    TXT_FW="Configuring firewall..."
    TXT_USER_CREATE="Creating user..."
    TXT_DONE="✅ SETUP COMPLETE"
    TXT_RESULT="RESULT"
fi

# Получаем IP
SERVER_IP=$(curl -s https://ipinfo.io/ip || curl -s ifconfig.me || echo "YOUR_IP")

echo "$TXT_USER"
read -p "Username: " NEW_USER

echo "$TXT_PASS"
read -s -p "Password: " USER_PASS
echo
read -s -p "Confirm password: " USER_PASS_CONFIRM
echo

while [ "$USER_PASS" != "$USER_PASS_CONFIRM" ] || [ ${#USER_PASS} -lt 6 ]; do
    echo "❌ Пароли не совпадают или короче 6 символов"
    read -s -p "Password: " USER_PASS
    echo
    read -s -p "Confirm password: " USER_PASS_CONFIRM
    echo
done

echo "$TXT_PORT"
read -p "Port [2222]: " SSH_PORT
SSH_PORT=${SSH_PORT:-2222}

echo "$TXT_KEY"
read -p "(yes/no): " HAS_KEY
HAS_KEY=$(echo "$HAS_KEY" | tr '[:upper:]' '[:lower:]')

SSH_KEY=""
if [[ "$HAS_KEY" =~ ^(yes|y|да|д)$ ]]; then
    echo "$TXT_KEY_PASTE"
    read -r SSH_KEY
fi

echo "$TXT_START"

# Обновление
echo "$TXT_UPDATE"
apt update -qq && apt full-upgrade -y -qq

# Установка пакетов
echo "$TXT_PACKAGES"
apt install -y -qq unattended-upgrades ufw fail2ban whois

# Автообновления
dpkg-reconfigure -f noninteractive unattended-upgrades || true

# Создание пользователя
echo "$TXT_USER_CREATE"
useradd -m -s /bin/bash "$NEW_USER"
echo "$NEW_USER:$USER_PASS" | chpasswd
usermod -aG sudo "$NEW_USER"

# Добавление SSH ключа если есть
if [ -n "$SSH_KEY" ]; then
    mkdir -p /home/$NEW_USER/.ssh
    echo "$SSH_KEY" > /home/$NEW_USER/.ssh/authorized_keys
    chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
    chmod 700 /home/$NEW_USER/.ssh
    chmod 600 /home/$NEW_USER/.ssh/authorized_keys
    echo "$TXT_KEY_ADDED"
fi

# Настройка SSH
echo "$TXT_SSH"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Правильная настройка порта
sed -i "s/^Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
grep -q "^Port $SSH_PORT" /etc/ssh/sshd_config && sed -i "s/^#Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
if ! grep -q "^Port $SSH_PORT" /etc/ssh/sshd_config; then
    echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
fi

# Запрет root
sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
grep -q "^PermitRootLogin no" /etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# Отключаем пароли если есть ключ
if [ -n "$SSH_KEY" ]; then
    sed -i 's/^PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
    sed -i 's/^ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
fi

# Перезапуск SSH
systemctl restart sshd || systemctl restart ssh

# Настройка фаервола
echo "$TXT_FW"
ufw --force disable >/dev/null 2>&1
ufw default deny incoming
ufw default allow outgoing
ufw allow "$SSH_PORT"/tcp comment 'SSH'
ufw --force enable >/dev/null 2>&1

# Настройка Fail2Ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local 2>/dev/null || true
sed -i "s/^port .*/port = $SSH_PORT/" /etc/fail2ban/jail.local 2>/dev/null || true
systemctl enable fail2ban
systemctl start fail2ban

# Финальный вывод
clear
echo ""
echo "=========================================="
echo "$TXT_DONE"
echo "=========================================="
echo ""
echo "📋 $TXT_RESULT:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   🌐 IP-адрес:     $SERVER_IP"
echo "   👤 Пользователь: $NEW_USER"
echo "   🔑 Пароль:       [скрыт]"
echo "   🚪 Порт SSH:     $SSH_PORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ -n "$SSH_KEY" ]; then
    echo "   🔐 Аутентификация: по SSH-ключу"
else
    echo "   🔐 Аутентификация: по паролю"
fi
echo "   ⚠️ Root доступ: отключён"
echo ""
echo "──────────────────────────────────────────"
echo "   🖥️ Команда для подключения:"
echo "   ssh $NEW_USER@$SERVER_IP -p $SSH_PORT"
echo "──────────────────────────────────────────"
echo ""
echo "📄 Лог: $LOGFILE"
echo ""
rm -- "$0"
echo "✅ Скрипт удалён."
