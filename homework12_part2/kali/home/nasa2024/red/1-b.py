from cryptography.hazmat.primitives import ciphers
from cryptography.hazmat.primitives.asymmetric import dh
from cryptography.hazmat.primitives.ciphers import algorithms
from cryptography.hazmat.primitives.ciphers import modes


def dh_shared_key(p: int, g: int, u: int) -> bytes:
    parameter_numbers = dh.DHParameterNumbers(p, g)
    parameter = parameter_numbers.parameters()
    server_public_numbers = dh.DHPublicNumbers(u, parameter_numbers)
    server_public_key = server_public_numbers.public_key()

    client_private_key = parameter.generate_private_key()
    print(f'x = {client_private_key.private_numbers().x}')
    print(f'v = {client_private_key.public_key().public_numbers().y}')

    shared_key = client_private_key.exchange(server_public_key)
    print(f'shared_key = {shared_key.hex()}')
    return shared_key


def aes_cbc_decrypt(ciphertext: bytes, key: bytes, iv: bytes) -> bytes:
    cipher = ciphers.Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()
    return decryptor.update(ciphertext) + decryptor.finalize()


def main():
    p = 22576738017835080262877843701749634850617615125854087739043526179744140537692546235303394342825099789672187131484809219828578209085434504812205466211809509312646010163420466911624570134938619901325974015691495758199847891029752021861010053488894613765091779498389361717199652203581458235912782404212189980887677364793502291589837490993625733938828495099140606994041074198876998848736729115104379412189526251092416512126001365278039535701527400528124922912992104175307434201957085685227920121496352427569705275331717292691027336085165189528066507004179996186174476800146427478310174828794820885700903184044808658319809
    g = 7
    u = int(input('u = '))

    aes_key = dh_shared_key(p, g, u)[:16]
    print(f'aes_key = {aes_key.hex()}')

    iv = bytes.fromhex(input('iv = '))
    ciphertext = bytes.fromhex(input('ecrypted password = '))
    print('decrypted password = '
          f'{aes_cbc_decrypt(ciphertext, aes_key, iv).decode()}')


if __name__ == '__main__':
    main()
