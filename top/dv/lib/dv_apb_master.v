`include "dv_apb_item.v"

module dv_apb_master #(
  parameter DW = 32, 
  parameter AW = 32
)(
  input                 pclk, 
  input                 prst_n,
  output reg            psel,      
  output reg            penable, 
  output reg            pwrite,
  output reg [AW-1:0]   paddr,
  output reg [DW-1:0]   pwdata, 
  output reg [DW/8-1:0] pstrb,
  input      [DW-1:0]   prdata,
  input                 pready,
  input                 pslverr
);

  always @(prst_n)
    if (prst_n == 1'b0)
    begin
      psel     <= 1'b0;
      penable  <= 1'b0;
      pwrite   <= 1'b0;
      paddr    <= '0;  
      pwdata   <= '0;  
      pstrb    <= '0;  
    end      

  task apb_write(
    input [AW-1:0]    addr, 
    input [DW-1:0]    wdata, 
    input [DW/8-1:0]  strb,
    output            slverr
  );
    begin 
      psel     = 1'b1;
      penable  = 1'b0;
      pwrite   = 1'b1;
      paddr    = addr;
      pwdata   = wdata;
      pstrb    = strb;
      @(posedge pclk); 
      penable  = 1'b1;
      @(posedge pclk); 
      while (pready == 1'b0) @(posedge pclk); 
      slverr   = pslverr;
      psel     = 1'b0;
      penable  = 1'b0;
    end
  endtask

  task apb_read(
    input  [AW-1:0] addr, 
    output [DW-1:0] rdata
  );
    begin 
      psel    = 1'b1;
      penable = 1'b0;
      pwrite  = 1'b0;
      paddr   = addr;
      pwdata  = '0;
      pstrb   = '0;
      @(posedge pclk); 
      penable = 1'b1;
      @(posedge pclk); 
      while (pready == 1'b0) @(posedge pclk); 
      psel    = 1'b0;
      penable = 1'b0;
      rdata   = prdata;
    end
  endtask

  task apb_drive(
    input dv_apb_item item,
    output [DW-1:0] result
  );
  begin
    if (item.write == 1'b1)
      apb_write(item.addr, item.data, item.strb, result);
    else
      apb_read(item.addr, result);
  end
  endtask

endmodule
