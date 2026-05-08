#!/bin/bash

# ==============================================
# Безопасная настройка сервера Ubuntu
# Скрипт с выбором языка и понятными пояснениями
# ==============================================

# Переменные по умолчанию
NEW_USER=""
NEW_SSH_PORT="2222"
LANG_CHOICE=""

# Функция для понятного вывода на русском
say_ru() {
    echo "🔹 $1"
    if [ ! -z "$2" ]; then
        echo "   ➤ $2"
    fi
}

# Функция для понятного вывода на английском
say_en() {
    echo "🔹 $1"
    if [ ! -z "$2" ]; then
        echo "   ➤ $2"
    fi
}

# Выбор языка
echo "========================================="
echo "Welcome / Добро пожаловать"
echo "========================================="
echo "Choose language / Выберите язык:"
echo "1) English"
echo "2) Русский"
read -p "Enter 1 or 2 / Введите 1 или 2: " lang_num

if [ "$lang_num" == "2" ]; then
    LANG="RU"
    say_ru "Начинаем настройку безопасности сервера."
    say_ru "Этот скрипт поможет защитить ваш сервер."
else
    LANG="EN"
    say_en "Starting server security setup."
    say_en "This script will help protect your server."
fi

# Запрос имени нового пользователя (не root)
if [ "$LANG" == "RU" ]; then
    echo ""
    say_ru "Создадим нового пользователя для работы на сервере."
    say_ru "Root (администратор) будет отключён для входа по SSH."
    read -p "Введите имя нового пользователя (например, myuser): " NEW_USER
    while [ -z "$NEW_USER" ]; do
        say_ru "Имя не может быть пустым. Попробуйте снова."
        read -p "Введите имя нового пользователя: " NEW_USER
    done
else
    echo ""
    say_en "We will create a new user to work on the server."
    say_en "Root (administrator) will be disabled for SSH login."
    read -p "Enter new username (e.g., myuser): " NEW_USER
    while [ -z "$NEW_USER" ]; do
        say_en "Username cannot be empty. Try again."
        read -p "Enter new username: " NEW_USER
    done
fi

# Запрос порта SSH (с пояснением)
if [ "$LANG" == "RU" ]; then
    echo ""
    say_ru "Изменим порт для подключения по SSH (сейчас 22)."
    say_ru "Нестандартный порт делает сервер безопаснее."
    read -p "Введите новый номер порта (рекомендуется 2222): " NEW_SSH_PORT
    if [ -z "$NEW_SSH_PORT" ]; then
        NEW_SSH_PORT="2222"
        say_ru "Будет использован порт 2222."
    fi
else
    echo ""
    say_en "We will change the SSH port (currently 22)."
    say_en "A non-standard port makes the server more secure."
    read -p "Enter new port number (recommended 2222): " NEW_SSH_PORT
    if [ -z "$NEW_SSH_PORT" ]; then
        NEW_SSH_PORT="2222"
        say_en "Will use port 2222."
    fi
fi

# Подтверждение начала
if [ "$LANG" == "RU" ]; then
    echo ""
    say_ru "Скрипт выполнит следующие действия:"
    echo "  1. Обновит систему"
    echo "  2. Установит полезные пакеты (ufw, fail2ban, unattended-upgrades)"
    echo "  3. Настроит SSH (новый порт, запрет root, запрет паролей после настройки ключа)"
    echo "  4. Настроит файрвол (разрешит только новый порт SSH)"
    echo "  5. Создаст нового пользователя '$NEW_USER'"
    echo "  6. Включит автоматические обновления безопасности"
    echo "  7. Настроит Fail2Ban для защиты от брутфорса"
    echo ""
    read -p "Нажмите Enter, чтобы продолжить, или Ctrl+C для отмены."
else
    echo ""
    say_en "The script will do the following:"
    echo "  1. Update the system"
    echo "  2. Install useful packages (ufw, fail2ban, unattended-upgrades)"
    echo "  3. Configure SSH (new port, disable root, disable passwords after key setup)"
    echo "  4. Configure firewall (allow only new SSH port)"
    echo "  5. Create new user '$NEW_USER'"
    echo "  6. Enable automatic security updates"
    echo "  7. Configure Fail2Ban to protect against brute force"
    echo ""
    read -p "Press Enter to continue, or Ctrl+C to cancel."
fi

# Начало выполнения
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 1: Обновление системы..."
else
    say_en "Step 1: Updating system..."
