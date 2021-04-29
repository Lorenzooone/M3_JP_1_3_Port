arch gba.thumb

//============================================================================================
//                                     DATA FILES
//============================================================================================

// relocate the big sound clip to the end of the ROM, freeing up hack space for us
org $8119C64; dd $9F92600
org $811B734; dd $9F92600
org $811F6DC; dd $9F92600
org $811FA90; dd $9F92600
org $812030C; dd $9F92600
org $9F92600; incbin sound_relocate_dump.bin

//============================================================================================
//                                  MEMO SCREEN STUFF
//============================================================================================

// Enable memo menu; hold Sel+L+R while loading the Status menu
org $804BE16; bl extra_hacks.memo_check

// Memo name counter fixes
org $8001DB0; push {lr}; bl extra_hacks.memo_counterfix1; pop {pc}
org $8048500; bl extra_hacks.memo_counterfix2

// Expand memo text
org $804BFD4; bl extra_hacks.memo_stretch

// Make printing work properly in the memo menu
// org $8048B98; bl extra_hacks.memo_printfix_storage; nop; nop; nop
// org $8049298; bl extra_hacks.memo_printfix_withdraw_positionfix; nop; nop
// org $80492A4; bl extra_hacks.memo_printfix_vertical

// Expand buffer size for a memo page
// org $804807A; bl extra_hacks.memo_expand_buffer_start_routine
// org $80480DA; bl extra_hacks.memo_expand_buffer_middle_routine
// org $80480F0; bl extra_hacks.memo_expand_buffer_end_routine
// org $80488BE; bl extra_hacks.memo_expand_writing_buffer
// org $8048C34; bl extra_hacks.memo_expand_writing_buffer
// org $8048100; dw $4284
// org $80476BC; dd $0201A2AC

// Make memo use strings terminated by 0xFFFFFFFF after every BREAK
//org $80488F9; db $49; nop
//org $8048904; bl extra_hacks.memo_eos

// Make the pigmask not set the null memo flag
//org $9369245; db $00

org $804BC90; db $F0    // Increase size of cleared lines in menus so it fully covers the screen

// Fix the text being loaded
org $80486DA; bl extra_hacks.memo_change_text_loading_routine

// Fix the memo lookup table, now it's bigger!
org $9FAA9F0; incbin data_memo_flags.bin
org $8052AF0; dd $09FAA9F0 //Table's beginning
org $8052AF4; dd $09FAAA96 //Table's second pointer, A6 bytes after the beginning
org $8052AF8; dd $09FAAB3A //Table's third pointer, 14A bytes after the beginning
org $804EF30; dd $09FAAB3A //Same thing as before

org $8052ADA; db $52 //Increments the number of loaded memos, so the last one is loaded too

//============================================================================================
//                                    NEW HACK CODE
//============================================================================================

// Clear out data for our hacks first
org $8124C18
fill $179C0

// Now insert the hack code
org $8124C18
incsrc general_hacks.asm
incsrc extra_hacks.asm



print "End of Current Hacks: ",pc
print "Max:                  0x813C743"
