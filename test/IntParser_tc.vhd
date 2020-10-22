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
use work.TestCase_pkg.all;

entity IntParser_tc is
end IntParser_tc;

architecture test_case of IntParser_tc is

  signal clk              : std_logic;
  signal reset            : std_logic;


  signal in_valid         : std_logic;
  signal in_ready         : std_logic;
  signal in_dvalid        : std_logic;
  signal in_last          : std_logic;
  signal in_data          : std_logic_vector(63 downto 0);
  signal in_count         : std_logic_vector(3 downto 0);
  signal in_strb          : std_logic_vector(7 downto 0);
  signal in_endi          : std_logic_vector(3 downto 0);

  signal out_ready        : std_logic;
  signal out_valid        : std_logic;
  signal out_data         : std_logic_vector(63 downto 0);

  signal adv_last         : std_logic_vector(7 downto 0);

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

    in_strb <= element_mask(in_count, in_dvalid, 8); 
    in_endi <= std_logic_vector(unsigned(in_count) - 1);

    adv_last <= std_logic_vector(shift_left(unsigned'("0000000" & in_last), to_integer(unsigned(in_endi))));
    
    dut: IntParser
    generic map (
      EPC                       => 8,
      NESTING_LEVEL             => 0,
      BITWIDTH                  => 64
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data                   => in_data,
      in_last                   => adv_last,
      in_strb                   => in_strb,
      out_data                  => out_data,
      out_valid                 => out_valid,
      out_ready                 => out_ready
    );

    out_sink: StreamSink_mdl
    generic map (
      NAME                      => "b",
      ELEMENT_WIDTH             => 64,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => out_valid,
      ready                     => out_ready,
      data                      => out_data
    );

    

  random_tc: process is
    variable a        : streamsource_type;
    variable b        : streamsink_type;

  begin
    tc_open("IntParser", "test");
    a.initialize("a");
    b.initialize("b");

    a.push_str("1234");
    a.transmit(last => true);
    
    a.push_str("12345");
    a.transmit(last => true);


    a.push_str("   1234");
    a.transmit(last => true);
    
    a.push_str("   12345");
    a.transmit(last => true);

    b.unblock;

    tc_wait_for(10 us);

    tc_check(b.pq_ready, true);
    tc_check(b.cq_get_d_nat, 1234, "1234");
    b.cq_next;
    tc_check(b.cq_get_d_nat, 12345, "12345");
    b.cq_next;
    tc_check(b.cq_get_d_nat, 1234, "1234 with spaces");
    b.cq_next;
    tc_check(b.cq_get_d_nat, 12345, "12345 with spaces");
    b.cq_next;


    tc_pass;
    wait;
  end process;

end test_case;