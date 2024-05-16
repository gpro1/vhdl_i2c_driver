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
	signal i2c_data		: unsigned(7 downto 0) := (others => '0');
	
	signal i2c_data_test	: unsigned(7 downto 0) := (others => '0');


		
begin

test_clk <= not test_clk after 2.5 us;

DUT: entity work.i2c_driver(rtl)
	port map (
		i_clk				=> test_clk,		
		i_en				=> i2c_en,
		i_bus_addr_rw	=> bus_addr_rw,
		i_bus_data		=> bus_data,
		o_rdy				=> i2c_rdy,
		o_data			=> i2c_data,
      o_sda				=> sda,
      o_scl				=> scl);
		
--stimulus: process
--begin
--
--	wait until rising_edge(test_clk);
--	bus_addr_rw <= x"A7";
--	bus_data 	<= x"55";
--	i2c_en 		<= '1';
--	wait until rising_edge(scl);
--	bus_data 	<= x"DE";
--	wait for 40 us;
--	sda <= '0';
--	wait for 5 us;
--	sda <= 'Z';
--
--	
--	wait;
--
--end process;

stimulus: process
begin

	--Set Initial address, Enable I2C 
	wait until rising_edge(test_clk);
	bus_addr_rw <= x"A6";
	bus_data 	<= x"55";
	i2c_en 		<= '1';
	
	--wait for first rising edge of SCL
	wait until rising_edge(scl);
	
	--Sample SDA for address
	for i in 7 downto 0 loop
		i2c_data_test(i) <= sda;
		wait until rising_edge(scl);
	end loop;
	
	--acknowledge data
	sda 	<= '0';
	--Check transmission
	assert(i2c_data_test = x"A6") report "Incorrect address detected at time: " & time'image(now) severity error;
	
	--Release SDA
	wait until rising_edge(scl);
	sda <= 'Z';
	
	--Sample SDA for data
	for i in 7 downto 0 loop
		i2c_data_test(i) <= sda;
		wait until rising_edge(scl);
	end loop;
	
	--acknowledge data, end transmission
	sda 		<= '0';
	i2c_en	<= '0';
	--Check transmission
	assert(i2c_data_test = x"55") report "Incorrect data detected at time: " & time'image(now) severity error;
	
	--Release SDA
	wait until rising_edge(scl);
	sda 		<= 'Z';

		
	
	wait for 15 us;
	
	bus_addr_rw <= x"A7";
	bus_data 	<= x"66"; --should be irrelevent
	i2c_en 		<= '1';
	

	wait until rising_edge(scl);
	
	--Sample SDA for address
	for i in 7 downto 0 loop
		i2c_data_test(i) <= sda;
		wait until rising_edge(scl);
	end loop;
	
	--acknowledge data
	sda 	<= '0';
	--Check transmission
	assert(i2c_data_test = x"A7") report "Incorrect address detected at time: " & time'image(now) severity error;
	
	
	wait until rising_edge(scl);
	
	--Prepare "Read" data
	i2c_data_test <= x"AB";
	
	--Simulate slave transmitter
	for i in 7 downto 0 loop
		sda <= i2c_data_test(i);
		wait until rising_edge(scl);
	end loop;
	
	--Disable module
	i2c_en	<= '0';
	
	wait until rising_edge(test_clk);
	wait until rising_edge(test_clk);

	--Verify correct parallel data out
	assert(i2c_data = x"AB") report "Incorrect data detected at time: " &time'image(now) severity error;
	
	
	wait;

end process;



end architecture;
