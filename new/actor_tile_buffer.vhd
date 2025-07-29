----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/17/2025 11:39:21 AM
-- Design Name: 
-- Module Name: actor_tile_buffer - Behavioral
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

entity actor_tile_buffer is
    Port ( i_clk : in STD_LOGIC;
--           i_reset : in STD_LOGIC;
           i_tile_id : in STD_LOGIC_VECTOR (3 downto 0);
           i_tile_read_px_x : in STD_LOGIC_VECTOR (3 downto 0);
           i_tile_read_px_y : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_tile_id : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_tile_px_x : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_tile_px_y : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_buffer_px : in STD_LOGIC;
           i_write_tile_pixel_color : in STD_LOGIC_VECTOR (3 downto 0);
           o_color_code : out STD_LOGIC_VECTOR (3 downto 0));
end actor_tile_buffer;

architecture Behavioral of actor_tile_buffer is


type tile_arr_actor_px is array(0 to 2047) of STD_LOGIC_VECTOR (3 downto 0);--8id * 16px_x * 16px_y (et le tableau stocke des couleurs sur 4 bits)
signal s_tile_arr_actor_px : tile_arr_actor_px := ( others => (others => '0'));

signal s_tiles_reading_index : std_logic_vector(10 downto 0);   -- 10 downto 8 => id (3bits), 7 downto 4 => px_y (4bits), 3 downto 0 => px_x (4bits)
signal s_tiles_writting_index : std_logic_vector(10 downto 0);  -- 10 downto 8 => id (3bits), 7 downto 4 => px_y (4bits), 3 downto 0 => px_x (4bits)

-- au final, c'est comme si on faisait cette opération pour get l'index du bits de couleur => index_color_code = (tile_id * 256) + (tile_y * 16) + tile_x, genre comme on le ferait dans une vrai matrice
-- A1   A2   A3   A4
-- A5   A6   A7   A8
-- A9   A10  A11  A12
-- A13  A14  A15  A16

begin

    s_tiles_reading_index(10 downto 8) <= i_tile_id(2 downto 0);
    s_tiles_reading_index(7 downto 4)  <= i_tile_read_px_y;
    s_tiles_reading_index(3 downto 0)  <= i_tile_read_px_x;
            
    s_tiles_writting_index(10 downto 8) <= i_write_tile_id(2 downto 0);
    s_tiles_writting_index(7 downto 4)  <= i_write_tile_px_y;
    s_tiles_writting_index(3 downto 0)  <= i_write_tile_px_x;

    process(i_clk)
    begin  
--        if i_reset = '1' then
--            s_tile_arr_actor_px <= ( others => (others => '0'));
        
        if rising_edge(i_clk) then -- magouille de on feed la couleur, mais on peux edit une couleur en parrallèle aussi (truss)
            o_color_code <= s_tile_arr_actor_px(to_integer(unsigned(s_tiles_reading_index))); 
            
        
            if i_write_buffer_px = '1' then
                s_tile_arr_actor_px(to_integer(unsigned(s_tiles_writting_index))) <= i_write_tile_pixel_color;
            end if;
                     
        end if;
        
         
    end process;

end Behavioral;
