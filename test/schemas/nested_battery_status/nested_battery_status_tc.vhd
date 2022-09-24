library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.TestCase_pkg.all;
use work.Stream_pkg.all;
use work.ClockGen_pkg.all;
use work.StreamSource_pkg.all;
use work.StreamSink_pkg.all;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;
use work.TestCase_pkg.all;
use work.nested_battery_status_pkg.all;


entity nested_battery_status_tc is
end nested_battery_status_tc;

architecture test_case of nested_battery_status_tc is

  signal clk              : std_logic;
  signal reset            : std_logic;

  constant EPC                   : integer := 2;
  constant INTEGER_WIDTH         : integer := 64;
  constant INT_P_PIPELINE_STAGES : integer := 1;

  signal in_valid         : std_logic;
  signal in_ready         : std_logic;
  signal in_dvalid        : std_logic;
  signal in_last          : std_logic;
  signal in_data          : std_logic_vector(EPC*8-1 downto 0);
  signal in_count         : std_logic_vector(log2ceil(EPC+1)-1 downto 0);
  signal in_strb          : std_logic_vector(EPC-1 downto 0);
  signal in_endi          : std_logic_vector(log2ceil(EPC+1)-1 downto 0) := (others => '1');
  signal in_stai          : std_logic_vector(log2ceil(EPC+1)-1 downto 0) := (others => '0');

  signal adv_last        : std_logic_vector(EPC*2-1 downto 0) := (others => '0');

  signal out_ready       : std_logic;
  signal out_valid       : std_logic;
  signal out_dvalid      : std_logic;
  signal out_strb        : std_logic;
  signal out_data        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal out_last        : std_logic_vector(3 downto 0);

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
              EPC*2), to_integer(unsigned(in_endi)*2+1)));

    record_parser_i: NestedBattSchemaParser
    generic map (
      EPC     => EPC,
      INT_WIDTH                 => INTEGER_WIDTH,
      INT_P_PIPELINE_STAGES     => INT_P_PIPELINE_STAGES,
      END_REQ_EN                => false
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => in_valid,
      in_ready                  => in_ready,
      in_data                   => in_data,
      in_strb                   => in_strb,
      in_last                   => adv_last,
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
      dvalid                    => out_dvalid
    );

  random_tc: process is
    variable a        : streamsource_type;
    variable b        : streamsink_type;

  begin
    tc_open("NestedBattSchemaParser", "test");
    a.initialize("a");
    b.initialize("b");

    -- a.push_str("{""outer"":[{""voltage"":1128},{""voltage"":1213},{""voltage"":1850},{""voltage"":429},{""voltage"":1770},{""voltage"":1683},{""voltage"":1483},{""voltage"":478},{""voltage"":545},{""voltage"":1555},{""voltage"":867},{""voltage"":1495},{""voltage"":1398},{""voltage"":1380},{""voltage"":1753},{""voltage"":43811111111}]}\n");

    a.push_str("{""voltage"": [");
    a.push_str("  {");
    a.push_str("     ""voltage"": 1128,");
    a.push_str("     ""differentkey"": 324,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage"": 1213,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage2"": 999,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage"": 1850,");
    a.push_str("  },");
    a.push_str("], }\n");
    a.push_str("{""voltage2"": [");
    a.push_str("  {");
    a.push_str("     ""voltage"": 1128,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage"": 1213,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage2"": 999,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage"": 1850,");
    a.push_str("  },");
    a.push_str("], }\n");
    a.push_str("{""voltage"": [");
    a.push_str("  {");
    a.push_str("     ""voltage"": 128,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage"": 213,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage2"": 99,");
    a.push_str("  },");
    a.push_str("  {");
    a.push_str("     ""voltage"": 850,");
    a.push_str("  },");
    a.push_str("], }\n");

    a.set_total_cyc(0, 40);
    b.set_valid_cyc(0, 40);
    b.set_total_cyc(0, 40);

    a.transmit;
    b.unblock;

    tc_wait_for(60 us);

    tc_check(b.pq_ready, true);
    tc_check(b.cq_get_d_nat, 1128, "1128");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1213, "1213");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1850, "1850");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 128, "128");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 213, "213");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 850, "850");

    tc_pass;
    wait;
  end process;

end test_case;