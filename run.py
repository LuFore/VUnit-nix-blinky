from vunit import VUnit
import random
import os


# Parameters for random testing
MAX_VAL     = 50e6 # 2x hard-coded (100Mhz) clock speed, 
MIN_VAL     = 100  # any slower is slow to simulate!
NO_OF_TESTS = 10

# Create VUnit instance by parsing command line arguments
prj = VUnit.from_argv(compile_builtins=False)

prj.add_vhdl_builtins()

#name library blinky
lib = prj.add_library("blinky")

#add files to library
base_path = os.path.dirname(os.path.abspath(__file__)) + "/hdl/"
lib.add_source_files(base_path + "hw/*.vhd")
lib.add_source_files(base_path + "tb/*.vhd")

def add_test(tb, freq):
	test_name = "test_" + str(round(freq)) + "Hz"
	generic_vals = {"blink_freq_hz":float(freq)}
	
	tb.add_config(
		name=test_name, 
		generics=generic_vals,
	)

#create testbench from entity 
tb = lib.test_bench("blinky_tb")

#edge case test
add_test(tb, MAX_VAL) 
add_test(tb, MIN_VAL) 

#constrained random test
random.seed(1066)
get_random = lambda _ : random.uniform(MIN_VAL, MAX_VAL)
random_nums = list(map(get_random, range(NO_OF_TESTS)))

#add test configurations
for test_freq in random_nums :
	add_test(tb, round(test_freq))

#generate waveform, unncomment if things aren't working!
#prj.set_sim_option("nvc.sim_flags", ["-w", "--format=fst"])

#run it!
prj.main()
