    .global _start
    .section text
_start:
.text
UTEST_STREAM:
    li.w        $a0,0x80100000
    li.w        $a1,0x80400000
    li.w        $a2,0x00000300
    add.w       $a2,$a0,$a2
stream_next:
    ld.w        $t0,$a0,0x0
    st.w        $t0,$a1,0x0
    addi.w      $a0,$a0,0x4
    addi.w      $a1,$a1,0x4
    bne         $a0,$a2,stream_next

    jirl        $zero,$ra,0x0