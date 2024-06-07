#!/usr/bin/python3
import signal
from Crypto.Util.number import long_to_bytes
from Crypto.Cipher import AES
import random

password = b'yLXGn4S3wYeAMnF7UySEsw9wMPdh5v2e'

# Timeout
def alarm(second):
    def handler(signum, frame):
        print('I think you are disconnect... Bye!')
        exit()
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(second)

if __name__ == '__main__':
    alarm(300)

    print('Hi nasa2024! I am nasa2023. Let\'s perform Diffie Hellman Key Exchange to send my password to you.')

    # Public parameters
    p = 22576738017835080262877843701749634850617615125854087739043526179744140537692546235303394342825099789672187131484809219828578209085434504812205466211809509312646010163420466911624570134938619901325974015691495758199847891029752021861010053488894613765091779498389361717199652203581458235912782404212189980887677364793502291589837490993625733938828495099140606994041074198876998848736729115104379412189526251092416512126001365278039535701527400528124922912992104175307434201957085685227920121496352427569705275331717292691027336085165189528066507004179996186174476800146427478310174828794820885700903184044808658319809
    g = 7
    print(f'Public Parameters: ')
    print(f'p = {p}')
    print(f'g = {g}')
    print('===' * 20)
    
    a = random.randint(2, p - 2)
    u = pow(g, a, p)

    print(f'u = {u}')

    v = int(input('v = '))

    if v <= 0 or v >= p :
        print('Invalid v')
        exit()
    
    w = pow(v, a, p)

    print('Good, I believe we build a shared secret that only you and I know.')
    print('Now, I will encrypt my password with AES in CBC mode using the first 16 bytes of shared secret (padding with zero byte until length of 16 bytes) as the key')
    print('===' * 20)
    
    key = long_to_bytes(w).ljust(16, b'\x00')[:16]
    # encrypt with cbc
    iv = random.randbytes(16)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    ciphertext = cipher.encrypt(password)
    print(f'IV in hex format: {iv.hex()}')
    print(f'Encrypted password in hex format: {ciphertext.hex()}')
    print('===' * 20)



