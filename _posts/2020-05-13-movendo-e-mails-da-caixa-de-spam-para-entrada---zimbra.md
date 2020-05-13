---
date: 2020-05-13 16:34:08
layout: post
title: "Movendo E-mails da Caixa de Spam para Entrada em Lote - Zimbra"
subtitle:
description:
image: /assets/img/uploads/zimbralogo.jpg
optimized_image:
category: zimbra
tags: zimbra email
author:
paginate: false
---
Quem nunca teve que mover um e-mail importante da caixa de Spam para Entrada de algumas pessoas manualmente, com certeza você deve ter se perguntando se não dava pra automatizar esse trabalho massante no Zimbra, e eu respondo **sim** é possível.

Recentemente passei por tal situação e desenvolvi um pequeno script para ajudar vocês.

Basta substituir os argumentos correntamente:

- **domain** (seu domínio)
- **subject** (trecho do assunto do e-mail em questão)
- **fOrig** (pasta onde o e-mail se encontra, no meu caso é Spam ou *Junk*)
- **fDest** (pasta  onde o e-mail será movido, no meu caso é Entrada ou *Inbox*)

O script abaixo está disponível no meu [GitHub](https://github.com/cristianovisk/move-emails-zimbra-folder):

```$ git clone https://github.com/cristianovisk/move-emails-zimbra-folder```

Baixe com o comando acima, e em seguida execute com o usuário *zimbra*:

```$ sudo su zimbra```

```$ ./move-mail.sh -domain yourdomain.com -subject Word_In_Subject -fOrig Junk -fDest Inbox```

Agora é sentar tomar um café e esperar os e-mails serem movidos do Spam para a Caixa de Entrada de todas as contas.

**Observação:** O script foi feito para mover com base no assunto do e-mail, mas é totalmente possível edita-lo para mover com base no remetente ou destinatário, estou disponível para tirar dúvidas no Telegram.