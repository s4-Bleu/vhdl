library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ppu is
Port ( 
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    i_x : in STD_LOGIC_VECTOR(11 downto 0); -- les coordonnée x du pixel a afficher
    i_y : in STD_LOGIC_VECTOR(11 downto 0); -- les coordonnée x du pixel a afficher
    o_dataValid : out STD_LOGIC;
    o_dataPixel : out STD_LOGIC_VECTOR(23 downto 0);
    i_instruction : in STD_LOGIC_VECTOR(31 downto 0)
);
end ppu;

architecture Behavioral of ppu is

--                      CONTROLLER

component controller is
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
           );
end component;

--                      VIEWPORT

component viewport_1 is
    Port ( i_clk : in STD_LOGIC;
           i_print_px_y : in STD_LOGIC_VECTOR(9 downto 0);
           i_print_px_x : in STD_LOGIC_VECTOR(9 downto 0);
           i_offset_px_y : in STD_LOGIC_VECTOR (9 downto 0);--devrait pas ben ben changer en terme de hauteur
           i_offset_px_x : in STD_LOGIC_VECTOR (9 downto 0);
           i_write_offset_en : in STD_LOGIC;
           o_global_px_x       : out STD_LOGIC_VECTOR (9 downto 0); --position global du pixel a afficher : (i_print_px_x + s_offset_px_x) mod MAX_GLOBAL_WIDTH
           o_global_px_y       : out STD_LOGIC_VECTOR (9 downto 0));--position global du pixel a afficher : (i_print_px_y + s_offset_px_y) mod MAX_GLOBAL_HEIGHT
end component;

--                      ACTOR_MANAGER

component actor_manager is
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
end component;

--                      ACTOR_TILE_BUFFER

component actor_tile_buffer is
    Port ( i_clk : in STD_LOGIC;
--           i_reset : in STD_LOGIC;
           i_tile_id : in STD_LOGIC_VECTOR (3 downto 0);
           i_tile_read_px_x : in STD_LOGIC_VECTOR (3 downto 0);
           i_tile_read_px_y : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_tile_id : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_tile_px_x : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_tile_px_y : in STD_LOGIC_VECTOR (3 downto 0);
           i_write_buffer_px : in STD_LOGIC;
           i_write_tile_pixel_color : in STD_LOGIC_VECTOR (3 downto 0);
           o_color_code : out STD_LOGIC_VECTOR (3 downto 0));
end component;

--                      BACKGROUND_MANAGER

component Background_manager is
    Port ( i_clk : in STD_LOGIC;
--           i_reset : in STD_LOGIC;
           
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
           o_tile_px_y : out STD_LOGIC_VECTOR (2 downto 0)
           );        

end component;
----                      BACKGROUND_TILE_BUFFER

component  Tile_buffer_background is
 Port (
        i_clk        : in  std_logic;
--        i_reset      : in  std_logic;

        i_tile_id    : in  std_logic_vector(5 downto 0); --64 tuiles
        i_x          : in  std_logic_vector(2 downto 0); 
        i_y          : in  std_logic_vector(2 downto 0); 
        
        i_we         : in std_logic;
        i_wr_x       : in  std_logic_vector(2 downto 0); 
        i_wr_y       : in  std_logic_vector(2 downto 0); 
        i_pixel_data : in std_logic_vector(3 downto 0); 

        o_color_code : out std_logic_vector(3 downto 0)
    );
end component;    



--                      COLOR_CONNECTOR

component color_connector is
Port (
    i_colorCode : in std_logic_vector(3 downto 0);
    o_color     : out std_logic_vector(23 downto 0);
    o_error     : out std_logic
);
end component;
-- SIGNAUX ENTRANT DU testPatternGen2
signal s_i_x : STD_LOGIC_VECTOR (9 downto 0);
signal s_i_y : STD_LOGIC_VECTOR (9 downto 0);

-- SIGNAUX SORTANT DU CONTROLLER

signal s_viewport_offset_x : STD_LOGIC_VECTOR (9 downto 0); -- s_viewport_curr_px_x
signal s_viewport_offset_y : STD_LOGIC_VECTOR (9 downto 0); -- devrait etre 8 downto 0  s_viewport_curr_px_y
signal s_viewport_update_en    : STD_LOGIC;           

signal s_actor_id : STD_LOGIC_VECTOR (2 downto 0);           
signal s_actor_new_pos_x : STD_LOGIC_VECTOR (9 downto 0);
signal s_actor_new_pos_y : STD_LOGIC_VECTOR (9 downto 0);
signal s_actor_pos_update_en : STD_LOGIC;                     
          
signal s_actor_new_tile_id : STD_LOGIC_VECTOR (3 downto 0); -- on ce laisse de la place pour 16 tuiles d'acteurs
signal s_actor_tile_update_en : STD_LOGIC;           

