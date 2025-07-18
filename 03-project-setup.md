#📁 Подготовка проекта
##Создание рабочей директории
```bash


# Создание директории проекта
mkdir ~/openwebui
cd ~/openwebui

# Создание структуры проекта
mkdir -p data logs config
Структура проекта

openwebui/
├── docker-compose.yml
├── .env (опционально)
├── data/              # Данные приложения
├── logs/              # Логи
└── config/            # Конфигурационные файлы
```
<details>
  <summary>📌 Расширение: Альтернативные пути и хранилища</summary>
##Системная директория
###Для серверного развертывания рекомендуется:
```bash

# Создание системной директории
sudo mkdir -p /opt/openwebui
sudo chown $USER:$USER /opt/openwebui
cd /opt/openwebui
```
##Сетевое хранилище
###Для хранения данных на NFS:
```bash

# Монтирование NFS
sudo apt install -y nfs-common
sudo mkdir -p /mnt/nfs-storage
sudo mount -t nfs 192.168.1.100:/storage /mnt/nfs-storage

# Создание символических ссылок
ln -s /mnt/nfs-storage/openwebui-data ./data
```
##Backup директория
```bash
# Создание директории для бэкапов
mkdir -p ~/backups/openwebui
```
##Права доступа
```bash

# Установка правильных прав
chmod 755 ~/openwebui
chmod 700 ~/openwebui/data
chmod 755 ~/openwebui/logs
```
</details>