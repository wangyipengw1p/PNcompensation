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
    constant totalBits              :natural    :=9;                                       -- # of the bits for all fixed point num (x,y,z,angle)
    constant cyclePerSymble             :natural    :=256;  --have something to do with counter
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
           top_in : in complex_vector(7 downto 0);
           top_out : out complex_vector(7 downto 0));
end TOP_PN;

architecture Behavioral of TOP_PN is
component main_calcu is                                 --main calculation(coefficience, data in => data out)
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           coe : in complex_vector(1 to 24);
           din : in complex_vector(1 to 10);
           dout : out complex_vector(7 downto 0));
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
--           i1 : in complex;
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
signal co_2:complex_vector(1 to 14);                 --reg
signal co_3:complex_vector(1 to 24);                -- reg
signal co_4:complex_vector(1 to 37);                --comb => coe reg
signal rco_1:complex_vector(1 to 3);
signal rco_2:complex_vector(1 to 14);
signal rco_3:complex_vector(1 to 24);

signal coe: complex_vector(1 to 24);                    --coefficience

signal din:complex_vector(1 to 10):=(others=> (others=> (others => '0')));   --data into main calculation(M,N, E,F,G,H)
signal dout:complex_vector(7 downto 0):=(others=> (others=> (others => '0'))); --dout

signal buf: complex_vector(47 downto 0):=(others=> (others=> (others => '0'))); --restore top_in, wait for coe generation latency
signal rbuf: complex_vector(47 downto 0):=(others=> (others=> (others => '0')));

signal counter: unsigned(7 downto 0):=(others=> '0');        --counter for step 3
signal rcounter: unsigned(7 downto 0):=(others=> '0');

signal flag:std_logic:='0';                         --flag for piolet and din



begin



