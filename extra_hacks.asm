extra_hacks:

// ---------------------------------------------------------------------------------------
// Makes the Memo screen stretch vertically correctly.
// ---------------------------------------------------------------------------------------

.memo_stretch:
push {r0-r4,lr}
// ----------------------------------------------
// Fill 30040F0 with 1C8 00's
mov  r0,#0
push {r0}
mov  r0,sp
ldr  r1,=#0x30040F0
mov  r2,#1
lsl  r2,r2,#24                     // Fill
mov  r3,#0xE4
orr  r2,r3
swi  #0xB
add  sp,#4
// ----------------------------------------------
pop  {r0-r4}
mov  r2,#0                         // clobbered code
mov  r0,#5
pop  {pc}

// ---------------------------------------------------------------------------------------
// Fixes the string counter in the Memo screen. Possibly fixes things elsewhere.
// ---------------------------------------------------------------------------------------

.memo_counterfix1:
// Return length in r0
push {r0,r5,lr}
mov  r0,r4
bl   check_name
cmp  r0,#0
beq  +

add  sp,#4
pop  {r5,pc}

+
pop  {r0,r5}
mov  r1,r0                         // original code
lsl  r1,r1,#0x10
lsr  r1,r1,#0x10
ldr  r0,=#0x8D1EE78
bl   $800289C
ldrh r0,[r0,#0]
pop  {pc}

// ---------------------------------------------------------------------------------------
// Another string counter fixer. Fixes the [44 FF] code in particular.
// ---------------------------------------------------------------------------------------

.memo_counterfix2:
push {r0,lr}

// Address in r1, length in r2
mov  r0,r1
bl   check_name
cmp  r0,#0
beq  +
mov  r2,r0
+
lsl  r2,r2,#0x10                   // clobbered code
lsr  r5,r2,#0x10
pop  {r0,pc}

// ---------------------------------------------------------------------------------------
// Fixes text loading for the memoes menu
// ---------------------------------------------------------------------------------------
.memo_change_text_loading_routine:
sub  r0,r0,#1
lsl  r0,r0,#0x10
lsr  r6,r0,#0x10
bx   lr

// ---------------------------------------------------------------------------------------
// Fixes position of text in the memo screen
// ---------------------------------------------------------------------------------------

.memo_printfix_positionfix:
push {lr}
lsl  r1,r0,#1
add  r1,r1,r0
lsl  r1,r1,#2
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#5
bne  +
cmp  r0,#0xA
bne  .memo_printfix_positionfix_left
sub  r1,r1,#1                // Put this 1 pixel more to the left
b    +
.memo_printfix_positionfix_left:
add  r1,r1,#3                // Put this 3 pixels more to the right
+
strh r1,[r6,#0]
pop  {pc}

// ---------------------------------------------------------------------------------------
// Fixes printing in the memo screen. Vertical fix in order to allow more space per line
// ---------------------------------------------------------------------------------------

.memo_printfix_vertical:
push {lr}
bl   $8002FC0
ldr  r1,=#0x201A288
ldrb r1,[r1,#0]
cmp  r1,#6
bne  .memo_printfix_vertical_end
sub  r1,r4,#4
ldr  r1,[r1,#0]              //Get the height from the previous set of bytes
lsr  r0,r1,#0x1C
cmp  r0,#3
bgt  +
mov  r0,#3                   //Memoes start at a height of 3
+

.memo_printfix_vertical_end:
pop  {pc}

// ---------------------------------------------------------------------------------------
// Fixes printing in the memo screen. Changes how letters are stored
// ---------------------------------------------------------------------------------------

.memo_printfix_storage:
push {r3-r4,lr}
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +                       //Do this only for the memo menu

ldr  r0,=#0x201AEF8
ldrb r1,[r0,#3]
add  r1,#0x11
strb r1,[r0,#3]              //Store, as info, the Y we're currently at
ldr  r3,[r4,#0]
sub  r3,r6,r3                //Letters are now stored sequentially, not by line
lsl  r4,r1,#0x1C
lsr  r4,r4,#0x1C
lsr  r2,r3,#1
add  r2,r2,r4
add  r2,#1
strh r2,[r5,#0]


lsl  r3,r2,#2
add  r0,r0,r3
add  r0,#4
lsr  r1,r1,#4
lsl  r1,r1,#4
add  r1,#0x30
strb r1,[r0,#3]              //Store, as info, the Y this line should be at when printed
b    .memo_printfix_storage_end
+

ldrh r0,[r4,#8]              //Default code
strh r0,[r5,#0]
ldrh r0,[r5,#2]
add  r0,#1
strh r0,[r5,#2]

.memo_printfix_storage_end:
pop  {r3-r4,pc}

// ---------------------------------------------------------------------------------------
// Improves buffer size for the memo menus
// ---------------------------------------------------------------------------------------

.memo_expand_buffer_start_routine:
add  sp,#-0x100
add  sp,#-0x168
lsl  r0,r0,#0x10
bx   lr

.memo_expand_buffer_middle_routine:
ldr  r1,=#0x268
bx   lr

.memo_expand_buffer_end_routine:
add  sp,#0x100
add  sp,#0x168
pop  {r3}
bx   lr

.memo_expand_writing_buffer:
push {lr}
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
bne  +
lsl  r0,r0,#2
ldr  r1,=#0x201AEF8
add  r1,#8
add  r0,r1,r0
b    .memo_expand_writing_buffer_end

+
bl   $8049894

.memo_expand_writing_buffer_end:
pop  {pc}

// ---------------------------------------------------------------------------------------
// These hacks are for activating the Memo screen.
// ---------------------------------------------------------------------------------------

.memo_check:
push {r0,lr}
ldr  r0,=#0x4000130
ldrh r0,[r0,#0]
lsl  r0,r0,#0x16
lsr  r0,r0,#0x1E                   // r0 = (r0 & 0x300) >> 8
cmp  r0,#0                         // we're checking for at least L+R, so other buttons are irrelevant
pop  {r0}
beq  +
bl   $804BF34                      // Status
pop  {pc}
+
bl   $804BFCC                      // Memo
pop  {pc}

// ---------------------------------------------------------------------------------------
// This hack fixes the scrolly sprite flashing by enabling the OBJ layer indefinitely
// whenever a scrolly line is being executed.
// ---------------------------------------------------------------------------------------

.scrolly_sprite_fix:
push {r2,lr}
ldrh r1,[r4,#8]
mov  r0,#0xFF
and  r0,r1

// Check for scrolly text
ldr  r2,=#0x203FFF8
ldrh r1,[r2,#0]
cmp  r1,#0
bne  +                             // ignore if not block 0
ldrh r1,[r2,#2]

cmp  r1,#7
beq  .scrolly_do_fix

cmp  r1,#8
beq  .scrolly_do_fix

cmp  r1,#9
beq  .scrolly_do_fix

cmp  r1,#10
beq  .scrolly_do_fix

cmp  r1,#11
beq  .scrolly_do_fix

cmp  r1,#12
beq  .scrolly_do_fix

cmp  r1,#13
beq  .scrolly_do_fix

cmp  r1,#15
beq  .scrolly_do_fix

cmp  r1,#16
beq  .scrolly_do_fix

// Add other lines here if necessary

b    +

.scrolly_do_fix:
mov  r1,#0x80
lsl  r1,r1,#0x5
orr  r0,r1

+
ldrh r1,[r4,#8]
strh r0,[r4,#8]
pop  {r2,pc}

// ---------------------------------------------------------------------------------------
// This hack updates the 203FFF8 RAM area with the block # and line # so that the
// above fix doesn't constantly enable the OBJ layer when it shouldn't be.
// ---------------------------------------------------------------------------------------

// r6 >> 1 == block number
// r7 == line number

.scrolly_sprite_fix2:
push {r0,lr}
ldr  r0,=#0x203FFF8
lsr  r6,r6,#1
strh r6,[r0,#0]
strh r7,[r0,#2]
lsl  r6,r6,#1
pop  {r0}
bl   $800289C                      // clobbered code
pop  {pc}


// ---------------------------------------------------------------------------------------
// This hack moves the Key goods cursor left by one pixel in the left column.
// ---------------------------------------------------------------------------------------

.keygoods_cursorfix1:
and  r0,r1                         // clobbered code
mov  r2,#0xFF                      // r2 was originally 0, so to move it left we need to make it -1, or 0xFFFF (signed hword)
lsl  r2,r2,#0x8
add  r2,#0xFF
bx   lr

// ---------------------------------------------------------------------------------------
// PSI menu
.psi_cursorfix1:
and  r0,r1                         // clobbered code
mov  r2,#0xFF                      // we want -3
lsl  r2,r2,#0x8
add  r2,#0xFD
bx   lr

// ---------------------------------------------------------------------------------------
// Withdraw menu
.withdraw_cursorfix1:
and  r0,r1                         // clobbered code
mov  r2,#0xFF                      // we want -3
lsl  r2,r2,#0x8
add  r2,#0xFD
bx   lr

// ---------------------------------------------------------------------------------------
// Skills (other) menu
.skills_cursorfix1:
and  r0,r1                         // clobbered code
mov  r2,#0xFF                      // we want -5
lsl  r2,r2,#0x8
add  r2,#0xFB
bx   lr

// ---------------------------------------------------------------------------------------
// Memoes menu
.memoes_cursorfix1:
and  r0,r1                         // clobbered code
mov  r2,#0                         // we want -0x7
sub  r2,#7
lsl  r2,r2,#0x10
lsr  r2,r2,#0x10
bx   lr

//---------------------------------------------------------------------------------------
// Properly handles equipment position when removing multiple items from an inventory
//---------------------------------------------------------------------------------------
.position_equipment_item_removal:
push {r4-r7,lr}
mov  r7,r1
mov  r6,#0
mov  r3,#1
neg  r3,r3
add  r0,#0x38
mov  r5,r0
add  r4,r0,#4
-

ldrb r0,[r4,#0]
ldrb r1,[r7,#0]
cmp  r0,r1
beq  +
ldr  r0,[r5,#0]
mov  r1,r3
and  r1,r0
lsr  r1,r1,#1
neg  r2,r3
sub  r2,r2,#1
and  r2,r0
orr  r1,r2
str  r1,[r5,#0]
b    .position_equipment_item_removal_end_of_loop
+
add  r4,#1
lsl  r3,r3,#1
.position_equipment_item_removal_end_of_loop:
add  r7,#1
add  r6,#1
cmp  r6,#0xF
ble  -

.position_equipment_item_removal_end:
pop  {r4-r7,pc}

//---------------------------------------------------------------------------------------
// Sets the current money on hand to an arbitrary value - 04 00 9E 00
//---------------------------------------------------------------------------------------
.set_money_on_hand:
push {lr}
mov  r1,#0
bl   $8021914
ldr  r2,=#0x2004860
str  r0,[r2,#8]
mov  r0,#0
pop  {pc}

//---------------------------------------------------------------------------------------
// Pushes the current money on hand. If it's too high, set it to 10000 - 04 00 9F 00
//---------------------------------------------------------------------------------------
.push_money_on_hand:
push {lr}
ldr  r2,=#0x2004860
ldr  r0,[r2,#8]
ldr  r1,=#0xF423F          // Maximum money is 999999
cmp  r0,r1
ble  +
ldr  r1,=#0x2710           // Set it to 10000
str  r1,[r2,#8]
+
bl   $80218E8
mov  r0,#0
pop  {pc}
