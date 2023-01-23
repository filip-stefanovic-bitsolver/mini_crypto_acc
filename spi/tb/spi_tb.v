`include "t_spi_master.v"
`include "/home/aleksandarc/mini_crypto_acc/spi/tb/clk_reset_n_generator.v"
`include "t_apb_rm.v"
`include "t_apb_icn.v"
`include "t_spi_master.v"
`include "spi_slave.v"
module lib_tb ();

reg clk;
reg reset_n;
reg [15:0] prdata_rm;
reg pready_rm;
reg pslverr_rm;
reg [15:0] prdata_icn;
reg pready_icn;
reg pslverr_icn;



clk_reset_n_generator clk_reset_n_generator_i (
  .clk(clk), 
  .reset_n(reset_n)
);

t_apb_rm t_apb_rm_i(
  .pclk(clk),
  .prst_n(reset_n),
  .psel(psel),      
  .penable(penable), 
  .pwrite(pwrite),
  .paddr(paddr),
  .pwdata(pwdata), 
  .pstrb(pstrb),
  .prdata(prdata_rm),
  .pready(pready_rm),
  .pslverr(pslverr_rm)
);  

t_apb_icn t_apb_icn_i(
  .pclk(clk),
  .prst_n(reset_n),
  .psel(psel),      
  .penable(penable), 
  .pwrite(pwrite),
  .paddr(paddr),
  .pwdata(pwdata), 
  .pstrb(pstrb),
  .prdata(prdata_icn),
  .pready(pready_icn),
  .pslverr(pslverr_icn)
);  

t_spi_master t_spi_master_i(
  .mosi(mosi),
  .miso(miso),
  .sclk(sclk),
  .cs_n(cs_n)
);


spi_slave spi_slave_i ( .clk(clk),
                        .reset_n(reset_n),
                        .sclk(sclk),
                        .cs_n(cs_n),
                        .mosi(mosi),
                        .spi_mode(spi_mode),
                        .prdata_rm(prdata_rm),
                        .pready_rm(pready_rm),
                        .pslverr_rm(pslverr_rm),
                        .prdata_icn(prdata_icn),
                        .pready_icn(pready_icn),
                        .pslverr_icn(pslverr_icn),

                        .miso(miso),
                        .psel(psel),
                        .penable(penable),
                        .write(write),
                        .strb(strb),
                        .addr(addr),
                        .wdata(wdata),
                        .err(err)
);

endmodule