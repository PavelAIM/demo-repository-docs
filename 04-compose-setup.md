# 🧾 Конфигурация docker-compose.yml
## Базовая конфигурация
### Создайте файл docker-compose.yml в директории проекта:

```bash
version: '3.8'

services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:latest
    container_name: openwebui
    ports:
      - "3000:8080"
    volumes:
      - openwebui-data:/app/backend/data
    restart: unless-stopped
    environment:
      - WEBUI_AUTH=true

volumes:
  openwebui-data:
```

```bash

```


<details>
  <summary>📌 Расширение: Переменные окружения  </summary>
## Основные переменные
```bash
    environment:
      # Отключение регистрации новых пользователей
      - WEBUI_AUTH=true
      - ALLOW_REGISTRATION=false
      
      # API ключи
      - OPENAI_API_KEY=sk-your-openai-key
      - ANTHROPIC_API_KEY=your-anthropic-key
      
      # Настройки интерфейса
      - WEBUI_NAME="Company Chat"
      - DEFAULT_LOCALE=ru-RU
```

```bash

```

```bash

```
```bash

```
```bash

```

</details>

<details>
  <summary>Расширение: Мониторинг и логирование</summary>
## Добавление мониторинга
```yaml
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --cleanup --interval 86400
    restart: unless-stopped
```
## Централизованное логирование
```yaml
  openwebui:
    # ... другие настройки
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

```bash

```
```bash

```
```bash

```

</details>


<details>
  <summary>Click to expand</summary>

```bash

```

```bash

```

```bash

```
```bash

```
```bash

```

</details>

