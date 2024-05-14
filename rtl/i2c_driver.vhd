-------------------------------------------------------------------------------------
-- i2c_driver.vhd
--
-- Date: 05/10/2024
--
-- Engineer: Gregory Evans
--
-- Desc: 
--
--
--
--
--
--
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
	o_rdy				: out std_logic; --Indicates when I2C driver is ready for new data
	o_data			: out unsigned(7 downto 0); --Parallel data output for reads
	o_sda				: inout std_logic; --SDA line
	o_scl				: out std_logic --SCL line
	);
	
end i2c_driver;


architecture rtl of i2c_driver is

	type 		t_i2c_state is (idle, start, addr_transmit, data_transmit, ack, stop);
	signal 	r_state 		: t_i2c_state := idle;
	--signal 	r_state_1	: t_i2c_state := idle;
	signal	r_en_0 		: std_logic := '0';
	--signal	r_sda			: std_logic := '1';
	signal 	r_scl 		: std_logic := '1';
	signal	r_bit_cnt	: unsigned(3 downto 0) := (others => '0');
	
	
	

begin


i2c_state_machine: process(i_clk)
begin

	if falling_edge(i_clk) then
	
		r_en_0 		<= i_en;
		--r_state_1 	<= r_state;
	
		case r_state is
		
		when idle =>
			
			if r_en_0 = '0' and i_en = '1' then
				
				o_sda 	<= '0';
				r_state 	<= start;
				
			else
				o_sda <= '1';
				
			end if;
		
		when start =>
		
			o_sda 	<= i_bus_addr_rw(7);
			r_state	<= addr_transmit;
			
		when addr_transmit =>
					
			case r_bit_cnt is
			
				when "0000" =>
					o_sda 		<= i_bus_addr_rw(6);
					r_bit_cnt 	<= r_bit_cnt + "0001";
					
				when "0001" =>
					o_sda 		<= i_bus_addr_rw(5);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0010" =>
					o_sda 		<= i_bus_addr_rw(4);
					r_bit_cnt 	<= r_bit_cnt + "0001";
					
				when "0011" =>
					o_sda 		<= i_bus_addr_rw(3);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0100" =>
					o_sda 		<= i_bus_addr_rw(2);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0101" =>
					o_sda 		<= i_bus_addr_rw(1);
					r_bit_cnt 	<= r_bit_cnt + "0001";
				
				when "0110" =>
					o_sda 		<= i_bus_addr_rw(0);
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
				o_sda 		<= i_bus_data(6);
				r_bit_cnt 	<= r_bit_cnt + "0001";
				
			when "0001" =>
				o_sda 		<= i_bus_data(5);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0010" =>
				o_sda 		<= i_bus_data(4);
				r_bit_cnt 	<= r_bit_cnt + "0001";
				
			when "0011" =>
				o_sda 		<= i_bus_data(3);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0100" =>
				o_sda 		<= i_bus_data(2);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0101" =>
				o_sda 		<= i_bus_data(1);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0110" =>
				o_sda 		<= i_bus_data(0);
				r_bit_cnt 	<= r_bit_cnt + "0001";
			
			when "0111" =>
				o_sda 		<= 'Z';
				r_state 		<= ack;
				r_bit_cnt 	<= "0000";
				
		
			when others =>			
			
			end case;
		
		
		
		when ack =>
		
			if i_en = '1' then
				r_state 	<= data_transmit;
				o_sda 	<= i_bus_data(7);
			else
				r_state <= stop;
			end if;
		
		when stop =>
		
			o_sda 	<= '1';
			r_State 	<= idle;
		
		
		
		end case;
	end if;
end process;

r_scl 	<= '1' when r_state = addr_transmit or r_state = data_transmit or r_state = ack else i_clk;
o_rdy 	<= '1'; --TODO: Implement this
o_data 	<= (others => '0'); --todo
o_scl 	<= r_scl;


end rtl;