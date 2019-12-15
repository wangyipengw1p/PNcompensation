----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2019 01:01:28 PM
-- Design Name: 
-- Module Name: multiplier - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
use ieee.std_logic_signed.all;
library work;
use work.PN_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier is                                            --none-pipelined multiplier, could be further pipelined
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i_m1 : in signed( totalBits - 1 downto 0);
           i_m2 : in signed( totalBits - 1 downto 0);
           o_m : out signed(2 * totalBits - 1 downto 0));
end multiplier;

architecture Behavioral of multiplier is

begin
o_m <= i_m1 * i_m2;
end Behavioral;
