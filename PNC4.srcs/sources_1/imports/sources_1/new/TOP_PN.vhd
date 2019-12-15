----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2019 06:00:51 PM
-- Design Name: 
-- Module Name: TOP_PN - Behavioral
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
package PN_pkg is
----------------------------------------------------------------------------constant----------
    constant N                      :natural    :=2048;                                     -- FFT size < 2^16 - 1
    constant Np                     :natural    :=3;                                        -- # of PN simplized frequency points
    constant Ncb                     :natural    :=4;
    constant totalBits              :natural    :=9;                                       -- # of the bits for all fixed point num 
    constant cyclePerSymble             :natural    :=512;  --have something to do with counter
----------------------------------------------------------------------------types-------------
    type complex is array(1 downto 0) of std_logic_vector(totalBits - 1 downto 0);                --complex num 
    type complex_vector is array (natural range<>) of complex;
    function "+"  (L:complex;R:complex) return complex;
    function "-"  (L:complex;R:complex) return complex;
end package;

package body PN_pkg is
    function "+"  (L:complex;R:complex) return complex is 
    begin
        return (L(1) + R(1)) & (L(0) + R(0));
    end function;
    
    function "-"  (L:complex;R:complex) return complex is 
        begin
            return (L(1) - R(1)) & (L(0) - R(0));
        end function;
   
end package body;
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
use ieee.std_logic_signed.all;
library work;
use work.PN_pkg.all;



entity TOP_PN is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           top_in : in complex_vector(3 downto 0);
           top_out : out complex_vector(3 downto 0));
end TOP_PN;

architecture Behavioral of TOP_PN is
component main_calcu is                                 --main calculation(coefficience, data in => data out)
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           coe : in complex_vector(1 to 12);
           din : in complex_vector(1 to 6);
           dout : out complex_vector(3 downto 0));
end component;
component divv is                                     --division for step 3
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i1 : in complex;
           i2 : in complex;
           o_c : out complex);
end component;
component div is                                        --psudo division(actually recirpocal)
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           i2 : in complex;
           o_c : out complex);
end component;
component mul is                                        --unpipelined complex multiplier
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
            i1 : in complex;
           i2 : in complex;
           o_c : out complex
          
           );
end component;
signal piolet:complex_vector(Np - 1 downto 0);          --dedicated piolet
signal rpiolet:complex_vector(Np - 1 downto 0);

--used for different layers of coe generation
signal co_0:complex_vector(1 to 6);                 --have reg in div, so no need for reg here 
signal co_1:complex_vector(1 to 3);                 --reg
signal co_2:complex_vector(1 to 7);                 --reg
signal co_3:complex_vector(1 to 10);                --comb => coe reg
signal rco_1:complex_vector(1 to 3);
signal rco_2:complex_vector(1 to 7);

signal coe: complex_vector(1 to 12);                    --coefficience 

signal din:complex_vector(1 to 6):=(others=> (others=> (others => '0')));   --data into main calculation(M,N, E,F,G,H)
signal dout:complex_vector(3 downto 0):=(others=> (others=> (others => '0'))); --dout

signal buf: complex_vector(19 downto 0):=(others=> (others=> (others => '0'))); --restore top_in, wait for coe generation latency
signal rbuf: complex_vector(19 downto 0):=(others=> (others=> (others => '0')));

signal counter: unsigned(8 downto 0):=(others=> '0');        --counter for step 3
signal rcounter: unsigned(8 downto 0):=(others=> '0');


signal flag:std_logic:='0';                         --flag for piolet


begin



process(counter,dout,buf)
begin
if flag = '1' then
din <= (others=> (others=> (others => '0')));
din(3 to 6) <=  buf(19 downto 16);
else
din <= dout(1 downto 0) & buf(19 downto 16);
end if;
end process;


main:main_calcu port map(
    clk => clk,
    rst => rst,
    coe => coe,
    din => din,
    dout => dout);
    
