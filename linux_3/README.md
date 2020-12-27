# Homework Linux №3

## Задание:
1. Создание и контроль доступа групе пользователей.
    - [x] Создать нескольких пользователей, задать им пароли, домашние директории и шеллы;
    - [x] Создать группу admin;
    - [x] Включить нескольких из ранее созданных пользователей, а также пользователя root, в группу admin;
    - [x] Запретить всем пользователям, кроме группы admin, логин в систему по SSH в выходные дни (суббота и воскресенье, без учета праздников).
    - [ ] (Optional) С учётом праздничных дней.
    (Для упрощения проверки можно разрешить парольную аутентификацию по SSH и использовать ssh user@localhost проверяя логин с этой же машины)

2. Установить docker; дать конкретному пользователю:
    - [x] права работать с docker (выполнять команды docker ps и т.п.);
    - [ ] (Optional) возможность перезапускать демон docker (systemctl restart docker) не выдавая прав более, чем для этого нужно;

Выполнение:
1. Подготовим среду для работы.
```
    vagrant init hashicorp/bionic64
    vagrant up
    vagrant ssh
```
2. Дбоавим новых пользователей:

    `sudo useradd <имя> -m -p <пароль> -s /bin/bash`

    где, -m создаст домашнюю директорию с именем пользователя

    -p задаст пароль пользователю

    -s задаст стандартный шел

3. Создадим группу admin и добавим туда root и одного пользователя:

    `sudo groupadd admin`

    `sudo usermod -a -G admin root`

    `sudo usermod -a -G admin <имя_пользователя>`

4. Ограничим доступ по ssh всем пользователям кроме группы admin в выходные

Для начала установим PAM
`sudo apt install libpam-script`.
Далее создадим файл `/usr/share/libpam-script/pam_script_acct`, с таким кодом:
```bash
#!bin/bash
script="$1"
shift

if groups $PAM_USER | grep admin > /dev/null
then
        exit 0
else
        if [[ $(date +%u) -lt 6 ]]
        then
                exit 0
        else
                exit 1
        fi
fi

if [ ! -e "$script" ]
then
        exit 0
fi
```

Cделаем этот файл исполняемым

`sudo chmod +x /usr/share/libpam-script/pam_script_acct`


И затем добавляем записи в файл `/etc/pam.d/sshd`

```bash
#account    required     pam_time.so
account    required     pam_script.so
```

5. Установить докер и выдать его под контроль одному пользователю.

    `sudo apt install docker.io` (для Ubuntu)

    Для того что бы конкретный пользователь мог ползоваться Docker необходимо поменять права владения исполняемым файлом.

    `sudo chmod 750 /usr/bin/*docker*`  отберем права на использования

    `sudo setfacl u:<имя пользователя>:rx *docker*`  добавим ACL правило на исполнение и чтение пользователю





            
