library ieee;
library std;
use ieee.std_logic_1164.all, ieee.math_real.all;

library blinky;

library vunit_lib;
context vunit_lib.vunit_context;

entity blinky_tb is
	generic 
	( runner_cfg    : string
	; blink_freq_hz : real    := 100.0
	; clk_freq      : natural := 100000000
	)  ;
end entity;

architecture tb of blinky_tb is

	--derived constants
	constant real_clk_p : real := 1.0/real(clk_freq);

	constant clk_peroid : time := real_clk_p * 1000 ms;

	constant counter_max : natural := 
		natural(ceil(real(clk_freq/2) / blink_freq_hz));

	constant blink_peroid : time := counter_max * clk_peroid * 2 ;

	--internal signals
	signal clk : std_ulogic := '0';
	signal rst : std_ulogic := '0';
	signal led : std_ulogic ;

	signal finished : boolean := false;
	
begin

	clk <= not clk after clk_peroid/2;

	UUT : entity blinky.blinky 
	generic map
	( clk_freq_hz   => clk_freq
	, blink_freq_hz => blink_freq_hz 
	, rst_polarity  => '1'
	) 
	port map 
	( clk => clk
	, rst => rst
	, blink => led
	) ;

--test script
test_script : process
begin
	rst <= '1';
	
	wait for clk_peroid;
	check(led = '0', "Expect to be low in when in reset mode");
	rst <= '0';

	wait for blink_peroid/2 + clk_peroid ;
	check(led = '1', "Expect to be high at 1/2 a peroid");

	wait for blink_peroid/2 + clk_peroid ; 
	check(led = '0', "Expect to be low after completing full cycle");

	wait for blink_peroid/2 + clk_peroid ;
	check(led = '1', "Completed low -> high cycle");

	rst <= '1';

	wait for clk_peroid;
	check(led ='0', "Expect to be low when reset set");
	finished <= true; --signal to other process to end sim
end process;

vunit_proc : process
begin
	test_runner_setup(runner, runner_cfg);
	wait until finished = true;
	test_runner_cleanup(runner);
	std.env.finish;
end process;

end architecture;
