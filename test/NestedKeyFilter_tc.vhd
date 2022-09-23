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

  signal inner_rec_ready             : std_logic;
  signal inner_rec_valid             : std_logic;
  signal inner_rec_vec               : std_logic_vector(EPC+EPC*8-1 downto 0);
  signal inner_rec_data              : std_logic_vector(EPC*8-1 downto 0);
  signal inner_rec_tag               : std_logic_vector(EPC-1 downto 0);
  signal inner_rec_empty             : std_logic_vector(EPC-1 downto 0);
  signal inner_rec_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_rec_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_rec_strb              : std_logic_vector(EPC-1 downto 0);
  signal inner_rec_last              : std_logic_vector(EPC*4-1 downto 0);

  signal outer_matcher_str_valid     : std_logic;
  signal outer_matcher_str_ready     : std_logic;
  signal outer_matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal outer_matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal outer_matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal outer_matcher_match_valid   : std_logic;
  signal outer_matcher_match_ready   : std_logic;
  signal outer_matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal outer_filter_ready          : std_logic;
  signal outer_filter_valid          : std_logic;
  signal outer_filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal outer_filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal outer_filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal outer_filter_last           : std_logic_vector(EPC*3-1 downto 0);
  signal outer_filter_last2           : std_logic_vector(EPC*3-1 downto 0);

  signal inner_matcher_str_valid     : std_logic;
  signal inner_matcher_str_ready     : std_logic;
  signal inner_matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal inner_matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal inner_matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal inner_matcher_match_valid   : std_logic;
  signal inner_matcher_match_ready   : std_logic;
  signal inner_matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal inner_filter_ready          : std_logic;
  signal inner_filter_valid          : std_logic;
  signal inner_filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal inner_filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal inner_filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal inner_filter_last           : std_logic_vector(EPC*4-1 downto 0);
  signal inner_filter_last2           : std_logic_vector(EPC*4-1 downto 0);

  signal out_ready             : std_logic;
  signal out_valid             : std_logic;
  signal out_strb              : std_logic;
  signal out_dvalid            : std_logic;
  signal out_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal out_last              : std_logic_vector(2 downto 0);

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

    outer_kf: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 2
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_rec_valid,
      in_ready                  => outer_rec_ready,
      in_data                   => outer_rec_vec,
      in_strb                   => outer_rec_strb,
      in_last                   => outer_rec_last,
      matcher_str_valid         => outer_matcher_str_valid,
      matcher_str_ready         => outer_matcher_str_ready,
      matcher_str_data          => outer_matcher_str_data,
      matcher_str_mask          => outer_matcher_str_mask,
      matcher_str_last          => outer_matcher_str_last,
      matcher_match_valid       => outer_matcher_match_valid,
      matcher_match_ready       => outer_matcher_match_ready,
      matcher_match             => outer_matcher_match,
      out_valid                 => outer_filter_valid,
      out_ready                 => outer_filter_ready,
      out_data                  => outer_filter_data,
      out_strb                  => outer_filter_strb,
      out_stai                  => outer_filter_stai,
      out_endi                  => outer_filter_endi,
      out_last                  => outer_filter_last
    );

    outer_matcher: voltage_matcher
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_matcher_str_valid,
      in_ready                  => outer_matcher_str_ready,
      in_mask                   => outer_matcher_str_mask,
      in_data                   => outer_matcher_str_data,
      in_xlast                  => outer_matcher_str_last,
      out_valid                 => outer_matcher_match_valid,
      out_ready                 => outer_matcher_match_ready,
      out_xmatch                => outer_matcher_match
    );

    inner_record_parser: JsonRecordParser
    generic map (
      EPC     => EPC,
      OUTER_NESTING_LEVEL       => 2,
      INNER_NESTING_LEVEL       => 0
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_filter_valid,
      in_ready                  => outer_filter_ready,
      in_data                   => outer_filter_data,
      in_stai                   => outer_filter_stai,
      in_strb                   => outer_filter_strb,
      in_last                   => outer_filter_last,
      out_valid                 => inner_rec_valid,
      out_ready                 => inner_rec_ready,
      out_strb                  => inner_rec_strb,
      out_data                  => inner_rec_vec,
      out_last                  => inner_rec_last,
      out_stai                  => inner_rec_stai,
      out_endi                  => inner_rec_endi
    );

    dut: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 3
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => inner_rec_valid,
      in_ready                  => inner_rec_ready,
      in_data                   => inner_rec_vec,
      in_strb                   => inner_rec_strb,
      in_last                   => inner_rec_last,
      matcher_str_valid         => inner_matcher_str_valid,
      matcher_str_ready         => inner_matcher_str_ready,
      matcher_str_data          => inner_matcher_str_data,
      matcher_str_mask          => inner_matcher_str_mask,
      matcher_str_last          => inner_matcher_str_last,
      matcher_match_valid       => inner_matcher_match_valid,
      matcher_match_ready       => inner_matcher_match_ready,
      matcher_match             => inner_matcher_match,
      out_valid                 => inner_filter_valid,
      out_ready                 => inner_filter_ready,
      out_data                  => inner_filter_data,
      out_strb                  => inner_filter_strb,
      out_stai                  => inner_filter_stai,
      out_endi                  => inner_filter_endi,
      out_last                  => inner_filter_last
    );

    

    inner_matcher: voltage_matcher
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => inner_matcher_str_valid,
      in_ready                  => inner_matcher_str_ready,
      in_mask                   => inner_matcher_str_mask,
      in_data                   => inner_matcher_str_data,
      in_xlast                  => inner_matcher_str_last,
      out_valid                 => inner_matcher_match_valid,
      out_ready                 => inner_matcher_match_ready,
      out_xmatch                => inner_matcher_match
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
      in_valid                  => inner_filter_valid,
      in_ready                  => inner_filter_ready,
      in_data                   => inner_filter_data,
      in_last                   => inner_filter_last,
      in_strb                   => inner_filter_strb,
      out_data                  => out_data,
      out_valid                 => out_valid,
      out_ready                 => out_ready,
      out_last                  => out_last,
      out_strb                  => out_strb
    );

    out_dvalid <= out_strb;

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
      valid                     => out_valid,
      ready                     => out_ready,
      data                      => out_data,
      dvalid                    => out_dvalid,
      last                      => out_last(2)
    );

   

  random_tc: process is
    variable a        : streamsource_type;
    variable b        : streamsink_type;

  begin
    tc_open("NestedKeyFilter_tc", "test");
    a.initialize("a");
    b.initialize("b");

    a.set_total_cyc(0, 10);
    b.set_valid_cyc(0, 40);
    b.set_total_cyc(0, 40);

    -- This should pass
    a.push_str("{ ");
    a.push_str(" ""voltage"" : {");
    a.push_str("   ""voltage"" : 11,");
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
    a.push_str(" ""voltage"" : {");
    a.push_str("   ""voltage"" : 44,");
    a.push_str("  }");
    a.push_str(",}");

    a.transmit;
    b.unblock;

    tc_wait_for(60 us);

    tc_check(b.pq_ready, true);
    tc_check(b.cq_get_d_nat, 11, "11");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 44, "44");
    
    -- if b.cq_get_last = '0' then
    --   b.cq_next;
    -- end if;
    -- tc_check(b.cq_get_last, '1', "Outermost nesting level last");


    tc_pass;
    wait;
  end process;

end test_case;