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
use work.trip_report_pkg.all;


entity trip_report_tc is
end trip_report_tc;

architecture test_case of trip_report_tc is

  signal clk              : std_logic;
  signal reset            : std_logic;

  constant EPC                   : integer := 8;
  constant INTEGER_WIDTH         : integer := 64;
  constant INT_P_PIPELINE_STAGES : integer := 4;

  signal in_valid         : std_logic;
  signal in_ready         : std_logic;
  signal in_dvalid        : std_logic;
  signal in_last          : std_logic;
  signal in_data          : std_logic_vector(EPC*8-1 downto 0);
  signal in_count         : std_logic_vector(log2ceil(EPC+1)-1 downto 0);
  signal in_strb          : std_logic_vector(EPC-1 downto 0);
  signal in_endi          : std_logic_vector(log2ceil(EPC+1)-1 downto 0) := (others => '1');
  signal in_stai          : std_logic_vector(log2ceil(EPC+1)-1 downto 0) := (others => '0');

  signal adv_last         : std_logic_vector(EPC*2-1 downto 0) := (others => '0');


  --Integer fields
  signal timezone_ready       : std_logic;
  signal timezone_valid       : std_logic;
  signal timezone_empty       : std_logic;
  signal timezone_dvalid      : std_logic;
  signal timezone_data        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal timezone_last        : std_logic_vector(1 downto 0);

begin

  clkgen: ClockGen_mdl
    port map (
      clk                       => clk,
      reset                     => reset
    );

  in_source: StreamSource_mdl
    generic map (
      NAME                      => "src",
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
              EPC*2), to_integer(unsigned(in_endi(log2ceil(EPC)-1 downto 0))*2+1)));

    record_parser_i: TripReportParser
    generic map (
      EPC     => EPC,
      TIMEZONE_INT_WIDTH              => INTEGER_WIDTH,
      TIMEZONE_INT_P_PIPELINE_STAGES  => INT_P_PIPELINE_STAGES,
      END_REQ_EN                      => false
    )
    port map (
      clk                             => clk,
      reset                           => reset,
      in_valid                        => in_valid,
      in_ready                        => in_ready,
      in_data                         => in_data,
      in_strb                         => in_strb,
      in_last                         => adv_last,
      timezone_data                   => timezone_data,
      timezone_valid                  => timezone_valid,
      timezone_ready                  => timezone_ready,
      timezone_last                   => timezone_last,
      timezone_empty                  => timezone_empty
    );

    timezone_dvalid <= not timezone_empty;

    timezone_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "timezone_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => timezone_valid,
      ready                     => timezone_ready,
      data                      => timezone_data,
      dvalid                    => timezone_dvalid
    );

  random_tc: process is
    variable src                    : streamsource_type;
    variable timezone_sink          : streamsink_type;

  begin
    tc_open("BattSchemaParser", "test");
    src.initialize("src");
    timezone_sink.initialize("timezone_sink");

    src.push_str("{ ");
    src.push_str(" ""timezone"" : 11,");
    src.push_str(" }");

    src.push_str("{ ");
    src.push_str(" ""timezone"" : 22,");
    src.push_str(" }");

    src.transmit;
    timezone_sink.unblock;

    tc_wait_for(2 us);

    tc_check(timezone_sink.pq_ready, true);
    while not timezone_sink.cq_get_dvalid loop
      timezone_sink.cq_next;
    end loop;
    tc_check(timezone_sink.cq_get_d_nat, 11, "11");
    timezone_sink.cq_next;
    while not timezone_sink.cq_get_dvalid loop
      timezone_sink.cq_next;
    end loop;
    tc_check(timezone_sink.cq_get_d_nat, 22, "22");


    tc_pass;
    wait;
  end process;

end test_case;