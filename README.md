# AOSOC

VLSI :+1:

## Usage

Download dependency: 
```
./download.sh
```

Simulation without debugger (DO NOT USE): 
```
cd run
make inner-ncsim V=1 JTAG_ENABLE=0
```

Spike with debugger + gdb: 
```
cd run
make run V=1
```

Simulation(ncsim) with debugger: 
```
cd run
make sim V=1
```
To run gdb in another terminal:
```
make gdb
```

## Tutorial

God bless you!
