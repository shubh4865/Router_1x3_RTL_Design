module router_FIFO_tb();

reg clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
reg [7:0] data_in;
wire [7:0] data_out;
wire empty, full;
integer i;
  
parameter cycle=10;

router_FIFO DUT(clock,resetn,write_enb,soft_reset,read_enb,lfd_state,data_in,data_out,empty,full); //DUT instantiation

//clock generation
always
   begin
	#(cycle/2);
	clock = 1'b0;
	#(cycle/2);
	clock = ~clock;
   end

//initialize task
task initialize();
   begin
	write_enb = 0;
	read_enb = 0;
	data_in = 0;
	lfd_state = 0;
   end
endtask

//Reset task, active low synchronous reset
task reset_dut();
   begin
	@(negedge clock);
	resetn = 1'b0;
	@(negedge clock);
	resetn = 1'b1;
   end
endtask

//Soft_reset task, active hign synchronous reset
task soft_reset_dut();
   begin
	@(negedge clock);
	soft_reset = 1'b1;
	@(negedge clock);
	soft_reset = 1'b0;
    end
endtask

//Packet generation task
task pkt_gen;
reg [7:0] payload_data,parity,header;
reg [5:0] payload_length; //payload length
reg [1:0] addr; //2 bit reg for address
   
  begin
	@(negedge clock);
	payload_length=6'd4;
	addr=2'b01;
	header={payload_length,addr};
	data_in=header;
	lfd_state=1'b1;
	write_enb=1;
	for(i=0;i<payload_length;i=i+1) //running a for loop for generating payload bytes
	   begin
		@(negedge clock)
		lfd_state=0;
		payload_data=($random)%256;
		data_in=payload_data;
	   end
	@(negedge clock); //generating parity bytes
	parity=($random)%256;
	data_in=parity;
  end
endtask

//Read task
task read(input b);
    begin 
	@(negedge clock)
	read_enb=b;
    end
endtask

//Generating stimulus
initial 
     begin
	initialize;
	reset_dut;
	soft_reset_dut;
	pkt_gen;
	@(negedge clock);
	write_enb=0;
	repeat(5)
	@(negedge clock);
	read(1'b1);
	@(negedge clock);
	wait(empty)
	@(negedge clock);
	read(1'b0);
	#100 $finish;
     end

//monitor task
initial
$monitor("data_in=%b,data_out=%b,full=%b,empty=%b",data_in,data_out,full,empty);

endmodule

