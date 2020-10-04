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

entity battery_status_tc is
end battery_status_tc;

architecture test_case of battery_status_tc is

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

  signal kv_ready        : std_logic;
  signal kv_valid        : std_logic;
  signal kv_data         : std_logic_vector(63 downto 0);
  signal kv_tag          : kv_tag_t;
  signal kv_stai         : std_logic_vector(2 downto 0);
  signal kv_endi         : std_logic_vector(2 downto 0);
  signal kv_strb         : std_logic_vector(7 downto 0);
  signal kv_last         : std_logic_vector(7 downto 0);

  signal array_ready        : std_logic;
  signal array_valid        : std_logic;
  signal array_data         : std_logic_vector(63 downto 0);
  signal array_stai         : std_logic_vector(2 downto 0);
  signal array_endi         : std_logic_vector(2 downto 0);
  signal array_strb         : std_logic_vector(7 downto 0);
  signal array_last         : std_logic_vector(7 downto 0);
  

  signal out_ready       : std_logic;
  signal out_valid       : std_logic;
  signal out_data        : std_logic_vector(63 downto 0);
  
  signal aligned_data    : std_logic_vector(63 downto 0);
  signal out_count       : std_logic_vector(3 downto 0);

  signal out_tag_int     : integer;

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
    
    record_praer_i: JsonRecordParser
    generic map (
      ELEMENTS_PER_TRANSFER     => 8,
      NESTING_LEVEL             => 2
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data.data              => in_data,
      in_data.comm              => ENABLE,
      in_strb                   => in_strb,
      out_data.data             => kv_data,
      out_data.tag              => kv_tag,
      out_stai                  => kv_stai,
      out_endi                  => kv_endi,
      out_ready                 => kv_ready,
      out_valid                 => kv_valid,
      out_strb                  => kv_strb,
      out_last                  => kv_last
    );



    array_parser_i: JsonArrayParser
    generic map (
      ELEMENTS_PER_TRANSFER     => 8
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => kv_valid,
      in_ready                  => kv_ready,
      in_data.data              => kv_data,
      in_data.comm              => ENABLE,
      in_last                   => kv_last,
      in_strb                   => kv_strb,
      out_data                  => array_data,
      out_valid                 => array_valid,
      out_ready                 => array_ready,
      out_last                  => array_last,
      out_stai                  => array_stai,
      out_endi                  => array_endi,
      out_strb                  => array_strb
    );


    intparser_i: Int64Parser
    generic map (
      ELEMENTS_PER_TRANSFER     => 8,
      NESTING_LEVEL             => 0
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => array_valid,
      in_ready                  => array_ready,
      in_data.data              => array_data,
      in_data.comm              => ENABLE,
      in_last(7 downto 0)       => array_last,
      in_strb                   => array_strb,
      out_data                  => out_data,
      out_valid                 => out_valid,
      out_ready                 => out_ready
    );

    --out_ready <= '1';
    --out_tag_int <= kv_tag_t'POS(out_tag);

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
    tc_open("JsonRecordParser", "test");
    a.initialize("a");
    b.initialize("b");

    a.push_str("{""values"" : [55 , 66]} {""valuessss"": [77 , 88]}");
    a.transmit;
    b.unblock;

    tc_wait_for(2 us);

    tc_check(b.pq_ready, true);
    tc_check(b.cq_get_d_nat, 55, "55");
    b.cq_next;
    tc_check(b.cq_get_d_nat, 66, "66");
    b.cq_next;
    tc_check(b.cq_get_d_nat, 77, "77");
    b.cq_next;
    tc_check(b.cq_get_d_nat, 88, "88");

    tc_pass;
    wait;
  end process;

end test_case;