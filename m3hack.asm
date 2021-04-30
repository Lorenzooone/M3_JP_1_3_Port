arch gba.thumb

define saturn_font $8D1CE78

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

// Make it so memo titles are printed earlier
org $804760E; mov r1,#0
org $8047642; mov r1,#0xA

// Cursor positions for memoes menu
org $8041558; bl extra_hacks.memoes_cursorfix1   // Memo, X, left column
org $8041560; db $6C                             // Memo, X, right column

// Memo name counter fixes
org $8001DB0; push {lr}; bl extra_hacks.memo_counterfix1; pop {pc}
org $8048500; bl extra_hacks.memo_counterfix2

// Expand memo text
org $804BFD4; bl extra_hacks.memo_stretch

// Change certain positions inside the memo menu
org $8049298; bl extra_hacks.memo_printfix_positionfix; nop; nop

org $804BC90; db $F0    // Increase size of cleared lines in menus so it fully covers the screen

// Make 0xFF0B prepare Saturn font's usage in Memoes
org $80488F9; db $49; nop
org $8048904; bl extra_hacks.memo_saturn_prepare

// Load Saturn Font in Memoes
org $8048D00; bl extra_hacks.memo_saturn_font_load

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
