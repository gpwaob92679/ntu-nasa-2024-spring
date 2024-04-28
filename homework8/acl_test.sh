#!/bin/bash

check() {
  if (( $? != "$1" )); then
    echo "Test failed"
    exit 1
  fi
}

# (a) Users cannot change other users' information.
ldapmodify -Z -D uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu -w b12902110<<END
dn: uid=ta1,ou=people,dc=nasa,dc=csie,dc=ntu
changetype: modify
replace: cn
cn: ta1
END

check 50

ldapmodify -Z -D uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu -w b12902110<<END
dn: uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu
changetype: modify
replace: cn
cn: b12902110
END
check 0

# (b) Users cannot change UID, GID and home directory.
ldapmodify -Z -D uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu -w b12902110<<END
dn: uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu
changetype: modify
replace: homeDirectory
homeDirectory: /home/b12902110_changed
END
check 50

ldapmodify -Z -D uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu -w b12902110<<END
dn: uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu
changetype: modify
replace: uidNumber
uidNumber: 1001
END
check 50

ldapmodify -Z -D uid=ta1,ou=people,dc=nasa,dc=csie,dc=ntu -w ta1<<END
dn: uid=ta1,ou=people,dc=nasa,dc=csie,dc=ntu
changetype: modify
replace: homeDirectory
homeDirectory: /home/ta1_changed
END
check 50

ldapmodify -Z -D uid=ta1,ou=people,dc=nasa,dc=csie,dc=ntu -w ta1<<END
dn: uid=ta1,ou=people,dc=nasa,dc=csie,dc=ntu
changetype: modify
replace: uidNumber
uidNumber: 1002
END
check 50

# (c) Anonymous can read information except password.
ldapsearch -LLL -Z -x -b dc=nasa,dc=csie,dc=ntu "(objectClass=posixAccount)" | grep userPassword
check 1

ldapsearch -LLL -Z -D uid=ta1,ou=people,dc=nasa,dc=csie,dc=ntu -w ta1 -b dc=nasa,dc=csie,dc=ntu "(objectClass=posixAccount)"
ldapsearch -LLL -Z -D uid=b12902110,ou=people,dc=nasa,dc=csie,dc=ntu -w b12902110 -b dc=nasa,dc=csie,dc=ntu "(objectClass=posixAccount)"

echo "Success"
