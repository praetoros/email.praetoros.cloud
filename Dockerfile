FROM alpine:3.10

# install service manager, postfix and dovecot
RUN apk update
RUN apk add --no-cache openrc postfix postfix-pcre postfix-openrc dovecot dovecot-pop3d dovecot-openrc cifs-utils

# create virtual mail group and user 'vmail'
RUN deluser vmail
RUN addgroup -S vmail
RUN adduser -h /var/mail -g vmail -s /sbin/nologin -G vmail -D vmail

# log files of dovecot must be owned by vmail, otherwise the dovecot
# process started by postfix cannot write to the log files
RUN mkdir -p /var/log
RUN touch /var/log/dovecot-info.log
RUN touch /var/log/dovecot.log
RUN chown vmail:vmail /var/log/dovecot.log
RUN chown vmail:vmail /var/log/dovecot-info.log

# create config directories
RUN mkdir -p /etc/dovecot
RUN mkdir -p /etc/postfix

# config for service manager
COPY etc/rc/rc.conf /etc

# config for dovecot
COPY etc/dovecot/dovecot.conf  /etc/dovecot

# config for postfix
COPY etc/postfix/main.cf       /etc/postfix
COPY etc/postfix/master.cf     /etc/postfix

# copy starting script
COPY usr/bin/mail.sh /mail.sh
COPY etc/mailusers etc/mailusers
COPY etc/virtual_alias etc/virtual_alias

# starting command
CMD ["/bin/sh"]

# expose ports:
#   - 25 : smtp
#   - 110: pop3
EXPOSE 25 110