signal s_actor_tile_buffer_tile_id : STD_LOGIC_VECTOR (3 downto 0);  -- on ce laisse de la place pour 16 tuiles d'acteurs
signal s_actor_tile_buffer_tile_px_x : STD_LOGIC_VECTOR (3 downto 0);
signal s_actor_tile_buffer_tile_px_y : STD_LOGIC_VECTOR (3 downto 0);
signal s_actor_tile_buffer_pixel_color : STD_LOGIC_VECTOR (3 downto 0);
signal s_actor_tile_buffer_tile_update_en : STD_LOGIC;       

signal s_clear_actors_en : STD_LOGIC;                      

signal s_bg_buffer_tile_id : STD_LOGIC_VECTOR(5 downto 0);--écriture dans la grille de background
signal s_bg_buffer_tile_row : STD_LOGIC_VECTOR(6 downto 0);--écriture dans la grille de background 
signal s_bg_buffer_tile_col : STD_LOGIC_VECTOR(6 downto 0);--écriture dans la grille de background
signal s_bg_buffer_tile_update_en : STD_LOGIC;

signal s_bg_tile_buffer_tile_id : STD_LOGIC_VECTOR(5 downto 0);--on a jusqu'a 64 tuiles dans notre buffer       
signal s_bg_tile_buffer_tile_x      : STD_LOGIC_VECTOR(2 downto 0);--8 pixel de large
signal s_bg_tile_buffer_tile_y      : STD_LOGIC_VECTOR(2 downto 0);-- 8 pixel de haut
signal s_bg_tile_buffer_pixel_color : STD_LOGIC_VECTOR(3 downto 0);
signal s_bg_tile_buffer_tile_update_en : STD_LOGIC;        

--signal s_instruction_valid : STD_LOGIC;

-- SIGNAUX SORTANT DU VIEWPORT
signal s_global_x : STD_LOGIC_VECTOR(9 downto 0);
signal s_global_y : STD_LOGIC_VECTOR(9 downto 0);

-- SIGNAUX SORTANT DU ACTOR_MANAGER
signal s_o_actor_tile_id : STD_LOGIC_VECTOR (3 downto 0);
signal s_o_actor_tile_px_x : STD_LOGIC_VECTOR (3 downto 0);
signal s_o_actor_tile_px_y : STD_LOGIC_VECTOR (3 downto 0);
signal s_actor_visible : STD_LOGIC;

-- SIGNAUX SORTANT DU ACTOR_TILE_BUFFER
signal s_color_code_actor_out: STD_LOGIC_VECTOR (3 downto 0);

-- SIGNAUX SORTANT DU BACKGROUND_MANAGER
signal s_o_bg_tile_id   : STD_LOGIC_VECTOR (5 downto 0);
signal s_o_bg_tile_px_x : STD_LOGIC_VECTOR (2 downto 0);
signal s_o_bg_tile_px_y : STD_LOGIC_VECTOR (2 downto 0);

-- SIGNAUX SORTANT DU BACKROUND_TILE_BUFFER
signal s_color_code_bg_out: STD_LOGIC_VECTOR (3 downto 0);

-- SIGNAUX SORTANT DU COLOR_CONNECTOR
signal s_color : STD_LOGIC_VECTOR(23 downto 0);
signal s_error_color : STD_LOGIC;



signal s_actor_update_en : STD_LOGIC;

signal s_selected_color_code : STD_LOGIC_VECTOR (3 downto 0);


