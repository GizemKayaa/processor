library ieee;
USE ieee.std_logic_1164.all; 
--USE ieee.std_logic_arith.all; 
USE ieee.numeric_std.all; 
--USE ieee.std_logic_unsigned.all;


entity eIslemci is
generic(n:natural:=8);
port( s, r ,secme: in std_logic;
         
         kmt: in std_logic_vector(2*n-1 downto 0)); -- 16 bit giris? secme


end eIslemci;


Architecture struct of eIslemci is



TYPE tMEM IS ARRAY(0 TO 63) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Ram : tMEM;  -- RAM

TYPE tREG IS ARRAY(0 TO 15) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Reg : tREG;

TYPE tROM IS ARRAY(0 TO 31) OF std_logic_vector(n-1 DOWNTO 0);


Constant Rom : tROM := (
0 => "00000000",
1 => "00000001",
2 => "00100010",
3 => "00000100",
4 => "00001000",
5 => "00010000",
6 => "00100000",
7 => "10000000",
8 => "01100010",
9 => "10000001",
10 => "01010010",
11 => "01000000",
12 => "00100000",
13 => "10010000",
14 => "00000001",
15 => "01001000",
16 => "00100100",
17 => "10000100",
18 => "01100010",
19 => "10000001",
20 => "01010010",
21 => "01000000",
22 => "00100000",
23 => "10010000",
24 => "00000001",
25 => "01001000",
26 => "00100100",
27 => "10000100",
28 => "01100010",
29 => "10000001",
30 => "01010010",
31 => "01000000");

Begin
Komut:process(s, r)

Begin
     
If(Rising_edge(s)) then
     If(r='1') then
     If(secme='1') then
       Ram(to_integer(unsigned(Kmt(7 downto 0)))) <= "ZZZZZZZZ";
       
     else
       Reg(to_integer(unsigned(Kmt(11 downto 8)))) <= "ZZZZZZZZ";

   end if;
  end if;


    

 else

        Case Kmt(15 downto 12) is -- en anlamli 4 bit
	When "0000"=> null;   -- is?lem yok... 

	-- loadx     0001  4bitREGadresi   8bit sabit sayi
	When "0001" =>
		Reg(to_integer(unsigned(Kmt(11 downto 8)))) <= Kmt(7 downto 0);  

	-- loadr     0010  4bitREGadresi   4bitREGadresiKaynak         Loadr  ax, bx    -- ax<=bx
	When "0010" =>  
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= Reg(  to_integer(unsigned(Kmt(7 downto 4))));

	When "0011" =>  -- loadm     0001  REGadresi   8bitRamAdresi 
         Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= Ram(  to_integer(unsigned(Kmt(7 downto 0))));

	-- loadmr     0101  REGadresi   RegAdresi 
	When "0101" =>  
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= 
			Ram( to_integer(unsigned( Reg( to_integer(unsigned(Kmt(7 downto 4)))))));

	-- Storer    0011  REGadresi   8bitRamAdresi
	-- Registerda olan bilgi BEllege yazilir
 	When "0110" =>  
           Ram( to_integer(unsigned(Kmt(7 downto 0))) ) <= 
			Reg( to_integer(unsigned(Kmt(11 downto 8))));
	
	-- ADDx    0111  4bitRegAdresi     8bit sabit Sayi 	
	-- add  ax,  x     x sabit sayi ile ax toplanir sonuc ax'e yazilir
 	When "0111" =>  
           Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <= 
				std_logic_vector( 
					unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8)))))
					 + unsigned(Kmt (7 downto 0)));
	
	-- ADDr:    1000  4bitRegAdresi     4bitRegAdresi   	
	-- addr     ax,  bx , cx      cx  bx toplanir sonuc ax'e yaz?l?r
 	When "1000" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			+ unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0))))));
 
	
        -- MULx:    1001  4bitRegAdresi       	8bit sabit Sayi 	
	-- mul     ax,  x    x sabit sayi ile ax çarp?l?r sonuc ax'e yazilir
 	When "1001" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
                                std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8)))))
					 * unsigned(Kmt (7 downto 0)));
			

        -- SUBr:    1010  4bitRegAdresi     4bitRegAdresi   	
	-- subr     ax,  bx , cx      cx  bx  c?kar?l?r    sonuc ax'e yaz?l?r
 	When "1010" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			- unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0))))));

        -- modr:    1011  4bitRegAdresi       4bitRegAdresi   	
	-- modr     ax,  bx , cx      cx  bx modlan?r sonuc ax'e yaz?l?r
 	When "1011" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			MOD unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0))))));  

        --NOTx:    1100  4bitRegAdresi      8bit sabit Say?   	
	-- not     ax,  x    x sabit sayin? tersle  sonucu ax'e yaz 
 	When "1100" =>  
           Reg(to_integer(unsigned(Kmt(11 downto 8)))) <=  NOT (Kmt(7 downto 0)); 

      	-- ANDr:    1101  4bitRegAdresi     4bitRegAdresi   	
	-- andr     ax,  bx , cx      cx  bx andlenir sonuc ax'e yaz?l?r
 	When "1101" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			AND unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0))))));

     	-- ORx:    1110  4bitRegAdresi       	8bit sabit Say?
	-- or     ax,  x    x sabit sayi ile ax orlan?r sonuc ax'e yazilir
 	When "1110" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			OR unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0))))));

	-- XORr:    1111  4bitRegAdresi     4bitRegAdresi   	
	-- xorr     ax,  bx , cx      cx  bx   xorlan?r sonuc ax'e yazilir  
 	When "1111" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			XOR unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0))))));



When others => null;
      


     end case; 
   end if;
 end Process;

 end struct;
