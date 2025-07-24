----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Victor Larose
-- 
-- Create Date: 07/13/2025 02:12:25 PM
-- Design Name: 
-- Module Name: actor_manager - Behavioral
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

entity actor_manager is
    Port ( i_clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           i_actor_update_en : in STD_LOGIC;
           i_actor_id : in STD_LOGIC_VECTOR (2 downto 0);
           i_update_pos_en : in STD_LOGIC;
           i_update_tile_en : in STD_LOGIC;
           i_new_pos_x : in STD_LOGIC_VECTOR (9 downto 0);
           i_new_pos_y : in STD_LOGIC_VECTOR (9 downto 0);--je pense que c'est 8 downto 0 fnl
           i_new_tile_id : in STD_LOGIC_VECTOR (3 downto 0);
           i_curr_px_x : in STD_LOGIC_VECTOR (9 downto 0);
           i_curr_px_y : in STD_LOGIC_VECTOR (9 downto 0);
           o_tile_id : out STD_LOGIC_VECTOR (3 downto 0);
           o_tile_px_x : out STD_LOGIC_VECTOR (3 downto 0);
           o_tile_px_y : out STD_LOGIC_VECTOR (3 downto 0);
           o_visible : out STD_LOGIC);
end actor_manager;

architecture Behavioral of actor_manager is

-- Nombre d'acteurs
    constant NB_ACTORS : integer := 8;

    type tile_id_array is array (0 to NB_ACTORS-1) of STD_LOGIC_VECTOR(3 downto 0);
    type tile_coord_array is array (0 to NB_ACTORS-1) of STD_LOGIC_VECTOR(3 downto 0);
    type is_visible_array is array (0 to NB_ACTORS-1) of STD_LOGIC;
    
    signal s_tile_id_arr : tile_id_array := (others => (others => '0'));
    signal s_tile_x_arr : tile_coord_array := (others => (others => '0'));
    signal s_tile_y_arr : tile_coord_array := (others => (others => '0'));
    signal s_is_visible_arr : is_visible_array := (others => '0'); -- peux en avoir plusieurs visible en meme temps
    signal s_actor_en_update : std_logic_vector(NB_ACTORS-1 downto 0) := (others => '0'); -- on modifie seulement 1 acteur a la fois
    
     component actor is
        Port ( 
            i_clk             : in  STD_LOGIC;
            i_reset           : in  STD_LOGIC;
            i_is_enable       : in STD_LOGIC;
            i_pos_update_en   : in  STD_LOGIC;
            i_tile_update_en  : in  STD_LOGIC;
            i_new_pos_x       : in  STD_LOGIC_VECTOR (9 downto 0);
            i_new_pos_y       : in  STD_LOGIC_VECTOR (9 downto 0);
            i_new_tile_id     : in  STD_LOGIC_VECTOR (3 downto 0);
            i_curr_px_x       : in  STD_LOGIC_VECTOR (9 downto 0);
            i_curr_px_y       : in  STD_LOGIC_VECTOR (9 downto 0);
            o_tile_id         : out STD_LOGIC_VECTOR (3 downto 0);
            o_tile_px         : out STD_LOGIC_VECTOR (3 downto 0);
            o_tile_py         : out STD_LOGIC_VECTOR (3 downto 0);
            o_is_visible      : out STD_LOGIC
        );
    end component;

begin

    s_actor_en_update <= "00000001" when (i_actor_id = "000" and i_actor_update_en = '1') else
                "00000010" when (i_actor_id = "001" and i_actor_update_en = '1') else
                "00000100" when (i_actor_id = "010" and i_actor_update_en = '1') else
                "00001000" when (i_actor_id = "011" and i_actor_update_en = '1') else
                "00010000" when (i_actor_id = "100" and i_actor_update_en = '1') else
                "00100000" when (i_actor_id = "101" and i_actor_update_en = '1') else
                "01000000" when (i_actor_id = "110" and i_actor_update_en = '1') else
                "10000000" when (i_actor_id = "111" and i_actor_update_en = '1') else
                "00000000";

    --généré les instances des acteurs:
     actor_gen: for i in 0 to NB_ACTORS-1 generate -- generate 8 actor
        actor_inst: actor
        port map (
            i_clk => i_clk,
            i_reset => i_reset,
            i_is_enable => s_actor_en_update(i), 
            i_pos_update_en =>   i_update_pos_en,
            i_tile_update_en =>  i_update_tile_en,
            i_new_pos_x => i_new_pos_x,      
            i_new_pos_y => i_new_pos_y,      
            i_new_tile_id => i_new_tile_id, 
            i_curr_px_x => i_curr_px_x,      
            i_curr_px_y => i_curr_px_y,  
            o_tile_id => s_tile_id_arr(i),     
            o_tile_px => s_tile_x_arr(i),       
            o_tile_py => s_tile_y_arr(i),        
            o_is_visible => s_is_visible_arr(i)
        );
        end generate;
        
    output_selection: process(i_clk) -- Finalement on a comme pas besoin de reset si je comprend bien
    begin
        o_tile_id    <= (others => '0');
        o_tile_px_x    <= (others => '0');
        o_tile_px_y    <= (others => '0');
        o_visible    <= '0';

        -- Parcours des acteurs, priorité au plus petit ID visible
        for i in 0 to NB_ACTORS - 1 loop
            if s_is_visible_arr(i) = '1' and unsigned(s_tile_id_arr(i)) /= 0 then
                o_tile_id <= s_tile_id_arr(i);
                o_tile_px_x <= s_tile_x_arr(i);
                o_tile_px_y <= s_tile_y_arr(i);
                o_visible <= '1';
                exit;  -- on a trouvé le premier acteur visible a ce pixel, on sort
            end if;
        end loop;
    end process;

    


end Behavioral;

-- l'entité actor_manager a 3 mission principal
-- 1. Instancier les 8 entité actor indépendantes
-- 2. Activer la mise a jour d'un acteur (avec s_actor_en_update)
-- 3. Récolter les sorties de visibilité de chaque acteur (s_is_visible_arr) et sélectionner le premier acteur visible a ce pixel (par priorité d'id) pour afficher sortir ses infos en output
