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
<details>
  <summary>📌 Расширение: Безопасность Docker</summary>

  <!-- Your content goes here -->

 Настройка безопасности
```bash
# Настройка auditd для мониторинга Docker
sudo apt install -y auditd
echo "-w /usr/bin/docker -p wa -k docker" | sudo tee -a /etc/audit/rules.d/docker.rules

# Настройка fail2ban
sudo apt install -y fail2ban
```
Ограничение ресурсов
```bash
# Настройка лимитов в /etc/docker/daemon.json
sudo tee /etc/docker/daemon.json <<EOF
{
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
EOF

sudo systemctl restart docker
```
Логирование
```bash

# Настройка логирования через journald
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "journald",
  "log-opts": {
    "tag": "docker/{{.Name}}"
  }
}
EOF
```
</details>


