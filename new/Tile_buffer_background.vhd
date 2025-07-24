----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/17/2025 01:06:09 PM
-- Design Name: 
-- Module Name: Tile_buffer_background - Behavioral
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

entity Tile_buffer_background is
 Port (
        i_clk        : in  std_logic;
        i_reset      : in  std_logic;

        i_tile_id    : in  std_logic_vector(5 downto 0); --64 tuiles
        i_x          : in  std_logic_vector(2 downto 0); 
        i_y          : in  std_logic_vector(2 downto 0); 
        
        i_we         : in std_logic;
        i_wr_x       : in  std_logic_vector(2 downto 0); 
        i_wr_y       : in  std_logic_vector(2 downto 0); 
        i_pixel_data : in std_logic_vector(3 downto 0); 

        o_color_code : out std_logic_vector(3 downto 0)
    );
end Tile_buffer_background;

architecture Behavioral of Tile_buffer_background is
    
    component tile
        Port (
            i_clk         : in  std_logic;
            i_reset       : in  std_logic;
            i_x           : in  std_logic_vector(2 downto 0);
            i_y           : in  std_logic_vector(2 downto 0);
            o_color_index : out std_logic_vector(3 downto 0);

            i_we          : in  std_logic; 
            i_wr_x        : in  std_logic_vector(2 downto 0);
            i_wr_y        : in  std_logic_vector(2 downto 0);
            i_pixel_data  : in  std_logic_vector(3 downto 0)
        );
     end component;
        
    type tile_output_array_t is array (0 to 63) of std_logic_vector(3 downto 0);
    signal tile_outputs : tile_output_array_t;   
        
    signal selected_color : std_logic_vector(3 downto 0);    
    
begin

    -- Génération des 64 tuiles
    tiles_generator : for i in 0 to 63 generate
    
    signal local_we : std_logic;
    
    begin
    
        local_we <= i_we when i_tile_id = std_logic_vector(to_unsigned(i, 6)) else '0';
        
        tile_inst : tile
            port map (
                i_clk         => i_clk,
                i_reset       => i_reset,
                i_x           => i_x,
                i_y           => i_y,
                o_color_index => tile_outputs(i),
                i_we          => local_we,
                i_wr_x        => i_wr_x,
                i_wr_y        => i_wr_y,
                i_pixel_data  => i_pixel_data
            );
            
        -- Lecture de la sortie color_code du pixel selectionnee
       -- process(i_clk)
        --begin
          --  if rising_edge(i_clk) then
            --    if i_tile_id = std_logic_vector(to_unsigned(i, 6)) then
              --      selected_color <= tile_outputs(to_integer(unsigned(i_tile_id)));
               -- end if;
            --end if;
        --end process;

    end generate; 
    
    -- Sélection de la bonne couleur selon i_tile_id
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            selected_color <= tile_outputs(to_integer(unsigned(i_tile_id)));
        end if;
    end process;  
    
    o_color_code <= selected_color;



end Behavioral;
