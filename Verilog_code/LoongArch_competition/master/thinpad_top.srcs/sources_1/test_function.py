import struct
import binascii

def int2bytes(val):
    return struct.pack('<I', val)

def bytes2hex(val):
    return ' '.join(f'\\x{b:02x}' for b in val)

USER_PROGRAM = binascii.unhexlify(
    # ###### User Program Assembly ######
    # __start:
    '0C048002'  # addi.w      $t0,$zero,0x1   # t0 = 1
    '0D048002'  # addi.w      $t1,$zero,0x1   # t1 = 1
    '04800015'  # lu12i.w     $a0,-0x7fc00    # a0 = 0x80400000
    '85808002'  # addi.w      $a1,$a0,0x20    # a1 = 0x80400020

    # loop:
    '8E351000'  # add.w       $t2,$t0,$t1     # t2 = t0+t1
    'AC018002'  # addi.w      $t0,$t1,0x0     # t0 = t1
    'CD018002'  # addi.w      $t1,$t2,0x0     # t1 = t2
    '8E008029'  # st.w        $t2,$a0,0x0
    '84108002'  # addi.w      $a0,$a0,0x4     # a0 += 4
    '85ECFF5F'  # bne         $a0,$a1,loop
    '2000004C'  # jirl        $zero,$ra,0x0
)

addr = 0x80100000
for i in range(0, len(USER_PROGRAM), 4):
    print(bytes2hex(b'A'))
    print(bytes2hex(int2bytes(addr + i)))
    print(bytes2hex(int2bytes(4)))
    print(bytes2hex(USER_PROGRAM[i:i+4]))

# print(bytes2hex(b'D'))
# print(bytes2hex(int2bytes(addr)))
# print(bytes2hex(int2bytes(len(USER_PROGRAM))))

# print(bytes2hex(b'G'))
# print(bytes2hex(int2bytes(addr)))