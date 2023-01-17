module pu( // processing unit
  input               clk,
  input               rst_n,
  // register map interface
  // first row config
  input  [7:0]        sel_r0,
  input  [7:0][31:0]  const_r0,
  input  [3:0][3:0]   op_r0,
  input  [1:0][3:0]   op_r1,
  input       [3:0]   op_r2,
  // input data interface
  input  [7:0][31:0]  i_data,
  input  [7:0]        i_dv,
  output              o_rdy,
//----------------------------------
//----------- UNUSED ATM -----------
//----------------------------------
//  // first row result outputs
//  output [3:0][31:0]  o_data_r0,
//  output [3:0]        o_dv_r0,
//  input  [3:0]        i_rdy_r0,
//  // second row result outputs
//  output [3:0]        o_data_r1,
//  output [3:0]        o_dv_r1,
//  input  [3:0]        i_rdy_r1,
//  // third row result outputs
//  output [1:0]        o_data_r2,
//  output [1:0]        o_dv_r2,
//  input  [1:0]        i_rdy_r2,
  // buffered third row result outputs
  output reg [31:0]     o_data_buff,
  output reg            o_dv_buff,
  input                 i_rdy_buff
);

reg [7:0][31:0] operand_r0;
reg [7:0]       dv_r0;
reg [3:0][31:0] operand_r1;
reg [1:0][31:0] operand_r2;
reg      [31:0] operand_r3;

assign o_rdy = (dv_r0 == '1) & (~o_dv_buff | i_rdy_buff); // creating long path TODO fix

always @*
  for (int i=0;i<8;i++)
    if (sel_r0[i]) begin
      operand_r0[i] = const_r0[i];
      dv_r0[i] = 1'b1;
    end else begin
      operand_r0[i] = i_data[i];
      dv_r0[i] = i_dv[i];
    end

always @*
  for (int i=0;i<4;i++)
    case (op_r0[i])
      4'd0:operand_r1[i] = operand_r0[i*2] + operand_r0[i*2+1];       // ADD
      4'd1:operand_r1[i] = operand_r0[i*2] & operand_r0[i*2+1];       // AND
      4'd2:operand_r1[i] = operand_r0[i*2] | operand_r0[i*2+1];       // OR
      4'd3:operand_r1[i] = operand_r0[i*2] ^ operand_r0[i*2+1];       // XOR
      4'd4:operand_r1[i] = operand_r0[i*2] >> operand_r0[i*2+1];      // SHIFT L
      4'd5:operand_r1[i] = operand_r0[i*2] << operand_r0[i*2+1];      // SHIFT R
      4'd6:operand_r1[i] = operand_r0[i*2] >>> operand_r0[i*2+1];     // ROT L
      default:operand_r1[i] = operand_r0[i*2] <<< operand_r0[i*2+1];  // ROT R
    endcase

  always @*
    for (int i=0;i<2;i++)
      case (op_r1[i])
        4'd0:operand_r2[i]    = operand_r1[i*2] + operand_r1[i*2+1]; // ADD
        4'd1:operand_r2[i]    = operand_r1[i*2] & operand_r1[i*2+1]; // AND
        4'd2:operand_r2[i]    = operand_r1[i*2] | operand_r1[i*2+1]; // OR
        4'd3:operand_r2[i]    = operand_r1[i*2] ^ operand_r1[i*2+1]; // XOR
        4'd4:operand_r2[i]    = operand_r1[i*2] >> operand_r1[i*2+1]; // SHIFT L
        4'd5:operand_r2[i]    = operand_r1[i*2] << operand_r1[i*2+1]; // SHIFT R
        4'd6:operand_r2[i]    = operand_r1[i*2] >>> operand_r1[i*2+1]; // ROT L
        default:operand_r2[i] = operand_r1[i*2] <<< operand_r1[i*2+1]; // ROT R
      endcase
      
  always @*
    case (op_r2)
      4'd0:operand_r3    = operand_r2[0] + operand_r2[1]; // ADD
      4'd1:operand_r3    = operand_r2[0] & operand_r2[1]; // AND
      4'd2:operand_r3    = operand_r2[0] | operand_r2[1]; // OR
      4'd3:operand_r3    = operand_r2[0] ^ operand_r2[1]; // XOR
      4'd4:operand_r3    = operand_r2[0] >> operand_r2[1]; // SHIFT L
      4'd5:operand_r3    = operand_r2[0] << operand_r2[1]; // SHIFT R
      4'd6:operand_r3    = operand_r2[0] >>> operand_r2[1]; // ROT L
      default:operand_r3 = operand_r2[0] <<< operand_r2[1]; // ROT R
    endcase

    always @(posedge clk, negedge rst_n)
      if (!rst_n) 
        o_data_buff <= '0;
      else if ((dv_r0 == '1) && ((o_dv_buff == 1'b0) || (i_rdy_buff == 1'b1)))
        o_data_buff <= operand_r3;
      

    always @(posedge clk, negedge rst_n)
      if (!rst_n)
        o_dv_buff <= 1'b0;
      else if (dv_r0 == '1)
        o_dv_buff <= 1'b1;
      else if (i_rdy_buff == 1'b1)
        o_dv_buff <= 1'b0;

endmodule