----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2019 06:30:29 PM
-- Design Name: 
-- Module Name: main_calcu - Behavioral
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


library ieee;
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

entity main_calcu is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           coe : in complex_vector(1 to 3);
           din : in complex_vector(1 to 3);
           dout : out complex);
end main_calcu;

architecture Behavioral of main_calcu is
component mul is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
            i1 : in complex;
           i2 : in complex;
           o_c : out complex
          
           );
    end component;
           
           
signal d_o:complex:= (others=> (others => '0'));

signal a:complex_vector(1 to 3);


begin

mul1: mul port map(clk,rst,coe(1) ,din(3),a(1));
mul2: mul port map(clk,rst,coe(2) ,din(2),a(2));
mul3: mul port map(clk,rst,coe(3) ,din(1),a(3));

d_o <= a(1) - a(2) - a(3);

our_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then
        dout <= (others=> (others => '0'));
    else
        dout <= d_o;
    end if;
end if;
end process;

end Behavioral;
