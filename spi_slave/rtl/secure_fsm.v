module secure_fsm(
  input clk,
  input reset_n,
  input [1:0] psel_s,
  input penable_s,
  input pwrite_s,
  input [1:0] pstrb_s,
  input [19:0] paddr_s,
  input [15:0] pwdata_s,
  input [15:0] prdata_rm,
  input pready_rm,
  input pslverr_rm,
  input [15:0] prdata_icn,
  input pready_icn,
  input pslverr_icn,

  output [1:0] psel,
  output penable,
  output pwrite,
  output [1:0] pstrb,
  output [19:0] paddr,
  output [15:0] pwdata,
  output [15:0] prdata_s,
  output pready_s,
  output pslverr_s_rm,
  output pslverr_s_icn
);

  reg [1:0] psel;
  reg penable;
  reg pwrite;
  reg [1:0] pstrb;
  reg [19:0] paddr;
  reg [15:0] pwdata;
  reg [15:0] prdata_s;
  reg pready_s;
  reg pslverr_s_rm;
  reg pslverr_s_icn;
  reg penable_temp;

  reg state, nexr;

  localparam LOCKED = 1'b0;
  localparam UNLOCKED = 1'b1;
  localparam PAS_ADR = 20'h00C1A;
  localparam PAS_DATA = 16'hA007;


  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      state <= LOCKED;
      psel <= 2'b00;
      penable <= 1'b0;
      pwrite <= 1'b0;
      pstrb <= 2'b00;
      paddr <= 20'h00000;
      pwdata <= 16'h0000;
      prdata_s <= 16'h0000;
      pready_s <= 1'b0;
      pslverr_s_rm <= 1'b0;
      pslverr_s_icn <= 1'b0;
    end
    else begin
      case (state)
        LOCKED: begin
          if (psel_s == 2'b01) begin
            state <= LOCKED;
            if (!pready_rm) begin             
              psel <= psel_s;
              penable_temp <= penable_s;
              penable <= penable_temp;
              pwrite <= pwrite_s;
              pstrb <= pstrb_s;
              paddr <= paddr_s;
              pwdata <= pwdata_s;
              prdata_s <= prdata_rm;
              pslverr_s_rm <= pslverr_rm;
              pslverr_s_icn <= 1'b0;
            end
            else begin
              psel <= 2'b00;
              penable <= 1'b0;             
            end
          end
          else if (psel_s == 2'b10) begin
            if ((paddr_s == PAS_ADR) & (pwdata_s == PAS_DATA)
              & (pwrite_s == 1'b1)) begin  
                if (!pready_icn) begin
                  state <= LOCKED;
                  psel <= psel_s;
                  penable_temp <= penable_s;
                  penable <= penable_temp;
                  pwrite <= pwrite_s;
                  pstrb <= pstrb_s;
                  paddr <= paddr_s;
                  pwdata <= pwdata_s;
                  pslverr_s_icn <= pslverr_icn;
                  pslverr_s_rm <= 1'b0;
                end         
                else begin
                  state <= UNLOCKED;
                  psel <= 2'b00;
                  penable <= 1'b0;             
                end
            end
            else begin
              state <= LOCKED;
              psel <= 2'b00;
              penable <= 1'b0;
              pwrite <= 1'b0;
              pstrb <= 2'b00;
              paddr <= 20'h00000;
              pwdata <= 16'h0000;
              prdata_s <= 16'h0000;
              pready_s <= 1'b0;
              pslverr_s_rm <= 1'b0;
              pslverr_s_icn <= 1'b0;
            end
          end
          else begin
            state <= LOCKED;
            psel <= 2'b00;
            penable <= 1'b0;
            pwrite <= 1'b0;
            pstrb <= 2'b00;
            paddr <= 20'h00000;
            pwdata <= 16'h0000;
            prdata_s <= 16'h0000;
            pready_s <= 1'b0;
            pslverr_s_rm <= 1'b0;
            pslverr_s_icn <= 1'b0;
          end
        end
        
        UNLOCKED: begin
          if (psel_s == 2'b01) begin
            state <= UNLOCKED;
            if (!pready_rm) begin             
              psel <= psel_s;
              penable_temp <= penable_s;
              penable <= penable_temp;
              pwrite <= pwrite_s;
              pstrb <= pstrb_s;
              paddr <= paddr_s;
              pwdata <= pwdata_s;
              prdata_s <= prdata_rm;
              pslverr_s_rm <= pslverr_rm;
              pslverr_s_icn <= 1'b0;
            end
            else begin
              psel <= 2'b00;
              penable <= 1'b0;             
            end
          end
          else if (psel_s == 2'b10) begin
            if ((paddr_s == PAS_ADR) & (pwdata_s == PAS_DATA)
              & (pwrite_s == 1'b1)) begin  
                if (!pready_icn) begin
                  state <= LOCKED;
                  psel <= psel_s;
                  penable_temp <= penable_s;
                  penable <= penable_temp;
                  pwrite <= pwrite_s;
                  pstrb <= pstrb_s;
                  paddr <= paddr_s;
                  pwdata <= pwdata_s;
                  pslverr_s_icn <= pslverr_icn;
                  pslverr_s_rm <= 1'b0;
                end         
                else begin
                  state <= UNLOCKED;
                  psel <= 2'b00;
                  penable <= 1'b0;             
                end
            end
            else begin
              if (!pready_icn) begin
                state <= UNLOCKED;
                psel <= psel_s;
                penable_temp <= penable_s;
                penable <= penable_temp;
                pwrite <= pwrite_s;
                pstrb <= pstrb_s;
                paddr <= paddr_s;
                pwdata <= pwdata_s;
                pslverr_s_icn <= pslverr_icn;
                pslverr_s_rm <= 1'b0;
              end         
              else begin
                state <= UNLOCKED;
                psel <= 2'b00;
                penable <= 1'b0;             
              end
            end
          end
          else begin
            state <= UNLOCKED;
            psel <= 2'b00;
            penable <= 1'b0;
            pwrite <= 1'b0;
            pstrb <= 2'b00;
            paddr <= 20'h00000;
            pwdata <= 16'h0000;
            prdata_s <= 16'h0000;
            pready_s <= 1'b0;
            pslverr_s_rm <= 1'b0;
            pslverr_s_icn <= 1'b0;
          end
        end
      endcase
    end
  
endmodule