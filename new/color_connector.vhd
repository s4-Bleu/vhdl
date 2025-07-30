----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11/18/2021 06:55:22 PM
-- Design Name:
-- Module Name: color_connector
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

entity color_connector is
Port (
    i_colorCode : in std_logic_vector(3 downto 0);
    o_color     : out std_logic_vector(23 downto 0);
    o_error     : out std_logic
);
end color_connector;

architecture Behavioral of color_connector is


begin

-- Rappel: Les Couleurs sont en RBG et non RGB, faire attention
with i_colorCode select
  o_color <= x"000000" when x"0", -- noir
             x"FF0000" when x"1", -- rouge
             x"FF00FF" when x"2", -- jaune
             x"000080" when x"3", -- vert
             x"9898FB" when x"4", -- vert pâle
             x"000064" when x"5", -- vert foncé
             x"87EBCE" when x"6", -- bleu ciel
             x"FFFFFF" when x"7", -- blanc
             x"FF00A5" when x"8", -- Orange
             x"696969" when x"F", -- Transparent merde à vic
             x"000000" when others;
--with i_colorCode select
--  o_color <= x"FFFFFF" when x"0",
--             x"000000" when x"1",
--             x"353FD0" when x"2",
--             x"1D33A9" when x"3",
--             x"000080" when x"4",
--             x"87EBCE" when x"5",
--             x"FF00FF" when x"6",
--             x"FF00A5" when x"7",
--             x"FF0000" when x"8",
--             x"646464" when x"9",
--             x"7E7CE7" when x"A",
--             x"696969" when x"F", -- Transparent merde à vic
--             x"000000" when others;


with i_colorCode select
o_error <=  '0' when x"0", -- noir
            '0' when x"1", -- rouge
            '0' when x"2", -- jaune
            '0' when x"3", -- vert
            '0' when x"4", -- vert pâle
            '0' when x"5", -- vert foncé
            '0' when x"6", -- bleu ciel
            '0' when x"7", -- blanc
            '0' when x"8", -- Orange
            '0' when x"9",
            '0' when x"A",
            '0' when x"F", -- Transparent merde à vic
            '1' when others;

end Behavioral;