module control_fsm(
  input clk,
  input reset_n,
  input address_ready,
  input status_ready,
  input data_ready,
  input [19:0] addr,
  input [3:0] status,
  input [15:0] wdata,
  input pready_s,
  input [15:0] prdata_s,
  input pslverr_s_rm,
  input pslverr_s_icn,
  input cs_n_o,
  input miso_start,

  output reg [1:0] psel_s,
  output reg penable_s,
  output reg pwrite_s, 
  output reg [1:0] pstrb_s,
  output reg [19:0] paddr_s,
  output reg [15:0] pwdata_s,
  output reg [15:0] rdata,
  output reg err
);


  reg [19:0] address;
  reg cs_flag;
  reg [3:0] state, next;

  //states
  localparam IDLE = 4'h0;
  localparam WAIT_WR = 4'h1;
  localparam SETUP_WR = 4'h2;
  localparam ACCESS_WR = 4'h3;
  localparam SETUP_RD = 4'h4;
  localparam ACCESS_RD = 4'h5;
  localparam WAIT_RD = 4'h6;
  localparam ERROR = 4'h7;
  //error message
  localparam DEAD = 16'h4552;

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
        if (status_ready) begin
          if (status[2])
            next = WAIT_WR;
          else
            next = SETUP_RD;
        end
        else
          next = IDLE;
      WAIT_WR:
        if (cs_flag)
          next = IDLE;
        else begin
          if (data_ready)
            next = SETUP_WR;
          else
            next = WAIT_WR;
        end
      SETUP_WR:
        next = ACCESS_WR;
      ACCESS_WR:
        if (pready_s) begin
          if (pslverr_s_icn || pslverr_s_rm)
            next = ERROR;
          else begin
            if (status[1])
              next = WAIT_WR;
            else 
              next = IDLE;
          end
        end
        else if (address_ready)
          next = IDLE;
        else 
          next = ACCESS_WR;
      SETUP_RD:
        next = ACCESS_RD;
      ACCESS_RD:
        if ((pready_s) && (!pslverr_s_icn && !pslverr_s_rm) && (!miso_start))
          next = WAIT_RD;
        else if ((miso_start) || ((pslverr_s_icn || pslverr_s_rm) && pready_s))
          next = ERROR;
        else if (cs_flag)
          next = IDLE;
        else
          next = ACCESS_RD;
      WAIT_RD:
        if (cs_flag)
          next = IDLE;
        else begin
          if (data_ready) begin
            if (status[1])
              next = SETUP_RD;
            else 
              next = IDLE;
          end
          else
            next = WAIT_RD;
        end
      ERROR:
        if (cs_flag)
          next = IDLE;
        else begin
          if (data_ready) begin
            if (status[1]) begin
              if (status[2])
                next = SETUP_WR;
              else
                next = SETUP_RD;
            end
            else 
              next = IDLE;
          end
          else
            next = ERROR;
        end
      default: 
          next = IDLE;
    endcase
  end

  //address sampling and incrementation, and cs_flag generation
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      address <= 20'h00000;
      cs_flag <= 1'b0;
    end
    else begin
      if (state == IDLE)
        cs_flag <= 1'b0;
      else if (cs_n_o)
        cs_flag <= 1'b1;
      else
        cs_flag <= cs_flag;
      //if ((state == IDLE) && (address_ready))
      if (address_ready)
        address <= addr;
      else if (((state == ACCESS_RD) || (state == ACCESS_WR)) && pready_s)
        address <= address + 20'h00002;
    end

  //error signal generation
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      err <= 1'b0;
    else begin
      if ((next == ERROR) && (state != ERROR))
        err <= 1'b1;
      else 
        err <= 1'b0;
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
          paddr_s <= address;
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
          paddr_s <= address;
          pwdata_s <= wdata;       
        end 
        ACCESS_RD: 
          penable_s <= 1'b1;  
        WAIT_RD: begin
          if (pready_s)
            rdata <= prdata_s;
          psel_s <= 2'b00;
          penable_s <= 1'b0;
        end
        IDLE: begin
          psel_s <= 2'b00;
          penable_s <= 1'b0;
          rdata <= 16'h0000;
        end
        WAIT_WR: begin
          psel_s <= 2'b00;
          penable_s <= 1'b0;
        end
        ERROR: begin
          rdata <= DEAD;
          psel_s <= 1'b0;
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