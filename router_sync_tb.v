module routr_sync_tb();

//Global veriables
reg clock,resetn,detect_add,write_enb_reg,full_0,full_1,full_2,empty_0,empty_1,empty_2,read_enb_0,read_enb_1,read_enb_2;
reg [1:0] data_in;
wire soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
wire vld_out_0,vld_out_1,vld_out_2;
wire [2:0] write_enb;

parameter cycle=10;

router_sync SYNC(clock,resetn,detect_add,data_in,write_enb_reg,empty_0,empty_1,empty_2,full_0,full_1,full_2,
                 read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,
                 vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);

//Clock generation
always
    begin 
	#(cycle/2);
	clock = 1'b0;
	#(cycle/2);
	clock = ~clock;
    end
//initialize the task
task initialize;
    begin
	data_in = 0;
	detect_add = 0;
 	full_0 = 0;
	full_1 = 0;
	full_2 = 0;
	empty_0 = 1;
	empty_1 = 1;
	empty_2 = 1;
	write_enb_reg = 0;
	read_enb_0 = 1;
	read_enb_1 = 1;
	read_enb_2 = 1;
    end
endtask

//Reset task
task rst_dut;
    begin 
	@(negedge clock);
	resetn = 1'b0;
	@(negedge clock);
	resetn = 1'b1;
    end
endtask

//Write task
task write;
    begin
	@(negedge clock);
	write_enb_reg = 1'b1;
	@(negedge clock);
	write_enb_reg = 1'b0;
     end
endtask

//Address task
task addr(input[1:0]m);
    begin
	@(negedge clock);
	detect_add = 1;
	data_in = m;
	@(negedge clock);
	detect_add = 0;
    end
endtask

//Input task
task inputs;
    begin
	@(negedge clock);
	full_1 = 1;
	empty_1 = 0;
	read_enb_1 = 0;
     end
endtask

//Stimulus block
initial
     begin
	$monitor("write_enb=%b,fifo_full=%b,vld_out_0=%b,vld_out_1=%b,vld_out_2=%b,soft_reset_0=%b,soft_reset_1=%b,soft_reset_2=%b",write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,
                  soft_reset_0,soft_reset_1,soft_reset_2);
	initialize;
	rst_dut;
	addr(2'd1);
	write;
	inputs;
	#400 $finish;
      end

endmodule

