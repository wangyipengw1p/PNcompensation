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
    constant cyclePerSymble             :natural    :=2048;  --have something to do with counter
----------------------------------------------------------------------------types-------------
    type complex is array(1 downto 0) of std_logic_vector(totalBits - 1 downto 0);                --complex num 
    type complex_vector is array (natural range<>) of complex;
    
    function "+"  (L:complex;R:complex) return complex;
    function "-"  (L:complex;R:complex) return complex;
    function "&"  (L:complex;R:complex) return complex_vector;
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
    function "&"  (L:complex;R:complex) return complex_vector is 
    variable ans:complex_vector(1 downto 0);
    begin
        ans(1) := L;
        ans(0) := R;
        return ans;
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
           top_in : in complex;
           top_out : out complex);
end TOP_PN;

architecture Behavioral of TOP_PN is
component main_calcu is                                 --main calculation(coefficience, data in => data out)
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           coe : in complex_vector(1 to 3);
           din : in complex_vector(1 to 3);
           dout : out complex);
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
signal co_0:complex_vector(1 to 4);                 --have reg in div, so no need for reg here 
signal co_1:complex_vector(1 to 2);                 --comb => coe reg

signal coe: complex_vector(1 to 3);                    --coefficience 

signal din:complex_vector(1 to 3):=(others=> (others=> (others => '0')));   --data into main calculation(M,N, E,F,G,H)
signal dout:complex:=(others=> (others => '0')); --dout

signal buf: complex_vector(4 downto 0):=(others=> (others=> (others => '0'))); --restore top_in, wait for coe generation latency
signal rbuf: complex_vector(4 downto 0):=(others=> (others=> (others => '0')));

signal counter: unsigned(11 downto 0):=(others=> '0');        --counter for step 3
signal rcounter: unsigned(11 downto 0):=(others=> '0');


signal flag:std_logic:='0';                         --flag for piolet
signal dout_previous:complex;

signal Hpiolet: complex;
signal rHpiolet:complex;
signal Hcounter:unsigned(1 downto 0);
signal HHpiolet:complex;


begin



process(counter,dout,buf)
begin
if flag = '1' then
din <= (others=> (others=> (others => '0')));
din(3) <=  buf(4);
else
din(1) <= dout_previous;
din(2) <= dout;
din(3) <= buf(4);
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
--2nd 3rd 4th level coe generation (3 cycles)
mul1: mul port map(clk,rst,co_0(1),co_0(4),co_1(1));
mul2: mul port map(clk,rst,co_0(4),co_0(3),co_1(2));
universal_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then 
        co_0(1 to 3) <= (others=> (others=> (others => '0')));
        counter <= (others=> '0');
        buf <= (others=> (others=> (others => '0')));
        flag <= '0';
        piolet <= (others=> (others=> (others => '0')));
        coe <= (others=> (others=> (others => '0')));
        dout_previous <=  (others=> (others => '0'));
        Hcounter <= "00";
    else
        co_0(1 to 3) <= piolet;
        counter <= counter + 1;
        buf <= buf(3 downto 0) & top_in;
        if counter = 4 then flag <= '1'; else flag <= '0';end if;
        piolet <= rpiolet;
        coe(1) <= co_0(4);                               
        coe(2) <= co_1(1);                               
        coe(3) <= co_1(2);   
        dout_previous <= dout;
        Hcounter <= Hcounter + 1;
    end if;
end if;
end process;



piolet_comb:process(piolet,top_in,counter) 
begin
rpiolet <= piolet;
if  counter = 0 then     
    rpiolet(2) <= top_in;
elsif counter = 1 then 
    rpiolet(1) <= top_in;
elsif counter = 2 then
    rpiolet(0) <= top_in;
end if;
end process;

step3_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then 
        Hpiolet <= (others=> (others => '0'));
    else
        Hpiolet <= rHpiolet;
    end if;
end if;
end process;
step3_comb:process(Hpiolet)
begin
    rHpiolet <= Hpiolet;
    if Hcounter = 0 then rHpiolet <= dout;end if;
end process;

step3_LUT:process(Hcounter,dout)
begin
if Hcounter = 0 then HHpiolet <= dout;
else HHpiolet <= Hpiolet;
end if;
end process;

---step3:

divider: divv port map(clk,rst,dout,HHpiolet,top_out);

end Behavioral;
