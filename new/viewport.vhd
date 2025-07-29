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
        
        i_offset_x :      in  std_logic_vector(9 downto 0);
        i_offset_y :      in  std_logic_vector(9 downto 0);
        o_x :             out std_logic_vector(9 downto 0); -- Bit limitation x = Auto wraparound x
        o_y :             out std_logic_vector(9 downto 0)  -- Bit limitation y = Auto wraparound y
        );
end viewport;

architecture Behavioral of viewport is

signal s_offset_x: integer := 0;
signal s_offset_y: integer := 0;
signal s_position_x: integer := 0;
signal s_position_y: integer := 0;

begin

process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_reset = '1' then
                o_x <= 0;
                o_y <= 0;
            else
                -- Update offset when we restart at origin position
                if s_position_x = 0 and s_position_y = 0 then
                    s_offset_x <= s_offset_x + to_integer(signed(i_offset_x));
                    s_offset_y <= s_offset_y + to_integer(signed(i_offset_y));
                end if;

                -- Update outputs and cast into a logic vector to apply the waparounds
                o_x <= std_logic_vector(to_unsigned(s_offset_x + s_position_x, 10));
                o_y <= std_logic_vector(to_unsigned(s_offset_y + s_position_y, 10));

                -- Update position for next iteration
                s_position_x <= s_position_x + 1;

                -- Be sure not to exceed the viewport x size and to increment y when needed
                if s_position_x = VIEWPORT_SIZE_X then
                    s_position_x <= 0;
                    s_position_y <= s_position_y + 1;
                end if;

                -- Be sure not to exceed the viewport y size
                if s_position_y = VIEWPORT_SIZE_Y then
                    s_position_y <= 0;
                end if;
            end if;
        end if;
end process;

end Behavioral;
