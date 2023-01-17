`include "$PROJDIR/dv/lib/clk_rst_generator.v"
`include "$PROJDIR/dv/lib/dv_apb_master.v"
`include "$PROJDIR/dv/lib/dv_mem_model.v"
`include "$PROJDIR/dv/lib/dv_spi_master.v"

module lib_trial_tb(
  input pready,
  input pslverr
);

  wire        pclk;
  wire        prst_n;
  wire        psel;
  wire        penable;
  wire        pwrite;
  wire [5:0]  paddr;
  wire [15:0] pwdata;
  wire [1:0]  pstrb;
  wire [15:0] prdata;

  wire [3:0] mosi, miso;
  wire sclk, cs_n;

  clk_rst_generator clk_rst_generator_i (
    .clk(pclk), 
    .rst_n(prst_n)
  );

  dv_apb_master #(
    .DW ( 16 ),
    .AW ( 6 )
  ) apb_master_i(
    .pclk(pclk),
    .prst_n(prst_n),
    .psel(psel),      
    .penable(penable), 
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata), 
    .pstrb(pstrb),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr)
  );  

  dv_mem_model #(
    .DW ( 16 ),
    .AW ( 6 )
  ) mem_model_i (
    .clk (pclk),
    .cs  (psel & ~penable),
    .we  (pwrite),
    .be  ({{8{pstrb[1]}}, {8{pstrb[0]}}}), 
    .addr(paddr),
    .din (pwdata),
    .dout(prdata)
  );

  dv_spi_master dv_spi_master_i(
    .mosi(mosi),
    .miso(miso),
    .sclk(sclk),
    .cs_n(cs_n)
  );

endmodule