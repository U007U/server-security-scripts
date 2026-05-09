# 🛡️ Server Security Scripts

**Автоматическая безопасная настройка Ubuntu VPS.**  
3 простые команды — и сервер защищён: новый порт SSH, disable root, UFW, Fail2Ban, автообновления.

[![Stars](https://img.shields.io/github/stars/U007U/server-security-scripts)](https://github.com/U007U/server-security-scripts)

## 🚀 Установка (3 команды)

**Требования:**  
- Чистый Ubuntu 20.04/22.04/24.04 VPS.  
- Подключены как **root** по SSH.  
- **⚠️ Только на свежем сервере! Root отключится.**

### Шаг 1: Скачайте скрипт
```bash
wget https://raw.githubusercontent.com/U007U/server-security-scripts/main/setup.sh -O setup.sh
```

### Шаг 2: Сделайте исполняемым
```bash
chmod +x setup.sh
```

### Шаг 3: Запустите
```bash
./setup.sh
```

## Что происходит

1. Выбор языка (EN/RU).  
2. Ввод имени пользователя, порта SSH (по умолчанию 2222).  
3. Опционально: добавьте публичный SSH-ключ (отключает пароли).  
4. Автоматически: обновление, UFW (только новый SSH), Fail2Ban (3 попытки → бан 1ч), новый sudo-user, disable root.  
5. **Подключитесь:** `ssh username@your_ip -p 2222`  
6. Скрипт удаляет себя + создаёт лог `setup_*.log`.

## Проверка после

```bash
ufw status
fail2ban-client status
ss -tuln | grep :2222
```

## Откат (если нужно)

```bash
ufw disable
systemctl stop fail2ban
cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
systemctl restart sshd
```

## Лицензия
MIT. Форк/улучшения приветствуются!

**Автор: U007U | 09.05.2026**
