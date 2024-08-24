module router_FIFO #(parameter width = 8,depth = 16) //fifo size is 16x8
		    (input clock,
		     input resetn,
		     input write_enb,
		     input soft_reset,
		     input read_enb,
		     input lfd_state,
		     input [width-1 : 0] data_in,
  		     output reg [width-1 : 0] data_out,
		     output empty,
		     output full);

//internal veriable
reg [8:0] memory [depth-1 : 0]; //memory witdh=9 & depth=16
reg [4:0] write_ptr;
reg [4:0] read_ptr;
reg[6:0] count;
integer i;

//FIFO full & empty logic

assign empty = (write_ptr == read_ptr) ? 1'b1 : 1'b0;
assign full  = (write_ptr == {~read_ptr[4],read_ptr[3:0]}) ? 1'b1 : 1'b0;

//FIFO write operation
always@(posedge clock)
  begin
     if(~resetn)  //synchronous reset active low
	begin
	   write_ptr <= 0;
	   for(i=0; i < 16; i=i+1)
	      begin
	         memory[i] <= 0;
	      end
	end
     else if(soft_reset)
	    begin
		write_ptr <= 0;
	   	for(i=0; i < 16; i=i+1)
		   begin 
		      memory[i] <= 0;
		   end
	    end
     else 
	begin
	    if(write_enb && ~full)
	      begin
		  write_ptr <= write_ptr + 1;
		  memory[write_ptr[3:0]] <= {lfd_state,data_in};
	      end
	end
  end

//FIFO read operation
always@(posedge clock)
   begin
       if(~resetn)
	  begin
	      read_ptr <= 0;
	      data_out <= 8'h00;
	   end
       else if(soft_reset)
           begin 
	       read_ptr <= 0;
	       data_out <= 8'hzz;
	   end
       else
	  begin 
	      if(read_enb && ~empty)
		 read_ptr <= read_ptr + 1;

	      if((count == 0) && (data_out != 0))
		  data_out <= 8'dz;
	      else if(read_enb && ~empty)
		  begin
		      data_out <= memory[read_ptr[3:0]];	
		  end
	   end
    end

//FIFO down-counter logic
always@(posedge clock)
    begin 
	if(~resetn)
	  begin
	      count <= 0;
	  end
	else if(soft_reset)
	  begin
	      count <= 0;
	  end
	else if(read_enb & ~empty)
	   begin 
              if(memory[read_ptr[3:0]][8] == 1'b1)
		 count <= memory[read_ptr[3:0]][7:2] + 1'b1;
	      else if(count != 0)
		 count <= count - 1'b1;
           end
     end

endmodule
	
