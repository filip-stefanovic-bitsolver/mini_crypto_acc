module rst_sync(
  input       arst_n,
  input       clk,
  output reg  srst_n
);

  reg meta;

  always @(posedge clk, negedge arst_n)
    if (!arst_n)
      {srst_n, meta} <= 2'b00;
    else 
      {srst_n, meta} <= {meta, 1'b1};

endmodule