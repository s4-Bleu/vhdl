----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/24/2025 01:32:44 PM
-- Design Name: 
-- Module Name: viewport_package - Behavioral
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

package viewport_package is
    constant BG_SIZE_X : integer := 1023;
    constant BG_SIZE_Y : integer := 1023;
    constant VIEWPORT_SIZE_X : integer := 659;
    constant VIEWPORT_SIZE_Y : integer := 639;
end package viewport_package;

package body viewport_package is
end package body viewport_package;
