# AoSoC
---
**Update (May 10, 2020)**: Due to the fast evolution of the RISC-V community, some dependencies (software and IP) of this project were deprecated or outdated. With the latest set of tools, workarounds in our code may no longer be required or they may have provided better solutions.

## System description
This is a system-on-chip (SoC) project utilizing always-on-sensor (AoS, a proprietary image processing IP which detects visual objects 24/7 with minimum power). The system can be used as a building block to awake more power demanding IP to achieve a low-power design, targeting in the domain of Internet-of-Things.

_List of IP_:
| Name | Author | Description |
|------|--------|-------------|
| AoS | [hchsiao](https://github.com/hchsiao/) | ASIC implementation of Viola-Jones algorithm ([Paper](https://ieeexplore.ieee.org/document/8724671/)) |
| apb | [pulp-platform](https://github.com/pulp-platform) | APB bus implemented in SystemVerilog |
| axi | [pulp-platform](https://github.com/pulp-platform) | AXI bus implemented in SystemVerilog |
| peripherals | [pulp-platform](https://github.com/pulp-platform) | Common peripherals for a MCU |
| zero-riscy | [pulp-platform](https://github.com/pulp-platform) | A low-footprint RISC-V (RV32IMC) core |
| zero-buggy | [hchsiao](https://github.com/hchsiao/) | RISC-V compatible debug module written for zero-riscy |

**Note to zero-buggy**: At the moment this project started, the debug module in zero-riscy is OpenRISC 1200 compatible (adv_debugsys from opencores.org).

### Architecture
For coarse-graied architecture, see [src/top.sv](src/top.sv) for how highest-level blocks are composed.

## Verification
### Setup dependencies
```
./download.sh
```
### Tools
- ncsim (a.k.a. Cadence Incisive)
  - HDL simulator
  - `ncsim` command should be available after a successful Incisive installation
- uartdpi
  - A program to start a pseudo-terminal to talk to uart hardware
  - Exploiting SystemVerilog's DPI to interact with simulator
  - Originally [wallento/uartdpi](https://github.com/wallento/uartdpi/tree/0d15fd9b68d56919d8833df79fb1e4c93edcdc09)
- openocd_jtag_dpi
  - UNIX socket controlled jtag for simulation
  - Originally [fjullien/jtag_vpi](https://github.com/fjullien/jtag_vpi/tree/bbdf4f62642031c03bd984826b9bc7389205e6cb)
  - **Hacked**: OpenOCD support, use DPI instead of VPI
- riscv-isa-sim (Spike)
  - Authorized RISC-V behavioral simulator
  - **Hacked**: a custom uart device were added to memory map (with incomplete functionality...)
- riscv-openocd
  - **Hacked**: bug fix (see the [git diff](https://github.com/hchsiao/riscv-openocd/commit/0767d8bd7850f466aeb22d080b2670f81358d0a1))

### Targets
Three targets are available (all these targets are verified by OpenOCD with manual inspection):
1. Behavioral simulator (i.e. Spike)
2. Cycle-accurate simulation with SystemVerilog
3. Emulation with FPGA

#### Behavioral simulation
To invoke spike simulator, load `dummy.elf` to ram, and start GDB with OpenOCD invoked with pipe mode:
```
cd run
make run V=1
```
Note that image processing IP will not be available in this mode.
- See [sw/spike.cfg](sw/spike.cfg) for OpenOCD configuration

#### RTL simulation
RTL simulation with `ncsim`. See [testbench](src/test.sv).
- Debug connection: ncsim <-> openocd_jtag_dpi <-> OpenOCD <-> gdb
- UI connection: ncsim <-> uartdpi <-> pseudo-terminal program (e.g. minicom)
```
cd run
make sim V=1
```
To run gdb seperately:
```
cd run
make gdb
```
- See [src/jtag_dpi.cfg](src/jtag_dpi.cfg) for OpenOCD configuration

#### FPGA emulation
Top module for bitstream generation: [src/top.sv](src/top.sv)
```
cd run
make FPGA V=1
```
To run gdb seperately:
```
cd run
make gdb
```
- See [src/fpga.cfg](src/fpga.cfg) for OpenOCD configuration

## Contributors
- [hchsiao](https://github.com/hchsiao) (Hsiang-Chih Hsiao)
- [Jyun-Neng](https://github.com/Jyun-Neng) (Jyun-Neng Ji)
- shiyong (Shi-Yong Wu)
