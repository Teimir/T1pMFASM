@echo off
cd %1
iverilog.exe -g2005 cpu.sv testbench.sv && vvp a.out
set /P var = ""
exit 1