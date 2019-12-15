----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2019 01:32:40 PM
-- Design Name: 
-- Module Name: tb_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is
component TOP_PN is
    Port ( clk          : in STD_LOGIC;
           rst          : in STD_LOGIC;
           test_top_in  : in std_logic;
           test_top_out : out std_logic);
end component;
signal clk         :STD_LOGIC:='1';
signal rst         :STD_LOGIC;
signal test_top_in :std_logic;
signal test_top_out:std_logic;
begin
top: TOP_PN port map(clk,rst,test_top_in,test_top_out);

clk <= not clk after 5ns;
rst <= '0','1' after 9ns;
test_top_in <= '1';


end Behavioral;
