`timescale 1ns/10ps

module tb();

reg               clk=0;
reg               rst_n=0;
// register map interface
// first row config
reg  [7:0]        sel_r0;
reg  [7:0][31:0]  const_r0;
reg  [3:0][3:0]   op_r0;
reg  [1:0][3:0]   op_r1;
reg       [3:0]   op_r2;
// reg data interface
reg  [7:0][31:0]  i_data;
reg  [7:0]        i_dv;
wire              o_rdy;
// buffered third row result outputs
wire [31:0]       o_data_buff;
wire              o_dv_buff;
reg               i_rdy_buff;

reg               entry_handshake;

always #1 clk = ~clk;

always @(posedge clk)
  entry_handshake <= i_dv & o_rdy;

always @(posedge clk)
  i_rdy_buff <= $random;

task drive(
input [2:0] lane,
input [31:0] operand0,
input [31:0] operand1,
input [3:0] op);

begin
  @(posedge clk);
  i_dv[lane] = 1;
  i_dv[lane+1] = 1;
  i_data[lane] = operand0;
  i_data[lane+1]  = operand1;
  op_r0[lane] = op;
  do @(posedge clk); while (!entry_handshake);
end
endtask

initial begin
  $dumpfile("waves.vcd");
  $dumpvars;
  i_data = '0;
  sel_r0 = 8'b11111100;
  const_r0 = '0;
  op_r0 = '0;
  op_r1 = '0;
  op_r2 = '0;
  i_dv = '0;
  i_rdy_buff = 0;
  #12;
  rst_n <= 1;
  drive(0, 345, 15, 0);
  drive(0, 13, 15, 0);
  drive(0, 32'hffaacd10, 32'h8155ffe4, 1);
  drive(0, 32'hffaae613, 32'h005519ec, 1);
  drive(0, 32'hffaae613, 32'h005519ec, 2);
  drive(0, 32'hffaae613, 32'h005519ec, 3);
  i_dv = 0;
  repeat (10) @(posedge clk);
  $finish;
end

pu pu_i(
  .clk(clk),
  .rst_n(rst_n),
  .sel_r0(sel_r0),
  .const_r0(const_r0),
  .op_r0(op_r0),
  .op_r1(op_r1),
  .op_r2(op_r2),
  .i_data(i_data),
  .i_dv(i_dv),
  .o_rdy(o_rdy),
  .o_data_buff(o_data_buff),
  .o_dv_buff(o_dv_buff),
  .i_rdy_buff(i_rdy_buff)
);

endmodule