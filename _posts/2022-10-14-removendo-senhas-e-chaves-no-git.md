---
date: 2022-10-14 14:34:08
layout: post
title: "Removendo credenciais vazadas em histórico do Git"
subtitle:
description:
image: /assets/img/uploads/leaks_git.png
optimized_image:
category: appsec
tags: appsec github gitlab git secrets passwords
author: 
paginate: false
---
Atualmente tem se tornado comum a quantidade de empresas que tem seus dados roubados e estorquidos por pessoas mal intencionadas, e os valores somados as perdas estão apenas no começo início.

A preocupação das grandes como GitHub e Amazon, levou os mesmos a gerarem alertas automatizados no que tange a vazamento de chaves AWS.

Neste artigo iremos ensinar como remover as senhas e chaves de API em histórico sem ter que perder tudo e ter que refazer o `.git`, e sim recalculando as hashs dos commits, tendo o mínimo de impacto para uma grande equipe de desenvolvedores.

Tópico   | Nome
--------- | ------
1 | Instalando ferramenta
2 | Clonando repositório comprometido
3 | Limpando arquivos sensíveis
4 | Limpando strings sensíveis
5 | Removendo dados lixo
6 | Upload do novo repo mirror

----
----

**1. Instalando ferramentas**

A ferramenta utilizada para realizar a mágica será o [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) que precisa do Java para funcionar, a mesma irá recalcular a hash dos commits no qual iremos remover as strings ou arquivos sensíveis, evitando que a cadeia de lógica do GIT seja quebrada.

Vamos iniciar a instalação via Docker para facilitar nosso trabalho criando via Dockerfile:

```dockerfile
FROM alpine:3.16.2
WORKDIR /app
RUN apk update && apk add openjdk11-jre-headless && wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -O bfg.jar
ENTRYPOINT ["java", "-jar", "/app/bfg.jar"]
```

Agora vamos criar a imagem:
```shell
docker build -t bfg:latest .
```

Ou se preferir a imagem está disponível no meu Docker Hub [BFG](https://hub.docker.com/r/cristianovisk/bfg) digitando o comando:
```shell
docker pull cristianovisk/bfg:latest
```

**2. Clonando repositório comprometido**
