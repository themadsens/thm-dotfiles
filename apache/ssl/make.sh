# From https://gist.github.com/nrollr/4daba07c67adcb30693e

openssl genrsa -out server.key 2048
openssl genrsa -out fmmbp.key 2048
openssl rsa -in fmmbp.key -out fmmbp.key.rsa
vi fmmbp.conf
openssl req -new -key server.key -subj "/C=/ST=/L=/O=/CN=/emailAddress=/" -out server.csr
openssl req -new -key fmmbp.key.rsa -subj "/C=/ST=/L=/O=/CN=fmmbp/" -out fmmbp.csr -config fmmbp.conf
openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt
openssl x509 -req -extensions v3_req -days 3650 -in fmmbp.csr -signkey fmmbp.key.rsa -out fmmbp.crt -extfile fmmbp.conf
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain fmmbp.crt
