module StateMachine(clock, state, cdb, listen, newState, emit, dataWB, abortMem);
  input clock;
  
  input[1:0] state;
  //00=I 01=S 10=M
  
  input[21:0] cdb;
  //[21:16]situation [15:0]data
  
  input listen;
  //1=ouvindo 0=escrevendo
  
  output reg dataWB;
  
  output reg abortMem;
  
  output reg[1:0] newState;
  //00=I 01=S 10=M
  
  output reg[21:0]emit;
  //[21:16]situation [15:0]data
  
  always @(posedge clock)
  begin
	dataWB = 0;
	abortMem = 0;
	
    if(listen==1)
    begin
      case(state)
        2'b01: //Shared
          begin
            case(cdb[21:16])
              6'b000000: //write miss
                begin
                  newState = 2'b00; //invalid
                end
              6'b000001: //read miss
                begin
                  newState = 2'b01; //->shared
                end
              6'b000100: //invalidate
                begin
                  newState = 2'b00;
                end
            endcase
          end
        2'b10: //Modified
           begin
             case(cdb[21:16])
              6'b000000: //write miss
                begin
                  newState = 2'b00; //Invalid
						dataWB = 1;
						abortMem = 1;
                end
              6'b000001: //read miss
                begin
                  newState = 2'b01; //->shared
						dataWB = 1;
						abortMem = 1;
                end
					6'b100100: //Fetch Invalidate
					begin 
						newState = 2'b00; //->Invalid
						dataWB = 1;
					end
					6'b100111: //Fetch
					begin 
						newState = 2'b01; //->Shared
						dataWB = 1;
					end
             endcase
           end
        endcase
    end
    else
    begin
      case(state)
        2'b00: //Invalid
          begin
            case(cdb[21:16])
              6'b100000: //CPU write miss
              begin
              emit = {6'b000000, 16'b0}; //emite write miis
              newState = 2'b10; //->modified
              end
              6'b100001: //CPU read miss
              begin
              emit = {6'b000001, 16'b0}; //emite read miis
              newState = 2'b01; //->shared
              end
            endcase
          end
        2'b01: //Shared
          begin
            case(cdb[21:16])
              6'b100000: //CPU write miss
              begin
              emit = {6'b000000, 16'b0}; //place write miss
              newState =  2'b10; //->modified
              end
              6'b100001: //CPU read miss
              begin
              emit = {6'b000001, 16'b0}; //place read miss
              newState = 2'b01; //->shared
              end
              6'b100010: //CPU write hit
              begin
              emit = {6'b000100, 16'b0}; //place invalidate
              newState = 2'b10; //->modified
              end
              6'b100011: //CPU read hit
              begin 
              newState = 2'b01; //->shared
              end
            endcase
          end
        2'b10: //Modified
          begin
            case(cdb[21:16])
              6'b100000: //CPU write miss
              begin
              emit = {6'b000000, 16'b0}; //place write miss
              newState = 2'b10; //->modified
				  dataWB = 1;
              end
				  6'b100001: //CPU read miss
				  begin
				  newState = 2'b01; //Shared
				  dataWB = 1;
				  end
              6'b100010: //CPU write hit
              begin
              newState = 2'b10; //->modified
              end
              6'b100011: //CPU read hit
              begin
              newState = 2'b10; //->modified
              end
            endcase
          end
      endcase
    end
    
  end
  
endmodule
