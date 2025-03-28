    .global _start
    .section text
_start:
.text
    li.w        $a0, 0x80400000
    li.w        $a1, 0x80410000
    li.w        $a2, 0x80420000
    li.w        $a3, 4
    or          $t8,$zero,$zero
loop1:
    beq         $t8,$a3,loop1end

    slli.w      $t0,$t8,2
    slli.w      $t2,$t8,9
    add.w       $t0,$a0,$t0
    add.w       $t2,$a1,$t2
    or          $t1,$zero,$zero
loop2:
    beq         $t1,$a3,loop2end

    ld.w        $t7,$t0,0x0             # a[i][k]的加载
    slli.w      $a4,$t1,9
    add.w       $a4,$a2,$a4
    or          $t4,$t2,$zero
    or          $t3,$zero,$zero
loop3:
    beq         $t3,$a3,loop3end

    addi.w      $t3,$t3,1
    ld.w        $t5,$t4,0x0             # 把c[i][j]之前的值调出来
    ld.w        $t6,$a4,0x0             # b[k][j] 的加载
    mul.w       $t5,$t7,$t5             # 
    addi.w      $a4,$a4,4
    addi.w      $t4,$t4,4
    add.w       $t5,$t6,$t5             # c[i][j] += a[i][k] * b[k][j]
    st.w        $t5,$a4,-4              # 写回到原来的地方
    b           loop3

loop3end:
    addi.w      $t1,$t1,1
    addi.w      $t0,$t0,512
    b           loop2

loop2end:
    addi.w      $t8,$t8,1
    b           loop1

loop1end:
    jirl        $zero,$ra,0x0