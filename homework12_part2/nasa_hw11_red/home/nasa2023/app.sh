#!/bin/ash

while true; do
	nc -lvp 8888 -e python3 /home/nasa2023/app.py
done
