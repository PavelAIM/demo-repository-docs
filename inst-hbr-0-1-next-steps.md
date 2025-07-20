
## Что дальше
Ниже собраны возможности для расширения базовой инструкции, организованные по шагам установки:
<details>
  <summary>📚 Оглавление</summary>

- [Что дальше](#что-дальше)
  - [🎯 Рекомендуемые приоритеты внедрения](##-рекомендуемые-приоритеты-внедрения)
- [Шаг 1. Установка Docker и Docker Compose](#шаг-1-установка-docker-и-docker-compose)
  - [📌 Точка расширения 1.1: Безопасность и управление правами](#точка-расширения-11-безопасность-и-управление-правами)
  - [📌 Точка расширения 1.2: Настройка системного времени](#точка-расширения-12-настройка-системного-времени)
- [Шаг 2. Создание рабочей директории](#шаг-2-создание-рабочей-директории)
  - [📌 Точка расширения 2.1: Размещение данных](#точка-расширения-21-размещение-данных)
- [Шаг 3. Создание файла docker-compose.yml](#шаг-3-создание-файла-docker-composeyml)
  - [📌 Точка расширения 3.1: Переменные окружения](#точка-расширения-31-переменные-окружения)
  - [📌 Точка расширения 3.2: Подключение к Ollama или другому backend](#точка-расширения-32-подключение-к-ollama-или-другому-backend)
  - [📌 Точка расширения 3.3: Мониторинг и логирование](#точка-расширения-33-мониторинг-и-логирование)
- [Шаг 4. Запуск контейнера](#шаг-4-запуск-контейнера)
  - [📌 Точка расширения 4.1: Управление жизненным циклом](#точка-расширения-41-управление-жизненным-циклом)
- [Шаг 5. Доступ и авторизация](#шаг-5-доступ-и-авторизация)
  - [📌 Точка расширения 5.1: Аутентификация и авторизация](#точка-расширения-51-аутентификация-и-авторизация)
  - [📌 Точка расширения 5.2: HTTPS и обратный прокси](#точка-расширения-52-https-и-обратный-прокси)
  - [📌 Точка расширения 5.3: Интеграция с корпоративными системами](#точка-расширения-53-интеграция-с-корпоративными-системами)

</details>

## 🎯 Рекомендуемые приоритеты внедрения:
<details> <summary>📄 Посмотреть...</summary>

**Высокий приоритет** (критично для продакшена):
- 1.1 Безопасность и управление правами
- 5.1 Аутентификация и авторизация  
- 5.2 HTTPS и обратный прокси

**Средний приоритет** (важно для операционной деятельности):
- 3.3 Мониторинг и логирование
- 4.1 Управление жизненным циклом
- 3.2 Подключение к Ollama (если нужна локальная модель)

**Низкий приоритет** (для оптимизации):
- 1.2 Настройка системного времени
- 2.1 Размещение данных
- 3.1 Переменные окружения
- 5.3 Интеграция с корпоративными системами

</details> 

---

## Шаг 1. Установка Docker и Docker Compose

### 📌 Точка расширения 1.1: Безопасность Docker

<details> <summary>🔍 Разница между "docker без sudo" и "Rootless mode"</summary>

## 🥉 **"Docker без sudo"** (реализовано в минимальной установке)

**Что это:**
```bash
# Добавляем пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Теперь можно запускать без sudo:
docker ps
docker run hello-world
```

```shell
# test shell
# Добавляем пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# Теперь можно запускать без sudo:
docker ps
docker run hello-world
```

**Как работает:**
- Демон Docker **все равно работает от root**
- Контейнеры **могут получить root на хосте** через volume mounts
- Просто пользователю не нужно каждый раз писать `sudo docker`

**Безопасность:** 
⚠️ **Низкая** - участники группы `docker` фактически имеют root-доступ к системе

## 🥇 **Rootless mode (настоящая безопасность)** [документация](https://docs.docker.com/engine/security/rootless/)

**Что это:**
```bash
# Установка rootless Docker (сложнее)
curl -fsSL https://get.docker.com/rootless | sh
systemctl --user enable docker
systemctl --user start docker
```

**Как работает:**
- Демон Docker работает **от обычного пользователя**
- Использует user namespaces для изоляции
- Контейнеры **не могут получить root на хосте**

**Безопасность:** 
✅ **Высокая** - реальная изоляция от host-системы

## 📊 Сравнение подходов

| Критерий | Docker без sudo | Rootless mode |
|----------|------------------|---------------|
| **Сложность настройки** | Простая | Сложная |
| **Безопасность** | Низкая | Высокая |
| **Совместимость** | 100% | ~80% (есть ограничения) |
| **Производительность** | Максимальная | Немного ниже |
| **Корпоративное использование** | Не рекомендуется | Рекомендуется |

</details>

**Зачем это нужно:**
- **Минимизация рисков**: Предотвращение случайного получения root-доступа через Docker
- **Соответствие политикам безопасности**: Многие компании требуют запуск сервисов без root
- **Изоляция**: Защита хост-системы от потенциальных уязвимостей в контейнерах

**Варианты реализации:**

#### **Вариант A: Простой (docker без sudo)** (реализовано в минимальной установке)
```bash
# Быстро, но менее безопасно
sudo usermod -aG docker $USER
newgrp docker
```
✅ Плюсы: просто, быстро, полная совместимость  
⚠️ Минусы: низкая безопасность

#### **Вариант B: Безопасный (Rootless mode)**
```bash
# Сложнее, но безопаснее
curl -fsSL https://get.docker.com/rootless | sh
systemctl --user enable docker
systemctl --user start docker
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
```
✅ Плюсы: высокая безопасность  
⚠️ Минусы: сложная настройка, некоторые ограничения

#### **Вариант C: Корпоративный подход**
```bash
# Отдельный пользователь для Docker
sudo useradd -r -s /bin/false dockeruser
sudo usermod -aG docker dockeruser
# + настройка systemd сервиса от этого пользователя
```

<details> <summary>💡 **Рекомендации для корпоративной среды:**</summary>

**Для быстрого тестирования:**
- Используйте **Вариант A** (docker без sudo)

**Для продакшена:**
- **Rootless mode** (Вариант B) - если позволяет инфраструктура
- **Dedicated user** (Вариант C) - если rootless не подходит

**Дополнительные меры безопасности:**
- Firewall правила
- SELinux/AppArmor политики  
- Регулярные аудиты контейнеров
- Сканирование образов на уязвимости

</details> 

---

### 📌 Точка расширения 1.2: Настройка системного времени
**Зачем это нужно:**
- **Корректные логи**: Временные метки в логах соответствуют рабочему времени сотрудников
- **Интеграция с корпоративными системами**: Синхронизация времени с AD, LDAP, системами мониторинга
- **Аудит и compliance**: Правильные временные метки для соответствия регулятивным требованиям
- **Удобство администрирования**: Понятное время в интерфейсах мониторинга и логах

**Что можно добавить:**
```bash
# Для Москвы
sudo timedatectl set-timezone Europe/Moscow
sudo systemctl enable systemd-timesyncd
sudo systemctl start systemd-timesyncd
```

---

## Шаг 2. Создание рабочей директории

### 📌 Точка расширения 2.1: Размещение данных
**Зачем это нужно:**
- **Корпоративные стандарты**: Унификация путей размещения приложений (/opt, /srv)
- **Резервное копирование**: Централизованное хранение для включения в backup-политики
- **Масштабируемость**: Возможность использования сетевых хранилищ при росте нагрузки
- **Восстановление после сбоев**: Быстрое восстановление сервиса с другого сервера

**Что можно добавить:**
- Использование стандартного корпоративного пути (/opt/openwebui)
- Подключение к сетевому хранилищу (NFS, CIFS)
- Настройку прав доступа к директориям

---

## Шаг 3. Создание файла docker-compose.yml

### 📌 Точка расширения 3.1: Переменные окружения
**Зачем это нужно:**
- **Контроль доступа**: Отключение публичной регистрации предотвращает несанкционированный доступ
- **Интеграция с внешними API**: Подключение к OpenAI, Claude или другим сервисам без хардкода ключей
- **Корпоративная сеть**: Настройка прокси для работы через корпоративный файервол
- **Масштабирование**: Гибкость конфигурации без пересборки контейнеров

**Что можно добавить в environment:**
```yaml
environment:
  - OPENAI_API_KEY=${OPENAI_API_KEY}
  - ALLOW_REGISTRATION=false
  - OLLAMA_API_URL=http://ollama:11434
  - HTTP_PROXY=http://proxy.company.com:8080
  - HTTPS_PROXY=http://proxy.company.com:8080
```

### 📌 Точка расширения 3.2: Подключение к Ollama или другому backend
**Зачем это нужно:**
- **Независимость от внешних сервисов**: Локальные модели не передают данные третьим лицам
- **Соблюдение политик конфиденциальности**: Важные корпоративные данные остаются в периметре компании
- **Контроль затрат**: Избежание платы за API внешних сервисов
- **Производительность**: Отсутствие задержек при обращении к внешним API

**Что можно добавить:**
```yaml
services:
  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    restart: unless-stopped

  openwebui:
    # ... остальная конфигурация
    environment:
      - OLLAMA_API_URL=http://ollama:11434
    depends_on:
      - ollama

volumes:
  openwebui-data:
  ollama:
```

### 📌 Точка расширения 3.3: Мониторинг и логирование
**Зачем это нужно:**
- **Операционный контроль**: Отслеживание работоспособности сервиса 24/7
- **Диагностика проблем**: Быстрое выявление и устранение неисправностей
- **Аудит использования**: Понимание нагрузки и паттернов использования сотрудниками
- **Соответствие требованиям**: Многие компании обязаны ведением логов по регулятивным требованиям

**Что можно добавить:**
- Docker logging driver (json-file, syslog, gelf)
- Интеграцию с Prometheus/Grafana для метрик
- Централизованное логирование через ELK Stack или Loki


Отличная идея! PostgreSQL для корпоративного использования действительно важен. Это логично добавить как **точку расширения 3.4** в рамках создания docker-compose.yml, поскольку требует изменения архитектуры и конфигурации системы.

---

### 📌 Точка расширения 3.4: Настройка внешней базы данных (PostgreSQL)

**Зачем это нужно:**
- **Производительность**: PostgreSQL значительно быстрее SQLite при множественных одновременных подключениях (>10 пользователей)
- **Масштабируемость**: Возможность горизонтального масштабирования и кластеризации
- **Резервное копирование**: Профессиональные инструменты бэкапа и восстановления данных
- **Высокая доступность**: Репликация и failover для критически важных систем
- **Корпоративные стандарты**: Интеграция с существующей инфраструктурой БД и политиками безопасности
- **Совместное использование**: Несколько инстансов OpenWebUI могут использовать одну БД

**Когда использовать:**
- ✅ Больше 10-15 одновременных пользователей
- ✅ Критически важные данные чатов
- ✅ Необходимость профессионального бэкапа
- ✅ Планы масштабирования
- ❌ Для тестирования или малых команд (до 5 человек) достаточно SQLite

**Варианты использования и настройки:**
- Вариант A: PostgreSQL в том же docker-compose (простой)
- Вариант B: Расширенная конфигурация PostgreSQL (продакшен)
- Вариант C: Подключение к внешней PostgreSQL (существующая корпоративная БД):
  
**Рекомендации по выбору:**
| Размер команды | Рекомендация |
|----------------|-------------|
| 1-5 пользователей | SQLite (по умолчанию) |
| 5-20 пользователей | PostgreSQL в Docker (Вариант A) |
| 20+ пользователей | PostgreSQL продакшен (Вариант B) |
| Корпоративная среда | Внешняя PostgreSQL (Вариант C) |

#### **Вариант A: PostgreSQL в том же docker-compose (простой)**
<details><summary>Посмотреть...</summary></summary>

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: openwebui-postgres
    environment:
      POSTGRES_DB: openwebui
      POSTGRES_USER: openwebui_user
      POSTGRES_PASSWORD: your_secure_password_here
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: unless-stopped
    # Опционально: ограничить доступ только от OpenWebUI
    networks:
      - openwebui-network

  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "127.0.0.1:3000:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      # Подключение к PostgreSQL
      - DATABASE_URL=postgresql://openwebui_user:your_secure_password_here@postgres:5432/openwebui
      - WEBUI_URL=https://openwebui.company.local
    networks:
      - openwebui-network

volumes:
  openwebui-data:
  postgres-data:

networks:
  openwebui-network:
    driver: bridge
```

</details>

#### **Вариант B: Расширенная конфигурация PostgreSQL (продакшен)**

<details><summary>Посмотреть...</summary></summary>


```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: openwebui-postgres
    environment:
      POSTGRES_DB: openwebui
      POSTGRES_USER: openwebui_user
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
      # Настройки производительности
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=ru_RU.UTF-8"
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./postgres-init:/docker-entrypoint-initdb.d/:ro
    restart: unless-stopped
    networks:
      - openwebui-network
    # Настройки производительности
    command: >
      postgres
      -c max_connections=100
      -c shared_buffers=256MB
      -c effective_cache_size=1GB
      -c maintenance_work_mem=64MB
      -c checkpoint_completion_target=0.9
      -c wal_buffers=16MB
      -c default_statistics_target=100
      -c random_page_cost=1.1
      -c effective_io_concurrency=200
    # Мониторинг здоровья
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U openwebui_user -d openwebui"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Бэкап PostgreSQL (опционально)
  postgres-backup:
    image: postgres:15-alpine
    container_name: openwebui-backup
    depends_on:
      - postgres
    environment:
      POSTGRES_USER: openwebui_user
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password
      POSTGRES_DB: openwebui
    volumes:
      - ./backups:/backups
    networks:
      - openwebui-network
    # Запуск только для бэкапа (не постоянный сервис)
    restart: "no"
    entrypoint: |
      bash -c '
      set -e
      echo "Waiting for postgres..."
      while ! pg_isready -h postgres -U openwebui_user; do
        sleep 1
      done
      echo "Creating backup..."
      pg_dump -h postgres -U openwebui_user -d openwebui > /backups/openwebui-$$(date +%Y%m%d_%H%M%S).sql
      echo "Backup completed"
      '

  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "127.0.0.1:3000:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      # Подключение к PostgreSQL с connection pooling
      - DATABASE_URL=postgresql://openwebui_user:your_secure_password_here@postgres:5432/openwebui?sslmode=prefer&connect_timeout=10
      - WEBUI_URL=https://openwebui.company.local
    networks:
      - openwebui-network

volumes:
  openwebui-data:
  postgres-data:
    # Опционально: использовать внешний volume для бэкапов
    driver: local
    driver_opts:
      type: none
      device: /opt/openwebui/postgres-data
      o: bind

networks:
  openwebui-network:
    driver: bridge

secrets:
  postgres_password:
    file: ./secrets/postgres_password.txt
```

#### **Создание файла с паролем (для безопасности):**

```bash
# Создать директорию для секретов
mkdir -p secrets

# Создать файл с паролем (сгенерировать случайный)
openssl rand -base64 32 > secrets/postgres_password.txt
chmod 600 secrets/postgres_password.txt

# Для простой конфигурации можно использовать переменную окружения
echo "DATABASE_PASSWORD=$(openssl rand -base64 32)" >> .env
```
</details>



#### **Вариант C: Подключение к внешней PostgreSQL (существующая корпоративная БД):**

<details><summary>Посмотреть...</summary></summary>

```yaml
version: '3.8'

services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "127.0.0.1:3000:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    environment:
      # Подключение к внешней PostgreSQL
      - DATABASE_URL=postgresql://openwebui_user:${DB_PASSWORD}@db.company.local:5432/openwebui?sslmode=require
      - WEBUI_URL=https://openwebui.company.local

volumes:
  openwebui-data:
```

#### **Настройка PostgreSQL на стороне DBA:**

```sql
-- Создание пользователя и базы данных
CREATE USER openwebui_user WITH ENCRYPTED PASSWORD 'secure_password';
CREATE DATABASE openwebui OWNER openwebui_user;
GRANT ALL PRIVILEGES ON DATABASE openwebui TO openwebui_user;

-- Для безопасности: ограничения подключений
ALTER USER openwebui_user CONNECTION LIMIT 20;
```

#### **Миграция с SQLite на PostgreSQL:**

```bash
# 1. Остановить OpenWebUI
docker-compose down

# 2. Экспортировать данные из SQLite (если есть)
# (OpenWebUI автоматически создаст схему в PostgreSQL)

# 3. Обновить docker-compose.yml с PostgreSQL

# 4. Запустить с новой конфигурацией
docker-compose up -d

# 5. Проверить логи
docker logs openwebui
docker logs openwebui-postgres
```

#### **Мониторинг и обслуживание:**

```bash
# Проверить статус БД
docker exec openwebui-postgres pg_isready -U openwebui_user

# Посмотреть размер БД
docker exec openwebui-postgres psql -U openwebui_user -d openwebui -c "
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    most_common_vals
FROM pg_stats 
WHERE schemaname = 'public';"

# Создать бэкап вручную
docker exec openwebui-postgres pg_dump -U openwebui_user openwebui > backup_$(date +%Y%m%d).sql

# Восстановить из бэкапа
docker exec -i openwebui-postgres psql -U openwebui_user openwebui < backup_20241201.sql
```

</details>

---

## Шаг 4. Запуск контейнера

### 📌 Точка расширения 4.1: Управление жизненным циклом
**Зачем это нужно:**
- **Непрерывность работы**: Автоматический перезапуск после сбоев сервера или обновлений ОС
- **Актуальность ПО**: Своевременное получение обновлений безопасности
- **Снижение нагрузки на IT**: Автоматизация рутинных задач обслуживания
- **Предсказуемость**: Стандартизация процедур развертывания и обновления

**Что можно добавить:**
- Watchtower для автообновления контейнеров
- systemd-сервис для автозапуска
- Скрипты health-check'ов
- Процедуры graceful shutdown

---

## Шаг 5. Доступ и авторизация

### 📌 Точка расширения 5.1: Аутентификация и авторизация
**Зачем это нужно:**
- **Интеграция с корпоративной инфраструктурой**: Единый вход (SSO) через Active Directory/LDAP
- **Контроль доступа**: Разграничение прав между отделами (HR не видит техдокументацию)
- **Безопасность**: Предотвращение несанкционированного доступа к AI-системе
- **Аудит**: Отслеживание действий конкретных пользователей для compliance

**Что можно добавить:**
- LDAP/AD интеграцию через переменные окружения
- OIDC подключение (если поддерживается)
- Отключение самостоятельной регистрации: `ALLOW_REGISTRATION=false`
- Настройку ролевой модели (admin, moderator, user)

### 📌 Точка расширения 5.2: HTTPS и обратный прокси
**Зачем это нужно:**
- **Безопасность передачи данных**: Шифрование трафика для защиты конфиденциальных запросов
- **Соответствие политикам**: Многие компании требуют HTTPS для всех внутренних сервисов
- **Интеграция с инфраструктурой**: Использование корпоративных сертификатов и load balancer'ов
- **Производительность**: Кеширование, сжатие, rate limiting

**Что можно добавить:**
- Nginx/Caddy конфигурацию для reverse proxy
- Let's Encrypt или корпоративные сертификаты
- Настройку WAF (Web Application Firewall)
- Rate limiting для защиты от злоупотреблений


Отлично! Вот обновленная точка расширения 5.2 с добавлением Caddy:

---

### 📌 Точка расширения 5.2: HTTPS и обратный прокси

**Зачем это нужно:**
- **Безопасность передачи данных**: Шифрование трафика для защиты конфиденциальных запросов к AI
- **Соответствие политикам**: Многие компании требуют HTTPS для всех внутренних сервисов
- **Интеграция с инфраструктурой**: Использование корпоративных сертификатов и load balancer'ов
- **Производительность**: Кеширование, сжатие, rate limiting для защиты от злоупотреблений
- **Удобство доступа**: Красивый URL вместо IP:порт (https://ai.company.com вместо http://192.168.1.100:3000)

**Варианты реализации:**
- Вариант A: Caddy (рекомендуется для простоты) [Документация...](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)
- Вариант B: Nginx (для существующей инфраструктуры) [Документация...](https://nginx.org/en/docs/install.html)
  
| Критерий | Caddy | Nginx |
|----------|-------|-------|
| **Простота настройки** | ✅ Очень простая | ⚠️ Требует опыта |
| **Автоматический HTTPS** | ✅ Встроено | ❌ Нужен certbot |
| **Производительность** | ✅ Хорошая | ✅ Отличная |
| **Гибкость** | ✅ Достаточная | ✅ Максимальная |
| **Корпоративная поддержка** | ✅ Есть | ✅ Отлична |
| **Потребление ресурсов** | ✅ Низкое | ✅ Очень низкое |

**Рекомендация:** Для быстрого внедрения используйте **Caddy**, для максимального контроля и интеграции с существующей инфраструктурой — **Nginx**.

#### **Вариант A: Caddy (рекомендуется для простоты)**
<details><summary>Посмотреть...</summary>

**Установка Caddy:**
```bash
# Ubuntu/Debian
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy
```

**Минимальная конфигурация Caddyfile:**
```bash
# Создать конфигурацию
sudo nano /etc/caddy/Caddyfile

# Содержимое файла:
openwebui.company.local {
    reverse_proxy localhost:3000
}
```

**Расширенная корпоративная конфигурация:**
```caddy
openwebui.company.local {
    # Использование корпоративных сертификатов
    tls /etc/ssl/certs/company.crt /etc/ssl/private/company.key
    
    # Или автоматические Let's Encrypt (для внешних доменов)
    # tls your-email@company.com

    # Ограничение доступа по IP
    @internal_only {
        remote_ip 192.168.1.0/24 10.0.0.0/8
    }
    handle @internal_only {
        # Заголовки безопасности
        header {
            X-Frame-Options DENY
            X-Content-Type-Options nosniff
            X-XSS-Protection "1; mode=block"
            Strict-Transport-Security "max-age=31536000; includeSubDomains"
        }

        # Логирование
        log {
            output file /var/log/caddy/openwebui.log {
                roll_size 10MiB
                roll_keep 5
            }
            format json
        }

        # Rate limiting (защита от злоупотреблений)
        rate_limit {
            zone dynamic {
                key {remote_host}
                events 20
                window 1m
            }
        }

        # Reverse proxy с настройками для AI
        reverse_proxy localhost:3000 {
            # Увеличенные таймауты для длинных ответов AI
            transport http {
                dial_timeout 60s
                response_header_timeout 300s
            }
            
            # Передача реального IP
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-Proto {scheme}
        }
    }

    # Блокировка внешних IP
    handle {
        respond "Access denied" 403
    }
}
```

**Запуск Caddy:**
```bash
# Проверить конфигурацию
sudo caddy validate --config /etc/caddy/Caddyfile

# Запустить и включить автозагрузку
sudo systemctl enable caddy
sudo systemctl start caddy
sudo systemctl status caddy
```
</details>

#### **Вариант B: Nginx (для существующей инфраструктуры)**

<details><summary>Посмотреть...</summary>
  
**Установка и базовая настройка:**
```bash
# Установка
sudo apt install nginx

# Создание конфигурации
sudo nano /etc/nginx/sites-available/openwebui
```

**Конфигурация Nginx:**
```nginx
# Редирект HTTP на HTTPS
server {
    listen 80;
    server_name openwebui.company.local;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name openwebui.company.local;

    # SSL сертификаты
    ssl_certificate /etc/ssl/certs/company.crt;
    ssl_certificate_key /etc/ssl/private/company.key;
    
    # Современные SSL настройки
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Ограничение по IP (корпоративная сеть)
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;

    # Безопасность заголовков
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=openwebui:10m rate=10r/m;
    limit_req zone=openwebui burst=20 nodelay;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Таймауты для AI
        proxy_read_timeout 300s;
        proxy_send_timeout 60s;
    }

    access_log /var/log/nginx/openwebui_access.log;
    error_log /var/log/nginx/openwebui_error.log;
}
```

**Активация Nginx:**
```bash
sudo ln -s /etc/nginx/sites-available/openwebui /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### **Обновление docker-compose.yml для работы с proxy:**

```yaml
version: '3.8'

services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "127.0.0.1:3000:8080"  # Привязка только к localhost
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    environment:
      - WEBUI_URL=https://openwebui.company.local

volumes:
  openwebui-data:
```

#### **Настройка DNS и сертификатов:**

```bash
# Добавить запись в /etc/hosts (временно для тестирования)
echo "127.0.0.1 openwebui.company.local" | sudo tee -a /etc/hosts

# Или в корпоративном DNS создать A-запись:
# openwebui.company.local -> IP-сервера

# Разместить корпоративные сертификаты
sudo cp company.crt /etc/ssl/certs/
sudo cp company.key /etc/ssl/private/
sudo chmod 600 /etc/ssl/private/company.key
```

#### **Проверка работы:**

```bash
# Проверить доступность
curl -I https://openwebui.company.local

# Проверить SSL
echo | openssl s_client -connect openwebui.company.local:443 2>/dev/null | openssl x509 -noout -dates

# Проверить логи
sudo tail -f /var/log/caddy/openwebui.log
# или для Nginx:
sudo tail -f /var/log/nginx/openwebui_access.log
```
</details>
  
### 📌 Точка расширения 5.3: Интеграция с корпоративными системами
**Зачем это нужно:**
- **Автоматизация рабочих процессов**: Подключение к CRM, ERP, системам документооборота
- **Уведомления и алерты**: Информирование IT о критических событиях
- **Аналитика использования**: Интеграция с BI-системами для анализа эффективности
- **Соответствие процедурам**: Логирование в SIEM-системы для информационной безопасности

**Что можно добавить:**
- API интеграции с внутренними системами
- Webhook'и для уведомлений в Slack/Teams
- Интеграцию с системами мониторинга (Zabbix, Nagios)
- Экспорт логов в SIEM (Splunk, QRadar)
