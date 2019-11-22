module StateMachineDir(clock, state, cdb, newState, emit);
  input clock;
  
  input[1:0] state;
  //00=U 01=S 10=E
  
  input[21:0] cdb;
  //[21:16]situation [15:0]data
  
  output reg[1:0] newState;
  //00=U 01=S 10=E
  
  output reg[21:0]emit;
  //[21:16]situation [15:0]data
  
  always @(posedge clock)
  begin
  
    case(state)
      2'b00: //Uncached
      begin
        case(cdb[21:16])
          6'b000000: //write miss
          begin
            newState = 2'b10;//Exclusive
          end
          6'b000001: //read miss
          begin
            newState = 2'b01;//Shared
          end
      end
      2'b01: //Shared
      begin
        case(cdb[21:16])
          6'b000000: //write miss
          begin
            newState = 2'b10;//Exclusive
            emit = {6'b000100, 16'b0}; //Place Invalidate
          end
          6'b000001: //read miss
          begin
            newState = 2'b01; //Shared
          end
        endcase
      end
      2'b10: //Exclusive
      begin
        case(cdb[21:16])
          6'b000000: //write miss
          begin
            newState = 2'b10; //Exclusive
          end
          6'b000001: //read miss
          begin
            newState = 2'b01; //Shared
            emit = {6'b100111, 16'b0}; //Fetch
          end
          6'b000101: //Data WB
          begin
            newState = 2'b00; //Uncached
          end
      end
    endcase
    
  end
  
endmodule

