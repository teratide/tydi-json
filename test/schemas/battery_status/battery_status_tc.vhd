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
use work.battery_status_pkg.all;


entity battery_status_tc is
end battery_status_tc;

architecture test_case of battery_status_tc is

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
  signal out_last        : std_logic_vector(2 downto 0);

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

    record_parser_i: BattSchemaParser
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
    tc_open("BattSchemaParser", "test");
    a.initialize("a");
    b.initialize("b");

    a.push_str("{""voltage"":[1128,1213,1850,429,1770,1683,1483,478,545,1555,867,1495,1398,1380,1753,43811111111]}\n");

    --a.set_total_cyc(0, 20);
    b.set_valid_cyc(0, 20);
    b.set_total_cyc(0, 20);

    a.transmit;
    b.unblock;

    tc_wait_for(10 us);

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
    tc_check(b.cq_get_d_nat, 429, "429");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1770, "1770");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1683, "1683");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1483, "1483");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 478, "478");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 545, "545");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1555, "1555");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 867, "867");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1495, "1495");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1398, "1398");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1380, "1380");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    tc_check(b.cq_get_d_nat, 1753, "1753");
    b.cq_next;
    while not b.cq_get_dvalid loop
      b.cq_next;
    end loop;
    --tc_check(b.cq_get_d_nat, 43811111111, "43811111111");

    tc_pass;
    wait;
  end process;

end test_case;