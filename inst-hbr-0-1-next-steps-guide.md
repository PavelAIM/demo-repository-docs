
# Руководстве по дополнительным настройкам
Ниже собраны возможности для расширения базовой инструкции, организованные по шагам установки, и рекомендуемый порядок внедрения в соответствии с важностью решаемых задач.

Для своей конкретной ситуации вы можете собрать список именно для вас и использовать его в AI-чат. Подробнее о том, как эффективно использовать AI-чат для настройки системы, читайте в [Расширяй и автоматизируй через AI-чат](inst-hbr-0-0.md#расширяй-и-автоматизируй-через-ai-чат).

## Рекомендуемый порядок внедрения:

[↑](#что-дальше)

**Высокий приоритет** (критично для продакшена):
- [1.1 Безопасность и управление правами](#точка-расширения-11-безопасность-docker)
- [5.1 Аутентификация и авторизация](#точка-расширения-51-аутентификация-и-авторизация)
- [5.2 HTTPS и обратный прокси](#точка-расширения-52-https-и-обратный-прокси)
- [3.4 Настройка внешней базы данных (PostgreSQL)](#точка-расширения-34-настройка-внешней-базы-данных-postgresql)
- [5.4 Конфигурация OpenWebUI для корпоративного использования](#точка-расширения-54-конфигурация-openwebui-для-корпоративного-использования)

**Средний приоритет** (важно для операционной деятельности):
- [3.3 Мониторинг и логирование](#точка-расширения-33-мониторинг-и-логирование)
- [4.1 Управление жизненным циклом](#точка-расширения-41-управление-жизненным-циклом)
- [3.2 Подключение к Ollama](#точка-расширения-32-подключение-к-ollama-или-другому-backend)
- [5.3 Интеграция с корпоративными системами](#точка-расширения-53-интеграция-с-корпоративными-системами)

**Низкий приоритет** (для оптимизации):
- [1.2 Настройка системного времени](#точка-расширения-12-настройка-системного-времени)
- [2.1 Размещение данных](#точка-расширения-21-размещение-данных)
- [3.1 Переменные окружения](#точка-расширения-31-переменные-окружения)

## Оглавление

- [Руководстве по дополнительным настройкам](#руководстве-по-дополнительным-настройкам)
  - [Рекомендуемый порядок внедрения:](#рекомендуемый-порядок-внедрения)
  - [Оглавление](#оглавление)
  - [Шаг 1. Установка Docker и Docker Compose](#шаг-1-установка-docker-и-docker-compose)
    - [Точка расширения 1.1: Безопасность Docker](#точка-расширения-11-безопасность-docker)
    - [Точка расширения 1.2: Настройка системного времени](#точка-расширения-12-настройка-системного-времени)
  - [Шаг 2. Создание рабочей директории](#шаг-2-создание-рабочей-директории)
    - [Точка расширения 2.1: Размещение данных](#точка-расширения-21-размещение-данных)
  - [Шаг 3. Создание файла docker-compose.yml](#шаг-3-создание-файла-docker-composeyml)
    - [Точка расширения 3.1: Переменные окружения](#точка-расширения-31-переменные-окружения)
    - [Точка расширения 3.2: Подключение к Ollama или другому backend](#точка-расширения-32-подключение-к-ollama-или-другому-backend)
    - [Точка расширения 3.3: Мониторинг и логирование](#точка-расширения-33-мониторинг-и-логирование)
    - [Точка расширения 3.4: Настройка внешней базы данных (PostgreSQL)](#точка-расширения-34-настройка-внешней-базы-данных-postgresql)
  - [Шаг 4. Запуск контейнера](#шаг-4-запуск-контейнера)
    - [Точка расширения 4.1: Управление жизненным циклом](#точка-расширения-41-управление-жизненным-циклом)
  - [Шаг 5. Доступ и авторизация](#шаг-5-доступ-и-авторизация)
    - [Точка расширения 5.1: Аутентификация и авторизация](#точка-расширения-51-аутентификация-и-авторизация)
    - [Точка расширения 5.2: HTTPS и обратный прокси](#точка-расширения-52-https-и-обратный-прокси)
    - [Точка расширения 5.3: Интеграция с корпоративными системами](#точка-расширения-53-интеграция-с-корпоративными-системами)
    - [Точка расширения 5.4: Конфигурация OpenWebUI для корпоративного использования](#точка-расширения-54-конфигурация-openwebui-для-корпоративного-использования)

---

## Шаг 1. Установка Docker и Docker Compose

[↑](#что-дальше)

### Точка расширения 1.1: Безопасность Docker

[↑](#что-дальше)

<details> <summary> Разница между "docker без sudo" и "Rootless mode"</summary>
  



**"Docker без sudo"** (реализовано в минимальной установке)

**Что это:**
```bash
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
 **Низкая** - участники группы `docker` фактически имеют root-доступ к системе

**Rootless mode (настоящая безопасность)** [документация](https://docs.docker.com/engine/security/rootless/)

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
 **Высокая** - реальная изоляция от host-системы

**Сравнение подходов**

| Критерий | Docker без sudo | Rootless mode |
|----------|------------------|---------------|
| **Сложность настройки** | Простая | Сложная |
| **Безопасность** | Низкая | Высокая |
| **Совместимость** | 100% | ~80% (есть ограничения) |
| **Производительность** | Максимальная | Немного ниже |
| **Корпоративное использование** | Не рекомендуется | Рекомендуется |

</details><br>

**Зачем это нужно:**
- **Минимизация рисков**: Предотвращение случайного получения root-доступа через Docker
- **Соответствие политикам безопасности**: Многие компании требуют запуск сервисов без root
- **Изоляция**: Защита хост-системы от потенциальных уязвимостей в контейнерах

**Варианты реализации:**

**Вариант A: Простой (docker без sudo)** (реализовано в минимальной установке)
```bash
# Быстро, но менее безопасно
sudo usermod -aG docker $USER
newgrp docker
```
 Плюсы: просто, быстро, полная совместимость  
 Минусы: низкая безопасность

**Вариант B: Безопасный (Rootless mode)**
```bash
# Сложнее, но безопаснее
curl -fsSL https://get.docker.com/rootless | sh
systemctl --user enable docker
systemctl --user start docker
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
```
 Плюсы: высокая безопасность  
 Минусы: сложная настройка, некоторые ограничения

**Вариант C: Корпоративный подход**
```bash
# Отдельный пользователь для Docker
sudo useradd -r -s /bin/false dockeruser
sudo usermod -aG docker dockeruser
# + настройка systemd сервиса от этого пользователя
```

<details> <summary>Рекомендации для корпоративной среды<summary>

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

</details><br> 

[↑](#что-дальше)

---

### Точка расширения 1.2: Настройка системного времени

[↑](#что-дальше)

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

[↑](#что-дальше)

---

## Шаг 2. Создание рабочей директории

[↑](#что-дальше)

### Точка расширения 2.1: Размещение данных

[↑](#что-дальше)
**Зачем это нужно:**
- **Корпоративные стандарты**: Унификация путей размещения приложений (/opt, /srv)
- **Резервное копирование**: Централизованное хранение для включения в backup-политики
- **Масштабируемость**: Возможность использования сетевых хранилищ при росте нагрузки
- **Восстановление после сбоев**: Быстрое восстановление сервиса с другого сервера

**Что можно добавить:**
- Использование стандартного корпоративного пути (/opt/openwebui)
- Подключение к сетевому хранилищу (NFS, CIFS)
- Настройку прав доступа к директориям

[↑](#что-дальше)

---

## Шаг 3. Создание файла docker-compose.yml

[↑](#что-дальше)

### Точка расширения 3.1: Переменные окружения

[↑](#что-дальше)
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

[↑](#что-дальше)

### Точка расширения 3.2: Подключение к Ollama или другому backend

[↑](#что-дальше)
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

[↑](#что-дальше)

### Точка расширения 3.3: Мониторинг и логирование

[↑](#что-дальше)
**Зачем это нужно:**
- **Операционный контроль**: Отслеживание работоспособности сервиса 24/7
- **Диагностика проблем**: Быстрое выявление и устранение неисправностей
- **Аудит использования**: Понимание нагрузки и паттернов использования сотрудниками
- **Соответствие требованиям**: Многие компании обязаны ведением логов по регулятивным требованиям

**Что можно добавить:**
- Docker logging driver (json-file, syslog, gelf)
- Интеграцию с Prometheus/Grafana для метрик
- Централизованное логирование через ELK Stack или Loki

[↑](#что-дальше)

---

### Точка расширения 3.4: Настройка внешней базы данных (PostgreSQL)

[↑](#что-дальше)

**Зачем это нужно:**
- **Производительность**: PostgreSQL значительно быстрее SQLite при множественных одновременных подключениях (>10 пользователей)
- **Масштабируемость**: Возможность горизонтального масштабирования и кластеризации
- **Резервное копирование**: Профессиональные инструменты бэкапа и восстановления данных
- **Высокая доступность**: Репликация и failover для критически важных систем
- **Корпоративные стандарты**: Интеграция с существующей инфраструктурой БД и политиками безопасности
- **Совместное использование**: Несколько инстансов OpenWebUI могут использовать одну БД

**Когда использовать:**
-  [ + ] Больше 10-15 одновременных пользователей
-  [ + ] Критически важные данные чатов
-  [ + ] Необходимость профессионального бэкапа
-  [ + ] Планы масштабирования
-  [ - ] Для тестирования или малых команд (до 5 человек) достаточно SQLite

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

**Вариант A: PostgreSQL в том же docker-compose (простой)**
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

</details><br><br>

**Вариант B: Расширенная конфигурация PostgreSQL (продакшен)**

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

**Создание файла с паролем (для безопасности):**

```bash
# Создать директорию для секретов
mkdir -p secrets

# Создать файл с паролем (сгенерировать случайный)
openssl rand -base64 32 > secrets/postgres_password.txt
chmod 600 secrets/postgres_password.txt

# Для простой конфигурации можно использовать переменную окружения
echo "DATABASE_PASSWORD=$(openssl rand -base64 32)" >> .env
```
</details><br>



**Вариант C: Подключение к внешней PostgreSQL (существующая корпоративная БД):**

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

**Настройка PostgreSQL на стороне DBA:**

```sql
-- Создание пользователя и базы данных
CREATE USER openwebui_user WITH ENCRYPTED PASSWORD 'secure_password';
CREATE DATABASE openwebui OWNER openwebui_user;
GRANT ALL PRIVILEGES ON DATABASE openwebui TO openwebui_user;

-- Для безопасности: ограничения подключений
ALTER USER openwebui_user CONNECTION LIMIT 20;
```

**Миграция с SQLite на PostgreSQL:**

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

**Мониторинг и обслуживание:**

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

[↑](#что-дальше)

</details><br>

---

## Шаг 4. Запуск контейнера

[↑](#что-дальше)

### Точка расширения 4.1: Управление жизненным циклом

[↑](#что-дальше)
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

[↑](#что-дальше)

---

## Шаг 5. Доступ и авторизация

[↑](#что-дальше)

### Точка расширения 5.1: Аутентификация и авторизация

[↑](#что-дальше)
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


**Вариант настройки: Корпоративная SSO через OAuth (docker-compose)**

<details><summary>Посмотреть…</summary>
  
**Создание файла с секретами:**

```bash
# Создать файл .env для безопасного хранения секретов
cat > .env << 'EOF'
OAUTH_CLIENT_SECRET=your-actual-secret-key-from-keycloak
OPENID_PROVIDER_URL=https://auth.company.ru/realms/company-realm/.well-known/openid-configuration
WEBUI_URL=https://ai.company.ru
EOF

# Защитить файл от чтения другими пользователями
chmod 600 .env
```

**docker-compose.yml с OAuth аутентификацией:**

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
    env_file:
      - .env
    environment:
      - OAUTH_CLIENT_ID=openwebui
      - OAUTH_SCOPES=openid email profile
      - OAUTH_PROVIDER_NAME=Company SSO
      - OAUTH_USERNAME_CLAIM=preferred_username
      - OAUTH_EMAIL_CLAIM=email
      - ENABLE_SIGNUP=false
      - DEFAULT_USER_ROLE=pending
      - OAUTH_ROLES_CLAIM=groups
      - OAUTH_ADMIN_ROLES=openwebui-admin
      - OAUTH_USER_ROLES=openwebui-user

volumes:
  openwebui-data:
```

**Пояснения по переменным окружения:**

- **OAUTH_CLIENT_ID** - идентификатор приложения в вашем Identity Provider
- **OAUTH_CLIENT_SECRET** - секретный ключ для аутентификации приложения  
- **OPENID_PROVIDER_URL** - URL конфигурации OIDC провайдера
- **OAUTH_SCOPES** - запрашиваемые разрешения (обычно "openid email profile")
- **OAUTH_PROVIDER_NAME** - название кнопки входа в интерфейсе
- **OAUTH_USERNAME_CLAIM** - поле для получения имени пользователя
- **OAUTH_ROLES_CLAIM** - поле для получения ролей пользователя

**Важное примечание:**

OAuth авторизация в примере настроена через KeyCloak - но у вас может быть другой OAuth OIDC провайдер (например Azure AD, Google Workspace, Okta, Auth0). Так или иначе, нужны OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, и OPENID_PROVIDER_URL. Настроить OAuth клиент в вашем Identity Provider должен ваш главный администратор, отвечающий за домен аутентификации и интеграцию приложений.

**Типичные URL для разных провайдеров:**

- **KeyCloak:** `https://auth.company.com/realms/realm-name/.well-known/openid-configuration`
- **Azure AD:** `https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration`
- **Google:** `https://accounts.google.com/.well-known/openid-configuration`
- **Okta:** `https://company.okta.com/.well-known/openid-configuration`

**Проверка работы OAuth:**

```bash
# Проверить логи контейнера
docker logs openwebui

# Проверить доступность OIDC конфигурации
curl https://auth.company.ru/realms/company-realm/.well-known/openid-configuration

# Открыть OpenWebUI - должна появиться кнопка "Login with Company SSO"
```

[↑](#что-дальше)

</details><br>

---

### Точка расширения 5.2: HTTPS и обратный прокси

[↑](#что-дальше)

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
| **Простота настройки** |  Очень простая |  [ **/!\\** ] Требует опыта |
| **Автоматический HTTPS** |  Встроено | [ **x** ] Нужен certbot |
| **Производительность** |  Хорошая |  Отличная |
| **Гибкость** |  Достаточная |  Максимальная |
| **Корпоративная поддержка** |  Есть |  Отлична |
| **Потребление ресурсов** |  Низкое |  Очень низкое |

**Рекомендация:** Для быстрого внедрения используйте **Caddy**, для максимального контроля и интеграции с существующей инфраструктурой — **Nginx**.

**Вариант A: Caddy (рекомендуется для простоты)**
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
</details><br>

####**Вариант B: Nginx (для существующей инфраструктуры)**

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

**Обновление docker-compose.yml для работы с proxy:**

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

**Настройка DNS и сертификатов:**

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

**Проверка работы:**

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

[↑](#что-дальше)

</details><br>

---

### Точка расширения 5.3: Интеграция с корпоративными системами

[↑](#что-дальше)
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

[↑](#что-дальше)

---

### Точка расширения 5.4: Конфигурация OpenWebUI для корпоративного использования

[↑](#что-дальше)

**Зачем это нужно:**
- **Безопасность и контроль**: Отключение нежелательных функций и ограничение доступа
- **Пользовательский опыт**: Настройка интерфейса под потребности сотрудников компании
- **Оптимизация затрат**: Выбор подходящих моделей и настройка их эффективного использования
- **Соответствие корпоративным политикам**: Адаптация под внутренние требования компании
- **Производительность**: Оптимизация работы системы под конкретную нагрузку

**Быстрый чек-лист по настройки:**

```bash

Фаза 1 (Минимальная настройка):
  Шаг 1: Самостоятельная регистрация отключена  
  Шаг 2: Подключение к AI-медиатору работает  
  Шаг 3: Показаны только нужные модели (4-5 штук)  
  Шаг 3: Настроены иконки и описания моделей  

Фаза 2 (Расширенная настройка):
  Шаг 4: Дешевая модель используется для генерации названий  
  Шаг 4: Интерфейс упрощен для корпоративного использования  
  Шаг 5: System prompt содержит информацию о компании  
  Шаг 6: Права пользователей соответствуют политикам компании  

Фаза 3 (Оптимизация):
  Шаг 7: Специализированные варианты моделей настроены  
  Шаг 8: Ограничения на загрузку файлов установлены  
  Шаг 9: Дополнительные интеграции (аудио, веб-поиск) настроены
```

---

**Последовательность настройки через Admin Panel:**

Шаг 1: Безопасность и доступ (Settings → General / Настройки → Общие)

<details><summary>Посмотреть…</summary>

```bash

Enable New Sign Ups / Разрешить новые регистрации: DISABLED
└── Предотвращает несанкционированную самостоятельную регистрацию

Default User Role / Роль пользователя по умолчанию: PENDING
└── Новые пользователи требуют одобрения администратора

Enable API Key Auth / Включить аутентификацию API-ключом: ENABLED
└── Позволяет интеграцию с внешними системами

Show Admin Details in Account Pending Overlay / Показывать данные администратора в уведомлении об ожидании: DISABLED
└── Скрывает контакты администратора от обычных пользователей

Enable Community Sharing / Включить общественный обмен: DISABLED
└── Предотвращает утечку внутренних промптов в публичные базы

Enable Message Rating / Включить оценку сообщений: DISABLED
└── Упрощает интерфейс для корпоративного использования

JWT Token Expiration / Срок действия JWT-токена: 2w
└── Баланс между безопасностью и удобством (перелогин раз в 2 недели)
```
</details><br>

Шаг 2: Подключение к AI-сервисам (Settings → Connections / Настройки → Подключения)

<details><summary>Посмотреть…</summary>

```bash

OpenAI API: ENABLED → Connect to AI-Mediator
└── Подключение к корпоративному AI-шлюзу

Ollama API: DISABLED
└── Отключаем, если используется только внешний API
```

</details><br>

Шаг 3: Настройка моделей (Settings → Models / Настройки → Модели)

<details><summary>Посмотреть…</summary>

```bash

Конфигурация моделей:

Нажать "Configure / Настроить" (иконка шестеренки)
Упорядочить модели по приоритету использования
Установить Default Model / Модель по умолчанию: Claude-3.7-Sonnet (или другую основную)
Для каждой модели:
├── Показать: оставить 4-5 наиболее релевантных
├── Скрыть: убрать экспериментальные и избыточные
├── Настроить иконки для удобной идентификации
├── Добавить краткие описания назначения модели
└── Задать system prompt / системный промпт с информацией о компании:

System Prompt пример:
"Ты AI-помощник компании [Название]. Помогаешь сотрудникам с:
- Анализом документов и данных
- Подготовкой презентаций и отчетов
- Решением рабочих задач
- Обучением и развитием

Используй markdown для форматирования ответов.
Соблюдай конфиденциальность корпоративной информации."
```
</details><br>

Шаг 4: Документы и RAG (Settings → Documents / Настройки → Документы)
<details><summary>Посмотреть…</summary>

```bash

  
Max Size / Максимальный размер: 5 MB
└── Разумное ограничение для корпоративных документов

Max Count / Максимальное количество: 5 Documents
└── Предотвращает перегрузку системы

Примечание: Расширенная настройка RAG требует отдельного тюнинга и может стать темой для дополнительной статьи
```
</details><br>

Шаг 5: Веб-поиск (Settings → Web Search / Настройки → Веб-поиск)

<details><summary>Посмотреть…</summary>

```bash  
Статус: DISABLED (на начальном этапе)

Для включения потребуется:
├── Google API Key (или другого поисковика)
├── Настройка корпоративных ограничений поиска
└── Политики использования внешних источников
```

</details><br>

Шаг 6: Интерфейс (Settings → Interface / Настройки → Интерфейс)

<details><summary>Посмотреть…</summary>

```bash  
Set Task Model / Установить модель для задач → External Models / Внешние модели: "gpt-4o-mini"
└── Использование дешевой модели для генерации названий чатов

Title Generation Prompt / Промпт для генерации заголовков:
"Create a concise, 3-5 word title summarizing the main topic of this prompt in its given language. RESPOND ONLY WITH THE TITLE TEXT. Prompt: {{prompt:middletruncate:1000}}"
└── Убирает emoji и делает названия более профессиональными

Enable Tags Generation / Включить генерацию тегов: DISABLED
└── Упрощает интерфейс для базового использования

Enable Retrieval Query Generation / Включить генерацию поисковых запросов: DISABLED
└── Отключить, если не используются Knowledge Bases

Enable Web Search Query Generation / Включить генерацию запросов веб-поиска: DISABLED
└── Отключить, если Web Search не используется
```

</details><br>


Шаг 7: Аудио (Settings → Audio / Настройки → Аудио)
<details><summary>Посмотреть…</summary>
  
```bash  
STT (Speech-to-Text) / Преобразование речи в текст: "Web API"
TTS (Text-to-Speech) / Преобразование текста в речь: "Web API"

└── Использование браузерных возможностей вместо нагрузки на сервер
└── Примечание: OpenAI Whisper пока недоступен через медиатор
```
</details><br>

Шаг 8: Права пользователей (Users → Groups → Default Permissions / Пользователи → Группы → Права по умолчанию)

<details><summary>Посмотреть…</summary>
  
```bash  
Prompts Access / Доступ к промптам: ENABLED
└── Рекомендуется разрешить для продуктивности

- Knowledge Bases Access / Доступ к базам знаний: зависит от готовности администрировать
- Model Presets Access / Доступ к пресетам моделей: зависит от продвинутости пользователей
- Tools Access / Доступ к инструментам: для простых внедрений лучше отключить вначале

Принцип: начать с минимальных прав, расширять по мере необходимости
```
</details><br>

Шаг 9: Продвинутая настройка моделей (Workspace → Models / Рабочее пространство → Модели)

<details><summary>Посмотреть…</summary>

```bash  
Создание специализированных вариантов моделей:
  
Например:
├── "Claude 3.7 Sonnet Thinking High"
│ └── Базовая модель + высокий уровень reasoning effort
├── "GPT-4o-mini High Reasoning"
│ └── Экономная модель с усиленными рассуждениями
└── "Gemini 2.5 Analysis Mode"
└── Специализированная настройка для анализа данных

Настройка reasoning_effort / уровня рассуждений: "low" | "medium" | "high"
```
</details><br>

[↑](#что-дальше)














