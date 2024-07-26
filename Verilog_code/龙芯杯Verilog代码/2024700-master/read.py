import cbor2
with open('sub45332brd10.cbor', 'rb') as f:
    data = cbor2.load(f)

print(data)