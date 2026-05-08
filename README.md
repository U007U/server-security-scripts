# 🚀 Настройка безопасности сервера (кратко)

Автоматическая защита Ubuntu: SSH-порт 2222, новый пользователь, ключи, firewall. [web:1][web:2]

## 📥 Шаги установки (скопируй и выполни по порядку)

1. **Скачай скрипт:**
   ```bash
   wget https://raw.githubusercontent.com/U007U/server-security-scripts/main/secure_server.sh
   ```

2. **Сделай исполняемым:**
   ```bash
   chmod +x secure_server.sh
   ```

3. **Запусти от root:**
   ```bash
   sudo ./secure_server.sh
   ```
   - Выбери язык: `1` (English) / `2` (Русский)
   - Имя пользователя: напр. `anya`
   - Порт SSH: Enter (2222)
   - SSH-ключ: `yes` + вставь ключ (1 строка) / `no`
   - Пароль: сложный!

4. **Подключись:**
   ```bash
   ssh anya@89.107.10.79 -p 2222
   ```

## ✅ Результат
Root отключён, сервер защищён. Готово! [web:5]
