//===========================================================================================
//This checks if the address in r0 points to a special 8- or 9-letter custom name.
//If it does, it will return the correct length in r0.
//If it doesn't, it will return r0 == 0.
//===========================================================================================

check_name:
push {r1,r5,lr}
mov  r5,#8
ldr  r1,=#0x200417E          // Flint's name in RAM = $200417E
cmp  r1,r0
beq  .fix_count

add  r1,#0x6C                // Lucas' name in RAM = $20041EA
cmp  r1,r0
beq  .fix_count

add  r1,#0x6C                // Duster's name in RAM = $2004256
cmp  r1,r0
beq  .fix_count

add  r1,#0x6C                // Kumatora's name in RAM = $20042C2
cmp  r1,r0
beq  .fix_count

add  r1,#0x6C                // Boney's name in RAM = $200432E
cmp  r1,r0
beq  .fix_count

add  r1,#0x6C                // Salsa's name in RAM = $200439A
cmp  r1,r0
beq  .fix_count

add  r1,#0xFC
add  r1,#0xFC
add  r1,#0xFC                // Claus's name in RAM = $200468E
cmp  r1,r0
beq  .fix_count

ldr  r1,=#0x2004EE2          // Hinawa's name in RAM = $2004EE2
cmp  r1,r0
beq  .fix_count

mov  r5,#8
add  r1,#0x10                // Claus' name #2 in RAM = $2004EF2
cmp  r1,r0                   // added in for v1.2, courtesy of Jeff
beq  .fix_count

mov  r5,#9
add  r1,#0x10                // Favorite Food in RAM = $2004F02
cmp  r1,r0
beq  .fix_count

mov  r5,#8
add  r1,#0x12                // Favorite Thing in RAM = $2004F14
cmp  r1,r0
beq  .fix_count

mov  r5,#16
add  r1,#0x12                // Player name in RAM = $2004F26
cmp  r1,r0
beq  .fix_count

mov  r5,#8
add  r1,#0xEC                // Slot 1 active name in RAM = $20050FE
add  r1,#0xEC
cmp  r1,r0
beq  .fix_count

add  r1,#0x64                // Slot 2 active name in RAM = $2005162
cmp  r1,r0
beq  .fix_count

b    +                       // if none of these, do the original code and leave

.fix_count:
mov  r0,r5
pop  {r1,r5,pc}

+
mov  r0,#0
pop  {r1,r5,pc}
