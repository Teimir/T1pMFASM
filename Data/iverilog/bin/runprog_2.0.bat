@echo off
cd %1
iverilog.exe -g2005 cpu.sv testbench_2.0.sv && vvp a.out
set /P var = ""
exit 1