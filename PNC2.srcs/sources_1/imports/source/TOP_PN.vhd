----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- Yipeng Wang
-- Create Date: 01/15/2019 06:00:51 PM
-- Design Name: #2 phase noise compensation using dedicated piolet
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
    constant Ncb                     :natural    :=4;										-- coherence bandwidth
    constant totalBits              :natural    :=9;                                       -- # of the bits for all fixed point num
    constant cyclePerSymble             :natural    :=1024;  --have something to do with counter
----------------------------------------------------------------------------types-------------
    type complex is array(1 downto 0) of std_logic_vector(totalBits - 1 downto 0);                --complex num 
    type complex_vector is array (natural range<>) of complex;
    function "+"  (L:complex;R:complex) return complex;										--overload for complex
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
--===================================================================================end pkg

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 
use ieee.std_logic_signed.all;
library work;
use work.PN_pkg.all;

entity TOP_PN is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           top_in : in complex_vector(1 downto 0);
           top_out : out complex_vector(1 downto 0));
end TOP_PN;

architecture Behavioral of TOP_PN is
component main_calcu is                                 --main calculation(coefficience, data in => data out)
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           coe : in complex_vector(1 to 6);
           din : in complex_vector(1 to 4);
           dout : out complex_vector(1 downto 0));
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

signal co_0:complex_vector(1 to 6);                 --have reg in div, so no need for reg here 
signal co_1:complex_vector(1 to 3);                 --reg
signal co_2:complex_vector(1 to 3);                 --comb => coe reg
signal rco_1:complex_vector(1 to 3);

signal coe: complex_vector(1 to 6);                    --coefficience

signal din:complex_vector(1 to 4):=(others=> (others=> (others => '0')));   --data into main calculation(M,N, E,F,G,H)
signal dout:complex_vector(1 downto 0):=(others=> (others=> (others => '0'))); --dout

signal buf: complex_vector(9 downto 0):=(others=> (others=> (others => '0'))); --restore top_in, wait for coe generation latency
signal rbuf: complex_vector(9 downto 0):=(others=> (others=> (others => '0')));

signal counter: unsigned(9 downto 0):=(others=> '0');        --counter for din and piolet
signal rcounter: unsigned(9 downto 0):=(others=> '0');


signal flag:std_logic:='0';                         --flag for piolet
signal Hpiolet: complex;
signal rHpiolet:complex;

signal Hcounter:std_logic:='0';
signal dout_piolet:complex;


begin



process(counter,dout,buf)
begin
--add 0 to the begining of a symol
--use flag to decrease the size of LUT from 2048 to 2
if flag = '1' then
din <= (others=> (others=> (others => '0')));
din(3 to 4) <=  buf(9 downto 8);
else
din <= dout & buf(9 downto 8);
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
mul1: mul port map(clk,rst,co_0(1),co_0(4),rco_1(1));					--q/p
mul2: mul port map(clk,rst,co_0(4),co_0(3),rco_1(2));					--r/p
mul3: mul port map(clk,rst,co_0(3),co_0(5),rco_1(3));					--r/q
																		--
mul4: mul port map(clk,rst,co_1(1),co_1(1),co_2(1));					--q^2/p^2 
mul5: mul port map(clk,rst,co_1(1),co_1(2),co_2(2));					--(q*r)/p^2 
mul6: mul port map(clk,rst,co_1(1),co_0(4),co_2(3));					--q/p^2 

universal_reg:process(clk,rst)
begin
if rising_edge(clk) then
    if rst = '0' then 
        co_0(1 to 3) <= (others=> (others=> (others => '0')));
        co_1 <= (others=> (others=> (others => '0')));
        counter <= (others=> '0');
        buf <= (others=> (others=> (others => '0')));
        flag <= '0';
        piolet <= (others=> (others=> (others => '0')));
        coe <= (others=> (others=> (others => '0')));
        dout_piolet <= (others=> (others => '0'));
    else
        co_1 <= rco_1;
        co_0(1 to 3) <= piolet;			--F0 F1 F2
        
        counter <= counter + 1;
        
        buf <= buf(7 downto 0) & top_in; --left shift
        
        if counter = 4 then flag <= '1'; else flag <= '0';end if;
        
        piolet <= rpiolet;
        
        coe(1) <= co_0(4);							 --1/p             
        coe(2) <= co_1(1);                           -- q/p   
        coe(3) <= co_1(2);                           -- r/p   
        coe(4) <= co_2(1) - co_1(2);                 -- (q^2/p^2 -r/p)             
        coe(5) <= co_2(2);                     		 --(q*r)/p^2 
        coe(6) <= co_2(3); 							 --q/p^2 

		Hcounter <= not Hcounter;

        dout_piolet <= dout(1);    
    end if;
end if;
end process;


piolet_comb:process(piolet,top_in,counter)                          --need 2 cycles, if input >= Np then onlu 1 cycle
begin
--extract the piolet
rpiolet <= piolet;
if  counter = 0 then 
    rpiolet(2 downto 1) <= top_in;
elsif counter =1 then
    rpiolet(0) <= top_in(1);
    
end if;
end process;


process(Hcounter,dout)											--LUT for what to be divided
begin
if Hcounter = '0' then Hpiolet <= dout(1);
else Hpiolet <= dout_piolet;
end if;
end process;

---step3:

divider2: divv port map(clk,rst,dout(1),Hpiolet,top_out(1));
divider3: divv port map(clk,rst,dout(0),Hpiolet,top_out(0));


end Behavioral;
