library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

package test_util_pkg is

  -- Returns the count with implicit '1' MSB of a one-hot- or thermometer-coded
  -- value.
  function left_align_stream(
    data    : std_logic_vector;
    stai    : std_logic_vector;
    bits    : natural
  ) return std_logic_vector;

end test_util_pkg;

package body test_util_pkg is

  function left_align_stream(
    data    : std_logic_vector;
    stai    : std_logic_vector;
    bits    : natural
  ) return std_logic_vector is
    variable var : unsigned(bits-1 downto 0);
    variable ret : std_logic_vector(bits-1 downto 0);
  begin
    var := shift_right(unsigned(data), to_integer(unsigned(stai)));
    ret := std_logic_vector(var);
    return ret;
  end function;

end test_util_pkg;
