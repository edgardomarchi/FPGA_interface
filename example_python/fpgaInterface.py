import numpy as np
import socket

s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('192.168.1.10', 7))


data = np.random.randint(0,100,10)
print(data)

s.send(data.tobytes())
print('Bytes sent: {0!s}'.format(len(data.tobytes())))
recvData = s.recv(len(data.tobytes()))
print('Bytes received: {0!s}'.format(len(recvData)))

rxData = np.frombuffer(recvData, dtype=int)
print(rxData)
