#!/bin/bash

read -rs -p "Admin password (password for cn=admin,dc=nasa,dc=csie,dc=ntu): " \
  admin_password
echo
read -r -p "Username: " username
echo

echo "Deleting user ${username}..."
echo "dn: uid=${username},ou=people,dc=nasa,dc=csie,dc=ntu"
echo

ldapdelete -Z -D cn=admin,dc=nasa,dc=csie,dc=ntu -w "${admin_password}" \
  -H ldapi:/// "uid=${username},ou=people,dc=nasa,dc=csie,dc=ntu"