fi
sudo apt update && sudo apt full-upgrade -y

if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 2: Установка необходимых пакетов..."
else
    say_en "Step 2: Installing required packages..."
fi
sudo apt install unattended-upgrades ufw fail2ban -y

# Настройка автоматических обновлений
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 3: Настройка автоматических обновлений безопасности..."
else
    say_en "Step 3: Configuring automatic security updates..."
fi
sudo dpkg-reconfigure --priority=low unattended-upgrades -f noninteractive

# Настройка SSH
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 4: Настройка SSH..."
    say_ru "Меняем порт на $NEW_SSH_PORT, запрещаем вход root, отключаем вход по паролю."
    say_ru "ВНИМАНИЕ: Перед отключением паролей убедитесь, что у вас есть SSH-ключ!"
    read -p "У вас уже есть SSH-ключ? (да/нет): " has_key
    if [ "$has_key" != "да" ] && [ "$has_key" != "yes" ] && [ "$has_key" != "y" ]; then
        say_ru "Рекомендуется сначала создать SSH-ключ на вашем компьютере и добавить его на сервер."
        say_ru "Пропускаем отключение паролей. Вы сможете сделать это вручную позже."
        DISABLE_PASSWORD="no"
    else
        DISABLE_PASSWORD="yes"
    fi
else
    say_en "Step 4: Configuring SSH..."
    say_en "Changing port to $NEW_SSH_PORT, disabling root login, disabling password authentication."
    say_en "WARNING: Before disabling passwords, make sure you have an SSH key!"
    read -p "Do you already have an SSH key? (yes/no): " has_key
    if [ "$has_key" != "yes" ] && [ "$has_key" != "y" ]; then
        say_en "It's recommended to first create an SSH key on your computer and add it to the server."
        say_en "Skipping password disable. You can do it manually later."
        DISABLE_PASSWORD="no"
    else
        DISABLE_PASSWORD="yes"
    fi
fi

# Бэкап конфига SSH
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
# Изменяем порт
sudo sed -i "s/^#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
sudo sed -i "s/^Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
# Запрещаем root
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
if ! grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
fi
# Отключаем пароли, если пользователь подтвердил наличие ключа
if [ "$DISABLE_PASSWORD" == "yes" ]; then
    sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    if ! grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
    fi
else
    # Оставляем пароли включенными, но предупреждаем
    if [ "$LANG" == "RU" ]; then
        say_ru "Вход по паролю остаётся включённым. Не забудьте позже настроить SSH-ключи и отключить пароли."
    else
        say_en "Password login remains enabled. Don't forget to set up SSH keys and disable passwords later."
    fi
fi
# Перезапуск SSH
sudo systemctl restart sshd

# Настройка файрвола UFW
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 5: Настройка файрвола (UFW)..."
    say_ru "Разрешаем только порт $NEW_SSH_PORT/tcp, всё остальное запрещаем."
else
    say_en "Step 5: Configuring firewall (UFW)..."
    say_en "Allowing only port $NEW_SSH_PORT/tcp, denying everything else."
fi
sudo ufw --force disable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow "$NEW_SSH_PORT"/tcp comment 'SSH port'
# Если нужен HTTP/HTTPS, можно раскомментировать:
# sudo ufw allow 80/tcp comment 'HTTP'
# sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw --force enable
sudo ufw status verbose

# Создание нового пользователя
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 6: Создание нового пользователя '$NEW_USER'..."
    say_ru "Сейчас нужно будет ввести пароль для этого пользователя."
    say_ru "Пароль должен быть надёжным (буквы, цифры, спецсимволы)."
else
    say_en "Step 6: Creating new user '$NEW_USER'..."
    say_en "You will now need to enter a password for this user."
    say_en "Password should be strong (letters, digits, special characters)."
fi
sudo adduser "$NEW_USER"

# Добавление пользователя в группу sudo (администраторы)
if [ "$LANG" == "RU" ]; then
    say_ru "Добавляем пользователя '$NEW_USER' в группу sudo, чтобы он мог выполнять административные команды."
else
    say_en "Adding user '$NEW_USER' to sudo group so they can run admin commands."
fi
sudo usermod -aG sudo "$NEW_USER"

