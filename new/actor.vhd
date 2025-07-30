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

        i_pos_update_en   : in  STD_LOGIC;                          -- Active la mise à jour de la position
        i_tile_update_en  : in  STD_LOGIC;                          -- Active la mise à jour de l'ID de tuile

        -- Nouvelles valeurs à charger (position X/Y de l'acteur et nouvelle tuile) -- les positions des acteurs sont ancré en haut a gauche
        i_new_pos_x       : in  STD_LOGIC_VECTOR (9 downto 0);      -- Nouvelle position globale X de l'acteur (en pixels)
        i_new_pos_y       : in  STD_LOGIC_VECTOR (9 downto 0);      -- Nouvelle position globale Y de l'acteur (en pixels)
        i_new_tile_id     : in  STD_LOGIC_VECTOR (3 downto 0);      -- Nouvelle tuile à afficher pour l'acteur

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
    signal s_tile_id: STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); -- la tuile de l'acteur
    
    -- FIN DES ELEMENTS DE MEMOIRE
--    signal s_is_reset    : STD_LOGIC := '0';
    
    constant largeur_acteur : integer := 16;
    constant hauteur_acteur : integer := 16;

begin

check_actor_update_needed : process(i_clk)
begin 
--    if i_reset = '1' then
--        s_actor_pos_x <= (others=>'0');
--        s_actor_pos_y <= (others=>'0');
--        s_tile_id     <= (others=>'0');
--        s_is_reset <= '1';
        
    if rising_edge(i_clk) then
        if i_pos_update_en = '1' and i_is_enable = '1' then
            s_actor_pos_x <= i_new_pos_x;
            s_actor_pos_y <= i_new_pos_y;
        end if; 
        
        if i_tile_update_en = '1' and i_is_enable = '1' then
            s_tile_id <= i_new_tile_id;
        end if;
        
--        s_is_reset <= '0';
    end if;
end process;

update_actor_output: process(i_curr_px_x, i_curr_px_y, s_actor_pos_x, s_actor_pos_y, s_tile_id, i_reset) --s_is_reset
    variable diff_x : unsigned(9 downto 0);
    variable diff_y : unsigned(9 downto 0);
begin

--    if s_is_reset = '1' then
--        o_tile_px    <= (others => '0');
--        o_tile_py    <= (others => '0');
--        o_tile_id    <= (others => '0');
--        o_is_visible <= '0';
    if i_reset = '1' then
        o_tile_px <= (others => '0');
        o_tile_py <= (others => '0');
        o_tile_id <= (others => '0');
        o_is_visible <= '0';
    else
    
        -- on vérifier si le pixel courant est belle et bien dans la zone de l'acteur
        if (unsigned(i_curr_px_x) >= unsigned(s_actor_pos_x)) and
           (unsigned(i_curr_px_x) < unsigned(s_actor_pos_x) + largeur_acteur) and
           (unsigned(i_curr_px_y) >= unsigned(s_actor_pos_y)) and
           (unsigned(i_curr_px_y) < unsigned(s_actor_pos_y) + hauteur_acteur) then
           
           diff_x := unsigned(i_curr_px_x) - unsigned(s_actor_pos_x);
           diff_y := unsigned(i_curr_px_y) - unsigned(s_actor_pos_y);
    
            o_tile_px <= STD_LOGIC_VECTOR(diff_x(3 downto 0)); -- on peux ce le permettre car on c'est qu'on est dans la zone de l'acteur
            o_tile_py <= STD_LOGIC_VECTOR(diff_y(3 downto 0));
            o_tile_id <= s_tile_id;
            o_is_visible <= '1';
    
        else
            o_tile_px <= (others => '0');
            o_tile_py <= (others => '0');
            o_tile_id <= (others => '0');
            o_is_visible <= '0';
        end if;
    end if;
end process;

end Behavioral;

-- l'entité actor a 3 mission principal
-- 1. Stocker sa position X/Y et son tuile id avec : s_actor_pos_x/s_actor_pos_y et s_tile_id
-- 2. Déterminé si l'acteur (une partie de celui-ci) est visible en fonction du pixel courant (i_curr_px_x/i_curr_px_y)
-- 3. Fournir les coordonée du pixel local dans la tuile (o_tile_px/o_tile_py) pour que le render puisse aller chercher le bon pixel dans le tile buffer
