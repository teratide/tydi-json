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
use work.tr_field_matcher_pkg.all;

entity NestedKeyFilter_tc is
end NestedKeyFilter_tc;

architecture test_case of NestedKeyFilter_tc is

  constant EPC                   : integer := 3;
  constant INTEGER_WIDTH         : integer := 64;
  constant INT_P_PIPELINE_STAGES : integer := 1;

  signal clk                   : std_logic;
  signal reset                 : std_logic;

  signal in_valid              : std_logic;
  signal in_ready              : std_logic;
  signal in_dvalid             : std_logic;
  signal in_last               : std_logic;
  signal in_data               : std_logic_vector(EPC*8-1 downto 0);
  signal in_count              : std_logic_vector(log2ceil(EPC+1)-1 downto 0);
  signal in_strb               : std_logic_vector(EPC-1 downto 0);
  signal in_endi               : std_logic_vector(log2ceil(EPC+1)-1 downto 0);

  signal adv_last              : std_logic_vector(EPC*2-1 downto 0) := (others => '0');

  signal outer_rec_ready             : std_logic;
  signal outer_rec_valid             : std_logic;
  signal outer_rec_vec               : std_logic_vector(EPC+EPC*8-1 downto 0);
  signal outer_rec_data              : std_logic_vector(EPC*8-1 downto 0);
  signal outer_rec_tag               : std_logic_vector(EPC-1 downto 0);
  signal outer_rec_empty             : std_logic_vector(EPC-1 downto 0);
  signal outer_rec_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_rec_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_rec_strb              : std_logic_vector(EPC-1 downto 0);
  signal outer_rec_last              : std_logic_vector(EPC*3-1 downto 0);

  signal timezone_ready, timezone_valid : std_logic;
  signal voltage_ready, voltage_valid : std_logic;

  signal voltage_rec_ready             : std_logic;
  signal voltage_rec_valid             : std_logic;
  signal voltage_rec_vec               : std_logic_vector(EPC+EPC*8-1 downto 0);
  signal voltage_rec_data              : std_logic_vector(EPC*8-1 downto 0);
  signal voltage_rec_tag               : std_logic_vector(EPC-1 downto 0);
  signal voltage_rec_empty             : std_logic_vector(EPC-1 downto 0);
  signal voltage_rec_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal voltage_rec_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal voltage_rec_strb              : std_logic_vector(EPC-1 downto 0);
  signal voltage_rec_last              : std_logic_vector(EPC*4-1 downto 0);

  signal timezone_rec_ready             : std_logic;
  signal timezone_rec_valid             : std_logic;
  signal timezone_rec_vec               : std_logic_vector(EPC+EPC*8-1 downto 0);
  signal timezone_rec_data              : std_logic_vector(EPC*8-1 downto 0);
  signal timezone_rec_tag               : std_logic_vector(EPC-1 downto 0);
  signal timezone_rec_empty             : std_logic_vector(EPC-1 downto 0);
  signal timezone_rec_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal timezone_rec_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal timezone_rec_strb              : std_logic_vector(EPC-1 downto 0);
  signal timezone_rec_last              : std_logic_vector(EPC*4-1 downto 0);

  signal outer_voltage_matcher_str_valid     : std_logic;
  signal outer_voltage_matcher_str_ready     : std_logic;
  signal outer_voltage_matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal outer_voltage_matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal outer_voltage_matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal outer_voltage_matcher_match_valid   : std_logic;
  signal outer_voltage_matcher_match_ready   : std_logic;
  signal outer_voltage_matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal outer_voltage_filter_ready          : std_logic;
  signal outer_voltage_filter_valid          : std_logic;
  signal outer_voltage_filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal outer_voltage_filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal outer_voltage_filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_voltage_filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_voltage_filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal outer_voltage_filter_last           : std_logic_vector(EPC*3-1 downto 0);

  signal outer_timezone_matcher_str_valid     : std_logic;
  signal outer_timezone_matcher_str_ready     : std_logic;
  signal outer_timezone_matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal outer_timezone_matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal outer_timezone_matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal outer_timezone_matcher_match_valid   : std_logic;
  signal outer_timezone_matcher_match_ready   : std_logic;
  signal outer_timezone_matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal outer_timezone_filter_ready          : std_logic;
  signal outer_timezone_filter_valid          : std_logic;
  signal outer_timezone_filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal outer_timezone_filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal outer_timezone_filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_timezone_filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_timezone_filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal outer_timezone_filter_last           : std_logic_vector(EPC*3-1 downto 0);

  signal inner_voltage_matcher_str_valid     : std_logic;
  signal inner_voltage_matcher_str_ready     : std_logic;
  signal inner_voltage_matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal inner_voltage_matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal inner_voltage_matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal inner_voltage_matcher_match_valid   : std_logic;
  signal inner_voltage_matcher_match_ready   : std_logic;
  signal inner_voltage_matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal inner_voltage_filter_ready          : std_logic;
  signal inner_voltage_filter_valid          : std_logic;
  signal inner_voltage_filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal inner_voltage_filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal inner_voltage_filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_voltage_filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_voltage_filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal inner_voltage_filter_last           : std_logic_vector(EPC*4-1 downto 0);

  signal inner_timezone_matcher_str_valid     : std_logic;
  signal inner_timezone_matcher_str_ready     : std_logic;
  signal inner_timezone_matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal inner_timezone_matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal inner_timezone_matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal inner_timezone_matcher_match_valid   : std_logic;
  signal inner_timezone_matcher_match_ready   : std_logic;
  signal inner_timezone_matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal inner_timezone_filter_ready          : std_logic;
  signal inner_timezone_filter_valid          : std_logic;
  signal inner_timezone_filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal inner_timezone_filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal inner_timezone_filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_timezone_filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_timezone_filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal inner_timezone_filter_last           : std_logic_vector(EPC*4-1 downto 0);

  signal voltage_out_ready             : std_logic;
  signal voltage_out_valid             : std_logic;
  signal voltage_out_strb              : std_logic;
  signal voltage_out_dvalid            : std_logic;
  signal voltage_out_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal voltage_out_last              : std_logic_vector(2 downto 0);

  signal timezone_out_ready             : std_logic;
  signal timezone_out_valid             : std_logic;
  signal timezone_out_strb              : std_logic;
  signal timezone_out_dvalid            : std_logic;
  signal timezone_out_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal timezone_out_last              : std_logic_vector(2 downto 0);

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

    in_strb <= element_mask(in_count, in_dvalid, EPC); 

    in_endi <= std_logic_vector(unsigned(in_count) - 1);

    -- TODO: Is there a cleaner solutiuon? It's getting late :(
    adv_last(EPC*2-1 downto 0) <=  std_logic_vector(shift_left(resize(unsigned'("0" & in_last), 
              EPC*2), to_integer((unsigned(in_endi))*2+1)));
    
    outer_record_parser: JsonRecordParser
    generic map (
      EPC     => EPC,
      OUTER_NESTING_LEVEL       => 1,
      INNER_NESTING_LEVEL       => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data                   => in_data,
      in_strb                   => in_strb,
      in_last                   => adv_last,
      out_valid                 => outer_rec_valid,
      out_ready                 => outer_rec_ready,
      out_strb                  => outer_rec_strb,
      out_data                  => outer_rec_vec,
      out_last                  => outer_rec_last,
      out_stai                  => outer_rec_stai,
      out_endi                  => outer_rec_endi
    );

    outer_rec_data <= outer_rec_vec(EPC*8-1 downto 0);
    outer_rec_tag <= outer_rec_vec(EPC+EPC*8-1 downto EPC*8);

    sync_i: StreamSync
    generic map (
      NUM_INPUTS              => 1,
      NUM_OUTPUTS             => 2
    )
    port map (
      clk                     => clk,
      reset                   => reset,
      in_valid(0)             => outer_rec_valid,
      in_ready(0)             => outer_rec_ready,

      out_valid(0)            => voltage_valid,
      out_valid(1)            => timezone_valid,


      out_ready(0)            => voltage_ready,
      out_ready(1)            => timezone_ready

    );

    outer_kf: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 2
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => voltage_valid,
      in_ready                  => voltage_ready,
      in_data                   => outer_rec_vec,
      in_strb                   => outer_rec_strb,
      in_last                   => outer_rec_last,
      matcher_str_valid         => outer_voltage_matcher_str_valid,
      matcher_str_ready         => outer_voltage_matcher_str_ready,
      matcher_str_data          => outer_voltage_matcher_str_data,
      matcher_str_mask          => outer_voltage_matcher_str_mask,
      matcher_str_last          => outer_voltage_matcher_str_last,
      matcher_match_valid       => outer_voltage_matcher_match_valid,
      matcher_match_ready       => outer_voltage_matcher_match_ready,
      matcher_match             => outer_voltage_matcher_match,
      out_valid                 => outer_voltage_filter_valid,
      out_ready                 => outer_voltage_filter_ready,
      out_data                  => outer_voltage_filter_data,
      out_strb                  => outer_voltage_filter_strb,
      out_stai                  => outer_voltage_filter_stai,
      out_endi                  => outer_voltage_filter_endi,
      out_last                  => outer_voltage_filter_last
    );

    outer_kf2: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 2
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => timezone_valid,
      in_ready                  => timezone_ready,
      in_data                   => outer_rec_vec,
      in_strb                   => outer_rec_strb,
      in_last                   => outer_rec_last,
      matcher_str_valid         => outer_timezone_matcher_str_valid,
      matcher_str_ready         => outer_timezone_matcher_str_ready,
      matcher_str_data          => outer_timezone_matcher_str_data,
      matcher_str_mask          => outer_timezone_matcher_str_mask,
      matcher_str_last          => outer_timezone_matcher_str_last,
      matcher_match_valid       => outer_timezone_matcher_match_valid,
      matcher_match_ready       => outer_timezone_matcher_match_ready,
      matcher_match             => outer_timezone_matcher_match,
      out_valid                 => outer_timezone_filter_valid,
      out_ready                 => outer_timezone_filter_ready,
      out_data                  => outer_timezone_filter_data,
      out_strb                  => outer_timezone_filter_strb,
      out_stai                  => outer_timezone_filter_stai,
      out_endi                  => outer_timezone_filter_endi,
      out_last                  => outer_timezone_filter_last
    );

    outer_voltage_matcher: voltage_matcher
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_voltage_matcher_str_valid,
      in_ready                  => outer_voltage_matcher_str_ready,
      in_mask                   => outer_voltage_matcher_str_mask,
      in_data                   => outer_voltage_matcher_str_data,
      in_xlast                  => outer_voltage_matcher_str_last,
      out_valid                 => outer_voltage_matcher_match_valid,
      out_ready                 => outer_voltage_matcher_match_ready,
      out_xmatch                => outer_voltage_matcher_match
    );

    outer_timezone_matcher: timezone_f_m
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_timezone_matcher_str_valid,
      in_ready                  => outer_timezone_matcher_str_ready,
      in_mask                   => outer_timezone_matcher_str_mask,
      in_data                   => outer_timezone_matcher_str_data,
      in_xlast                  => outer_timezone_matcher_str_last,
      out_valid                 => outer_timezone_matcher_match_valid,
      out_ready                 => outer_timezone_matcher_match_ready,
      out_xmatch                => outer_timezone_matcher_match
    );

    voltage_record_parser: JsonRecordParser
    generic map (
      EPC     => EPC,
      OUTER_NESTING_LEVEL       => 2,
      INNER_NESTING_LEVEL       => 0
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_voltage_filter_valid,
      in_ready                  => outer_voltage_filter_ready,
      in_data                   => outer_voltage_filter_data,
      in_stai                   => outer_voltage_filter_stai,
      in_strb                   => outer_voltage_filter_strb,
      in_last                   => outer_voltage_filter_last,
      out_valid                 => voltage_rec_valid,
      out_ready                 => voltage_rec_ready,
      out_strb                  => voltage_rec_strb,
      out_data                  => voltage_rec_vec,
      out_last                  => voltage_rec_last,
      out_stai                  => voltage_rec_stai,
      out_endi                  => voltage_rec_endi
    );

    voltage_record_parser2: JsonRecordParser
    generic map (
      EPC     => EPC,
      OUTER_NESTING_LEVEL       => 2,
      INNER_NESTING_LEVEL       => 0
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_timezone_filter_valid,
      in_ready                  => outer_timezone_filter_ready,
      in_data                   => outer_timezone_filter_data,
      in_stai                   => outer_timezone_filter_stai,
      in_strb                   => outer_timezone_filter_strb,
      in_last                   => outer_timezone_filter_last,
      out_valid                 => timezone_rec_valid,
      out_ready                 => timezone_rec_ready,
      out_strb                  => timezone_rec_strb,
      out_data                  => timezone_rec_vec,
      out_last                  => timezone_rec_last,
      out_stai                  => timezone_rec_stai,
      out_endi                  => timezone_rec_endi
    );

    dut: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 3
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => voltage_rec_valid,
      in_ready                  => voltage_rec_ready,
      in_data                   => voltage_rec_vec,
      in_strb                   => voltage_rec_strb,
      in_last                   => voltage_rec_last,
      matcher_str_valid         => inner_voltage_matcher_str_valid,
      matcher_str_ready         => inner_voltage_matcher_str_ready,
      matcher_str_data          => inner_voltage_matcher_str_data,
      matcher_str_mask          => inner_voltage_matcher_str_mask,
      matcher_str_last          => inner_voltage_matcher_str_last,
      matcher_match_valid       => inner_voltage_matcher_match_valid,
      matcher_match_ready       => inner_voltage_matcher_match_ready,
      matcher_match             => inner_voltage_matcher_match,
      out_valid                 => inner_voltage_filter_valid,
      out_ready                 => inner_voltage_filter_ready,
      out_data                  => inner_voltage_filter_data,
      out_strb                  => inner_voltage_filter_strb,
      out_stai                  => inner_voltage_filter_stai,
      out_endi                  => inner_voltage_filter_endi,
      out_last                  => inner_voltage_filter_last
    );

    inner_kf2: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 3
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => timezone_rec_valid,
      in_ready                  => timezone_rec_ready,
      in_data                   => timezone_rec_vec,
      in_strb                   => timezone_rec_strb,
      in_last                   => timezone_rec_last,
      matcher_str_valid         => inner_timezone_matcher_str_valid,
      matcher_str_ready         => inner_timezone_matcher_str_ready,
      matcher_str_data          => inner_timezone_matcher_str_data,
      matcher_str_mask          => inner_timezone_matcher_str_mask,
      matcher_str_last          => inner_timezone_matcher_str_last,
      matcher_match_valid       => inner_timezone_matcher_match_valid,
      matcher_match_ready       => inner_timezone_matcher_match_ready,
      matcher_match             => inner_timezone_matcher_match,
      out_valid                 => inner_timezone_filter_valid,
      out_ready                 => inner_timezone_filter_ready,
      out_data                  => inner_timezone_filter_data,
      out_strb                  => inner_timezone_filter_strb,
      out_stai                  => inner_timezone_filter_stai,
      out_endi                  => inner_timezone_filter_endi,
      out_last                  => inner_timezone_filter_last
    );

    

    inner_voltage_matcher: voltage_matcher
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => inner_voltage_matcher_str_valid,
      in_ready                  => inner_voltage_matcher_str_ready,
      in_mask                   => inner_voltage_matcher_str_mask,
      in_data                   => inner_voltage_matcher_str_data,
      in_xlast                  => inner_voltage_matcher_str_last,
      out_valid                 => inner_voltage_matcher_match_valid,
      out_ready                 => inner_voltage_matcher_match_ready,
      out_xmatch                => inner_voltage_matcher_match
    );


    intparser_i: IntParser
    generic map (
      EPC     => EPC,
      NESTING_LEVEL             => 3,
      BITWIDTH                  => INTEGER_WIDTH,
      PIPELINE_STAGES           => INT_P_PIPELINE_STAGES
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => inner_voltage_filter_valid,
      in_ready                  => inner_voltage_filter_ready,
      in_data                   => inner_voltage_filter_data,
      in_last                   => inner_voltage_filter_last,
      in_strb                   => inner_voltage_filter_strb,
      out_data                  => voltage_out_data,
      out_valid                 => voltage_out_valid,
      out_ready                 => voltage_out_ready,
      out_last                  => voltage_out_last,
      out_strb                  => voltage_out_strb
    );

    inner_timezone_matcher: timezone_f_m
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => inner_timezone_matcher_str_valid,
      in_ready                  => inner_timezone_matcher_str_ready,
      in_mask                   => inner_timezone_matcher_str_mask,
      in_data                   => inner_timezone_matcher_str_data,
      in_xlast                  => inner_timezone_matcher_str_last,
      out_valid                 => inner_timezone_matcher_match_valid,
      out_ready                 => inner_timezone_matcher_match_ready,
      out_xmatch                => inner_timezone_matcher_match
    );


    intparser_i2: IntParser
    generic map (
      EPC     => EPC,
      NESTING_LEVEL             => 3,
      BITWIDTH                  => INTEGER_WIDTH,
      PIPELINE_STAGES           => INT_P_PIPELINE_STAGES
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => inner_timezone_filter_valid,
      in_ready                  => inner_timezone_filter_ready,
      in_data                   => inner_timezone_filter_data,
      in_last                   => inner_timezone_filter_last,
      in_strb                   => inner_timezone_filter_strb,
      out_data                  => timezone_out_data,
      out_valid                 => timezone_out_valid,
      out_ready                 => timezone_out_ready,
      out_last                  => timezone_out_last,
      out_strb                  => timezone_out_strb
    );

    voltage_out_dvalid <= voltage_out_strb;
    timezone_out_dvalid <= timezone_out_strb;

    out_sink: StreamSink_mdl
    generic map (
      NAME                      => "b",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => voltage_out_valid,
      ready                     => voltage_out_ready,
      data                      => voltage_out_data,
      dvalid                    => voltage_out_dvalid,
      last                      => voltage_out_last(2)
    );

    out_sink2: StreamSink_mdl
    generic map (
      NAME                      => "c",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => timezone_out_valid,
      ready                     => timezone_out_ready,
      data                      => timezone_out_data,
      dvalid                    => timezone_out_dvalid,
      last                      => timezone_out_last(2)
    );

   

  random_tc: process is
    variable a        : streamsource_type;
    variable b        : streamsink_type;
    variable c        : streamsink_type;

  begin
    tc_open("NestedKeyFilter_tc", "test");
    a.initialize("a");
    b.initialize("b");
    c.initialize("c");

    a.set_total_cyc(0, 20);
    b.set_valid_cyc(0, 50);
    b.set_total_cyc(0, 50);
    c.set_valid_cyc(0, 50);
    c.set_total_cyc(0, 50);

    -- -- This should pass
    -- a.push_str("{ ");
    -- a.push_str(" ""unrelated"": 123,");
    -- -- Even just including an empty record breaks subsequent records?
    -- a.push_str(" ""other_rec"": { },");
    -- a.push_str(" ""timezone"" : {");
    -- a.push_str("   ""timezone"" : 13,");
    -- a.push_str("  }");
    -- a.push_str(",}");
    a.push_str("{ ");
    a.push_str(" ""voltage"" : {");
    a.push_str("   ""voltage"" : 11,");
    a.push_str("  },");
    a.push_str(" ""timezone"" : {");
    a.push_str("   ""timezone"" : 22,");
    a.push_str("  }");
    a.push_str(",}");
    a.push_str("{ ");
    a.push_str(" ""timezone"" : {");
    a.push_str("   ""timezone"" : 55,");
    a.push_str("  }");
    a.push_str(",}");
    -- This should fail (wrong outer key)
    a.push_str("{ ");
    a.push_str(" ""voltage2"" : {");
    a.push_str("   ""voltage"" : 20,");
    a.push_str("  }");
    a.push_str(",}");
    -- This should fail (wrong inner key)
    a.push_str("{ ");
    a.push_str(" ""voltage"" : {");
    a.push_str("   ""voltage2"" : 30,");
    a.push_str("  }");
    a.push_str(",}");
    -- This should pass
    a.push_str("{ ");
    a.push_str(" ""timezone"" : {");
    a.push_str("   ""timezone"" : 66,");
    a.push_str("  },");
    a.push_str(" ""voltage"" : {");
    a.push_str("   ""voltage"" : 44,");
    a.push_str("  }");
    a.push_str(",}");

    a.transmit;
    b.unblock;
    c.unblock;

    tc_wait_for(70 us);

    tc_check(b.pq_ready, true);
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 11, "voltage: 11");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 44, "voltage: 44");

    tc_check(c.pq_ready, true);
    -- while not c.cq_get_dvalid loop
    --   c.cq_next;
    -- end loop;
    -- tc_check(c.cq_get_d_nat, 13, "timezone: 13");
    -- c.cq_next;
    while not c.cq_get_dvalid loop
      c.cq_next;
    end loop;
    tc_check(c.cq_get_d_nat, 22, "timezone: 22");
    c.cq_next;
    while not c.cq_get_dvalid loop
      c.cq_next;
    end loop;
    tc_check(c.cq_get_d_nat, 55, "timezone: 55");
    c.cq_next;
    while not c.cq_get_dvalid loop
      c.cq_next;
    end loop;
    tc_check(c.cq_get_d_nat, 66, "timezone: 66");
    
    -- if b.cq_get_last = '0' then
    --   b.cq_next;
    -- end if;
    -- tc_check(b.cq_get_last, '1', "Outermost nesting level last");


    tc_pass;
    wait;
  end process;

end test_case;