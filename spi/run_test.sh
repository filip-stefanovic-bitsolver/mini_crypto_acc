#!/bin/bash
[ -d work ] && rm -rf work
mkdir work
cd work
iverilog -g2012 \
    -I $PROJDIR/top/dv/lib \
    -I $PROJDIR/spi_slave/rtl \
    -I $PROJDIR/spi_data_path/rtl \
    -I ../rtl \
    -I ../tb \
    ../tb/spi_regmap_test.v
    vvp tb.o
cd ../