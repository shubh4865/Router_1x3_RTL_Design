//FSm controller testbench

module router_fsm_tb();


//Global veriable

  reg clock,resetn,pkt_valid,fifo_full,parity_done,low_pkt_valid;
  reg [1:0] data_in;
  reg fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2;
  wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_in_reg,busy;

parameter cycle = 10;

//DUT instance
router_fsm DUT(clock,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_full,
		pkt_valid,data_in,
		parity_done,
		low_pkt_valid,
		resetn,
		soft_reset_0,soft_reset_1,soft_reset_2,
		busy,
		detect_add,
		write_enb_reg,
		ld_state,
		laf_state,
		lfd_state,
		full_state,
		rst_in_reg);
//Clock generator logic
always
    begin
	#(cycle/2);
	clock = 1'b0;
	#(cycle/2);
	clock = ~clock;
    end
//Initialize Task
task initialize();
    begin
	{data_in,pkt_valid,fifo_full,parity_done,low_pkt_valid} = 0;
	{fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2} = 0;
    end
endtask

//Reset task
task rst_dut();
    begin
	@(negedge clock);
	resetn = 1'b0;
	@(negedge clock);
	resetn = 1'b1;
     end
endtask

//Scenario1 : DA-LFD-LD-LP-CPE-DA
task t1;
    begin
	@(negedge clock);
	pkt_valid = 1;
	data_in = 0;
	fifo_empty_0 = 1;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 0;
	pkt_valid = 0;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 0;
    end
endtask

//Scenario2 : DA-LFD-LD-LP-CPE-FFS-LAF-DA
task t2;
    begin
	@(negedge clock);
	pkt_valid = 1;
	data_in = 0;
	fifo_empty_0 = 1;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 0;
	pkt_valid = 0;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 1;
	@(negedge clock);
	fifo_full = 0;
	@(negedge clock);
	parity_done = 1;
	@(negedge clock);
	parity_done = 0;
    end
endtask

//Scenario3 : DA-LFD-LD-FFS-LAF-LP-CPE-DA
task t3;
    begin
	@(negedge clock);
	pkt_valid = 1;
	data_in = 0;
	fifo_empty_0 = 1;
	@(negedge clock);
	@(negedge clock);
	@(negedge clock);
	fifo_full = 1;
	@(negedge clock);
	fifo_full = 0;
	@(negedge clock);
	parity_done = 0;
	pkt_valid = 0;
	low_pkt_valid = 1;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 0;
    end
endtask

//Scenario4 : DA-LFD-LD-FFS-LAF-LD-LP-CPE-DA
task t4;
    begin 
	@(negedge clock);
	pkt_valid = 1;
	data_in = 0;
	fifo_empty_0 = 1;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 1;
	@(negedge clock);
	fifo_full = 0;
	@(negedge clock);
	parity_done = 0;
	low_pkt_valid = 0;
	@(negedge clock);
	@(negedge clock);
	fifo_full = 0;
    end
endtask

//Stimulus block
initial 
    begin
	initialize;
	rst_dut;
	t1;
	t2;
	t3;
	t4;
	#100 $finish;
    end


endmodule
  
