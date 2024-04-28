#!/bin/bash

read -rs -p "Admin password (password for cn=admin,dc=nasa,dc=csie,dc=ntu): " \
  admin_password
echo
read -r -p "Username: " username
read -rs -p "Password: " password
echo
echo

hashed_password="$(slappasswd -s "${password}")"
max_uid="$(
  ldapsearch -LLL -Z -D cn=admin,dc=nasa,dc=csie,dc=ntu -w "${admin_password}" \
      -H ldapi:/// -b "ou=people,dc=nasa,dc=csie,dc=ntu" uidNumber |
    grep uidNumber: |
    sed 's/uidNumber: //g' |
    sort -n |
    tail -n 1
)"
next_uid="$(( "${max_uid}" + 1 ))"

echo "Adding user ${username}..."
echo "dn: uid=${username},ou=people,dc=nasa,dc=csie,dc=ntu"
echo "uidNumber: ${next_uid}"
echo "homeDirectory: /home/${username}"
echo

ldapadd -Z -D cn=admin,dc=nasa,dc=csie,dc=ntu -w "${admin_password}" \
  -H ldapi:///<<END
dn: uid=${username},ou=people,dc=nasa,dc=csie,dc=ntu
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: ${username}
uid: ${username}
uidNumber: ${next_uid}
gidNumber: 101
homeDirectory: /home/${username}
loginShell: /bin/bash
userPassword: ${hashed_password}
END