begin

    inst_controller : controller
     Port map ( i_instruction => i_instruction,
        i_clk => clk,
--        i_reset => '0',           
        -- actions sur le viewport
        o_viewport_curr_px_x => s_viewport_offset_x,
        o_viewport_curr_px_y => s_viewport_offset_y,
        o_viewport_update_en    => s_viewport_update_en,
        --action sur la position des acteurs dans la grille
        o_actor_id => s_actor_id,      
        o_actor_new_pos_x => s_actor_new_pos_x,
        o_actor_new_pos_y => s_actor_new_pos_y,
        o_actor_pos_update_en => s_actor_pos_update_en,                   
        --action sur la tuile des acteurs (inclue également le o_actor_id)           
        o_actor_new_tile_id => s_actor_new_tile_id,
        o_actor_tile_update_en => s_actor_tile_update_en,
        --action sur la modification d'une tuile d'acteur (au niveau de la couleur)
        o_actor_tile_buffer_tile_id => s_actor_tile_buffer_tile_id,
        o_actor_tile_buffer_tile_px_x => s_actor_tile_buffer_tile_px_x,
        o_actor_tile_buffer_tile_px_y => s_actor_tile_buffer_tile_px_y,
        o_actor_tile_buffer_pixel_color => s_actor_tile_buffer_pixel_color,
        o_actor_tile_buffer_tile_update_en => s_actor_tile_buffer_tile_update_en,     
        --action pour clears les actors
        o_clear_actors_en => s_clear_actors_en,                  
        --action sur la modification de la grille du background
        o_bg_buffer_tile_id => s_bg_buffer_tile_id,
        o_bg_buffer_tile_row => s_bg_buffer_tile_row, 
        o_bg_buffer_tile_col => s_bg_buffer_tile_col,
        o_bg_buffer_tile_update_en => s_bg_buffer_tile_update_en,
        --action sur la modification dune tuile de bg dans le buffer (au niveau de la couleur)
        o_bg_tile_buffer_tile_id => s_bg_tile_buffer_tile_id,
        o_bg_tile_buffer_tile_x      => s_bg_tile_buffer_tile_x,
        o_bg_tile_buffer_tile_y      => s_bg_tile_buffer_tile_y,
        o_bg_tile_buffer_pixel_color => s_bg_tile_buffer_pixel_color,
        o_bg_tile_buffer_tile_update_en => s_bg_tile_buffer_tile_update_en);

    inst_viewport_1 : viewport_1
     Port map ( i_clk => clk,                                                                                                                               
        i_print_px_y => s_i_y,                                                                                                   
        i_print_px_x => s_i_x,                                                                                                    
        i_offset_px_y => s_viewport_offset_x,                                                   
        i_offset_px_x => s_viewport_offset_y,                                                   
        i_write_offset_en => s_viewport_update_en,                                                                                                                 
        o_global_px_x => s_global_x,
        o_global_px_y => s_global_y);
        
    inst_actor_manager : actor_manager
     Port map ( i_clk => clk,                                                              
        i_reset =>    rst,                                                      
        i_actor_update_en => s_actor_update_en,                                                  
        i_actor_id => s_actor_id,                                    
        i_update_pos_en => s_actor_pos_update_en,                                                    
        i_update_tile_en => s_actor_tile_update_en,                                                  
        i_new_pos_x => s_actor_new_pos_x, 
        i_new_pos_y => s_actor_new_pos_y, 
        i_new_tile_id => s_actor_new_tile_id,                                
        i_curr_px_x => s_global_x,                                    
        i_curr_px_y => s_global_y,                                    
        o_tile_id => s_o_actor_tile_id,                                  
        o_tile_px_x => s_o_actor_tile_px_x,                                 
        o_tile_px_y => s_o_actor_tile_px_y,                                 
        o_visible => s_actor_visible);   
        
    inst_actor_tile_buffer: actor_tile_buffer
     Port map ( i_clk => clk,                                       
--        i_reset => '0',                                 
        i_tile_id => s_o_actor_tile_id,
        i_tile_read_px_x => s_o_actor_tile_px_x,        
        i_tile_read_px_y => s_o_actor_tile_px_y,  
        i_write_tile_id => s_actor_tile_buffer_tile_id,      
        i_write_tile_px_x => s_actor_tile_buffer_tile_px_x,       
        i_write_tile_px_y => s_actor_tile_buffer_tile_px_y,       
        i_write_buffer_px => s_actor_tile_buffer_tile_update_en,                           
        i_write_tile_pixel_color => s_actor_tile_buffer_pixel_color,
        o_color_code => s_color_code_actor_out);
        
    inst_Background_manager : Background_manager
    Port map ( i_clk => clk,
           --Modification d'une tuile du background
           i_update_tile_en => s_bg_buffer_tile_update_en,
           i_new_pos_x => s_bg_buffer_tile_row,
           i_new_pos_y => s_bg_buffer_tile_col,
           i_new_tile_id => s_bg_buffer_tile_id,
           
           --Pixel a lire
           i_view_px_x => s_global_x,
           i_view_px_y => s_global_y,
           
           --Lecture d'une tuile
           o_tile_id   => s_o_bg_tile_id,
           o_tile_px_x => s_o_bg_tile_px_x,
           o_tile_px_y => s_o_bg_tile_px_y            
           ); 
           
    inst_Tile_buffer_background : Tile_buffer_background
    Port map (
        i_clk        => clk,
--        i_reset      : in  std_logic;

        i_tile_id    => s_o_bg_tile_id,
        i_x          => s_o_bg_tile_px_x, 
        i_y          => s_o_bg_tile_px_x, 
        
        i_we         => s_bg_tile_buffer_tile_update_en,
        i_wr_x       => s_bg_tile_buffer_tile_x, 
        i_wr_y       => s_bg_tile_buffer_tile_y, 
        i_pixel_data => s_bg_tile_buffer_pixel_color, 

        o_color_code => s_color_code_bg_out
    );
   
    s_selected_color_code <= s_color_code_bg_out when s_actor_visible = '0' else s_color_code_actor_out; -- genre couleur transparente = 15 => 0xF
    inst_color_connector: color_connector
     Port map (
        i_colorCode => s_selected_color_code, -- s_selected_color_code or s_color_code_actor_out when no bg
        o_color     => s_color,
        o_error     => s_error_color );                                                   
    
    
    o_dataValid <= '1';-- on pourrait mux toute les erreur dans ce bit o_dataValid là a la fin 
    
    s_actor_update_en <= '1' when s_actor_pos_update_en = '1' or s_actor_tile_update_en = '1' else '0';
    o_dataPixel <= s_color;
    
    s_i_x <= i_x(9 downto 0);
    s_i_y <= i_y(9 downto 0);
    
    
    
    
    
    

end Behavioral;