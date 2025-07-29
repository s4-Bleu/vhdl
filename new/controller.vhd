----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Victor Larose
-- 
-- Create Date: 07/14/2025 09:01:28 PM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
    Port ( i_instruction : in STD_LOGIC_VECTOR (31 downto 0);
           i_clk : in STD_LOGIC;
           
           -- actions sur le viewport
           o_viewport_curr_px_x : out STD_LOGIC_VECTOR (9 downto 0);
           o_viewport_curr_px_y : out STD_LOGIC_VECTOR (9 downto 0); -- devrait etre 8 downto 0
           o_viewport_update_en    : out STD_LOGIC;
           
           --action sur la position des acteurs dans la grille
           o_actor_id : out STD_LOGIC_VECTOR (2 downto 0);           
           o_actor_new_pos_x : out STD_LOGIC_VECTOR (9 downto 0);
           o_actor_new_pos_y : out STD_LOGIC_VECTOR (9 downto 0);
           o_actor_pos_update_en : out STD_LOGIC;
                      
           --action sur la tuile des acteurs (inclue également le o_actor_id)           
           o_actor_new_tile_id : out STD_LOGIC_VECTOR (3 downto 0); -- on ce laisse de la place pour 16 tuiles d'acteurs
           o_actor_tile_update_en : out STD_LOGIC;
           
           --action sur la modification d'une tuile d'acteur (au niveau de la couleur)
           o_actor_tile_buffer_tile_id : out STD_LOGIC_VECTOR (3 downto 0);  -- on ce laisse de la place pour 16 tuiles d'acteurs
           o_actor_tile_buffer_tile_px_x : out STD_LOGIC_VECTOR (3 downto 0);
           o_actor_tile_buffer_tile_px_y : out STD_LOGIC_VECTOR (3 downto 0);
           o_actor_tile_buffer_pixel_color : out STD_LOGIC_VECTOR (3 downto 0);
           o_actor_tile_buffer_tile_update_en : out STD_LOGIC;
       
           --action pour clears les actors
           o_clear_actors_en : out STD_LOGIC;           
           
           --action sur la modification de la grille du background
           o_bg_buffer_tile_id : out STD_LOGIC_VECTOR(5 downto 0);--écriture dans la grille de background
           o_bg_buffer_tile_row : out STD_LOGIC_VECTOR(6 downto 0);--écriture dans la grille de background 
           o_bg_buffer_tile_col : out STD_LOGIC_VECTOR(6 downto 0);--écriture dans la grille de background
           o_bg_buffer_tile_update_en : out STD_LOGIC;
            
           --action sur la modification dune tuile de bg dans le buffer (au niveau de la couleur)
           o_bg_tile_buffer_tile_id : out STD_LOGIC_VECTOR(5 downto 0);--on a jusqu'a 64 tuiles dans notre buffer       
           o_bg_tile_buffer_tile_x      : out STD_LOGIC_VECTOR(2 downto 0);--8 pixel de large
           o_bg_tile_buffer_tile_y      : out STD_LOGIC_VECTOR(2 downto 0);-- 8 pixel de haut
           o_bg_tile_buffer_pixel_color : out STD_LOGIC_VECTOR(3 downto 0);
           o_bg_tile_buffer_tile_update_en : out STD_LOGIC
---------------------------------------------------------          

--            --action sur overlay (a faire en dernier)
--            o_overlay_enable: out STD_LOGIC;
--            o_overlay_width: out STD_LOGIC_VECTOR(3 downto 0);
--            o_overlay_height: out STD_LOGIC_VECTOR(3 downto 0);
--            o_overlay_pos_x: out STD_LOGIC_VECTOR(9 downto 0);
--            o_overlay_pos_y: out STD_LOGIC_VECTOR(9 downto 0);
           
           -- instruction valide (Faire allumer une led en guise de YOLO) => qu'on peu reset avec un bouton
--           o_instruction_valid : out STD_LOGIC
           );
end controller;

architecture Behavioral of controller is
    signal s_OPCODE : std_logic_vector(3 downto 0);
    
    constant OPCODE_NOP: STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant OPCODE_SET_BG_TILE: STD_LOGIC_VECTOR(3 downto 0) := "0001";--1
    constant OPCODE_SET_BG_TILE_COLOR: STD_LOGIC_VECTOR(3 downto 0) := "0010";--2
    constant OPCODE_SET_ACTOR_TILE: STD_LOGIC_VECTOR(3 downto 0) := "0011";--3
    constant OPCODE_SET_ACTOR_TILE_COLOR: STD_LOGIC_VECTOR(3 downto 0) := "0100";--4
    constant OPCODE_SET_ACTOR_POS: STD_LOGIC_VECTOR(3 downto 0) := "0101";--5        
    constant OPCODE_CLEAR_ACTORS: STD_LOGIC_VECTOR(3 downto 0) := "0110";--6
    constant OPCODE_SET_VIEW_PORT: STD_LOGIC_VECTOR(3 downto 0) := "0111";--7
    constant OPCODE_DARK_REC_OVERLAY: STD_LOGIC_VECTOR(3 downto 0) := "1000";--8    

    
    -- mettre les autres opcode ici
