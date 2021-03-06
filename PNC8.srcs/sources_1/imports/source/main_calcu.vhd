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
           coe : in complex_vector(1 to 24);
           din : in complex_vector(1 to 10);
           dout : out complex_vector(7 downto 0));
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
           
           
signal d_o:complex_vector(7 downto 0):=(others=> (others=> (others => '0')));

signal a:complex_vector(1 to 3);
signal b:complex_vector(1 to 4);
signal c:complex_vector(1 to 5);
signal d:complex_vector(1 to 6);
signal ee:complex_vector(1 to 7);
signal f:complex_vector(1 to 8);
signal g:complex_vector(1 to 9);
signal h:complex_vector(1 to 10);


begin
--multiply the din with coes
mul1: mul port map(clk,rst,coe(1) ,din(3) ,a(1));
mul2: mul port map(clk,rst,coe(2) ,din(2) ,a(2));
mul3: mul port map(clk,rst,coe(3) ,din(1) ,a(3));

mul4: mul port map(clk,rst,coe(1) ,din(4) ,b(1));
mul5: mul port map(clk,rst,coe(4) ,din(2) ,b(2));
mul6: mul port map(clk,rst,coe(5) ,din(1) ,b(3));
mul7: mul port map(clk,rst,coe(6) ,din(3) ,b(4));

mul8: mul port map(clk,rst,coe(7) ,din(2) ,c(1));
mul9: mul port map(clk,rst,coe(1) ,din(5) ,c(2));
mul10:mul port map(clk,rst,coe(8) ,din(1) ,c(3));
mul11:mul port map(clk,rst,coe(9) ,din(3) ,c(4));
mul12:mul port map(clk,rst,coe(6) ,din(4) ,c(5));

mul13:mul port map(clk,rst,coe(10),din(3) ,d(1));
mul14:mul port map(clk,rst,coe(1) ,din(6) ,d(2));
mul15:mul port map(clk,rst,coe(11),din(2) ,d(3));
mul16:mul port map(clk,rst,coe(9) ,din(4) ,d(4));
mul17:mul port map(clk,rst,coe(12),din(1) ,d(5));
mul18:mul port map(clk,rst,coe(6) ,din(5) ,d(6));

mul19:mul port map(clk,rst,coe(10) ,din(4) ,ee(1));
mul20:mul port map(clk,rst,coe(13) ,din(3) ,ee(2));
mul21:mul port map(clk,rst,coe(1)  ,din(7) ,ee(3));
mul22:mul port map(clk,rst,coe(9)  ,din(5) ,ee(4));
mul23:mul port map(clk,rst,coe(6)  ,din(6) ,ee(5));
mul24:mul port map(clk,rst,coe(14) ,din(1) ,ee(6));
mul25:mul port map(clk,rst,coe(15) ,din(2) ,ee(7));

mul26:mul port map(clk,rst,coe(10)  ,din(5) ,f(1));
mul27:mul port map(clk,rst,coe(16)  ,din(2) ,f(2));
mul28:mul port map(clk,rst,coe(13)  ,din(4) ,f(3));
mul29:mul port map(clk,rst,coe(1)   ,din(8) ,f(4));
mul30:mul port map(clk,rst,coe(9)   ,din(6) ,f(5));
mul31:mul port map(clk,rst,coe(17)  ,din(1) ,f(6));
mul32:mul port map(clk,rst,coe(6)   ,din(7) ,f(7));
mul33:mul port map(clk,rst,coe(18)  ,din(3) ,f(8));

mul34:mul port map(clk,rst,coe(10)  ,din(6) ,g(1));
mul35:mul port map(clk,rst,coe(19)  ,din(1) ,g(2));
mul36:mul port map(clk,rst,coe(20)  ,din(3) ,g(3));
mul37:mul port map(clk,rst,coe(13)  ,din(5) ,g(4));
mul38:mul port map(clk,rst,coe(1)   ,din(9) ,g(5));
mul39:mul port map(clk,rst,coe(9)   ,din(7) ,g(6));
mul40:mul port map(clk,rst,coe(21)  ,din(2) ,g(7));
mul41:mul port map(clk,rst,coe(6)   ,din(8) ,g(8));
mul42:mul port map(clk,rst,coe(18)  ,din(4) ,g(9));

mul43:mul port map(clk,rst,coe(1)   ,din(10),h(1));
mul44:mul port map(clk,rst,coe(10)  ,din(7) ,h(2));
mul45:mul port map(clk,rst,coe(22)  ,din(2) ,h(3));
mul46:mul port map(clk,rst,coe(20)  ,din(4) ,h(4));
mul47:mul port map(clk,rst,coe(14)  ,din(6) ,h(5));
mul48:mul port map(clk,rst,coe(23)  ,din(1) ,h(6));
mul49:mul port map(clk,rst,coe(9)   ,din(8) ,h(7));
mul50:mul port map(clk,rst,coe(24)  ,din(3) ,h(8));
mul51:mul port map(clk,rst,coe(16)  ,din(9) ,h(9));
mul52:mul port map(clk,rst,coe(18)  ,din(5) ,h(10));

--add the products to form the output
d_o(7) <= a(1) - a(2) - a(3);
d_o(6) <= b(1) + b(2) + b(3) - b(4);
d_o(5) <= c(1) + c(2) + c(3) + c(4) - c(5);
d_o(4) <= d(1) + d(2) + d(3) + d(4) + d(5) - d(6);
d_o(3) <= ee(1) + ee(2) + ee(3) + ee(4) - ee(5) + ee(6) + ee(7);
d_o(2) <= f(1) + f(2) + f(3) + f(4) + f(5) + f(6) - f(7) + f(8);
d_o(1) <=g(1) + g(2) + g(3) + g(4) + g(5) + g(6) + g(7) + g(8) + g(9);
d_o(0) <=h(1) + h(2) + h(3) + h(4) + h(5) + h(6) + h(7) + h(8) - h(9) + h(10);


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
