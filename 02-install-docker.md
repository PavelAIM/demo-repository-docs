# 🛠️ Установка Docker и Docker Compose
Установка Docker
Выполните следующие команды для установки Docker:
```bash
# Обновление системы
sudo apt update
sudo apt upgrade -y

# Установка Docker
sudo apt install -y docker.io docker-compose

# Запуск и автозагрузка Docker
sudo systemctl enable docker
sudo systemctl start docker

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Применение изменений группы
newgrp docker
```
Проверка установки

```bash

# Проверка версии Docker
docker --version

# Проверка версии Docker Compose
docker-compose --version

# Тестовый запуск
docker run hello-world
```



