library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.UtilInt_pkg.all;
use work.TestCase_pkg.all;
use work.Stream_pkg.all;
use work.ClockGen_pkg.all;
use work.StreamSource_pkg.all;
use work.StreamSink_pkg.all;
use work.Json_pkg.all;
use work.TestMisc_pkg.all;

entity KeyFilter_tc is
end KeyFilter_tc;

architecture test_case of KeyFilter_tc is

  constant EPC : integer := 8;

  signal clk                   : std_logic;
  signal reset                 : std_logic;


  signal in_valid              : std_logic;
  signal in_ready              : std_logic;
  signal in_dvalid             : std_logic;
  signal in_last               : std_logic;
  signal in_data               : std_logic_vector(EPC*8-1 downto 0);
  signal in_count              : std_logic_vector(log2ceil(EPC+1)-1 downto 0);
  signal in_strb               : std_logic_vector(EPC-1 downto 0);
  signal in_endi               : std_logic_vector(log2ceil(EPC)-1 downto 0);

  signal rec_ready             : std_logic;
  signal rec_valid             : std_logic;
  signal rec_data              : std_logic_vector(EPC*8-1 downto 0);
  signal rec_tag               : std_logic_vector(EPC-1 downto 0);
  signal rec_empty             : std_logic_vector(EPC-1 downto 0);
  signal rec_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal rec_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal rec_strb              : std_logic_vector(EPC-1 downto 0);
  signal rec_last              : std_logic_vector(EPC*3-1 downto 0);


  signal matcher_str_valid     : std_logic;
  signal matcher_str_ready     : std_logic;
  signal matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal matcher_match_valid   : std_logic;
  signal matcher_match_ready   : std_logic;
  signal matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal out_ready             : std_logic;
  signal out_valid             : std_logic;
  signal out_data              : std_logic_vector(EPC*8-1 downto 0);
  signal out_tag               : std_logic_vector(EPC-1 downto 0);
  signal out_empty             : std_logic_vector(EPC-1 downto 0);
  signal out_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal out_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal out_strb              : std_logic_vector(EPC-1 downto 0);

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
      COUNT_MAX                 => EPC,
      COUNT_WIDTH               => log2ceil(EPC+1)
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
    --in_endi <= std_logic_vector(unsigned(in_count) - 1);
    
    record_parser: JsonRecordParser
    generic map (
      EPC     => EPC,
      OUTER_NESTING_LEVEL       => 1,
      INNER_NESTING_LEVEL       => 0
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data.data              => in_data,
      in_data.comm              => ENABLE,
      in_strb                   => in_strb,
      out_valid                 => rec_valid,
      out_ready                 => rec_ready,
      out_strb                  => rec_strb,
      out_data.data             => rec_data,
      out_data.tag              => rec_tag,
      out_empty                 => rec_empty,
      out_last                  => rec_last,
      out_stai                  => rec_stai,
      out_endi                  => rec_endi
    );

    dut: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 2
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => rec_valid,
      in_ready                  => rec_ready,
      in_data.data              => rec_data,
      in_data.tag               => rec_tag,
      in_empty                  => rec_empty,
      in_strb                   => rec_strb,
      in_last                   => rec_last,
      matcher_str_valid         => matcher_str_valid,
      matcher_str_ready         => matcher_str_ready,
      matcher_str_data          => matcher_str_data,
      matcher_str_mask          => matcher_str_mask,
      matcher_str_last          => matcher_str_last,
      matcher_match_valid       => matcher_match_valid,
      matcher_match_ready       => matcher_match_ready,
      matcher_match             => matcher_match,
      out_valid                 => out_valid,
      out_ready                 => out_ready,
      out_data                  => out_data,
      out_empty                 => out_empty,
      out_stai                  => out_stai,
      out_endi                  => out_endi
    );

    matcher: voltage_matcher
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => matcher_str_valid,
      in_ready                  => matcher_str_ready,
      in_mask                   => matcher_str_mask,
      in_data                   => matcher_str_data,
      in_xlast                  => matcher_str_last,
      out_valid                 => matcher_match_valid,
      out_ready                 => matcher_match_ready,
      out_xmatch                => matcher_match
    );



    out_ready <= '1';
    --out_tag_int <= kv_tag_t'POS(out_tag);

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
    tc_open("KeyFilter", "test");
    a.initialize("a");
    --b.initialize("b");

    a.push_str("{ ");
    a.push_str(" ""voltage"" : 123456");
    a.push_str(" ,}");
    a.push_str("{ ");
    a.push_str(" ""voltages1"" : 123456,");
    a.push_str(" ""voltages2"" : 123456,");
    a.push_str(" ""voltages3"" : 123456,");
    a.push_str(" ""voltages4"" : 123456,");
    a.push_str(" ,}");
    a.push_str("{ ");
    a.push_str(" ""voltage"" : 123456");
    a.push_str(" ,}");
    --a.push_str("{""voltage"" : true}");
    a.transmit;
    --b.unblock;

    tc_wait_for(2 us);

    --tc_note(b.cq_get_d_str);


    tc_pass;
    wait;
  end process;

end test_case;