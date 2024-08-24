module router_reg_tb();

//Global veriables
  reg clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,lfd_state,full_state,rst_in_reg;
  reg [7:0]data_in;

  wire err,parity_done,low_pkt_valid;
  wire [7:0]dout;

parameter cycle = 10;
integer i;

//DUT instance
router_reg DUT(clock,resetn,pkt_valid,data_in,fifo_full,rst_in_reg,detect_add,ld_state,lfd_state,
		laf_state,full_state,parity_done,low_pkt_valid,dout,err);

always
   begin
	#(cycle/2);
	clock = 1'b0;
	#(cycle/2);
	clock = ~clock;
   end

//Reset task
task rst_dut();
   begin
	@(negedge clock);
	resetn = 1'b0;
	@(negedge clock);
	resetn = 1'b1;
   end
endtask

//Initialize task
task initialize();
   begin
	{pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_in_reg,data_in} = 0;
   end
endtask

//good packet generation task
task good_packet;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
   begin
	@(negedge clock)
	payload_len = 6'd3;
	addr = 2'b10; //valid packet
	pkt_valid = 1;
	detect_add = 1;
	header = {payload_len,addr};
	parity = 0 ^ header;
	data_in = header;
	@(negedge clock)
	detect_add = 0;
	lfd_state = 1;
	full_state = 0;
	fifo_full= 0;
	laf_state = 0;
	for(i=0;i<payload_len;i=i+1)
   	   begin
	       @(negedge clock)
	        lfd_state = 0;
		ld_state = 1;
		payload_data = {$random}%256;
		data_in = payload_data;
		parity = parity ^ data_in;
	   end
	@(negedge clock)
	pkt_valid = 0;
	data_in = parity;
	@(negedge clock)
	ld_state = 0;
   end
endtask

//Bad parity genetarion task
task bad_packet;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
   begin
	@(negedge clock)
	payload_len = 6'd3;
	addr = 2'b10; //valid packet
	pkt_valid = 1;
	detect_add = 1;
	header = {payload_len,addr};
	parity = 0 ^ header;
	data_in = header;
	@(negedge clock)
	detect_add = 0;
	lfd_state = 1;
	full_state = 0;
	fifo_full= 0;
	laf_state = 0;
	for(i=0;i<payload_len;i=i+1)
   	   begin
	       @(negedge clock)
	        lfd_state = 0;
		ld_state = 1;
		payload_data = {$random}%256;
		data_in = payload_data;
		parity = parity ^ data_in;
	   end
	@(negedge clock)
	pkt_valid = 0;
	data_in = ~parity;
	@(negedge clock)
	ld_state = 0;
   end
endtask

//Stimulus block
initial
    begin
	initialize;
	rst_dut;
	good_packet;
	bad_packet;
	#1000 $finish;
    end

endmodule