--first level coe generation (2 cycles)
reciprocal1:div port map(clk,rst,piolet(2),co_0(4));                    --p^-1 
reciprocal2:div port map(clk,rst,piolet(1),co_0(5));                    --q^-1
reciprocal3:div port map(clk,rst,piolet(0),co_0(6));                    --r^-1
--2nd 3rd 4th level coe generation (3 cycles)
mul1: mul port map(clk,rst,co_0(1),co_0(4),rco_1(1));
mul2: mul port map(clk,rst,co_0(4),co_0(3),rco_1(2));
mul3: mul port map(clk,rst,co_0(3),co_0(5),rco_1(3));

mul4: mul port map(clk,rst,co_1(1),co_1(1),rco_2(1));
mul5: mul port map(clk,rst,co_1(1),co_1(2),rco_2(2));
mul6: mul port map(clk,rst,co_1(1),co_0(4),rco_2(3));
mul7: mul port map(clk,rst,co_1(2),co_1(2),rco_2(4));          --(std_logic_vector(to_signed($NUM,totalBits)) & std_logic_vector(to_signed(0,totalBits)))
mul8: mul port map(clk,rst,co_0(4),co_1(3),rco_2(5));
mul9: mul port map(clk,rst,co_1(1),(std_logic_vector(to_signed(2,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(6));
mul10:mul port map(clk,rst,co_1(1),(std_logic_vector(to_signed(3,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(7));


mul11: mul port map(clk,rst,co_2(2),(std_logic_vector(to_signed(2,totalBits)) & std_logic_vector(to_signed(0,totalBits))),co_3(1));
mul12: mul port map(clk,rst,co_2(1),co_1(1),co_3(2));
mul13: mul port map(clk,rst,co_2(1),co_1(2),co_3(3));
mul14: mul port map(clk,rst,co_2(1),co_0(4),co_3(4));
mul15: mul port map(clk,rst,co_2(6),co_2(2),co_3(5));
mul16: mul port map(clk,rst,co_2(1),co_2(3),co_3(6));
mul17: mul port map(clk,rst,co_2(1),co_2(1),co_3(7));
mul19: mul port map(clk,rst,co_2(2),co_2(7),co_3(8));
mul20: mul port map(clk,rst,co_2(1),co_2(7),co_3(9));
mul21: mul port map(clk,rst,co_2(4),co_2(6),co_3(10));

universal_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then 
        co_0(1 to 3) <= (others=> (others=> (others => '0')));
        co_1 <= (others=> (others=> (others => '0')));
        co_2 <= (others=> (others=> (others => '0')));
        counter <= (others=> '0');
        buf <= (others=> (others=> (others => '0')));
        flag <= '0';
        piolet <= (others=> (others=> (others => '0')));
        coe <= (others=> (others=> (others => '0')));
    else
        co_1 <= rco_1;
        co_2 <= rco_2;
        co_0(1 to 3) <= piolet;
        counter <= counter + 1;
        buf <= buf(15 downto 0) & top_in;
        if counter = 4 then flag <= '1'; else flag <= '0';end if;
        piolet <= rpiolet;
        coe(1) <= co_0(4);                               
        coe(2) <= co_1(1);                               
        coe(3) <= co_1(2);                               
        coe(4) <= co_2(1) - co_1(2);                               
        coe(5) <= co_2(2);                     
        coe(6) <= co_2(3);                               
        coe(7) <= co_3(1) - co_3(2);                     
        coe(8) <= co_2(4) - co_3(3);           
        coe(9) <= co_3(4) - co_2(5);                     
        coe(10) <= co_3(5) - co_3(6);                    
        coe(11) <= co_2(4) + co_3(7) - co_3(8);
        coe(12) <= co_3(9) - co_3(10); 
    end if;
end if;
end process;



piolet_comb:process(piolet,top_in,counter) 
begin
rpiolet <= piolet;
if  counter = 0 then   
    rpiolet <= top_in(3 downto 1);
end if;
end process;



---step3:
top_out(3) <= dout(3);
divider1: divv port map(clk,rst,dout(2),dout(3),top_out(2));
divider2: divv port map(clk,rst,dout(1),dout(3),top_out(1));
divider3: divv port map(clk,rst,dout(0),dout(3),top_out(0));

end Behavioral;
