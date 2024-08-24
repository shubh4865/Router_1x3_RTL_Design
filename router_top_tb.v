module router_top_tb();

reg clock,resetn;
reg pkt_valid;
reg [7:0] data_in;
reg read_enb_0,read_enb_1,read_enb_2;

wire [7:0] data_out_0,data_out_1,data_out_2;
wire vld_out_0,vld_out_1,vld_out_2;
wire busy,err;

integer i;

router_top ROUTER_DUT(clock,
		resetn,
		pkt_valid,
		data_in,
		read_enb_0,
		read_enb_1,
		read_enb_2,
		data_out_0,
		data_out_1,
		data_out_2,
		vld_out_0,
		vld_out_1,
		vld_out_2,
		busy,
		err);
//Clock generation
initial
    begin
	#10 clock=0;
	forever
	#10 clock=~clock;
    end
//Reset task
task rst;
    begin
	@(negedge clock);
	resetn = 0;
	@(negedge clock);
	resetn = 1;
    end
endtask

//Packet with payload length : 14bytes
task pkt_gen_14;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
   begin
	@(negedge clock);
	wait(~busy)
	@(negedge clock);
	payload_len = 6'd14;
	addr = 2'b01;  //valid packet
	header = {payload_len,addr};
	parity =0;
	data_in = header;
	pkt_valid = 1;
	parity = parity ^ header;
	@(negedge clock);
	wait(~busy)
	for(i=0;i<payload_len;i=i+1)
	   begin
		@(negedge clock);
		wait(~busy)
		payload_data = {$random} % 256;
		data_in = payload_data;
		parity = parity ^ payload_data;
	   end
	@(negedge clock);
	wait(~busy)
	pkt_valid = 0;
	data_in = parity;
   end
endtask

//Stimulus block
initial
    begin
	rst;
	repeat(3)
	@(negedge clock);
	pkt_gen_14;
	repeat(2)
	@(negedge clock);
	read_enb_1 =1;
	@(negedge clock);
	wait(~vld_out_1)
	@(negedge clock);
	read_enb_1 = 0;
	#1000 $finish;
    end

endmodule
