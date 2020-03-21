# docker-postfix-dovecot

Simple mailserver with postfix and dovecot, based on alpine linux and docker.

## Installation

To start the server, run the following

    # to build the docker image
    > bin/mail build
    # to run the container
    > bin/mail run
    # start the server
    > bin/mail start

## Verify
A set of users are created for testing. Usernames and passwords are located in etc/mailusers. Mail aliases can be created in etc/virtual_alias. Use any mail client (e.g., Thunderbird) and setup with the following settings:

|  Server           |  Servername  |  Port     |
|  :-------------:  |  :----:      |  :-----:  |
|  SMTP             |  localhost   |  9025     |
|  POP3             |  localhost   |  9110     |


