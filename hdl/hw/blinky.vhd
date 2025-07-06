library ieee;
use ieee.std_logic_1164.all, ieee.math_real.all;

entity blinky is 
	generic
	( clk_freq_hz   : natural    := 100000000
	; blink_freq_hz : real       := 1.0
	; rst_polarity  : std_ulogic := '0'
	) ;

	port
	( clk   : in std_ulogic
	; rst   : in std_ulogic 
	; blink :out std_ulogic
	) ;

end entity;

architecture blinky_arch of blinky is
	
	--calculate how long counter needs to be
	constant counter_max : natural := 
		natural(ceil(real(clk_freq_hz/2) / blink_freq_hz));
	subtype counter_t is natural range 0 to counter_max;

	signal counter     : counter_t ;
	signal blink_state : std_ulogic := '0';

begin
process(clk)
begin
	if rising_edge(clk) then
		if rst = rst_polarity then
			blink_state <= '0';
			counter <= 0;
		elsif counter = counter_max then
			blink_state <= not blink_state;
			counter <= 0;
		else
			counter <= counter + 1;
		end if;
	end if;
end process;

blink <= blink_state;

end blinky_arch;
