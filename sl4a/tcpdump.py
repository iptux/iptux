# tcpdump.py
# dump network packages
# ROOT permition needed to open raw socket
#
# Author: Tommy Alex
# Create: 2012-02-22 23:28


from __future__ import print_function
import struct
import socket, sys
from datetime import datetime


ETH_P_ALL = 0x3


def print_packet(data):
	now = datetime.now().time()
	print('+---------+---------------+----------+\n%s,%03d,000   ETHER\n|0   |' % (now.strftime('%H:%M:%S'), now.microsecond / 1000), sep = '', end = '')
	for i in data:
		print('%02x|' % (ord(i),), sep = '', end = '')
	print('\n')


def dump():
	s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
	s.settimeout(15)
	try:
		while True:
			data, address = s.recvfrom(4096)
			print_packet(data)
	finally:
		s.close()


if __name__ == '__main__':
	dump()

