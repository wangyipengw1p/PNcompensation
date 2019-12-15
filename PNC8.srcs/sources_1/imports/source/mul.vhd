----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2019 02:29:32 PM
-- Design Name: 
-- Module Name: mul - Behavioral
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

entity mul is
    Port ( clk : in STD_LOGIC;                                          --no reg (if multiplier not pipelined)
           rst : in STD_LOGIC;
            i1 : in complex;
           i2 : in complex;
           o_c : out complex
          
           );
end mul;

architecture Behavioral of mul is
component multiplier
Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i_m1 : in signed(totalBits - 1 downto 0);
           i_m2 : in signed(totalBits - 1 downto 0);
           o_m : out signed(2 * totalBits - 1 downto 0));
end component;
signal ac :signed (2 * totalBits - 1 downto 0);
signal ad :signed(2 * totalBits - 1 downto 0);
signal bc :signed(2 * totalBits - 1 downto 0);
signal bd :signed(2 * totalBits - 1 downto 0);
signal ac_M_bd:std_logic_vector(2 * totalBits - 1 downto 0);                -- ac - bd
signal bc_P_ad:std_logic_vector(2 * totalBits - 1 downto 0);                -- bc + ad
begin

mul1:multiplier port map(clk, rst, signed(i1(1)),signed(i2(1)),ac); 
mul2:multiplier port map(clk, rst, signed(i1(0)),signed(i2(0)),bd); 
mul3:multiplier port map(clk, rst, signed(i1(1)),signed(i2(0)),ad); 
mul4:multiplier port map(clk, rst, signed(i1(0)),signed(i2(1)),bc);  
ac_M_bd <= std_logic_vector(ac - bd);
bc_P_ad <= std_logic_vector(bc + ad);
o_c <= ac_M_bd(2 * totalBits  - 1 downto totalBits ) 
& bc_P_ad(2 * totalBits  - 1 downto totalBits);

--process(clk,rst)
--begin
--if rising_edge(clk) then
--    if rst = '0' then 
--        ac_M_bd <= (others => '0');
--        bc_P_ad <= (others => '0');
--    else
--        ac_M_bd <= std_logic_vector(ac - bd);
--        bc_P_ad <= std_logic_vector(bc + ad);
--    end if;
--end if;
--end process;
end Behavioral;
