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
        
        i_offset_x :      in std_logic_vector(9 downto 0);
        i_offset_y :      in std_logic_vector(9 downto 0);
        i_background :    in background_type;
        o_viewport :      out viewport_type
        );
end viewport;

architecture Behavioral of viewport is

begin

process(i_clk)
    variable source_x, source_y : integer;
    
    begin
        if rising_edge(i_clk) then
            for i in 0 to VIEWPORT_SIZE_X loop
                for j in 0 to VIEWPORT_SIZE_Y loop
                
                    -- Wraparound using modulo
                    source_x := (to_integer(unsigned(i_offset_x)) + i) mod (BG_SIZE_X + 1);
                    source_y := (to_integer(unsigned(i_offset_y)) + j) mod (BG_SIZE_Y + 1);

                    o_viewport(i)(j) <= i_background(source_x)(source_y);
                end loop;
            end loop;
        end if;
    end process;

end Behavioral;