begin

    s_OPCODE <= i_instruction(31 downto 28);
    process(i_clk)
    begin 
--        if i_reset = '1' then --ajuster le reset fnl                              
--            o_instruction_valid <= '0';
        if rising_edge(i_clk) then
            o_viewport_curr_px_x <= (others => '0');
            o_viewport_curr_px_y <= (others => '0');
            o_viewport_update_en <= '0';
        
            o_actor_id <= (others => '0');            
            o_actor_new_pos_x <= (others => '0');
            o_actor_new_pos_y <= (others => '0');
            o_actor_pos_update_en <= '0';
                                    
            o_actor_new_tile_id <= (others => '0');
            o_actor_tile_update_en <= '0';
            
            o_actor_tile_buffer_tile_id <= (others => '0');
            o_actor_tile_buffer_tile_px_x <= (others => '0');
            o_actor_tile_buffer_tile_px_y <= (others => '0');
            o_actor_tile_buffer_pixel_color <= (others => '0');
            o_actor_tile_buffer_tile_update_en <= '0';                     
            
            o_clear_actors_en <= '0';
            
            o_bg_buffer_tile_id <= (others => '0');
            o_bg_buffer_tile_row <= (others => '0');
            o_bg_buffer_tile_col <= (others => '0');
            o_bg_buffer_tile_update_en <= '0';     
            
            o_bg_tile_buffer_tile_id <= (others => '0');     
            o_bg_tile_buffer_tile_x <= (others => '0');     
            o_bg_tile_buffer_tile_y <= (others => '0');     
            o_bg_tile_buffer_pixel_color <= (others => '0');
            o_bg_tile_buffer_tile_update_en <= '0';                  
            
            
            case s_OPCODE is
                when OPCODE_NOP =>
                --on fait absolument rien 
                
                when OPCODE_SET_BG_TILE => 
                    o_bg_buffer_tile_id <= i_instruction(27 downto 22);
                    o_bg_buffer_tile_row <= i_instruction(21 downto 15);
                    o_bg_buffer_tile_col <= i_instruction(14 downto 8);
                    o_bg_buffer_tile_update_en <= '1';
                    
                when OPCODE_SET_BG_TILE_COLOR =>
                    o_bg_tile_buffer_tile_id <= i_instruction(27 downto 22);         
                    o_bg_tile_buffer_tile_x <= i_instruction(21 downto 19);--8 pixel de large
                    o_bg_tile_buffer_tile_y <= i_instruction(18 downto 16);-- 8 pixel de haut
                    o_bg_tile_buffer_pixel_color <= i_instruction(15 downto 12);
                    o_bg_tile_buffer_tile_update_en <= '1';
                        
                when OPCODE_SET_ACTOR_TILE =>
                     o_actor_id <= i_instruction(27 downto 25);  
                     o_actor_new_tile_id <= i_instruction(24 downto 21);
                     o_actor_tile_update_en <= '1';
                
                when OPCODE_SET_ACTOR_TILE_COLOR =>
                    o_actor_tile_buffer_tile_id     <= i_instruction(27 downto 24);
                    o_actor_tile_buffer_tile_px_x      <= i_instruction(23 downto 20);
                    o_actor_tile_buffer_tile_px_y      <= i_instruction(19 downto 16);
                    o_actor_tile_buffer_pixel_color <= i_instruction(15 downto 12);
                    o_actor_tile_buffer_tile_update_en <= '1';
                
                when OPCODE_SET_ACTOR_POS =>
                    o_actor_id <= i_instruction(27 downto 25);
                    o_actor_new_pos_x <= i_instruction(24 downto 15);
                    o_actor_new_pos_y <= i_instruction(14 downto 5);
                    o_actor_pos_update_en <= '1';                                                
                
--                when OPCODE_CLEAR_ACTORS =>-- rien pour l'instant               
                
                when OPCODE_SET_VIEW_PORT =>
                    o_viewport_curr_px_x <= i_instruction(27 downto 18);
                    o_viewport_curr_px_y <= i_instruction(17 downto 8); -- DEVRAIT ETRE 17 downto 9
                    o_viewport_update_en <= '1';                             
                
                when OPCODE_DARK_REC_OVERLAY =>-- rien pour l'instant                                             
                     
                when others =>                    
--                    o_instruction_valid <= '1'; -- il c'est produit une erreur (la led est allumé (laule)
                                                           
            end case; 
        end if;
        
        
    end process;
    

end Behavioral;
