#!/bin/sh

USERS="/etc/mailusers"
VIRTUAL_USERS="/etc/dovecot/vusers.conf"
VIRTUAL_MAILBOX="/etc/postfix/virtual_mailbox"
VIRTUAL_ALIAS="/etc/postfix/virtual_alias"

update_user_databases() {
    # make sure vusers.conf exists
    touch   $VIRTUAL_USERS

    # create user databases for postfix
    touch   $VIRTUAL_ALIAS
    postmap $VIRTUAL_ALIAS
    echo "Created $VIRTUAL_ALIAS.db"

    touch   $VIRTUAL_MAILBOX
    postmap $VIRTUAL_MAILBOX
    echo "Created $VIRTUAL_MAILBOX.db"
}

get_domains() {
    cat $USERS | cut -d":" -f1 | cut -d"@" -f2 | sort | uniq | tr "\n" " "
}

set_postfix_domains() {
    DOMAINS=$(get_domains $USERS)
    postconf -e "virtual_mailbox_domains = $DOMAINS"
    echo "Postfix is set to recognose the following domains:"
    echo "    $(postconf -h 'virtual_mailbox_domains')"
}

set_postfix_virtual_mailbox() {
    cat $USERS | cut -d ":" -f1 | sort | uniq | awk -F ":" '{OFS=" "; print $1,"OK"}' > $VIRTUAL_MAILBOX
    echo "Created $VIRTUAL_MAILBOX:"
    cat $VIRTUAL_MAILBOX | sed 's:^:    :'
}

set_dovecot_virtual_users() {
    cat $USERS | awk -F ":" '{OFS=""; print $1,":{PLAIN}",$2}' > $VIRTUAL_USERS
    echo "Created $VIRTUAL_USERS:"
    cat $VIRTUAL_USERS | sed 's:^:    :'
}

update() {
    # make sure that user database exists
    touch $USERS
    echo "Using users file '$USERS'"
    cat $USERS | sed 's:^:    :'

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
    # trigger update if files are missing
    if [ ! -f "$VIRTUAL_USERS" -o ! -f "$VIRTUAL_MAILBOX.db" -o ! -f "$VIRTUAL_ALIAS.db" ]; then
        update
    fi

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
}

case "$1" in
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
        echo "Usage: $0 {start|stop|restart|update}" 1>&2
        ;;
esac


