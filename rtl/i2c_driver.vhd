-------------------------------------------------------------------------------------
-- i2c_driver.vhd
--
-- Date: 05/10/2024
--
-- Engineer: Gregory Evans
--
-- Desc: 
--
--	Basic I2C Master driver. Supports reading and writing. 
-- Only supports single byte reads. Supports multi-byte writes.
--
-- i_clk 			- clock source for the module and SCL
-- i_en				- I2C Enable. Set this high to start a transaction
-- i_bus_addr_rw 	- 7 bit address [7..1] read/active lo write [0]
-- i_bus_data		- Transmit data input
-- o_rdy				- When writing, indicates when transmission is complete and new data can be provided
--						- When reading, indicates when o_data is valid.
-- o_data			- Read data output
-- o_scl				- I2C SCL output
-- o_sda				- I2C SDA I/O
--------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_driver is
 port (
	i_clk				: in std_logic; --Input clock. This will be the i2C Clock frequency.
	i_en				: in std_logic; --Enable to start and stop a transaction.
	i_bus_addr_rw	: in unsigned(7 downto 0); -- I2C Address (7..1) R/W (0)
	i_bus_data		: in unsigned(7 downto 0); --bus data
	o_rdy				: out std_logic; --Indicates when I2C driver is ready 
	o_data			: out unsigned(7 downto 0); --Parallel data output for reads
	o_sda				: inout std_logic; --SDA line
	o_scl				: out std_logic --SCL line
	);
	
end i2c_driver;


architecture rtl of i2c_driver is

	type 		t_i2c_state is (idle, start, addr_transmit, data_transmit, data_read, ack, stop);
	signal 	r_state 		: t_i2c_state := idle;

	signal	r_en_0 		: std_logic := '0';
	signal	r_bit_cnt	: unsigned(3 downto 0) := (others => '0');
	signal 	r_data		: unsigned(7 downto 0) := (others => '0');
	
	signal r_bus_addr_rw : unsigned(7 downto 0) := (others => '0');
	signal r_bus_data 	: unsigned(7 downto 0) := (others => '0');

begin


i2c_state_machine: process(i_clk)
begin

	if rising_edge(i_clk) then
	
		r_en_0 		<= i_en;
	
		case r_state is
		
		when idle =>
			
			if r_en_0 = '0' and i_en = '1' then
				
				o_sda 			<= '0';
				r_state 			<= start;
				r_bus_addr_rw 	<= i_bus_addr_rw;
				r_bus_data		<= i_bus_data;
				o_rdy				<= '0';
				
			else
				o_sda 			<= '1';
				o_rdy 			<= '1';
				
			end if;
		
		when start =>
		
			o_sda 	<= r_bus_addr_rw(7);
			r_state	<= addr_transmit;
			
		when addr_transmit =>
					
			case r_bit_cnt is
			
				when "0000" =>
					o_sda 		<= r_bus_addr_rw(6);
					r_bit_cnt 	<= r_bit_cnt + "0001";
					
				when "0001" =>
					o_sda 		<= r_bus_addr_rw(5);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0010" =>
					o_sda 		<= r_bus_addr_rw(4);
					r_bit_cnt 	<= r_bit_cnt + "0001";
					
				when "0011" =>
					o_sda 		<= r_bus_addr_rw(3);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0100" =>
					o_sda 		<= r_bus_addr_rw(2);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0101" =>
					o_sda 		<= r_bus_addr_rw(1);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0110" =>
					o_sda 		<= r_bus_addr_rw(0);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0111" =>
					o_sda 		<= 'Z';
					r_state 		<= ack;
					r_bit_cnt 	<= "0000";
					
			
				when others =>			
				
			end case;
		
		when data_transmit =>
		
			case r_bit_cnt is
		
			when "0000" =>
				o_sda 		<= r_bus_data(6);
				r_bit_cnt 	<= r_bit_cnt + "0001";
				o_rdy 		<= '1';
				
			when "0001" =>
				o_sda 		<= r_bus_data(5);
				r_bit_cnt 	<= r_bit_cnt + "0001";
				o_rdy			<= '0';
			
			when "0010" =>
				o_sda 		<= r_bus_data(4);
				r_bit_cnt 	<= r_bit_cnt + "0001";
				
			when "0011" =>
				o_sda 		<= r_bus_data(3);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0100" =>
				o_sda 		<= r_bus_data(2);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0101" =>
				o_sda 		<= r_bus_data(1);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0110" =>
				o_sda 		<= r_bus_data(0);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0111" =>
				o_sda 		<= 'Z';
				r_state 		<= ack;
				r_bit_cnt 	<= "0000";
	
				
		
			when others =>			
			
			end case;
		
		when data_read =>
		
			case r_bit_cnt is
		
			when "0000" =>
				r_data(7) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
				
			when "0001" =>
				r_data(6) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0010" =>
				r_data(5) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
				
			when "0011" =>
				r_data(4) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0100" =>
				r_data(3) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0101" =>
				r_data(2) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0110" =>
				r_data(1) 	<= o_sda;
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0111" =>
				o_data		<= r_data(7 downto 1) & o_sda;
				o_sda			<= '1';
				r_state 		<= stop;
				r_bit_cnt 	<= "0000";
				o_rdy 		<= '1';
				
		
			when others =>			
			
			end case;			
			
		
		when ack =>
			
			if i_en = '1' and r_bus_addr_rw(0) = '0' then
				r_state 		<= data_transmit;
				r_bus_data	<= i_bus_data;	
				o_sda 		<= i_bus_data(7);
				
			elsif i_en = '1' and r_bus_addr_rw(0) = '1' then
				r_state 	<= data_read;
				o_sda		<= 'Z';
			else
				r_state <= stop;
				o_sda <= '0';
			end if;
		
		when stop =>
		
			o_sda 	<= '1';
			o_rdy 	<= '1';
			r_State 	<= idle;	
		
		end case;
	end if;
end process;

o_scl <= i_clk when r_state = start or 
							r_state = data_read or 
							r_state = addr_transmit or 
							r_state = data_transmit or 
							r_state = ack 
							else '1';




end rtl;