
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
    task_mod();  
    #30us;
    $finish;     
end

task task_mod();
  begin
    task_mod_1 (reset_n, cs_n, spi_mode, mosi, rdata);
    task_mod_2 (reset_n, cs_n, spi_mode, mosi, rdata);
    task_mod_4 (reset_n, cs_n, spi_mode, mosi, rdata);
  end
endtask

task task_mod_1;
  begin
    spi_mode = 2'b01;
    mosi = 4'b0001;
    rdata = 16'hC69A;
    #50ns;
    reset_n = 1;
    #10ns;
    cs_n = 0;
    #1930ns
    mosi = 4'b0000;
    #1930ns
    mosi = 4'b0000;
    #5880ns;
    cs_n = 1;
  end
endtask  

task task_mod_2;
  begin
    spi_mode = 2'b10;
    mosi = 4'b0001;
    rdata = 16'h8BFA;
    #50ns;
    reset_n = 1;
    #10ns;
    cs_n = 0;
    #1930ns
    mosi = 4'b0000;
    #1930ns
    mosi = 4'b0000;
    #5880ns;
    cs_n = 1;
  end
endtask  

task task_mod_4;
  begin
    spi_mode = 2'b11;
    mosi = 4'b0001;
    rdata = 16'hC69A;
    #50ns;
    reset_n = 1;
    #10ns;
    cs_n = 0;
    #1930ns
    mosi = 4'b0000;
    #1930ns
    mosi = 4'b0000;
    #5880ns;
    cs_n = 1;
  end
endtask  

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
