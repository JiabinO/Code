# ###### User Program Assembly ######
# __start:
80100000:  addi.w      $t0,$zero,0x1   # t0 = 1
80100004:  addi.w      $t1,$zero,0x1   # t1 = 1
80100008:  lu12i.w     $a0,-0x7fc00    # a0 = 0x80400000
8010000c:  addi.w      $a1,$a0,0x20    # a1 = 0x80400020
80100010:  add.w       $t2,$t0,$t1     # t2 = t0+t1
80100014:  addi.w      $t0,$t1,0x0     # t0 = t1
80100018:  addi.w      $t1,$t2,0x0     # t1 = t2
8010001c:  st.w        $t2,$a0,0x0
80100020:  addi.w      $a0,$a0,0x4     # a0 += 4
80100024:  bne         $a0,$a1,loop
80100028:  jirl        $zero,$ra,0x0