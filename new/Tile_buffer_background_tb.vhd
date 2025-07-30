----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2025 01:52:04 PM
-- Design Name: 
-- Module Name: Background_manager_2_tb - Behavioral
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

entity tb_Background_manager is
end tb_Background_manager;

architecture behavior of tb_Background_manager is

    component Background_manager
        Port (
            i_clk           : in  STD_LOGIC;
            i_update_tile_en : in  STD_LOGIC;
            i_new_pos_x     : in  STD_LOGIC_VECTOR (6 downto 0);
            i_new_pos_y     : in  STD_LOGIC_VECTOR (6 downto 0);
            i_new_tile_id   : in  STD_LOGIC_VECTOR (5 downto 0);
            i_view_px_x     : in  STD_LOGIC_VECTOR (9 downto 0);
            i_view_px_y     : in  STD_LOGIC_VECTOR (9 downto 0);
            o_tile_id       : out STD_LOGIC_VECTOR (5 downto 0);
            o_tile_px_x     : out STD_LOGIC_VECTOR (2 downto 0);
            o_tile_px_y     : out STD_LOGIC_VECTOR (2 downto 0)
        );
    end component;

    signal clk         : STD_LOGIC := '0';
    signal update_en   : STD_LOGIC := '0';
    signal pos_x       : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal pos_y       : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal tile_id_in  : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal view_px_x        : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal view_px_y        : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal tile_id_out : STD_LOGIC_VECTOR(5 downto 0);
    signal tile_px_x   : STD_LOGIC_VECTOR(2 downto 0);
    signal tile_px_y   : STD_LOGIC_VECTOR(2 downto 0);

    constant clk_period : time := 10 ns;

begin
    
    uut: Background_manager
        port map (
            i_clk           => clk,
            i_update_tile_en => update_en,
            i_new_pos_x     => pos_x,
            i_new_pos_y     => pos_y,
            i_new_tile_id   => tile_id_in,
            i_view_px_x     => view_px_x,
            i_view_px_y     => view_px_y,
            o_tile_id       => tile_id_out,
            o_tile_px_x     => tile_px_x,
            o_tile_px_y     => tile_px_y
        );
    
    -- Horloge
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus
    stim_proc : process
    begin
        -- Attendre une horloge complète au début
        wait until rising_edge(clk);

        -- Cas 1 : écriture (10,20) -> ID = 0x01
        pos_x      <= std_logic_vector(to_unsigned(10, 7));
        pos_y      <= std_logic_vector(to_unsigned(20, 7));
        tile_id_in <= "000001";
        update_en  <= '1';
        wait until rising_edge(clk);
        update_en  <= '0';
        wait until rising_edge(clk);

        -- Lecture pixel (85,165) ? (10,20)
        view_px_x <= std_logic_vector(to_unsigned(85, 10));
        view_px_y <= std_logic_vector(to_unsigned(165, 10));
        wait until rising_edge(clk);

        -- Cas 2 : écriture (0,0) -> ID = 0x3F
        update_en  <= '1';
        pos_x      <= std_logic_vector(to_unsigned(0, 7));
        pos_y      <= std_logic_vector(to_unsigned(0, 7));
        tile_id_in <= "111111";
        
        wait until rising_edge(clk);
        update_en  <= '0';
        wait until rising_edge(clk);

        -- Lecture pixel (0,0) ? (0,0)
        view_px_x <= std_logic_vector(to_unsigned(0, 10));
        view_px_y <= std_logic_vector(to_unsigned(0, 10));
        wait until rising_edge(clk);

        -- Cas 3 : écriture (127,127) -> ID = 0x15
        pos_x      <= std_logic_vector(to_unsigned(127, 7));
        pos_y      <= std_logic_vector(to_unsigned(127, 7));
        tile_id_in <= "010101";
        update_en  <= '1';
        wait until rising_edge(clk);
        update_en  <= '0';
        wait until rising_edge(clk);

        -- Lecture pixel (1023,1023) ? (127,127)
        view_px_x <= std_logic_vector(to_unsigned(1023, 10));
        view_px_y <= std_logic_vector(to_unsigned(1023, 10));
        wait until rising_edge(clk);

        -- Cas 4 : lecture vide (64,64) ? (8,8)
        view_px_x <= std_logic_vector(to_unsigned(64, 10));
        view_px_y <= std_logic_vector(to_unsigned(64, 10));
        wait until rising_edge(clk);

        wait;
    end process;

end behavior;
