module SnoopingMSF(clock, request, listen, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
input clock;
output[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
input[21:0] request;// enviar ao CDB
wire[21:0] emit;//receber do CDB
reg[1:0] state;
input listen;
wire[1:0] newState;

StateMachine controlador(clock, state, request, listen, newState, emit);

always@(posedge clock)
begin
	state <= newState;
	
end

hexto7segment display0({2'b00, state}, HEX0);

hexto7segment display4(emit[19:16], HEX4);
hexto7segment display5({2'b00, emit[21:20]}, HEX5);

hexto7segment display6(request[19:16], HEX6);
hexto7segment display7({2'b00, request[21:20]}, HEX7);

assign HEX1 = 7'b1111111;
assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;

endmodule