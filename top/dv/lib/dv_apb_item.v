class dv_apb_item;
  parameter DW = 32;
  parameter AW = 32;

  rand logic            write;
  rand logic [AW-1:0]   addr;
  rand logic [DW-1:0]   data;
  rand logic [DW/8-1:0] strb;
endclass