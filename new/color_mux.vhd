----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/17/2025 10:41:14 AM
-- Design Name: 
-- Module Name: color_mux - Behavioral
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

entity color_mux is
    Port ( bg_tile_buffer_color_code : in STD_LOGIC_VECTOR (3 downto 0);
           actor_tile_buffer_color_code : in STD_LOGIC_VECTOR (3 downto 0);
           actor_tile_id : in STD_LOGIC_VECTOR (3 downto 0);--pt que sa sert a rien
           actor_visible : in STD_LOGIC;
           color_code : out STD_LOGIC_VECTOR (3 downto 0));
end color_mux;

architecture Behavioral of color_mux is

begin

color_code <= actor_tile_buffer_color_code when actor_visible ='1' or bg_tile_buffer_color_code /= "1111" else bg_tile_buffer_color_code; -- 0000 = couleur transparente


end Behavioral;
