----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/03/2025 02:30:31 PM
-- Design Name: 
-- Module Name: Tile - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tile is
   Port (
        i_clk          : in  std_logic;
        i_reset        : in  std_logic;

        -- Lecture
        i_x            : in  std_logic_vector(2 downto 0);  -- position x à lire
        i_y            : in  std_logic_vector(2 downto 0);  -- position y à lire
        o_color_index  : out std_logic_vector(3 downto 0);

        -- Écriture
        i_we           : in  std_logic;                     -- write enable
        i_wr_x         : in  std_logic_vector(2 downto 0);  -- position x à écrire
        i_wr_y         : in  std_logic_vector(2 downto 0);  -- position y à écrire
        i_pixel_data   : in  std_logic_vector(3 downto 0)   -- valeur à écrire
    );
end tile;

architecture Behavioral of tile is

    -- tableau de 8x8 pixels codee sur 4 bits
    type pixel_array_t is array (0 to 7, 0 to 7) of std_logic_vector(3 downto 0);
    signal pixels : pixel_array_t;
    

begin

    -- Écriture d'un pixel
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                for y in 0 to 7 loop
                    for x in 0 to 7 loop
                        pixels(y, x) <= (others => '0');
                    end loop;
                end loop;
            elsif i_we = '1' then
                pixels(
                    to_integer(unsigned(i_wr_y)),
                    to_integer(unsigned(i_wr_x))
                ) <= i_pixel_data;
            end if;
        end if;
    end process;

    -- Lecture de pixel
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                o_color_index <= (others => '0');
            else
                o_color_index <= pixels(
                    to_integer(unsigned(i_y)),
                    to_integer(unsigned(i_x))
                );
            end if;
        end if;
    end process;

end Behavioral;

