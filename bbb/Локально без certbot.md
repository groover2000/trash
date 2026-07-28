

### Выпустить сертификаты 


### Заменить их в greenlight , compose в папке root

```
/root/greenlight-v3/
```

Перед этим остановить или потом перегргузить контейнер 

*Остановить запустить*
```
docker-compose down
docker-compose up -d

```

*перегрузить*

```
docker compose restart

```

*docker-compose*

```docker
version: '3'

services:
  postgres:
    image: postgres:14.6-alpine3.17
    container_name: postgres
    restart: unless-stopped
    volumes:
      - ./data/postgres/14/database_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=c742ac863781845810625422647c0496572494405828f7fc

  redis:
    image: redis:6.2-alpine3.17
    container_name: redis
    restart: unless-stopped
    volumes:
      - ./data/redis/database_data:/data

  greenlight-v3:
    entrypoint: [bin/start]
    image: bigbluebutton/greenlight:v3
    container_name: greenlight-v3
    restart: unless-stopped
    env_file: .env
    ports:
      - 127.0.0.1:5050:3000
    logging:
      driver: journald
    volumes:
      - ./data/greenlight-v3/storage:/usr/src/app/storage
      - ./mycerts:/usr/local/share/ca-certificates
    depends_on:
      - postgres
      - redis

```

Где volumes mycerts - сертификаты для домена

``` bash
ls /root/greenlight-v3/mycerts

Пример - conference.sktek.local.crt  conference.sktek.local.key  sktek.crt

```
Обновить сертификаты в контейнере

```
docker exec greenlight-v3 update-ca-certificates
```

