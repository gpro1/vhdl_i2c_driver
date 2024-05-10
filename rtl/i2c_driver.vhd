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
	i_bus_clk		: in std_logic;
	i_module_clk	: in std_logic; -- might not need. Generate clock internally?
	i_en				: in std_logic;
	i_bus_addr_rw	: in unsigned(7 downto 0);
	i_reg_addr		: in unsigned(7 downto 0); -- might not need. One data bus?
	i_bus_data		: in unsigned(7 downto 0);
	o_sda				: out std_logic;
	o_scl				: out std_logic
	);
	
end i2c_driver;


architecture rtl of i2c_driver is




begin



end rtl;