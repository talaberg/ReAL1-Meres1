// This is a sheet automatic generated from "StateMachine"
assign PC_Out_En=(state==`StFetch0) | (state==`StRead0) | (state==`StRead3) ;
assign PC_Load_En=(state==`StFetch0) | (state==`StRead0) | (state==`StRead3) | (state==`StJump1) | (state==`StJumpNC1) | (state==`StJumpNC2) | (state==`StJump1) ;
assign PC_Inc_nLoad=(state==`StFetch0) | (state==`StRead0) | (state==`StRead3) | (state==`StJumpNC1) | (state==`StJumpNC2) ;
assign MAR_Load=(state==`StFetch0) | (state==`StRead0) | (state==`StRead3) | (state==`StRead6) ;
assign Read=(state==`StFetch2) | (state==`StRead2) | (state==`StRead5) | (state==`StRead8) ;
assign Write=(state==`StWrite2) ;
assign MDR_XB_Load=(state==`StFetch2) | (state==`StRead2) | (state==`StRead8) ;
assign MDR_IB_Load=(state==`StWrite1) ;
assign MDR_XB_En=(state==`StWrite2) ;
assign MDR_IB_En=(state==`StFetch3) | (state==`StRead6) | (state==`StExecData) | (state==`StJump1) | (state==`StJump1) ;
assign AuxR_Load_En=(state==`StRead5) ;
assign AuxR_Out_En=(state==`StRead6) | (state==`StJump1) | (state==`StJump1) ;
assign IR_Load=(state==`StFetch3) ;
assign ACC_Out_En=(state==`StWrite1) ;
