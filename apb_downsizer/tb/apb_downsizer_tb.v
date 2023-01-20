`timescale 1ns/1ps

module apb_downsizer_tb();

reg pclk, preset_n, pwrite_i, psel_i, penable_i;
reg [31:0]paddr_i;
reg [31:0]pwdata_i;
reg [15:0]prdata_i;
reg pready_i;
reg [3:0]pstrb_i;

initial begin
    $display("Start: %t", $time);
    preset_n = 0;
    pclk = 0;
    psel_i = 0;
    penable_i = 0;
    #50ns;

    pready_i = 0;
    preset_n = 1;
    #4ns;

    //WRITE CYCLE - STROBE: 0110
    psel_i = 1;
    pwrite_i = 1;
    pstrb_i = 4'h6;
    paddr_i = 32'h00000600;
    pwdata_i = 32'h77554433;
    #4ns;
    penable_i = 1;

    #20.1ns;
    pready_i = 1;
    #4ns;
    pready_i = 0;
    #12ns;
    pready_i = 1;
    #4ns;
    pready_i = 0;
    #4ns;
    psel_i = 0;
    penable_i = 0;
    #12ns;

    //READ CYCLE - STROBE: 1111
    psel_i = 1;
    pwrite_i = 0;
    pstrb_i = 4'hF;
    paddr_i = 32'h00003334;
    #4ns;

    penable_i = 1;
    #20ns;
    pready_i = 1;
    prdata_i = 16'hCC33;
    #4ns;
    pready_i = 0;
    #8ns;
    pready_i = 1;
    prdata_i = 16'h1111;
    #4ns; 
    pready_i = 0;
    #4ns;
    psel_i = 0;
    penable_i = 0;
    #12ns;

    //WRITE CYCLE - STROBE: 1100
    psel_i = 1;
    pwrite_i = 1;
    pstrb_i = 4'hC;
    paddr_i = 32'h00000008;
    pwdata_i = 32'hBBAAFF00;
    #4ns;

    penable_i = 1;

    #16ns;
    pready_i = 1;
    #4ns;
    pready_i = 0;
    #4ns;
    psel_i = 0;
    penable_i = 0;
    #12ns;

    //READ CYCLE - STROBE: 0011
    psel_i = 1;
    pwrite_i = 0;
    pstrb_i = 4'h3;
    paddr_i = 32'h0000001C;
    #4ns;

    penable_i = 1;
    #20ns;
    pready_i = 1;
    prdata_i = 16'hFFAA;
    #4ns;
    pready_i = 1;
    #4ns;
    psel_i = 0;
    penable_i = 0;
    #8ns;

    //WRITE CYCLE - STROBE: 1101 and pready always 1 
    psel_i = 1;
    pwrite_i = 1;
    pstrb_i = 4'hC;
    paddr_i = 32'h00000A28;
    pwdata_i = 32'hCCAA1313;
    #4ns;

    penable_i = 1;

    #16ns;
    pready_i = 1;
    #4ns;
    pready_i = 1;
    #4ns;
    psel_i = 0;
    penable_i = 0;
    #12ns;
    


    
    #100ns;
    $finish;
    end

initial begin
    $dumpfile("waves.vcd");
    $dumpvars;
end

always begin
    #2ns;
    pclk = ~pclk;
end

apb_downsizer apb_downsizer(.penable_i(penable_i),
                            .pclk(pclk),
                            .preset_n(preset_n),
                            .pwrite_i(pwrite_i),
                            .psel_i(psel_i),
                            .paddr_i(paddr_i),
                            .pwdata_i(pwdata_i),
                            .prdata_i(prdata_i), 
                            .pready_i(pready_i), 
                            .pstrb_i(pstrb_i));

endmodule