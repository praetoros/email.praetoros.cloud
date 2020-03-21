# docker-postfix-dovecot

Simple mailserver with postfix and dovecot, based on alpine linux and docker. The server is build for the purpose of testing. It supports multiple (virtual) domains and users, and uses no encryption.

## Installation

To start the server, run the following

    # to build the docker image
    > bin/mail build
    # to run the container
    > bin/mail run
    # start the server
    > bin/mail start


## Verify
A set of users are created for testing. Usernames and passwords are located in etc/mailusers, and below. Mail aliases can be created in etc/virtual_alias.

|  Username           |  Password  |
|  :-------------:    |  :----:    |
|  user1@domain1.com  |  pass      |
|  user2@domain1.com  |  pass      |
|  user1@domain2.com  |  pass      |

Use any mail client (e.g., Thunderbird) and setup with the following settings:

|  Server           |  Servername  |  Port     |  SSL     |  Authentication   |
|  :-------------:  |  :----:      |  :-----:  |  :-----: |  :-----:          |
|  Outgoing: SMTP   |  localhost   |  9025     |  None    |  Normal password  |
|  Incomping: POP3  |  localhost   |  9110     |  None    |  Normal password  |


