
-- Generated by vhdre.py version 0.2
-- 
-- MIT License
-- 
-- Copyright (c) 2017-2019 Jeroen van Straten, Delft University of Technology
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity small_speed_var_f_m_tb is
end small_speed_var_f_m_tb;

architecture Testbench of small_speed_var_f_m_tb is
  signal clk                    : std_logic := '1';
  signal reset                  : std_logic := '1';
  signal in_valid               : std_logic;
  signal in_data                : std_logic_vector(7 downto 0);
  signal in_last                : std_logic;
  signal out_valid              : std_logic;
  signal out_match              : std_logic_vector(0 downto 0);
  signal out_error              : std_logic;
  signal out_match_mon          : std_logic_vector(0 downto 0);
  signal out_error_mon          : std_logic;
begin

  clk_proc: process is
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  stim_proc: process is
    procedure x(data_x: std_logic_vector) is
      constant data: std_logic_vector(data_x'length-1 downto 0) := data_x;
    begin
      in_valid <= '1';
      in_last <= '0';
      for i in data'length/8-1 downto 0 loop
        in_data <= data(i*8+7 downto i*8);
        if i = 0 then
          in_last <= '1';
        end if;
        wait until falling_edge(clk);
      end loop;
      in_valid <= '0';
      in_data <= (others => '0');
      in_last <= '0';
    end procedure;
  begin
    reset <= '1';
    in_valid <= '0';
    in_data <= (others => '0');
    in_last <= '0';
    wait for 500 ns;
    wait until falling_edge(clk);
    reset <= '0';
    wait until falling_edge(clk);
    x(X"736D616C6C5F73706565645F766172");
    wait;
  end process;

  uut: entity work.small_speed_var_f_m
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_data                   => in_data,
      in_last                   => in_last,
      out_valid                 => out_valid,
      out_match                 => out_match,
      out_error                 => out_error
    );

  mon_proc: process (clk) is
  begin
    if falling_edge(clk) then
      if to_X01(out_valid) = '1' then
        out_match_mon <= out_match;
        out_error_mon <= out_error;
      elsif to_X01(out_valid) = '0' then
        out_match_mon <= (others => 'Z');
        out_error_mon <= 'Z';
      else
        out_match_mon <= (others => 'X');
        out_error_mon <= 'X';
      end if;
    end if;
  end process;

end Testbench;
