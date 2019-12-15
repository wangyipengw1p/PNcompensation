----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2019 03:01:32 PM
-- Design Name: 
-- Module Name: div - Behavioral
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

entity divv is
    Port ( clk : in STD_LOGIC;                              --2 clk cycles, have 2 regs
           rst : in STD_LOGIC;
           i1 : in complex;
           i2 : in complex;
           o_c : out complex);
end divv;

architecture Behavioral of divv is
component multiplier
Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i_m1 : in signed(totalBits - 1 downto 0);
           i_m2 : in signed(totalBits - 1 downto 0);
           o_m : out signed(2 * totalBits - 1 downto 0));
end component;
component reciprocal
Port ( din : in signed(totalBits - 1 downto 0);
       dout : out signed(totalBits - 1 downto 0));
end component;
signal ac :signed (2 * totalBits - 1 downto 0);
signal ad :signed(2 * totalBits - 1 downto 0);
signal bc :signed(2 * totalBits - 1 downto 0);
signal bd :signed(2 * totalBits - 1 downto 0);
signal cc :signed(2 * totalBits - 1 downto 0);
signal dd :signed(2 * totalBits - 1 downto 0);
signal ac_P_bd:signed( totalBits - 1 downto 0);                -- ac - bd
signal bc_M_ad:signed( totalBits - 1 downto 0);                -- bc + ad
signal cc_M_dd:signed( totalBits - 1 downto 0);                -- c*c - d*d

signal r_cc_M_dd:signed( totalBits - 1 downto 0);                -- (c*c - d*d)^ -1
signal temp1 :signed(2 * totalBits - 1 downto 0);
signal temp2 :signed(2 * totalBits - 1 downto 0);
begin
mul1:multiplier port map(clk, rst, signed(i1(0)),signed(i2(0)),ac); 
mul2:multiplier port map(clk, rst, signed(i1(1)),signed(i2(1)),bd); 
mul3:multiplier port map(clk, rst, signed(i1(0)),signed(i2(1)),ad); 
mul4:multiplier port map(clk, rst, signed(i1(1)),signed(i2(0)),bc); 
mul5:multiplier port map(clk, rst, signed(i2(0)),signed(i2(0)),cc); 
mul6:multiplier port map(clk, rst, signed(i2(1)),signed(i2(1)),dd);
mul7:multiplier port map(clk, rst, ac_P_bd, r_cc_M_dd(totalBits - 1 downto 0),temp1); 
mul8:multiplier port map(clk, rst, bc_M_ad,r_cc_M_dd(totalBits - 1 downto 0),temp2);
reciproc:reciprocal port map(cc_M_dd, r_cc_M_dd);


process(clk,rst)
variable tt : signed(2 * totalBits - 1 downto 0);
begin
if rising_edge(clk) then
    if rst = '0' then 
        ac_P_bd  <= (others => '0');
        bc_M_ad  <= (others => '0');
        cc_M_dd  <= (others => '0');
        o_c    <= (others =>(others => '0'));
    else
        tt := ac + bd;
        ac_P_bd  <= tt(2 * totalBits - 1 downto totalBits);
        tt := bc - ad;
        bc_M_ad  <= tt(2 * totalBits - 1 downto totalBits);
        tt := cc - dd;
        cc_M_dd  <= tt(2 * totalBits - 1 downto totalBits);
        o_c <= std_logic_vector(temp1(totalBits - 1 downto 0)) & std_logic_vector(temp2(totalBits - 1 downto 0));
        
    end if;
end if;
end process;
end Behavioral;
