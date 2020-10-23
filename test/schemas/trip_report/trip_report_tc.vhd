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


  -- 
  -- INTEGER FIELDS
  --
  signal timezone_ready             : std_logic;
  signal timezone_valid             : std_logic;
  signal timezone_empty             : std_logic;
  signal timezone_dvalid            : std_logic;
  signal timezone_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal timezone_last              : std_logic_vector(1 downto 0);

  signal vin_ready                  : std_logic;
  signal vin_valid                  : std_logic;
  signal vin_empty                  : std_logic;
  signal vin_dvalid                 : std_logic;
  signal vin_data                   : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal vin_last                   : std_logic_vector(1 downto 0);

  signal odometer_ready             : std_logic;
  signal odometer_valid             : std_logic;
  signal odometer_empty             : std_logic;
  signal odometer_dvalid            : std_logic;
  signal odometer_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal odometer_last              : std_logic_vector(1 downto 0);

  signal avg_speed_ready            : std_logic;
  signal avg_speed_valid            : std_logic;
  signal avg_speed_empty            : std_logic;
  signal avg_speed_dvalid           : std_logic;
  signal avg_speed_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal avg_speed_last             : std_logic_vector(1 downto 0);

  signal s_acc_dec_ready            : std_logic;
  signal s_acc_dec_valid            : std_logic;
  signal s_acc_dec_empty            : std_logic;
  signal s_acc_dec_dvalid           : std_logic;
  signal s_acc_dec_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal s_acc_dec_last             : std_logic_vector(1 downto 0);

  signal e_spd_chg_ready            : std_logic;
  signal e_spd_chg_valid            : std_logic;
  signal e_spd_chg_empty            : std_logic;
  signal e_spd_chg_dvalid           : std_logic;
  signal e_spd_chg_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal e_spd_chg_last             : std_logic_vector(1 downto 0);

  -- 
  -- BOOLEAN FIELDS
  --
  signal hyper_miling_valid         : std_logic;
  signal hyper_miling_ready         : std_logic;
  signal hyper_miling_data          : std_logic;
  signal hyper_miling_empty         : std_logic;
  signal hyper_miling_dvalid        : std_logic;
  signal hyper_miling_last          : std_logic_vector(1 downto 0);

  signal orientation_valid          : std_logic;
  signal orientation_ready          : std_logic;
  signal orientation_data           : std_logic;
  signal orientation_empty          : std_logic;
  signal orientation_dvalid         : std_logic;
  signal orientation_last           : std_logic_vector(1 downto 0);
  

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

      -- 
      -- INTEGER FIELDS
      --
      TIMEZONE_INT_WIDTH                    => INTEGER_WIDTH,
      TIMEZONE_INT_P_PIPELINE_STAGES        => INT_P_PIPELINE_STAGES,
      TIMEZONE_BUFFER_D                     => 1,
      
      VIN_INT_WIDTH                         => INTEGER_WIDTH,
      VIN_INT_P_PIPELINE_STAGES             => INT_P_PIPELINE_STAGES,
      VIN_BUFFER_D                          => 1,

      ODOMETER_INT_WIDTH                    => INTEGER_WIDTH,
      ODOMETER_INT_P_PIPELINE_STAGES        => INT_P_PIPELINE_STAGES,
      ODOMETER_BUFFER_D                     => 1,

      AVG_SPEED_INT_WIDTH                   => INTEGER_WIDTH,
      AVG_SPEED_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      AVG_SPEED_BUFFER_D                    => 1,

      S_ACC_DEC_INT_WIDTH                   => INTEGER_WIDTH,
      S_ACC_DEC_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      S_ACC_DEC_BUFFER_D                    => 1,

      E_SPD_CHG_INT_WIDTH                   => INTEGER_WIDTH,
      E_SPD_CHG_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      E_SPD_CHG_BUFFER_D                    => 1,

      -- 
      -- BOOLEAN FIELDS
      --
      HYPER_MILING_BUFFER_D                 => 1,
      ORIENTATION_BUFFER_D                  => 1,
      
      END_REQ_EN                            => false
    )
    port map (
      clk                                   => clk,
      reset                                 => reset,
      in_valid                              => in_valid,
      in_ready                              => in_ready,
      in_data                               => in_data,
      in_strb                               => in_strb,
      in_last                               => adv_last,
      timezone_data                         => timezone_data,
      timezone_valid                        => timezone_valid,
      timezone_ready                        => timezone_ready,
      timezone_last                         => timezone_last,
      timezone_empty                        => timezone_empty,
    
      vin_data                              => vin_data,
      vin_valid                             => vin_valid,
      vin_ready                             => vin_ready,
      vin_last                              => vin_last,
      vin_empty                             => vin_empty,

      odometer_data                         => odometer_data,
      odometer_valid                        => odometer_valid,
      odometer_ready                        => odometer_ready,
      odometer_last                         => odometer_last,
      odometer_empty                        => odometer_empty,

      avg_speed_data                        => avg_speed_data,
      avg_speed_valid                       => avg_speed_valid,
      avg_speed_ready                       => avg_speed_ready,
      avg_speed_last                        => avg_speed_last,
      avg_speed_empty                       => avg_speed_empty,

      s_acc_dec_data                        => s_acc_dec_data,
      s_acc_dec_valid                       => s_acc_dec_valid,
      s_acc_dec_ready                       => s_acc_dec_ready,
      s_acc_dec_last                        => s_acc_dec_last,
      s_acc_dec_empty                       => s_acc_dec_empty,

      e_spd_chg_data                        => e_spd_chg_data,
      e_spd_chg_valid                       => e_spd_chg_valid,
      e_spd_chg_ready                       => e_spd_chg_ready,
      e_spd_chg_last                        => e_spd_chg_last,
      e_spd_chg_empty                       => e_spd_chg_empty,

      hyper_miling_data                     => hyper_miling_data,
      hyper_miling_valid                    => hyper_miling_valid,
      hyper_miling_ready                    => hyper_miling_ready,
      hyper_miling_last                     => hyper_miling_last,
      hyper_miling_empty                    => hyper_miling_empty,

      orientation_data                      => orientation_data,
      orientation_valid                     => orientation_valid,
      orientation_ready                     => orientation_ready,
      orientation_last                      => orientation_last,
      orientation_empty                     => orientation_empty
      
    );

    -- 
    -- INTEGER FIELDS
    --
    timezone_dvalid <= not timezone_empty;
    vin_dvalid <= not vin_empty;
    odometer_dvalid <= not odometer_empty;
    avg_speed_dvalid <= not avg_speed_empty;
    s_acc_dec_dvalid <= not s_acc_dec_empty;
    e_spd_chg_dvalid <= not e_spd_chg_empty;

    -- 
    -- BOOLEAN FIELDS
    --
    hyper_miling_dvalid <= not hyper_miling_empty;
    orientation_dvalid <= not orientation_empty;

    -- 
    -- INTEGER FIELDS
    --
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

    vin_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "vin_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => vin_valid,
      ready                     => vin_ready,
      data                      => vin_data,
      dvalid                    => vin_dvalid
    );

    odometer_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "odometer_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => odometer_valid,
      ready                     => odometer_ready,
      data                      => odometer_data,
      dvalid                    => odometer_dvalid
    );

    avg_speed_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "avg_speed_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => avg_speed_valid,
      ready                     => avg_speed_ready,
      data                      => avg_speed_data,
      dvalid                    => avg_speed_dvalid
    );

    s_acc_dec_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "s_acc_dec_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => s_acc_dec_valid,
      ready                     => s_acc_dec_ready,
      data                      => s_acc_dec_data,
      dvalid                    => s_acc_dec_dvalid
    );

    e_spd_chg_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "e_spd_chg_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => e_spd_chg_valid,
      ready                     => e_spd_chg_ready,
      data                      => e_spd_chg_data,
      dvalid                    => e_spd_chg_dvalid
    );

    -- 
    -- BOOLEAN FIELDS
    --
    hyper_miling_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "hyper_miling_sink",
      ELEMENT_WIDTH             => 1,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => hyper_miling_valid,
      ready                     => hyper_miling_ready,
      data(0)                   => hyper_miling_data,
      dvalid                    => hyper_miling_dvalid
    );

    orientation_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "orientation_sink",
      ELEMENT_WIDTH             => 1,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => orientation_valid,
      ready                     => orientation_ready,
      data(0)                   => orientation_data,
      dvalid                    => orientation_dvalid
    );

  random_tc: process is
    variable src                    : streamsource_type;

    -- 
    -- INTEGER FIELDS
    --
    variable timezone_sink          : streamsink_type;
    variable vin_sink               : streamsink_type;
    variable odometer_sink          : streamsink_type;
    variable avg_speed_sink         : streamsink_type;
    variable s_acc_dec_sink         : streamsink_type;
    variable e_spd_chg_sink         : streamsink_type;

    -- 
    -- BOOLEAN FIELDS
    --
    variable hyper_miling_sink      : streamsink_type;
    variable orientation_sink       : streamsink_type;

  begin
    tc_open("TripReportParser", "test");

    src.initialize("src");

    -- 
    -- INTEGER FIELDS
    --
    timezone_sink.initialize("timezone_sink");
    vin_sink.initialize("vin_sink");
    odometer_sink.initialize("odometer_sink");
    avg_speed_sink.initialize("avg_speed_sink");
    s_acc_dec_sink.initialize("s_acc_dec_sink");
    e_spd_chg_sink.initialize("e_spd_chg_sink");

    -- 
    -- BOOLEAN FIELDS
    --
    hyper_miling_sink.initialize("hyper_miling_sink");
    orientation_sink.initialize("orientation_sink");

    src.push_str("{ ");
    src.push_str(" ""timezone"" : 42,");
    src.push_str(" ""vin"" : 124,");
    src.push_str(" ""odometer"" : 68000,");
    src.push_str(" ""avg speed"" : 54,");
    src.push_str(" ""successive accel decel"" : 687,");
    src.push_str(" ""excessive speed changes"" : 99,");
    src.push_str(" ""hyper-miling"" : true,");
    src.push_str(" ""orientation"" : false,");
    src.push_str(" }");

    src.push_str("{ ");
    src.push_str(" ""timezone"" : 68,");
    src.push_str(" ""vin"" : 125,");
    src.push_str(" ""odometer"" : 76000,");
    src.push_str(" ""avg speed"" : 62,");
    src.push_str(" ""successive accel decel"" : 4561,");
    src.push_str(" ""excessive speed changes"" : 111,");
    src.push_str(" ""hyper-miling"" : false,");
    src.push_str(" ""orientation"" : true,");
    src.push_str(" }");

    
    
    src.transmit;
    
    -- 
    -- INTEGER FIELDS
    --
    timezone_sink.unblock;
    vin_sink.unblock;
    odometer_sink.unblock;
    avg_speed_sink.unblock;
    s_acc_dec_sink.unblock;
    e_spd_chg_sink.unblock;

    -- 
    -- BOOLEAN FIELDS
    --
    hyper_miling_sink.unblock;
    orientation_sink.unblock;
    

    tc_wait_for(2 us);

    -- 
    -- INTEGER FIELDS
    --

    -- "timezone"
    tc_check(timezone_sink.pq_ready, true);
    while not timezone_sink.cq_get_dvalid loop
      timezone_sink.cq_next;
    end loop;
    tc_check(timezone_sink.cq_get_d_nat, 42, "timezone: 42");
    timezone_sink.cq_next;
    while not timezone_sink.cq_get_dvalid loop
      timezone_sink.cq_next;
    end loop;
    tc_check(timezone_sink.cq_get_d_nat, 68, "timezone: 68");

    -- "vin"
    tc_check(vin_sink.pq_ready, true);
    while not vin_sink.cq_get_dvalid loop
      vin_sink.cq_next;
    end loop;
    tc_check(vin_sink.cq_get_d_nat, 124, "vin: 124");
    vin_sink.cq_next;
    while not vin_sink.cq_get_dvalid loop
      vin_sink.cq_next;
    end loop;
    tc_check(vin_sink.cq_get_d_nat, 125, "vin: 125");

    -- "odometer"
    tc_check(odometer_sink.pq_ready, true);
    while not odometer_sink.cq_get_dvalid loop
      odometer_sink.cq_next;
    end loop;
    tc_check(odometer_sink.cq_get_d_nat, 68000, "odometer: 68000");
    odometer_sink.cq_next;
    while not odometer_sink.cq_get_dvalid loop
      odometer_sink.cq_next;
    end loop;
    tc_check(odometer_sink.cq_get_d_nat, 76000, "odometer: 76000");

    -- "avg speed"
    tc_check(avg_speed_sink.pq_ready, true);
    while not avg_speed_sink.cq_get_dvalid loop
      avg_speed_sink.cq_next;
    end loop;
    tc_check(avg_speed_sink.cq_get_d_nat, 54, "avg speed: 54");
    avg_speed_sink.cq_next;
    while not avg_speed_sink.cq_get_dvalid loop
      avg_speed_sink.cq_next;
    end loop;
    tc_check(avg_speed_sink.cq_get_d_nat, 62, "avg speed: 62");

    -- "successive accel decel"
    tc_check(s_acc_dec_sink.pq_ready, true);
    while not s_acc_dec_sink.cq_get_dvalid loop
      s_acc_dec_sink.cq_next;
    end loop;
    tc_check(s_acc_dec_sink.cq_get_d_nat, 687, "successive accel decel: 687");
    s_acc_dec_sink.cq_next;
    while not s_acc_dec_sink.cq_get_dvalid loop
      s_acc_dec_sink.cq_next;
    end loop;
    tc_check(s_acc_dec_sink.cq_get_d_nat, 4561, "successive accel decel: 4561");

    -- "excessive speed changes"
    tc_check(e_spd_chg_sink.pq_ready, true);
    while not e_spd_chg_sink.cq_get_dvalid loop
      e_spd_chg_sink.cq_next;
    end loop;
    tc_check(e_spd_chg_sink.cq_get_d_nat, 99, "excessive speed changes: 99");
    e_spd_chg_sink.cq_next;
    while not e_spd_chg_sink.cq_get_dvalid loop
      e_spd_chg_sink.cq_next;
    end loop;
    tc_check(e_spd_chg_sink.cq_get_d_nat, 111, "excessive speed changes: 111");

    -- 
    -- BOOLEAN FIELDS
    --

    -- "hyper-miling"
    tc_check(hyper_miling_sink.pq_ready, true);
    while not hyper_miling_sink.cq_get_dvalid loop
      hyper_miling_sink.cq_next;
    end loop;
    tc_check(hyper_miling_sink.cq_get_d_nat, 1, "hyper-miling: true");
    hyper_miling_sink.cq_next;
    while not hyper_miling_sink.cq_get_dvalid loop
      hyper_miling_sink.cq_next;
    end loop;
    tc_check(hyper_miling_sink.cq_get_d_nat, 0, "hyper-miling: false");

    -- "orientation"
    tc_check(orientation_sink.pq_ready, true);
    while not orientation_sink.cq_get_dvalid loop
      orientation_sink.cq_next;
    end loop;
    tc_check(orientation_sink.cq_get_d_nat, 0, "orientation: false");
    orientation_sink.cq_next;
    while not orientation_sink.cq_get_dvalid loop
      orientation_sink.cq_next;
    end loop;
    tc_check(orientation_sink.cq_get_d_nat, 1, "orientation: true");



    tc_pass;
    wait;
  end process;

end test_case;