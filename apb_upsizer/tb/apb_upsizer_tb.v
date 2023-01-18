`timescale 1ns/1ps

module apb_upsizer_tb ();

reg         prst,pclk;
reg [15:0]  prdata_m_o;
reg         pready_m_o,
            pwrite_s_o,
            psel_s_o,
            penable_s_o;
reg [3:0]   pstrb_s_o;
reg [31:0]  pwdata_s_o;
reg [31:0]  paddr_s_o;
reg         psel_m_i,
            penable_m_i,
            pready_s_i;
reg [1:0]   pstrb_m_i;        
reg [31:0]  prdata_s_i;
reg [31:0]  paddr_m_i;
reg [15:0]  pwdata_m_i;
reg         pwrite_m_i; 


initial begin

        pclk=0;
	prst = 0;
	psel_m_i=0;
	penable_m_i=0;
    
    	#50ns;
    	prst = 1;
    	
    	#4ns;
       psel_m_i<=1;
       pwrite_m_i=1;
       pstrb_m_i=2'b11;
       paddr_m_i=32'h00000000;
       pwdata_m_i=16'h6689;
       
       
       #4ns;
       penable_m_i<=1;
       
       
       #8ns;
       penable_m_i=0;
       psel_m_i=0;
       
       
       #8ns;
       psel_m_i<=1;
       pwrite_m_i=1;
       pstrb_m_i=2'b11;
       paddr_m_i=32'h00000002;
       pwdata_m_i=16'h6677;
       
       #4ns;
       penable_m_i<=1;
       
       
       #8ns;
       penable_m_i=0;
       psel_m_i=0;
       
       #16ns;
       psel_m_i<=1;
       pwrite_m_i=0;
       pstrb_m_i=2'b10;
       paddr_m_i=32'h00000004;
       
       
       #4ns;
       penable_m_i=1;
       
       
       
       #8ns;
       penable_m_i=0;
       psel_m_i=0;
       
       #8ns;
       psel_m_i=1;
       pwrite_m_i=0;
       pstrb_m_i=2'b10;
       paddr_m_i=32'h00000006;
       
       
       #4ns;
       penable_m_i=1;
       
       #10us;
       
end


initial begin
	pready_s_i=0;
	prdata_s_i=32'h99998888;
	
	//#140ns;
	//prdata_s_i=32'h1234;
end	

always begin
	
	#8ns;
        pready_s_i=~pready_s_i;
                         
end


initial begin

    	$dumpfile("waves.vcd");
    	$dumpvars;
end


always begin
    
    	#2ns;
    	pclk = ~pclk;
end


apb_upsizer apb_upsizer (pclk,prst,
                   pwrite_m_i,psel_m_i,
                   penable_m_i,pwdata_m_i,
                   prdata_m_o,paddr_m_i,
                   pstrb_m_i,pready_m_o,
                
                   pwrite_s_o,psel_s_o,
                   penable_s_o,pwdata_s_o,
                   prdata_s_i,paddr_s_o,
                   pstrb_s_o,pready_s_i);



endmodule
