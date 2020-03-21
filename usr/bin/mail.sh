#!/bin/sh

USERS="/etc/mailusers"
LOGFILE="/var/log/users.log"
VIRTUAL_USERS="/etc/dovecot/vusers.conf"
VIRTUAL_MAILBOX="/etc/postfix/virtual_mailbox"
VIRTUAL_ALIAS="/etc/postfix/virtual_alias"

timestamp() {
    if [ $# -eq 0 ]; then
        awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' < /dev/stdin
    else
        echo "$@" | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }'
    fi
}

log() {
    if [ $# -eq 0 ]; then
        timestamp < /dev/stdin >> $LOGFILE;
    else
        timestamp "$@" >> $LOGFILE;
    fi
}

run() {
    local CMD
    local OUT
    local RET

    CMD="$@"
    log "RUN: $CMD"
    OUT=$(eval $CMD 2>&1)
    RET=$?
    echo "$OUT" | log
    return $RET
}

update_user_databases() {
    # make sure vusers.conf exists
    touch   $VIRTUAL_USERS

    # create user databases for postfix
    touch   $VIRTUAL_ALIAS
    postmap $VIRTUAL_ALIAS
    touch   $VIRTUAL_MAILBOX
    postmap $VIRTUAL_MAILBOX
}

get_domains() {
    cat $USERS | cut -d":" -f1 | cut -d"@" -f2 | sort | uniq | tr "\n" " "
}

set_postfix_domains() {
    DOMAINS=$(get_domains $USERS)
    run "postconf -e 'virtual_mailbox_domains = $DOMAINS'"
    [ $? -eq 0 ] && log "Postfix is set to recognose following domains: $DOMAINS"
}

set_postfix_virtual_mailbox() {
    cat $USERS | cut -d ":" -f1 | sort | uniq | awk -F ":" '{OFS=" "; print $1,"OK"}' > $VIRTUAL_MAILBOX
}

set_dovecot_virtual_users() {
    cat $USERS | awk -F ":" '{OFS=""; print $1,":{PLAIN}",$2}' > $VIRTUAL_USERS
}

update() {
    # make sure that user database exists
    touch $USERS

    # set domains recognized by postfix
    set_postfix_domains

    # update mailboxes
    set_postfix_virtual_mailbox

    # update user accounts
    set_dovecot_virtual_users

    # create databases
    update_user_databases
}

start() {
    # allow services to start from a pid other than 1
    mkdir -p /run/openrc
    touch /run/openrc/softlevel

    # start service manager rc
    openrc

    # start postfix (smtp server)
    rc-service postfix start

    # start dovecot (pop3/imap server)
    rc-service dovecot start
}

stop() {
    # stop postfix (smtp server)
    rc-service postfix stop

    # stop dovecot (pop3/imap server)
    rc-service dovecot stop

    sleep 5
}

case "$1" in
    boot)
        update
        start
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    update)
        update
        ;;
    *)
        echo "Usage: $0 {boot|start|stop|restart|update}" 1>&2
        ;;
esac

