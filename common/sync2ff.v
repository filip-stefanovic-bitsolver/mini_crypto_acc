module sync2ff(
  input       clk,
  input       arst_n,
  input       d,
  output reg  q
);

  reg meta;

  always @(posedge clk, negedge arst_n)
    if (!arst_n)
      {q, meta} <= 2'b00;
    else
      {q, meta} <= {meta, d};

endmodule