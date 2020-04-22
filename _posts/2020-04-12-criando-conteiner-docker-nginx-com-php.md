---
date: 2020-04-12 21:08:45
layout: post
title: "Criando contêiner Docker NGINX com PHP"
subtitle:
description:
image: /assets/img/uploads/dockernginxphp.png
optimized_image:
category: docker
tags: docker php nginx
author: 
paginate: false
---
Neste guia rápido irei mostrar como criar um contêiner passo a passo com NGINX e PHP 7.2.
Para iniciarmos iremos criar um arquivo Dockerfile que se baseará na imagem [PHP Oficial](https://hub.docker.com/layers/php/library/php/7.2.30-fpm-alpine3.11/images/sha256-6a15c85dd61538cccd7b6774a980d69a54eda84008979eabb4c09b42df586431?context=explore) Alpine Linux que temos no [Docker Hub](https://hub.docker.com/cristianovisk):
```Dockerfile - 1ª linha```

    FROM php:7.2-fpm-alpine3.11

Como a imagem já contém o PHP-FPM 7.2 precisaremos apenas instalar o NGINX e um Supervisor de processos simultâneos com o seguinte linha:

```Dockerfile - 2ª linha```
    
    RUN apk add --no-cache nginx supervisor

Precisamos agora criar um arquivo por nome *nginx.ini* para montarmos as configurações necessárias para o supervisor subir todos os processos corretamente:

```nginx.ini```

    [program:nginx]
    command=/usr/sbin/nginx -g "pid /run/nginx.pid; daemon off;"
    autostart=true
    autorestart=true
    startretries=5
    numprocs=1
    startsecs=0
    process_name=%(program_name)s_%(process_num)02d
    stderr_logfile=/var/log/nginx/%(program_name)s_stderr.log
    stderr_logfile_maxbytes=10MB
    stdout_logfile=/var/log/nginx/%(program_name)s_stdout.log
    stdout_logfile_maxbytes=10MB

    [program:php-fpm]
    command = /usr/local/sbin/php-fpm -FR
    user = root
    autostart = true
    stdout_logfile = /dev/stdout
    stdout_logfile_maxbytes = 0
    stderr_logfile = /dev/stderr
    stderr_logfile_maxbytes = 0
Em seguida adicionar no Dockerfile:

```Dockerfile - 3ª linha```

    COPY nginx.ini /etc/supervisor.d/nginx.ini

Agora criaremos um arquivo por nome *default.conf* com o intuito de configurarmos o NGINX para reconhecer arquivos **.php* e interpreta-los.

```default.conf```

    server {
            listen 80 default_server;
            listen [::]:80 default_server;
            root /var/www/html;
            index index.php index.html index.htm;
            location / {
                    try_files $uri $uri/ /index.php?$query_string;
            }
            location ~ \.php$ {
                    include fastcgi.conf;
                    fastcgi_read_timeout 300;
                    fastcgi_pass 127.0.0.1:9000;
                    fastcgi_split_path_info ^(.+\.php)(/.+)$;
                    include fastcgi_params;
                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    fastcgi_param PATH_INFO $fastcgi_path_info;
            }
            location ~ /\.ht {
                    deny all;
            }
    }
Adicionamos no Dockerfile:

```Dockerfile - 4ª linha```

    COPY default.conf /etc/nginx/conf.d/default.conf

*Opcional:* Para testarmos se o container foi configurado corretamente, adicionaremos o arquivo *index.php*.

```index.php```

    <?php
        phpinfo();
    ?>

Adicionamos também no nosso Dockerfile:

```Dockerfile - 5ª linha```

    COPY index.php /var/www/html/index.php

Adicionaremos dois comandos [sed](https://pt.wikipedia.org/wiki/Sed) com *RUN* para os últimos ajustes no ambiente:

```Dockerfile - 6ª linha```

    RUN sed -i 's/\;nodaemon\=false/nodaemon\=true/g' /etc/supervisord.conf ; \ # substituirá uma linha no arquivo de configuração para que o serviço supervisord não inicie no modo daemon.
        sed -i 's/user nginx\;/user www\-data\;/' /etc/nginx/nginx.conf # substituirá uma linha no arquivo de configuração do NGINX para que o mesmo suba todos os Workers com permissões do usuário www-data

Para finalizarmos, iremos informar ao nosso contêiner que executará o serviço do Supervisord, que por si subirá o *NGINX e PHP-FPM* com seus Workers.
```Dockerfile - 7ª linha```

    CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

O Dockerfile com todos os arquivos que criamos estará em meu [GitHub](https://github.com/cristianovisk/dockerfile_php_nginx):

    FROM php:7.2-fpm-alpine3.11
    LABEL maintainer=Cristianovisk
    LABEL baseimage=AlpinePHP
    RUN apk add --no-cache nginx \
            supervisor
    COPY nginx.ini /etc/supervisor.d/nginx.ini
    COPY default.conf /etc/nginx/conf.d/default.conf
    COPY index.php /var/www/html
    RUN sed -i 's/\;nodaemon\=false/nodaemon\=true/g' /etc/supervisord.conf ;\
        sed -i 's/user nginx\;/user www\-data\;/' /etc/nginx/nginx.conf
    CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

Agora é só criar a imagem com o comando ```docker build . -t nginx_php:1.0``` estando dentro da pasta com todos os arquivos:

![Dockerbuildimg](/assets/img/uploads/dockerbuild1.png)

E testamos com o comando ```docker run -d -p 80:80 --name nginx-php-image nginx_php:1.0```:


![Dockerrunimg](/assets/img/uploads/dockerrun1.png)

Acessamos pelo navegador [http://127.0.0.1/](http://127.0.0.1) e pronto:
![indexphpnginximg](/assets/img/uploads/indexphpnginximg1.png)
**Observação:** os plugins do PHP estão disponíveis a sua maioria no repositório Alpine basta instala-los. 
> **Exemplo:** ```apk update``` depois ```apk add php7-pgsql --no-cache```

Veja todos os complementos disponíveis:
```apk search php```
![apksearch](/assets/img/uploads/apksearchphp1.png)

A imagem estará disponível para download com o comando ```docker pull cristianovisk/nginx_php:latest```