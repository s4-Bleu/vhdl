----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/28/2025 08:31:30 PM
-- Design Name: 
-- Module Name: Background_manager - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Background_manager is
    Port ( i_clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           
           --Modification d'une tuile du background
           i_update_tile_en : in STD_LOGIC;
           i_new_pos_x : in STD_LOGIC_VECTOR (6 downto 0); --Position de la tuile dans la grille
           i_new_pos_y : in STD_LOGIC_VECTOR (6 downto 0); --Position de la tuile dans la grille
           i_new_tile_id : in STD_LOGIC_VECTOR (5 downto 0);           
           
           --Pixel a lire
           i_view_px_x : in STD_LOGIC_VECTOR (9 downto 0);
           i_view_px_y : in STD_LOGIC_VECTOR (9 downto 0);
           
           --Lecture d'une tuile
           o_tile_id   : out STD_LOGIC_VECTOR (5 downto 0);
           o_tile_px_x : out STD_LOGIC_VECTOR (2 downto 0);
           o_tile_px_y : out STD_LOGIC_VECTOR (2 downto 0);
           
           --Modification d'une tuile
           o_we         : in std_logic;
           o_wr_x       : in  std_logic_vector(2 downto 0); 
           o_wr_y       : in  std_logic_vector(2 downto 0); 
           o_pixel_data : in std_logic_vector(3 downto 0)); 
            
end Background_manager;

architecture Behavioral of Background_manager is
    
    constant BACKGRND_HEIGHT : integer := 128;
    constant BACKGRND_WIDTH  : integer := 128;
    
    type t_tile_grid is array (0 to BACKGRND_WIDTH-1, 0 to BACKGRND_HEIGHT-1) of std_logic_vector(5 downto 0);
    signal r_tile_grid : t_tile_grid;
    
    -- Signaux interne
    signal tile_x, tile_y : integer range 0 to 127;
    signal pixel_in_tile_x, pixel_in_tile_y : std_logic_vector(2 downto 0);
    
begin
    process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_reset = '1' then
            -- Vider la grille : chaque case reçoit "000000"
            for x in 0 to 127 loop
                for y in 0 to 127 loop
                    r_tile_grid(x, y) <= (others => '0');
                end loop;
            end loop;
        else
            -- Mise à jour de la grille
            if i_update_tile_en = '1' then
                r_tile_grid(to_integer(unsigned(i_new_pos_x)), to_integer(unsigned(i_new_pos_y))) <=
                    i_new_tile_id;
            end if;
        end if;
    end if;
end process;

    -- Tuile a la position demandee
    tile_x <= to_integer(unsigned(i_view_px_x(9 downto 3)));  
    tile_y <= to_integer(unsigned(i_view_px_y(9 downto 3)));
    
     -- Position dans la tuile
    pixel_in_tile_x <= i_view_px_x(2 downto 0); 
    pixel_in_tile_y <= i_view_px_y(2 downto 0);

    -- Sorties de lecture
    o_tile_id   <= r_tile_grid(tile_x, tile_y)(5 downto 0); 
    o_tile_px_x <= pixel_in_tile_x;
    o_tile_px_y <= pixel_in_tile_y;


end Behavioral;
