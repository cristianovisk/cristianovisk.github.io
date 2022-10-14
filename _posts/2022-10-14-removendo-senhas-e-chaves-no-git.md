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
WORKDIR /data
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

Vamos criar um ALIAS no BASH para facilitar o próximo passo, lembrando que o comando pode ser inserido no .bashrc do seu usuário para deixar permanente o comando.

```shell
alias bfg='docker run --rm -it -v "$(pwd)":/data bfg:latest'
```

*Obs:* se o procedimento estiver sendo feito no Powershell, basta trocar **bfg** no início dos comandos seguintes para `docker run --rm -it -v $PWD:/data bfg:latest`.

**2. Clonando repositório comprometido**

Por conta da natureza da alteração que será realizada no repositório destino, iremos realizar um clone espelhado com o seguinte comando:
```shell
git clone --mirror $URL_DO_SEU_REPOSITORIO
```
**Extra**: Caso queira detectar as senhas que estão vazadas no seu projeto, basta usar a ferramenta [GitLeaks](https://github.com/zricethezav/gitleaks) com o seguinte comando:
```shell
gitleaks detect -f json -v | jq '.Description, .Secret'
```
**3. Limpando arquivos sensíveis**

Caso seja algum arquivo em especifico que seja necessário remover por inteiro de um repositório como um Private Key de um JWT por exemplo, deve-se usar os seguintes comandos:
```shell
bfg --delete-files id_{dsa,rsa} my-repo.git
bfg --delete-files *.log my-repo.git
bfg --delete-files my_certificate.p12 my-repo.git
```

**4. Limpando strings sensíveis**

Na maioria das vezes o problema está em esquecer as chaves/senhas no código em si, vamos exemplificar o processo de remoção:
```shell
echo "senha_para_remover" >> remover.txt
echo "aws_key_para_remover" >> remover.txt
echo "jwt_private_key_para_remover" >> remover.txt
```

Agora basta executar o comando de remoção:
```shell
bfg --replace-text remover.txt my-repo.git
```

**5. Removendo dados lixo**

Para que as mudanças sejam efetivadas e seja removido todo lixo restante no diretório `.git`, basta executar este comando:
```shell
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

**6. Upload do novo repo mirror**

Simplesmente rode o PUSH:
```shell
git push
```

Após isso todas as strings contidas no arquivo `remover.txt` indicado no passo 4 foram trocadas por `***REMOVED***`.

*Atenção: Cuidado, não se deve indicar strings muito genéricas para evitar a remoção de código válido no seu projeto*