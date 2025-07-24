----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/24/2025 01:03:48 PM
-- Design Name: 
-- Module Name: Tile_buffer_background_tb - Behavioral
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

entity tb_Tile_buffer_background is
end tb_Tile_buffer_background;

architecture behavior of tb_Tile_buffer_background is

    -- Composant à tester
    component Tile_buffer_background
        Port (
            i_clk        : in  std_logic;
            i_reset      : in  std_logic;
            i_tile_id    : in  std_logic_vector(5 downto 0);
            i_x          : in  std_logic_vector(2 downto 0); 
            i_y          : in  std_logic_vector(2 downto 0); 
            i_we         : in  std_logic;
            i_wr_x       : in  std_logic_vector(2 downto 0); 
            i_wr_y       : in  std_logic_vector(2 downto 0); 
            i_pixel_data : in  std_logic_vector(3 downto 0); 
            o_color_code : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signaux internes
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal tile_id     : std_logic_vector(5 downto 0) := (others => '0');
    signal x, y        : std_logic_vector(2 downto 0) := (others => '0');
    signal we          : std_logic := '0';
    signal wr_x, wr_y  : std_logic_vector(2 downto 0) := (others => '0');
    signal pixel_data  : std_logic_vector(3 downto 0) := (others => '0');
    signal color_code  : std_logic_vector(3 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instanciation du module testé
    uut: Tile_buffer_background
        port map (
            i_clk        => clk,
            i_reset      => rst,
            i_tile_id    => tile_id,
            i_x          => x,
            i_y          => y,
            i_we         => we,
            i_wr_x       => wr_x,
            i_wr_y       => wr_y,
            i_pixel_data => pixel_data,
            o_color_code => color_code
        );

    -- Génération d'horloge
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimuli de test
    stim_proc : process
    begin
        -- Réinitialisation
        rst <= '1';
        wait for 2*clk_period;
        rst <= '0';

        -- Écriture du pixel (2,1) de la tuile 3 avec la valeur 0xA
        tile_id     <= "000011"; -- tuile 3
        wr_x        <= "010";    -- colonne 2
        wr_y        <= "001";    -- ligne 1
        pixel_data  <= "1010";   -- valeur 0xA
        we          <= '1';
        wait for clk_period;
        we          <= '0';

        -- Attente pour stabilisation
        wait for 2*clk_period;

        -- Lecture du pixel (2,1) de la tuile 3
        x <= "010";
        y <= "001";
        wait for 2*clk_period;

        -- Fin du test
        wait;
    end process;

end behavior;