# Инструкция по добавлению SSH-ключа для нового пользователя
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 7: Настройка SSH-ключа для нового пользователя (рекомендуется)."
    say_ru "Сейчас вы можете скопировать свой публичный ключ на сервер для пользователя $NEW_USER."
    say_ru "Если у вас есть ключ (обычно файл id_rsa.pub или id_ed25519.pub), введите его содержимое."
    say_ru "Или вы можете сделать это позже командой: ssh-copy-id $NEW_USER@ваш_сервер -p $NEW_SSH_PORT"
    read -p "Хотите добавить SSH-ключ сейчас? (да/нет): " add_key_now
    if [ "$add_key_now" == "да" ] || [ "$add_key_now" == "yes" ] || [ "$add_key_now" == "y" ]; then
        echo "Вставьте содержимое вашего публичного ключа (одна строка) и нажмите Enter:"
        read -r ssh_key
        if [ ! -z "$ssh_key" ]; then
            sudo mkdir -p /home/$NEW_USER/.ssh
            echo "$ssh_key" | sudo tee -a /home/$NEW_USER/.ssh/authorized_keys
            sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
            sudo chmod 700 /home/$NEW_USER/.ssh
            sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys
            if [ "$LANG" == "RU" ]; then
                say_ru "Ключ добавлен. Теперь вы сможете входить под пользователем $NEW_USER без пароля."
            else
                say_en "Key added. Now you can log in as $NEW_USER without a password."
            fi
        fi
    fi
else
    say_en "Step 7: Setting up SSH key for new user (recommended)."
    say_en "Now you can copy your public key to the server for user $NEW_USER."
    say_en "If you have a key (usually id_rsa.pub or id_ed25519.pub), paste it."
    say_en "Or you can do it later with: ssh-copy-id $NEW_USER@your_server -p $NEW_SSH_PORT"
    read -p "Do you want to add an SSH key now? (yes/no): " add_key_now
    if [ "$add_key_now" == "yes" ] || [ "$add_key_now" == "y" ]; then
        echo "Paste your public key (one line) and press Enter:"
        read -r ssh_key
        if [ ! -z "$ssh_key" ]; then
            sudo mkdir -p /home/$NEW_USER/.ssh
            echo "$ssh_key" | sudo tee -a /home/$NEW_USER/.ssh/authorized_keys
            sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
            sudo chmod 700 /home/$NEW_USER/.ssh
            sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys
            say_en "Key added. Now you can log in as $NEW_USER without a password."
        fi
    fi
fi

# Настройка Fail2Ban
if [ "$LANG" == "RU" ]; then
    say_ru "Шаг 8: Настройка Fail2Ban (защита от повторных неудачных попыток входа)..."
else
    say_en "Step 8: Configuring Fail2Ban (protection against repeated failed logins)..."
fi
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime = 600/bantime = 3600/' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Итоговое сообщение
if [ "$LANG" == "RU" ]; then
    echo ""
    echo "========================================="
    say_ru "✅ Настройка безопасности завершена успешно!"
    echo "========================================="
    echo "Теперь вы можете подключаться к серверу командой:"
    echo "  ssh $NEW_USER@89.107.10.79 -p $NEW_SSH_PORT"
    echo ""
    echo "ВАЖНЫЕ ЗАМЕЧАНИЯ:"
    echo "1. Если вы не добавили SSH-ключ, подключитесь по паролю."
    echo "2. Root-доступ по SSH отключён."
    echo "3. Файрвол пропускает только порт $NEW_SSH_PORT."
    echo "4. Чтобы отключить вход по паролю окончательно, отредактируйте /etc/ssh/sshd_config"
    echo "   и установите 'PasswordAuthentication no', затем перезапустите SSH."
    echo ""
    read -p "Нажмите Enter для завершения и самоудаления скрипта."
else
    echo ""
    echo "========================================="
    say_en "✅ Security setup completed successfully!"
    echo "========================================="
    echo "Now you can connect to the server with:"
    echo "  ssh $NEW_USER@89.107.10.79 -p $NEW_SSH_PORT"
    echo ""
    echo "IMPORTANT NOTES:"
    echo "1. If you didn't add an SSH key, you will log in with a password."
    echo "2. Root access via SSH is disabled."
    echo "3. Firewall allows only port $NEW_SSH_PORT."
    echo "4. To permanently disable password login, edit /etc/ssh/sshd_config"
    echo "   and set 'PasswordAuthentication no', then restart SSH."
    echo ""
    read -p "Press Enter to finish and self-delete the script."
fi

# Самоудаление скрипта
rm -- "$0"
