from PIL import Image
import numpy as np


def main():
    a = Image.open('english-menu_A.png')
    b = Image.open('english-menu_B.png')
    a_array = np.asarray(a)
    b_array = np.asarray(b)

    xor_array = np.bitwise_xor(a_array, b_array)
    xor_image = Image.fromarray(xor_array)
    xor_image.save('xor.png')


if __name__ == '__main__':
    main()
