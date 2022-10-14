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
Quem nunca teve que mover um e-mail importante da caixa de Spam para Entrada de algumas pessoas manualmente, com certeza você deve ter se perguntando se não dava pra automatizar esse trabalho massante no Zimbra, e eu respondo **sim** é possível.

Recentemente passei por tal situação e desenvolvi um pequeno script para ajudar vocês.

Basta substituir os argumentos correntamente:

- **domain** (seu domínio)
- **subject** (trecho do assunto do e-mail em questão)
- **fOrig** (pasta onde o e-mail se encontra, no meu caso é Spam ou *Junk*)
- **fDest** (pasta  onde o e-mail será movido, no meu caso é Entrada ou *Inbox*)

O script abaixo está disponível no meu [GitHub](https://github.com/cristianovisk/move-emails-zimbra-folder):

    #!/bin/bash

    # Created by cristianovisk
    # Github https://github.com/cristianovisk
    # Site https://cristianovisk.github.io

    function moveMail {
        for email in `zmprov -l gaa | grep $domain`;
        do
            for msgid in `zmmailbox -z -m "$email" s -l 999 -t message "in:$fOrig subject: $subject" | grep mess | awk '{print $2}'`;
                do
                    echo "Msg from $email, is moved for Inbox folder - MsgID: $msgid"   
                    zmmailbox -z -m "$email" mm $msgid $fDest;
                done;
        done
    }

    if [ $# -lt 8 ];
    then
        echo -e "Your command line contains $# arguments\nNeed:\n-domain domain.com.br\n-subject word_in_subject_to_search\n-fOrig Junk\n-fDest Inbox"
    elif [ $# -lt 1 ];
    then
        echo "Your command line contains no arguments\nNeed:\n-domain domain.com.br\n-subject word_in_subject_to_search\n-fOrig Junk\n-fDest Inbox"
    elif [ $# -eq 8 ];
    then
        array=($@)
        for arg in {0..8};
        do
            if [[ ${array[$arg]} == '-domain' ]];then
                domain=${array[$arg+1]};
            elif [[ ${array[$arg]} == '-subject' ]];then
                subject=${array[$arg+1]};
            elif [[ ${array[$arg]} == '-fOrig' || ${array[$arg]} == '-forig' ]];then
                fOrig=${array[$arg+1]};
            elif [[ ${array[$arg]} == '-fDest' || ${array[$arg]} == '-fdest' ]];then
                fDest=${array[$arg+1]};
            fi
        done
        echo -e "Domain: $domain\nSubject: $subject\nFolder Orig: $fOrig\nFolder Dest: $fDest"
        echo -e "-------\nYou confirm the informations above ?\n1) Yes\n2) No"
        read op
        if [ $op -eq 1 ];
        then
            echo "Moving you e-mails... wait and drink a coffee!"
            moveMail
        elif [ $op -eq 2 ];
        then
            echo "Exiting script..."
            exit;
        else
            echo "Chose wrong...";
        fi
    fi

```$ git clone https://github.com/cristianovisk/move-emails-zimbra-folder```

Baixe com o comando acima, e em seguida execute com o usuário *zimbra*:

```$ sudo su zimbra```

```$ ./move-mail.sh -domain yourdomain.com -subject Word_In_Subject -fOrig Junk -fDest Inbox```

Agora é sentar tomar um café e esperar os e-mails serem movidos do Spam para a Caixa de Entrada de todas as contas.

**Observação:** O script foi feito para mover com base no assunto do e-mail, mas é totalmente possível edita-lo para mover com base no remetente ou destinatário, estou disponível para tirar dúvidas no Telegram.
