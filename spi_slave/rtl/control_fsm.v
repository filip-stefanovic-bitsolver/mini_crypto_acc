module control_fsm(
  input clk,
  input reset_n,
  input address_ready,
  input data_ready,
  input [19:0] addr,
  input [3:0] status,
  input [15:0] wdata,
  input pready_s,
  input [15:0] prdata_s,
  input pslverr_s_rm,
  input pslverr_s_icn,

  output [1:0] psel_s,
  output penable_s,
  output pwrite_s, 
  output [1:0] pstrb_s,
  output [19:0] paddr_s,
  output [15:0] pwdata_s,
  output [15:0] rdata
);
  reg [1:0] psel_s;
  reg penable_s;
  reg pwrite_s;
  reg [1:0] pstrb_s;
  reg [19:0] paddr_s;
  reg [15:0] pwdata_s;
  reg [15:0] rdata;

  reg [3:0] state, next;

  localparam IDLE = 4'h0;
  localparam WAIT_WR = 4'h1;
  localparam SETUP_WR = 4'h2;
  localparam ACCESS_WR = 4'h3;
  localparam SETUP_RD = 4'h4;
  localparam ACCESS_RD = 4'h5;
  localparam WAIT_RD = 4'h6;

  //state transition process
  always @(posedge clk or negedge reset_n)
    if (!reset_n) 
      state <= IDLE;
    else
      state <= next;
  //next state logic
  always @(*) begin
    case (state)
      IDLE:
        if (address_ready) begin
          if (status[2])
            next = WAIT_WR;
          else
            next = SETUP_RD;
        end
        else
          next = IDLE;
      WAIT_WR:
        if (data_ready)
          next = SETUP_WR;
        else
          next = WAIT_WR;
      SETUP_WR:
        next = ACCESS_WR;
      ACCESS_WR:
        if (pready_s) begin
          if (status[1])
            next = WAIT_WR;
          else 
            next = IDLE;
        end
        else
          next = ACCESS_WR;
      SETUP_RD:
        next = ACCESS_RD;
      ACCESS_RD:
        if (pready_s)
          next = WAIT_RD;
        else
          next = ACCESS_RD;
      WAIT_RD:
        if (data_ready) begin
          if (status[1])
            next = SETUP_RD;
          else 
            next = IDLE;
        end
        else
          next = WAIT_RD;
      default: 
          next = IDLE;
    endcase
  end

  //calculate and register next outputs
  always @(posedge clk or negedge reset_n)
    if (!reset_n ) begin
      rdata <= 16'h0000;
      psel_s <= 2'b00;
      pwrite_s <= 1'b0;
      penable_s <= 1'b0;
      pstrb_s <= 2'b00;
      paddr_s <= 20'h00000;
      pwdata_s <= 16'h0000;  
    end
    
    else begin
      case (next)
        SETUP_WR: begin
          if (status[0])
            psel_s <= 2'b10;
          else 
            psel_s <= 2'b01;
          pwrite_s <= 1'b1;
          pstrb_s <= 2'b11;
          paddr_s <= addr;
          pwdata_s <= wdata;           
        end 
        ACCESS_WR: 
          penable_s <= 1'b1;  
        SETUP_RD: begin
          if (status[0])
            psel_s <= 2'b10;
          else 
            psel_s <= 2'b01;
          pwrite_s <= 1'b0;
          pstrb_s <= 2'b11;
          paddr_s <= addr;
          pwdata_s <= wdata;           
        end 
        ACCESS_RD: 
          penable_s <= 1'b1;  
        WAIT_RD: begin
          rdata <= prdata_s;
          psel_s <= 2'b00;
          penable_s <= 1'b0;
        end
        IDLE: begin
          psel_s <= 2'b00;
          penable_s <= 1'b0;
        end
        WAIT_WR: begin
          psel_s <= 2'b00;
          penable_s <= 1'b0;
        end

        default: begin
          rdata <= 16'h0000;
          psel_s <= 2'b00;
          pwrite_s <= 1'b0;
          penable_s <= 1'b0;
          pstrb_s <= 2'b00;
          paddr_s <= 20'h00000;
          pwdata_s <= 16'h0000; 
        end
    endcase
  end

endmodule