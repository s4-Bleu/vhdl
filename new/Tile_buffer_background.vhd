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
--        i_reset      : in  std_logic;

        -- LECTURE
        i_tile_id    : in  std_logic_vector(5 downto 0); --64 tuiles => ID de la tuile à lire
        i_x          : in  std_logic_vector(2 downto 0); 
        i_y          : in  std_logic_vector(2 downto 0); 
        
        -- ÉCRITURE
        i_ch_tile_id  : in  std_logic_vector(5 downto 0); --64 tuiles => ID de la tuile à modifier
        i_we         : in  std_logic;
        i_wr_x       : in  std_logic_vector(2 downto 0); 
        i_wr_y       : in  std_logic_vector(2 downto 0); 
        i_pixel_data : in  std_logic_vector(3 downto 0); 

        o_color_code : out std_logic_vector(3 downto 0)
    );
end Tile_buffer_background;

architecture Behavioral of Tile_buffer_background is

    component tile is
        Port (
            i_clk         : in  std_logic;
--            i_reset       : in  std_logic;
            i_x           : in  std_logic_vector(2 downto 0);
            i_y           : in  std_logic_vector(2 downto 0);
            o_color_index : out std_logic_vector(3 downto 0);
            i_we          : in  std_logic;
            i_wr_x        : in  std_logic_vector(2 downto 0);
            i_wr_y        : in  std_logic_vector(2 downto 0);
            i_pixel_data  : in  std_logic_vector(3 downto 0)
        );
    end component;

    -- Tableau des sorties de chaque tuile
    type tile_output_array_t is array (0 to 15) of std_logic_vector(3 downto 0);
    
    
    signal tile_outputs : tile_output_array_t;
--    attribute ram_style : string;
--    attribute ram_style of tile_outputs : signal is "block";

    -- Tableau des signaux de we individuels
    signal we_signals : std_logic_vector(0 to 15);

    signal selected_color : std_logic_vector(3 downto 0);

begin

    -- Génération des signaux we_signals
    gen_we_signals : process(i_ch_tile_id, i_we)
    begin
        we_signals <= (others => '0');
        if i_we = '1' then
            we_signals(to_integer(unsigned(i_ch_tile_id))) <= '1';
        end if;
    end process;

    -- Instanciation des tuiles
    tiles_generator : for i in 0 to 15 generate
        tile_inst : tile
            port map (
                i_clk         => i_clk,
--                i_reset       => i_reset,
                i_x           => i_x,
                i_y           => i_y,
                o_color_index => tile_outputs(i),
                i_we          => we_signals(i),
                i_wr_x        => i_wr_x,
                i_wr_y        => i_wr_y,
                i_pixel_data  => i_pixel_data
            );
    end generate;

    -- Multiplexage de lecture : on lit la tuile sélectionnée si aucune écriture en cours
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_we = '0' then
                selected_color <= tile_outputs(to_integer(unsigned(i_tile_id)));
            end if;
        end if;
    end process;

    o_color_code <= selected_color;

end Behavioral;