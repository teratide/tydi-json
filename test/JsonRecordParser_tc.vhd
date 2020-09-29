library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.TestCase_pkg.all;
use work.Stream_pkg.all;
use work.ClockGen_pkg.all;
use work.StreamSource_pkg.all;
use work.StreamSink_pkg.all;
use work.Json_pkg.all;

entity JsonRecordParser_tc is
end JsonRecordParser_tc;

architecture test_case of JsonRecordParser_tc is

  signal clk        : std_logic;
  signal reset      : std_logic;


  signal in_valid   : std_logic;
  signal in_ready   : std_logic;
  signal in_dvalid  : std_logic;
  signal in_last    : std_logic;
  signal in_data    : std_logic_vector(63 downto 0);
  signal in_count   : std_logic_vector(3 downto 0);
  signal in_strb    : std_logic_vector(7 downto 0);
  signal in_endi    : std_logic_vector(3 downto 0);

  signal out_ready  : std_logic;

begin

  clkgen: ClockGen_mdl
    port map (
      clk                       => clk,
      reset                     => reset
    );

  in_source: StreamSource_mdl
    generic map (
      NAME                      => "a",
      ELEMENT_WIDTH             => 8,
      COUNT_MAX                 => 8,
      COUNT_WIDTH               => 4
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => in_valid,
      ready                     => in_ready,
      dvalid                    => in_dvalid,
      last                      => in_last,
      data                      => in_data,
      count                     => in_count
    );

    with in_count(3 downto 0) select in_strb <=
     "00000001" when "0001",
     "00000011" when "0010", 
     "00000111" when "0011", 
     "00001111" when "0100",
     "00011111" when "0101", 
     "00111111" when "0110",
     "01111111" when "0111",
     "11111111" when "1000",
     "00000000" when others;

    dut: JsonRecordParser
    generic map (
      ELEMENTS_PER_TRANSFER     => 8
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data                   => in_data,
      --in_stai                   => "000",
      --in_endi                   => in_endi,
      in_strb                   => in_strb,
      out_ready                 => out_ready
    );

    in_endi <= std_logic_vector(unsigned(in_count) - 1);

    out_ready <= '1';

  random_tc: process is
    variable a        : streamsource_type;

  begin
    tc_open("JsonRecordParser", "test");
    a.initialize("a");

    a.push_str("{""voltage"" : 123456,}");

    a.transmit;

    tc_wait_for(2 us);

    tc_pass;
    wait;
  end process;

end test_case;