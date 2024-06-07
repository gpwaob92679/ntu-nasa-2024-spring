#!/usr/bin/python3
import signal
import random

# Timeout
def alarm(second):
    def handler(signum, frame):
        print('I think you are disconnect... Bye!')
        exit()
    signal.signal(signal.SIGALRM, handler)
    signal.alarm(second)

if __name__ == '__main__':
    alarm(300)

    p, g, u = int(input('p = ')), int(input('g = ')), int(input('u = '))
    if u <= 0 or u >= p :
        print('Invalid u')
        exit()
    b = random.randint(2, p - 2)
    v = pow(g, b, p)
    print(f'v = {v}')

    w = pow(u, b, p)

    print('Ok. I received your password :D Thanks!')
