`timescale 1ns/1ps

module spi_data_path_tb ();


reg clk;
reg reset_n;
reg sclk;
reg cs_n;
reg [3:0]  mosi;
reg [1:0]  spi_mode;
reg [15:0] rdata;
reg address_ready;
reg data_ready; 
reg [3:0]  miso;
reg [19:0] addr;
reg [3:0]  status;
reg [15:0] wdata;
reg cs_n_o;
reg miso_start;




initial 
  begin
    clk = 1;
    sclk = 1;
    reset_n = 0;
    cs_n = 1;
    spi_mode = 2'b10;
    mosi = 4'b0001;
    rdata = 16'hC69A;
    
    #50ns;
    reset_n = 1;
    	
    #10ns;
    cs_n = 0;

   // #1930ns
    //mosi = 4'b0000;
    //spi_mode = 2'b11;

    #1930ns
    mosi = 4'b0000;

    #5880ns;
    cs_n = 1;

    
       
    #10us;
    $finish;
       
end


initial 
  begin
    $dumpfile("waves.vcd");
    $dumpvars;
  end


always 
  begin
    #5ns;
    clk = ~clk;
  end


always 
  begin
    #20ns;
    if(~cs_n)
    begin
    sclk = ~sclk;
    mosi[0] = ~mosi[0];
    
    end
    //#10us;
    //$finish;
  end

spi_data_path spi_data_path (clk,
                            reset_n,
                            sclk,
                            cs_n,
                            mosi,
                            spi_mode,
                            rdata,
                            address_ready,
                            data_ready, 
                            miso,
                            addr,
                            status,
                            wdata,
                            cs_n_o,
                            miso_start
);
endmodule
