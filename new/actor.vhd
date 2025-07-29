----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Victor Larose
-- 
-- Create Date: 07/12/2025 02:20:17 PM
-- Design Name: 
-- Module Name: actor - Behavioral
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

entity actor is
    Port ( 
        i_clk             : in  STD_LOGIC;
        i_reset           : in  STD_LOGIC;
        i_is_enable       : in STD_LOGIC;        

        -- Signaux de mise à jour
        i_pos_update_en   : in  STD_LOGIC;                          -- Active la mise à jour de la position
        i_new_pos_x       : in  STD_LOGIC_VECTOR (9 downto 0);      -- Nouvelle position globale X de l'acteur (en pixels)
        i_new_pos_y       : in  STD_LOGIC_VECTOR (9 downto 0);      -- Nouvelle position globale Y de l'acteur (en pixels)
        
        
        -- Nouvelles valeurs à charger (position X/Y de l'acteur et nouvelle tuile) -- les positions des acteurs sont ancré en haut a gauche
       i_tile_update_en      : in  STD_LOGIC;                          -- Active la mise �  jour de l'ID de tuile
       i_tile_pos_index      : in  STD_LOGIC_VECTOR(1 downto 0);     -- Indice (0 � 3)
       i_new_tile_id         : in  STD_LOGIC_VECTOR (3 downto 0);      -- Nouvelle tuile à afficher pour l'acteur

        -- Pixel courant envoyé par le viewport (le pixel qui ce fait print)
        i_curr_px_x       : in  STD_LOGIC_VECTOR (9 downto 0);      -- Position X du pixel courant (à l'écran)
        i_curr_px_y       : in  STD_LOGIC_VECTOR (9 downto 0);      -- Position Y du pixel courant (à l'écran) (pt que sa devrait etre sur 8 downto 0 => 360px de haut visible)

        -- Sorties si l'acteur est actif pour ce pixel
        o_tile_id         : out STD_LOGIC_VECTOR (3 downto 0);      -- ID de la tuile à lire (tile buffer)
        o_tile_px         : out STD_LOGIC_VECTOR (3 downto 0);      -- Coordonnée X locale dans la tuile (0 à 15)
        o_tile_py         : out STD_LOGIC_VECTOR (3 downto 0);      -- Coordonnée Y locale dans la tuile (0 à 15)
        o_is_visible      : out STD_LOGIC                           -- Indique si ce pixel est couvert par l'acteur
    );
end actor;

architecture Behavioral of actor is
    -- ELEMTENT DE MEMOIRE DE L'ACTEUR
    signal s_actor_pos_x: STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); -- position de absolue de l'acteur X (coin en haut a gauche)
    signal s_actor_pos_y: STD_LOGIC_VECTOR(9 downto 0) := (others => '0'); -- position de absolue de l'acteur Y (coin en haut a gauche)
    
    type t_tile_id_array is array (0 to 3) of std_logic_vector(3 downto 0);
    signal s_actor_tiles : t_tile_id_array := (others => (others => '0')); --Vecteur 2D de tuiles d'acteur. (bit0 correspond a (0,0), bit1 correspond a (0,1) etc,)
    
    --signal s_tile_id: STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- la tuile de l'acteur
    
    -- FIN DES ELEMENTS DE MEMOIRE
--    signal s_is_reset    : STD_LOGIC := '0';
    
    constant largeur_acteur : integer := 16;
    constant hauteur_acteur : integer := 16;

begin

check_actor_update_needed : -- Processus de mise � jour
process(i_clk)
    variable index : integer;
begin
    if rising_edge(i_clk) then
        if i_is_enable = '1' then
            if i_pos_update_en = '1' then
                s_actor_pos_x <= i_new_pos_x;
                s_actor_pos_y <= i_new_pos_y;
            end if;

            if i_tile_update_en = '1' then
                index := to_integer(unsigned(i_tile_pos_index));
                s_actor_tiles(index) <= i_new_tile_id;
            end if;
        end if;
    end if;
end process;

-- Calcul de la sortie visible
update_actor_output: process(i_curr_px_x, i_curr_px_y, s_actor_pos_x, s_actor_pos_y, s_actor_tiles)
    variable diff_x : unsigned(9 downto 0);
    variable diff_y : unsigned(9 downto 0);
    variable tile_idx : integer;
begin
    if (unsigned(i_curr_px_x) >= unsigned(s_actor_pos_x)) and
       (unsigned(i_curr_px_x) < unsigned(s_actor_pos_x) + largeur_acteur) and
       (unsigned(i_curr_px_y) >= unsigned(s_actor_pos_y)) and
       (unsigned(i_curr_px_y) < unsigned(s_actor_pos_y) + hauteur_acteur) then

        diff_x := unsigned(i_curr_px_x) - unsigned(s_actor_pos_x);
        diff_y := unsigned(i_curr_px_y) - unsigned(s_actor_pos_y);

        o_tile_px <= STD_LOGIC_VECTOR(diff_x(3 downto 0));
        o_tile_py <= STD_LOGIC_VECTOR(diff_y(3 downto 0));

        tile_idx := 2 * to_integer(unsigned(diff_y(4 downto 4))) + to_integer(unsigned(diff_x(4 downto 4)));

        o_tile_id <= s_actor_tiles(tile_idx);
        o_is_visible <= '1';
    else
        o_tile_px <= (others => '0');
        o_tile_py <= (others => '0');
        o_tile_id <= (others => '0');
        o_is_visible <= '0';
    end if;
end process;

end Behavioral;

-- l'entité actor a 3 mission principal
-- 1. Stocker sa position X/Y et son tuile id avec : s_actor_pos_x/s_actor_pos_y et s_tile_id
-- 2. Déterminé si l'acteur (une partie de celui-ci) est visible en fonction du pixel courant (i_curr_px_x/i_curr_px_y)
-- 3. Fournir les coordonée du pixel local dans la tuile (o_tile_px/o_tile_py) pour que le render puisse aller chercher le bon pixel dans le tile buffer
