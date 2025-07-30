----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/17/2025 08:15:05 PM
-- Design Name: 
-- Module Name: viewport_1 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity viewport_1 is
    Port ( i_clk : in STD_LOGIC;
            --i_print_px_y/x sont les coordonées local du pixel a afficher dans le viewport
           i_print_px_y : in STD_LOGIC_VECTOR(9 downto 0);--le signal qui est passé ici en entré est un 11 downto 0 (faire gaffe)  "a changer pour un 8 downto 0)
           i_print_px_x : in STD_LOGIC_VECTOR(9 downto 0);--le signal qui est passé ici en entré est un 11 downto 0 (faire gaffe)
           i_offset_px_y : in STD_LOGIC_VECTOR (9 downto 0);--devrait pas ben ben changer en terme de hauteur
           i_offset_px_x : in STD_LOGIC_VECTOR (9 downto 0);
           i_write_offset_en : in STD_LOGIC;
           o_global_px_x       : out STD_LOGIC_VECTOR (9 downto 0); --position global du pixel a afficher : (i_print_px_x + s_offset_px_x) mod MAX_GLOBAL_WIDTH
           o_global_px_y       : out STD_LOGIC_VECTOR (9 downto 0));--position global du pixel a afficher : (i_print_px_y + s_offset_px_y) mod MAX_GLOBAL_HEIGHT
end viewport_1;

architecture Behavioral of viewport_1 is
    constant MAX_GLOBAL_WIDTH  : unsigned(10 downto 0) := to_unsigned(1024, 11);
    constant MAX_GLOBAL_HEIGHT  : unsigned(10 downto 0) := to_unsigned(1024, 11);
    
    -- Coordonnée en haut a gauche du view port
    signal s_offset_px_x : STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); --coordonnée X du view port : offset par rapport a la position global
    signal s_offset_px_y : STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); --coordonnée Y du view port : offset par rapport a la position global
    
    -- somme du offset + de la position global : i_print_px_ + s_offset_px_
    signal s_sum_x  : STD_LOGIC_VECTOR(10 downto 0);
    signal s_sum_y : STD_LOGIC_VECTOR(10 downto 0);
begin
    s_sum_x <= STD_LOGIC_VECTOR(resize(unsigned(i_print_px_x), 11) + resize(unsigned(s_offset_px_x), 11));
    s_sum_y <= STD_LOGIC_VECTOR(resize(unsigned(i_print_px_y), 11) + resize(unsigned(s_offset_px_y), 11));
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_write_offset_en = '1' then
                s_offset_px_y <= i_offset_px_y;
                s_offset_px_x <= i_offset_px_x;                
            end if;
        end if;      
    end process;
    
    process(s_sum_x, s_sum_y)
    begin
        
        if unsigned(s_sum_x) > MAX_GLOBAL_WIDTH then
            o_global_px_x <= std_logic_vector(resize((unsigned(s_sum_x) - MAX_GLOBAL_WIDTH),10));
        else
            o_global_px_x <= s_sum_x(9 downto 0);
        end if;
        
        if unsigned(s_sum_y) > MAX_GLOBAL_HEIGHT then
            o_global_px_y <= std_logic_vector(resize((unsigned(s_sum_y) - MAX_GLOBAL_HEIGHT),10));
        else
            o_global_px_y <= s_sum_y(9 downto 0);
        end if;
    end process;


end Behavioral;
