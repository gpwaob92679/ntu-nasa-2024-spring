#!/bin/ash

while true; do
	nc -lvp 9999 -e python3 /home/nasa2024/app.py
done
