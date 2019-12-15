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
           coe : in complex_vector(1 to 6);
           din : in complex_vector(1 to 4);
           dout : out complex_vector(1 downto 0));
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
           
           
signal d_o:complex_vector(1 downto 0):=(others=> (others=> (others => '0')));

signal a:complex_vector(1 to 3);
signal b:complex_vector(1 to 4);
--signal c:complex_vector(1 to 5);
--signal d:complex_vector(1 to 6);


begin

mul1: mul port map(clk,rst,coe(1) ,din(3),a(1));
mul2: mul port map(clk,rst,coe(2) ,din(2),a(2));
mul3: mul port map(clk,rst,coe(3) ,din(1),a(3));
mul4: mul port map(clk,rst,coe(1) ,din(4),b(1));
mul5: mul port map(clk,rst,coe(4) ,din(2),b(2));
mul6: mul port map(clk,rst,coe(5) ,din(1),b(3));
mul7: mul port map(clk,rst,coe(6) ,din(3),b(4));
--mul8: mul port map(clk,rst,coe(7) ,din(2),c(1));
--mul9: mul port map(clk,rst,coe(1) ,din(5),c(2));
--mul10:mul port map(clk,rst,coe(8) ,din(1),c(3));
--mul11:mul port map(clk,rst,coe(9) ,din(3),c(4));
--mul12:mul port map(clk,rst,coe(6) ,din(4),c(5));
--mul13:mul port map(clk,rst,coe(10),din(3),d(1));
--mul14:mul port map(clk,rst,coe(1) ,din(6),d(2));
--mul15:mul port map(clk,rst,coe(11),din(2),d(3));
--mul16:mul port map(clk,rst,coe(9) ,din(4),d(4));
--mul17:mul port map(clk,rst,coe(12),din(1),d(5));
--mul18:mul port map(clk,rst,coe(6) ,din(5),d(6));

d_o(1) <= a(1) - a(2) - a(3);
d_o(0) <= b(1) + b(2) + b(3) - b(4);
--d_o(1) <= c(1) + c(2) + c(3) + c(4) - c(5);
--d_o(0) <= d(1) + d(2) + d(3) + d(4) + d(5) - d(6);

our_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then
        dout <= (others=> (others=> (others => '0')));
    else
        dout <= d_o;
    end if;
end if;
end process;

end Behavioral;
