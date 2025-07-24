----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/19/2025 07:20:55 PM
-- Design Name: 
-- Module Name: viewport - Behavioral
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
use work.viewport_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity viewport is
    Port (
        i_clk :           in  std_logic;
        i_reset :         in  std_logic;
        
        i_offset_x :       in integer;
        i_offset_y :       in integer;
        o_offset_x_left :  out integer;
        o_offset_y_left :  out integer;
        o_offset_x_right : out integer;
        o_offset_y_right : out integer
        );
end viewport;

architecture Behavioral of viewport is

signal s_offset_x_left: integer := 0;
signal s_offset_y_left: integer := 0;

begin

o_offset_x_right <= s_offset_x_left + VIEWPORT_SIZE_X;
o_offset_y_right <= s_offset_y_left + VIEWPORT_SIZE_Y;

process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                o_offset_x_left <= 0;
                o_offset_y_left <= 0;
            else
                o_offset_x_left <= s_offset_x_left + i_offset_x;
                o_offset_y_left <= s_offset_y_left + i_offset_y;
            end if;
        end if;
end process;

end Behavioral;
