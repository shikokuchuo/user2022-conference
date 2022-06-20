import numpy as np
import pynng
socket = pynng.Pair0(listen="ipc:///tmp/nanonext.socket")

raw = socket.recv()
array = np.frombuffer(raw)
print(array)
msg = array.tobytes()
socket.send(msg)
