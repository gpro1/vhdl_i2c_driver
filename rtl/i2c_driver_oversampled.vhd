-------------------------------------------------------------------------------------
-- i2c_driver_oversampled.vhd
--
-- Date: 05/28/2024
--
-- Engineer: Gregory Evans
--
-- Desc: 
--
--	Basic I2C Master driver. Supports reading and writing. 
-- Only supports single byte reads. Supports multi-byte writes.
--
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

entity i2c_driver_oversampled is
 generic (
	G_INPUT_CLOCK 	: integer := 50_000_000; --System clock used in this module;
	G_BUS_CLOCK		: integer := 100_000; --The I2C clock frequency to be generated on SCL
 port (
	i_clk				: in std_logic; --Input clock.
	i_en				: in std_logic; --Enable to start and stop a transaction.
	i_bus_addr_rw	: in unsigned(7 downto 0); -- I2C Address (7..1) R/W (0)
	i_bus_data		: in unsigned(7 downto 0); --bus data
	o_rdy				: out std_logic; --Indicates when I2C driver is ready 
	o_data			: out unsigned(7 downto 0); --Parallel data output for reads
	o_sda				: inout std_logic; --SDA line
	o_scl				: out std_logic --SCL line
	);
	
end entity;	

architecture rtl of i2c_driver_oversampled is

begin


end rtl;
		