process(counter,dout,buf)
begin
if flag = '1' then
din <= (others=> (others=> (others => '0')));
din(3 to 10) <=  buf(47 downto 40);
else
din <= dout(1 downto 0) & buf(47 downto 40);
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
mul11: mul port map(clk,rst,co_1(1),(std_logic_vector(to_signed(5,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(8));
mul12: mul port map(clk,rst,co_1(3),(std_logic_vector(to_signed(2,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(9));
mul13: mul port map(clk,rst,co_1(2),co_1(3),rco_2(10));
mul14: mul port map(clk,rst,co_1(3),(std_logic_vector(to_signed(4,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(11));
mul15: mul port map(clk,rst,co_1(1),(std_logic_vector(to_signed(4,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(12));
mul16: mul port map(clk,rst,co_1(2),(std_logic_vector(to_signed(6,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(13));
mul17: mul port map(clk,rst,co_1(1),(std_logic_vector(to_signed(7,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_2(14));


mul18: mul port map(clk,rst,co_2(2),(std_logic_vector(to_signed(2,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_3(1));
mul19: mul port map(clk,rst,co_2(1),co_1(1),rco_3(2));
mul20: mul port map(clk,rst,co_2(1),co_1(2),rco_3(3));
mul21: mul port map(clk,rst,co_2(1),co_0(4),rco_3(4));
mul22: mul port map(clk,rst,co_2(6),co_2(2),rco_3(5));
mul23: mul port map(clk,rst,co_2(1),co_2(3),rco_3(6));
mul24: mul port map(clk,rst,co_2(1),co_2(1),rco_3(7));
mul25: mul port map(clk,rst,co_2(2),co_2(7),rco_3(8));
mul26: mul port map(clk,rst,co_2(1),co_2(7),rco_3(9));
mul27: mul port map(clk,rst,co_2(4),co_2(6),rco_3(10));
mul28: mul port map(clk,rst,co_2(4),co_0(4),rco_3(11));
mul29: mul port map(clk,rst,co_2(4),co_1(3),rco_3(12));
mul30: mul port map(clk,rst,co_2(4),(std_logic_vector(to_signed(2,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_3(13));
mul31: mul port map(clk,rst,co_2(4),(std_logic_vector(to_signed(5,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_3(14));
mul32: mul port map(clk,rst,co_2(4),co_2(5),rco_3(15));
mul33: mul port map(clk,rst,co_2(8),co_0(4),rco_3(16));
mul34: mul port map(clk,rst,co_0(4),co_2(9),rco_3(17));
mul35: mul port map(clk,rst,co_2(13),co_0(1),rco_3(18));
mul36: mul port map(clk,rst,co_2(4),(std_logic_vector(to_signed(10,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_3(19));
mul37: mul port map(clk,rst,co_2(4),co_2(4),rco_3(20));
mul38: mul port map(clk,rst,co_2(14),co_2(1),rco_3(21));
mul39: mul port map(clk,rst,co_2(4),(std_logic_vector(to_signed(15,totalBits)) & std_logic_vector(to_signed(0,totalBits))),rco_3(22));
mul40: mul port map(clk,rst,co_2(13),co_2(2),rco_3(23));
mul41: mul port map(clk,rst,co_2(13),co_2(3),rco_3(24));


mul42: mul port map(clk,rst,co_1(1) ,co_3(6) ,co_4(1));
mul43: mul port map(clk,rst,co_3(8) ,co_0(4) ,co_4(2));
mul44: mul port map(clk,rst,co_1(3) ,co_3(8) ,co_4(3));
mul45: mul port map(clk,rst,co_3(7) ,co_1(3) ,co_4(4));
mul46: mul port map(clk,rst,co_2(11) ,co_3(2) ,co_4(5));
mul47: mul port map(clk,rst,co_3(8) ,co_1(3) ,co_4(6));
mul48: mul port map(clk,rst,co_3(7) ,co_1(1) ,co_4(7));
mul49: mul port map(clk,rst,co_3(7) ,co_2(1) ,co_4(8));
mul77: mul port map(clk,rst,co_3(9) ,co_2(8) ,co_4(9));
mul50: mul port map(clk,rst,co_3(8) ,co_2(9) ,co_4(10));
mul51: mul port map(clk,rst,co_3(8) ,co_2(10) ,co_4(11));
mul52: mul port map(clk,rst,co_3(7) ,co_2(2) ,co_4(12));
mul53: mul port map(clk,rst,co_3(9) ,co_2(11) ,co_4(13));
mul54: mul port map(clk,rst,co_2(11) ,co_3(6) ,co_4(14));
mul55: mul port map(clk,rst,co_3(11) ,co_2(7) ,co_4(15));
mul56: mul port map(clk,rst,co_3(7) ,co_2(3) ,co_4(16));
mul57: mul port map(clk,rst,co_3(7) ,co_3(3) ,co_4(17));
mul58: mul port map(clk,rst,co_2(2) ,co_3(24) ,co_4(18));
mul59: mul port map(clk,rst,co_3(14) ,co_3(7) ,co_4(19));
mul78: mul port map(clk,rst,co_3(7) ,co_3(4) ,co_4(20));
mul60: mul port map(clk,rst,co_3(23) ,co_2(2) ,co_4(21));
mul61: mul port map(clk,rst,co_2(9) ,co_3(10) ,co_4(22));
mul62: mul port map(clk,rst,co_3(7) ,co_3(2) ,co_4(23));
mul63: mul port map(clk,rst,co_2(2) ,co_3(7) ,co_4(24));
mul64: mul port map(clk,rst,co_3(2) ,co_3(19) ,co_4(25));
mul65: mul port map(clk,rst,co_3(7) ,co_3(7) ,co_4(26));
mul66: mul port map(clk,rst,co_3(21) ,co_3(9) ,co_4(27));
mul67: mul port map(clk,rst,co_3(3) ,co_3(19) ,co_4(28));
mul68: mul port map(clk,rst,co_3(22) ,co_3(7) ,co_4(29));
mul69: mul port map(clk,rst,co_3(9) ,co_3(7) ,co_4(30));
mul70: mul port map(clk,rst,co_3(10) ,co_2(13) ,co_4(31));
mul71: mul port map(clk,rst,co_3(9) ,co_3(19) ,co_4(32));
mul72: mul port map(clk,rst,co_3(24) ,co_3(7) ,co_4(33));
mul73: mul port map(clk,rst,co_3(5) ,co_3(13) ,co_4(34));
mul74: mul port map(clk,rst,co_3(7) ,co_3(6) ,co_4(35));
mul75: mul port map(clk,rst,co_3(23) ,co_3(7) ,co_4(36));
mul76: mul port map(clk,rst,co_3(6) ,co_3(19) ,co_4(37));

universal_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then 
        co_0(1 to 3) <= (others=> (others=> (others => '0')));
        co_1 <= (others=> (others=> (others => '0')));
        co_2 <= (others=> (others=> (others => '0')));
        co_3 <= (others=> (others=> (others => '0')));
        counter <= (others=> '0');
        buf <= (others=> (others=> (others => '0')));
        flag <= '0';
        piolet <= (others=> (others=> (others => '0')));
        coe <= (others=> (others=> (others => '0')));
    else
        co_1 <= rco_1;
        co_2 <= rco_2;
        co_3 <= rco_3;
        co_0(1 to 3) <= piolet;
        
        counter <= counter + 1;
        
        buf <= buf(39 downto 0) & top_in;
        
        if counter = 5 then flag <= '1'; else flag <= '0';end if;
        
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
        coe(13) <= co_3(11) + co_4(1) - co_4(2);
        coe(14) <= co_4(3) - co_4(4) - co_3(12);
        coe(15) <= co_4(5) - co_4(6) - co_4(7);
        coe(16) <= co_4(8) - co_3(12) - co_4(9) + co_4(10);
        coe(17) <= co_4(11) + co_4(12) - co_4(14);
        coe(18) <= co_4(14) - co_4(15) - co_4(16);
        coe(19) <= co_3(20) - co_4(17) - co_4(18) + co_4(19);
        coe(20) <= co_4(20) - co_3(15) - co_4(19) + co_4(21);
        coe(21) <= co_4(22) - co_4(23) + co_4(24) - co_4(25);
        coe(22) <= co_3(20) + co_4(26) - co_4(27) - co_4(28) + co_4(29);
        coe(23) <= co_4(30) - co_4(31) + co_4(32) - co_4(33);
        coe(24) <= co_4(34) - co_4(35) + co_4(36) - co_4(37);
        
    end if;
end if;
end process;



piolet_comb:process(piolet,top_in,counter) 
begin
--rflag <= flag;
rpiolet <= piolet;
if  counter = 0 then     -------------------------------!!!
    rpiolet <= top_in(7 downto 5);
--    rflag <= '1';
end if;
end process;

---step3:
top_out(7) <= dout(7);
divider1: divv port map(clk,rst,dout(6),dout(7),top_out(6));
divider2: divv port map(clk,rst,dout(5),dout(7),top_out(5));
divider3: divv port map(clk,rst,dout(4),dout(7),top_out(4));
top_out(3) <= dout(3);
divider4: divv port map(clk,rst,dout(2),dout(3),top_out(2));
divider5: divv port map(clk,rst,dout(1),dout(3),top_out(1));
divider6: divv port map(clk,rst,dout(0),dout(3),top_out(0));

end Behavioral;
