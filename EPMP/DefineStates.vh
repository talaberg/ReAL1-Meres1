// This is a sheet automatic generated from "StateMachines" 
// Opcode fetch 
`define StFetch0 0
`define StFetch1 1
`define StFetch2 2
`define StFetch3 3
// Execute no memory access instruction or continue state-machine 
`define StExecInst 4
// Read operand 
// Read operand, read address low byte 
`define StRead0 5
`define StRead1 6
`define StRead2 7
// Read operand, read address high byte 
`define StRead3 8
`define StRead4 9
`define StRead5 10
// Read operand, read data 
`define StRead6 11
`define StRead7 12
`define StRead8 13
// Use read data 
`define StExecData 14
// Store accumulator 
// Up to Read6 same states as for read operand 
`define StWrite1 15
`define StWrite2 16
// Jump to 16bit address, unconditional or conditional with jump taken 
`define StJump1 17
// Jump to 16bit address, conditional, jump not taken 
`define StJumpNC1 18
`define StJumpNC2 19
