--I2C Driver Testbench
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_driver_testbench is
end entity i2c_driver_testbench;

architecture rtl of i2c_driver_testbench is
	
	signal test_clk 		: std_logic := '0';
	signal i2c_en 			: std_logic := '0';
	signal bus_addr_rw	: unsigned(7 downto 0) := (others => '0');
	signal bus_data		: unsigned(7 downto 0) := (others => '0');
	signal sda				: std_logic := 'Z';
	signal scl				: std_logic := 'Z';
	signal i2c_rdy			: std_logic := 'Z';


		
begin

test_clk <= not test_clk after 2.5 us;

DUT: entity work.i2c_driver(rtl)
	port map (
		i_clk				=> test_clk,		
		i_en				=> i2c_en,
		i_bus_addr_rw	=> bus_addr_rw,
		i_bus_data		=> bus_data,
		o_rdy				=> i2c_rdy,
		o_data			=> open,
      o_sda				=> sda,
      o_scl				=> scl);
		
stimulus: process
begin

	wait until rising_edge(test_clk);
	bus_addr_rw <= x"A7";
	bus_data 	<= x"55";
	i2c_en 		<= '1';
	wait until rising_edge(scl);
	bus_data 	<= x"DE";
	wait for 37.5 us;
	sda <= '0';
	wait for 5 us;
	sda <= 'Z';

	
	wait;

end process;


end architecture;
