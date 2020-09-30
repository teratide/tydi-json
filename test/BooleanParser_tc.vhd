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
use work.test_util_pkg.all;
use work.TestCase_pkg.all;

entity BooleanParser_tc is
end BooleanParser_tc;

architecture test_case of BooleanParser_tc is

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
  signal out_data         : std_logic;

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
    
    dut: BooleanParser
    generic map (
      ELEMENTS_PER_TRANSFER     => 8
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data                   => in_data,
      in_last(0)                => in_last,
      in_strb                   => in_strb,
      out_data                  => out_data,
      out_valid                 => out_valid,
      out_ready                 => out_ready
    );

    out_ready <= '1';
    -- out_count <= std_logic_vector(unsigned('0' & out_endi) - unsigned('0' & out_stai) + 1);
    -- aligned_data <= left_align_stream(out_data, out_stai, 64);


    -- out_sink: StreamSink_mdl
    -- generic map (
    --   NAME                      => "b",
    --   ELEMENT_WIDTH             => 8,
    --   COUNT_MAX                 => 8,
    --   COUNT_WIDTH               => 4
    -- )
    -- port map (
    --   clk                       => clk,
    --   reset                     => reset,
    --   valid                     => out_valid,
    --   ready                     => out_ready,
    --   data                      => aligned_data,
    --   count                     => out_count
    -- );

    

  random_tc: process is
    variable a        : streamsource_type;
    --variable b        : streamsink_type;

  begin
    tc_open("BooleanParser", "test");
    a.initialize("a");
    --b.initialize("b");

    a.push_str("false");
    a.transmit;
    --b.unblock;

    a.push_str("true");
    a.transmit;

    tc_wait_for(10 us);

    --tc_note(b.cq_get_d_str);


    tc_pass;
    wait;
  end process;

end test_case;