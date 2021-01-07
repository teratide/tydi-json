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

  constant EPC                   : integer := 2;
  constant INTEGER_WIDTH         : integer := 64;
  constant INT_P_PIPELINE_STAGES : integer := 4;

  signal clk              : std_logic;
  signal reset            : std_logic;

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
  signal timezone_dvalid            : std_logic;
  signal timezone_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal timezone_last              : std_logic_vector(1 downto 0);
  signal timezone_strb              : std_logic;

  signal vin_ready                  : std_logic;
  signal vin_valid                  : std_logic;
  signal vin_strb                   : std_logic;
  signal vin_dvalid                 : std_logic;
  signal vin_data                   : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal vin_last                   : std_logic_vector(1 downto 0);

  signal odometer_ready             : std_logic;
  signal odometer_valid             : std_logic;
  signal odometer_strb              : std_logic;
  signal odometer_dvalid            : std_logic;
  signal odometer_data              : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal odometer_last              : std_logic_vector(1 downto 0);

  signal avg_speed_ready            : std_logic;
  signal avg_speed_valid            : std_logic;
  signal avg_speed_strb             : std_logic;
  signal avg_speed_dvalid           : std_logic;
  signal avg_speed_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal avg_speed_last             : std_logic_vector(1 downto 0);

  signal s_acc_dec_ready            : std_logic;
  signal s_acc_dec_valid            : std_logic;
  signal s_acc_dec_strb             : std_logic;
  signal s_acc_dec_dvalid           : std_logic;
  signal s_acc_dec_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal s_acc_dec_last             : std_logic_vector(1 downto 0);

  signal e_spd_chg_ready            : std_logic;
  signal e_spd_chg_valid            : std_logic;
  signal e_spd_chg_strb             : std_logic;
  signal e_spd_chg_dvalid           : std_logic;
  signal e_spd_chg_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal e_spd_chg_last             : std_logic_vector(1 downto 0);

  -- 
  -- BOOLEAN FIELDS
  --
  signal hyper_miling_valid         : std_logic;
  signal hyper_miling_ready         : std_logic;
  signal hyper_miling_data          : std_logic;
  signal hyper_miling_strb          : std_logic;
  signal hyper_miling_dvalid        : std_logic;
  signal hyper_miling_last          : std_logic_vector(1 downto 0);

  signal orientation_valid          : std_logic;
  signal orientation_ready          : std_logic;
  signal orientation_data           : std_logic;
  signal orientation_strb           : std_logic;
  signal orientation_dvalid         : std_logic;
  signal orientation_last           : std_logic_vector(1 downto 0);
  
  -- 
  -- INTEGER ARRAY FIELDS
  --
  signal secs_in_b_ready            : std_logic;
  signal secs_in_b_valid            : std_logic;
  signal secs_in_b_strb             : std_logic;
  signal secs_in_b_dvalid           : std_logic;
  signal secs_in_b_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal secs_in_b_last             : std_logic_vector(2 downto 0);

  signal miles_in_time_ready        : std_logic;
  signal miles_in_time_valid        : std_logic;
  signal miles_in_time_strb         : std_logic;
  signal miles_in_time_dvalid       : std_logic;
  signal miles_in_time_data         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal miles_in_time_last         : std_logic_vector(2 downto 0);

  signal const_spd_m_in_b_ready     : std_logic;
  signal const_spd_m_in_b_valid     : std_logic;
  signal const_spd_m_in_b_strb      : std_logic;
  signal const_spd_m_in_b_dvalid    : std_logic;
  signal const_spd_m_in_b_data      : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal const_spd_m_in_b_last      : std_logic_vector(2 downto 0);

  signal var_spd_m_in_b_ready       : std_logic;
  signal var_spd_m_in_b_valid       : std_logic;
  signal var_spd_m_in_b_strb        : std_logic;
  signal var_spd_m_in_b_dvalid      : std_logic;
  signal var_spd_m_in_b_data        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal var_spd_m_in_b_last        : std_logic_vector(2 downto 0);

  signal seconds_decel_ready        : std_logic;
  signal seconds_decel_valid        : std_logic;
  signal seconds_decel_strb         : std_logic;
  signal seconds_decel_dvalid       : std_logic;
  signal seconds_decel_data         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal seconds_decel_last         : std_logic_vector(2 downto 0);

  signal seconds_accel_ready        : std_logic;
  signal seconds_accel_valid        : std_logic;
  signal seconds_accel_strb         : std_logic;
  signal seconds_accel_dvalid       : std_logic;
  signal seconds_accel_data         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal seconds_accel_last         : std_logic_vector(2 downto 0);

  signal brk_m_t_10s_ready          : std_logic;
  signal brk_m_t_10s_valid          : std_logic;
  signal brk_m_t_10s_strb           : std_logic;
  signal brk_m_t_10s_dvalid         : std_logic;
  signal brk_m_t_10s_data           : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal brk_m_t_10s_last           : std_logic_vector(2 downto 0);

  signal accel_m_t_10s_ready        : std_logic;
  signal accel_m_t_10s_valid        : std_logic;
  signal accel_m_t_10s_strb         : std_logic;
  signal accel_m_t_10s_dvalid       : std_logic;
  signal accel_m_t_10s_data         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal accel_m_t_10s_last         : std_logic_vector(2 downto 0);

  signal small_spd_v_m_ready        : std_logic;
  signal small_spd_v_m_valid        : std_logic;
  signal small_spd_v_m_strb         : std_logic;
  signal small_spd_v_m_dvalid       : std_logic;
  signal small_spd_v_m_data         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal small_spd_v_m_last         : std_logic_vector(2 downto 0);

  signal large_spd_v_m_ready        : std_logic;
  signal large_spd_v_m_valid        : std_logic;
  signal large_spd_v_m_strb         : std_logic;
  signal large_spd_v_m_dvalid       : std_logic;
  signal large_spd_v_m_data         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal large_spd_v_m_last         : std_logic_vector(2 downto 0);

  -- 
  -- STRING FIELDS
  --
  signal timestamp_valid            : std_logic;
  signal timestamp_ready            : std_logic;
  signal timestamp_data             : std_logic_vector(8*EPC-1 downto 0);
  signal timestamp_last             : std_logic_vector(3*EPC-1 downto 0);
  signal timestamp_stai             : std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
  signal timestamp_endi             : std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
  signal timestamp_strb             : std_logic_vector(EPC-1 downto 0);

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
              EPC*2), to_integer((unsigned(in_endi))*2+1)));

    dut: TripReportParser
    generic map (
      EPC     => EPC,

      -- 
      -- INTEGER FIELDS
      --
      TIMEZONE_INT_WIDTH                        => INTEGER_WIDTH,
      TIMEZONE_INT_P_PIPELINE_STAGES            => INT_P_PIPELINE_STAGES,
      TIMEZONE_BUFFER_D                         => 1,

      VIN_INT_WIDTH                             => INTEGER_WIDTH,
      VIN_INT_P_PIPELINE_STAGES                 => INT_P_PIPELINE_STAGES,
      VIN_BUFFER_D                              => 1,

      ODOMETER_INT_WIDTH                        => INTEGER_WIDTH,
      ODOMETER_INT_P_PIPELINE_STAGES            => INT_P_PIPELINE_STAGES,
      ODOMETER_BUFFER_D                         => 1,

      AVG_SPEED_INT_WIDTH                       => INTEGER_WIDTH,
      AVG_SPEED_INT_P_PIPELINE_STAGES           => INT_P_PIPELINE_STAGES,
      AVG_SPEED_BUFFER_D                        => 1,

      S_ACC_DEC_INT_WIDTH                       => INTEGER_WIDTH,
      S_ACC_DEC_INT_P_PIPELINE_STAGES           => INT_P_PIPELINE_STAGES,
      S_ACC_DEC_BUFFER_D                        => 1,

      E_SPD_CHG_INT_WIDTH                       => INTEGER_WIDTH,
      E_SPD_CHG_INT_P_PIPELINE_STAGES           => INT_P_PIPELINE_STAGES,
      E_SPD_CHG_BUFFER_D                        => 1,

      --    
      -- BOOLEAN FIELDS   
      --    
      HYPER_MILING_BUFFER_D                     => 1,
      ORIENTATION_BUFFER_D                      => 1,

      --    
      -- INTEGER ARRAY FIELDS   
      --    
      SECS_IN_B_INT_WIDTH                       => INTEGER_WIDTH,
      SECS_IN_B_INT_P_PIPELINE_STAGES           => INT_P_PIPELINE_STAGES,
      SECS_IN_B_BUFFER_D                        => 1,

      MILES_IN_TIME_INT_WIDTH                   => INTEGER_WIDTH,
      MILES_IN_TIME_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      MILES_IN_TIME_BUFFER_D                    => 1,

      CONST_SPD_M_IN_B_INT_WIDTH                => INTEGER_WIDTH,
      CONST_SPD_M_IN_B_INT_P_PIPELINE_STAGES    => INT_P_PIPELINE_STAGES,
      CONST_SPD_M_IN_B_BUFFER_D                 => 1,

      VAR_SPD_M_IN_B_INT_WIDTH                  => INTEGER_WIDTH,
      VAR_SPD_M_IN_B_INT_P_PIPELINE_STAGES      => INT_P_PIPELINE_STAGES,
      VAR_SPD_M_IN_B_BUFFER_D                   => 1,

      SECONDS_DECEL_INT_WIDTH                   => INTEGER_WIDTH,
      SECONDS_DECEL_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      SECONDS_DECEL_BUFFER_D                    => 1,

      SECONDS_ACCEL_INT_WIDTH                   => INTEGER_WIDTH,
      SECONDS_ACCEL_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      SECONDS_ACCEL_BUFFER_D                    => 1,

      BRK_M_T_10S_INT_WIDTH                     => INTEGER_WIDTH,
      BRK_M_T_10S_INT_P_PIPELINE_STAGES         => INT_P_PIPELINE_STAGES,
      BRK_M_T_10S_BUFFER_D                      => 1,

      ACCEL_M_T_10S_INT_WIDTH                   => INTEGER_WIDTH,
      ACCEL_M_T_10S_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      ACCEL_M_T_10S_BUFFER_D                    => 1,

      SMALL_SPD_V_M_INT_WIDTH                   => INTEGER_WIDTH,
      SMALL_SPD_V_M_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      SMALL_SPD_V_M_BUFFER_D                    => 1,

      LARGE_SPD_V_M_INT_WIDTH                   => INTEGER_WIDTH,
      LARGE_SPD_V_M_INT_P_PIPELINE_STAGES       => INT_P_PIPELINE_STAGES,
      LARGE_SPD_V_M_BUFFER_D                    => 1,

      END_REQ_EN                                => false
    )   
    port map (    
      clk                                       => clk,
      reset                                     => reset,
      in_valid                                  => in_valid,
      in_ready                                  => in_ready,
      in_data                                   => in_data,
      in_strb                                   => in_strb,
      in_last                                   => adv_last,

      timezone_data                             => timezone_data,
      timezone_valid                            => timezone_valid,
      timezone_ready                            => timezone_ready,
      timezone_last                             => timezone_last,
      timezone_strb                             => timezone_strb,

      vin_data                                  => vin_data,
      vin_valid                                 => vin_valid,
      vin_ready                                 => vin_ready,
      vin_last                                  => vin_last,
      vin_strb                                  => vin_strb,

      odometer_data                             => odometer_data,
      odometer_valid                            => odometer_valid,
      odometer_ready                            => odometer_ready,
      odometer_last                             => odometer_last,
      odometer_strb                             => odometer_strb,

      avg_speed_data                            => avg_speed_data,
      avg_speed_valid                           => avg_speed_valid,
      avg_speed_ready                           => avg_speed_ready,
      avg_speed_last                            => avg_speed_last,
      avg_speed_strb                            => avg_speed_strb,

      s_acc_dec_data                            => s_acc_dec_data,
      s_acc_dec_valid                           => s_acc_dec_valid,
      s_acc_dec_ready                           => s_acc_dec_ready,
      s_acc_dec_last                            => s_acc_dec_last,
      s_acc_dec_strb                            => s_acc_dec_strb,

      e_spd_chg_data                            => e_spd_chg_data,
      e_spd_chg_valid                           => e_spd_chg_valid,
      e_spd_chg_ready                           => e_spd_chg_ready,
      e_spd_chg_last                            => e_spd_chg_last,
      e_spd_chg_strb                            => e_spd_chg_strb,

      hyper_miling_data                         => hyper_miling_data,
      hyper_miling_valid                        => hyper_miling_valid,
      hyper_miling_ready                        => hyper_miling_ready,
      hyper_miling_last                         => hyper_miling_last,
      hyper_miling_strb                         => hyper_miling_strb,

      orientation_data                          => orientation_data,
      orientation_valid                         => orientation_valid,
      orientation_ready                         => orientation_ready,
      orientation_last                          => orientation_last,
      orientation_strb                          => orientation_strb,

      secs_in_b_data                            => secs_in_b_data,
      secs_in_b_valid                           => secs_in_b_valid,
      secs_in_b_ready                           => secs_in_b_ready,
      secs_in_b_last                            => secs_in_b_last,
      secs_in_b_strb                            => secs_in_b_strb,

      miles_in_time_data                        => miles_in_time_data,
      miles_in_time_valid                       => miles_in_time_valid,
      miles_in_time_ready                       => miles_in_time_ready,
      miles_in_time_last                        => miles_in_time_last,
      miles_in_time_strb                        => miles_in_time_strb,

      const_spd_m_in_b_data                     => const_spd_m_in_b_data,
      const_spd_m_in_b_valid                    => const_spd_m_in_b_valid,
      const_spd_m_in_b_ready                    => const_spd_m_in_b_ready,
      const_spd_m_in_b_last                     => const_spd_m_in_b_last,
      const_spd_m_in_b_strb                     => const_spd_m_in_b_strb,

      var_spd_m_in_b_data                       => var_spd_m_in_b_data,
      var_spd_m_in_b_valid                      => var_spd_m_in_b_valid,
      var_spd_m_in_b_ready                      => var_spd_m_in_b_ready,
      var_spd_m_in_b_last                       => var_spd_m_in_b_last,
      var_spd_m_in_b_strb                       => var_spd_m_in_b_strb,

      seconds_decel_data                        => seconds_decel_data,
      seconds_decel_valid                       => seconds_decel_valid,
      seconds_decel_ready                       => seconds_decel_ready,
      seconds_decel_last                        => seconds_decel_last,
      seconds_decel_strb                        => seconds_decel_strb,

      seconds_accel_data                        => seconds_accel_data,
      seconds_accel_valid                       => seconds_accel_valid,
      seconds_accel_ready                       => seconds_accel_ready,
      seconds_accel_last                        => seconds_accel_last,
      seconds_accel_strb                        => seconds_accel_strb,

      brk_m_t_10s_data                          => brk_m_t_10s_data,
      brk_m_t_10s_valid                         => brk_m_t_10s_valid,
      brk_m_t_10s_ready                         => brk_m_t_10s_ready,
      brk_m_t_10s_last                          => brk_m_t_10s_last,
      brk_m_t_10s_strb                          => brk_m_t_10s_strb,

      accel_m_t_10s_data                        => accel_m_t_10s_data,
      accel_m_t_10s_valid                       => accel_m_t_10s_valid,
      accel_m_t_10s_ready                       => accel_m_t_10s_ready,
      accel_m_t_10s_last                        => accel_m_t_10s_last,
      accel_m_t_10s_strb                        => accel_m_t_10s_strb,

      small_spd_v_m_data                        => small_spd_v_m_data,
      small_spd_v_m_valid                       => small_spd_v_m_valid,
      small_spd_v_m_ready                       => small_spd_v_m_ready,
      small_spd_v_m_last                        => small_spd_v_m_last,
      small_spd_v_m_strb                        => small_spd_v_m_strb,

      large_spd_v_m_data                        => large_spd_v_m_data,
      large_spd_v_m_valid                       => large_spd_v_m_valid,
      large_spd_v_m_ready                       => large_spd_v_m_ready,
      large_spd_v_m_last                        => large_spd_v_m_last,
      large_spd_v_m_strb                        => large_spd_v_m_strb,

      timestamp_data                            => timestamp_data,
      timestamp_valid                           => timestamp_valid,
      timestamp_ready                           => timestamp_ready,
      timestamp_last                            => timestamp_last
      );

    -- String fields are not tested currently
    timestamp_ready <= '1';

    -- 
    -- INTEGER FIELDS
    --
    timezone_dvalid <= timezone_strb;
    vin_dvalid <= vin_strb;
    odometer_dvalid <= odometer_strb;
    avg_speed_dvalid <= avg_speed_strb;
    s_acc_dec_dvalid <= s_acc_dec_strb;
    e_spd_chg_dvalid <= e_spd_chg_strb;

    -- 
    -- BOOLEAN FIELDS
    --
    hyper_miling_dvalid <= hyper_miling_strb;
    orientation_dvalid <= orientation_strb;

    -- 
    -- INTEGER ARRAY FIELDS
    --
    secs_in_b_dvalid <= secs_in_b_strb;
    miles_in_time_dvalid <= miles_in_time_strb;
    const_spd_m_in_b_dvalid <= const_spd_m_in_b_strb;
    var_spd_m_in_b_dvalid <= var_spd_m_in_b_strb;
    seconds_decel_dvalid <= seconds_decel_strb;
    seconds_accel_dvalid <= seconds_accel_strb;
    brk_m_t_10s_dvalid <= brk_m_t_10s_strb;
    accel_m_t_10s_dvalid <= accel_m_t_10s_strb;
    small_spd_v_m_dvalid <= small_spd_v_m_strb;
    large_spd_v_m_dvalid <= large_spd_v_m_strb;


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

    secs_in_b_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "secs_in_b_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => secs_in_b_valid,
      ready                     => secs_in_b_ready,
      data                      => secs_in_b_data,
      dvalid                    => secs_in_b_dvalid
    );

    miles_in_time_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "miles_in_time_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => miles_in_time_valid,
      ready                     => miles_in_time_ready,
      data                      => miles_in_time_data,
      dvalid                    => miles_in_time_dvalid
    );

    const_spd_m_in_b_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "const_spd_m_in_b_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => const_spd_m_in_b_valid,
      ready                     => const_spd_m_in_b_ready,
      data                      => const_spd_m_in_b_data,
      dvalid                    => const_spd_m_in_b_dvalid
    );

    var_spd_m_in_b_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "var_spd_m_in_b_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => var_spd_m_in_b_valid,
      ready                     => var_spd_m_in_b_ready,
      data                      => var_spd_m_in_b_data,
      dvalid                    => var_spd_m_in_b_dvalid
    );

    seconds_decel_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "seconds_decel_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => seconds_decel_valid,
      ready                     => seconds_decel_ready,
      data                      => seconds_decel_data,
      dvalid                    => seconds_decel_dvalid
    );

    seconds_accel_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "seconds_accel_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => seconds_accel_valid,
      ready                     => seconds_accel_ready,
      data                      => seconds_accel_data,
      dvalid                    => seconds_accel_dvalid
    );

    brk_m_t_10s_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "brk_m_t_10s_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => brk_m_t_10s_valid,
      ready                     => brk_m_t_10s_ready,
      data                      => brk_m_t_10s_data,
      dvalid                    => brk_m_t_10s_dvalid
    );

    accel_m_t_10s_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "accel_m_t_10s_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => accel_m_t_10s_valid,
      ready                     => accel_m_t_10s_ready,
      data                      => accel_m_t_10s_data,
      dvalid                    => accel_m_t_10s_dvalid
    );

    small_spd_v_m_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "small_spd_v_m_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => small_spd_v_m_valid,
      ready                     => small_spd_v_m_ready,
      data                      => small_spd_v_m_data,
      dvalid                    => small_spd_v_m_dvalid
    );

    large_spd_v_m_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "large_spd_v_m_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => large_spd_v_m_valid,
      ready                     => large_spd_v_m_ready,
      data                      => large_spd_v_m_data,
      dvalid                    => large_spd_v_m_dvalid
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

    -- 
    -- INTEGER ARRAY FIELDS
    --
    variable secs_in_b_sink         : streamsink_type;
    variable miles_in_time_sink     : streamsink_type;
    variable const_spd_m_in_b_sink  : streamsink_type;
    variable var_spd_m_in_b_sink    : streamsink_type;
    variable seconds_decel_sink     : streamsink_type;
    variable seconds_accel_sink     : streamsink_type;
    variable brk_m_t_10s_sink       : streamsink_type;
    variable accel_m_t_10s_sink     : streamsink_type;
    variable small_spd_v_m_sink     : streamsink_type;
    variable large_spd_v_m_sink     : streamsink_type;
    

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

    -- 
    -- INTEGER ARRAY FIELDS
    --
    secs_in_b_sink.initialize("secs_in_b_sink");
    miles_in_time_sink.initialize("miles_in_time_sink");
    const_spd_m_in_b_sink.initialize("const_spd_m_in_b_sink");
    var_spd_m_in_b_sink.initialize("var_spd_m_in_b_sink");
    seconds_decel_sink.initialize("seconds_decel_sink");
    seconds_accel_sink.initialize("seconds_accel_sink");
    brk_m_t_10s_sink.initialize("brk_m_t_10s_sink");
    accel_m_t_10s_sink.initialize("accel_m_t_10s_sink");
    small_spd_v_m_sink.initialize("small_spd_v_m_sink");
    large_spd_v_m_sink.initialize("large_spd_v_m_sink");


    -- 
    -- TEST DATA
    --
    src.push_str("{ ");
    src.push_str(" ""timezone"" : 42,");
    src.push_str(" ""timestamp"" : ""2005-09-09T11:59:06-10:00"",");
    src.push_str(" ""vin"" : 124,");
    src.push_str(" ""odometer"" : 68000,");
    src.push_str(" ""avg speed"" : 54,");
    src.push_str(" ""successive accel decel"" : 687,");
    src.push_str(" ""excessive speed changes"" : 99,");
    src.push_str(" ""hyper-miling"" : true,");
    src.push_str(" ""orientation"" : false,");
    src.push_str(" ""seconds in band"" : [10, 20, 30],");
    src.push_str(" ""miles in time range"" : [1191, 524, 1722],");
    src.push_str(" ""constant speed miles in band"" : [1922, 1889, 679],");
    src.push_str(" ""varying speed miles in band"" : [99, 431, 1647],");
    src.push_str(" ""seconds decel"" : [98, 1857, 675],");
    src.push_str(" ""seconds accel"" : [387, 1379, 1950],");
    src.push_str(" ""braking more than 10s"" : [1678, 1880, 308],");
    src.push_str(" ""accel more than 10s"" : [147, 845, 923],");
    src.push_str(" ""small speed var miles"" : [867, 1460, 1661],");
    src.push_str(" ""large speed var miles"" : [1580, 1387, 1713],");
    src.push_str(" }\n");

    src.push_str("{ ");
    src.push_str(" ""timezone"" : 68,");
    src.push_str(" ""timestamp"" : ""2005-09-09T11:59:06-11:00"",");
    src.push_str(" ""vin"" : 125,");
    src.push_str(" ""odometer"" : 76000,");
    src.push_str(" ""avg speed"" : 62,");
    src.push_str(" ""successive accel decel"" : 4561,");
    src.push_str(" ""excessive speed changes"" : 111,");
    src.push_str(" ""hyper-miling"" : false,");
    src.push_str(" ""orientation"" : true,");
    src.push_str(" ""seconds in band"" : [40, 50, 60],");
    src.push_str(" ""miles in time range"" : [398, 1648, 755],");
    src.push_str(" ""constant speed miles in band"" : [140, 1441, 210],");
    src.push_str(" ""varying speed miles in band"" : [1414, 562, 83],");
    src.push_str(" ""seconds decel"" : [1749, 581, 896],");
    src.push_str(" ""seconds accel"" : [1205, 1442, 1507],");
    src.push_str(" ""braking more than 10s"" : [1065, 1541, 717],");
    src.push_str(" ""accel more than 10s"" : [254, 1223, 1427],");
    src.push_str(" ""small speed var miles"" : [1291, 1631, 410],");
    src.push_str(" ""large speed var miles"" : [360, 1837, 92],");
    src.push_str(" }\n");

    
    
    
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

    -- 
    -- INTEGER ARRAY FIELDS
    --
    secs_in_b_sink.unblock;
    miles_in_time_sink.unblock;
    const_spd_m_in_b_sink.unblock;
    var_spd_m_in_b_sink.unblock;
    seconds_decel_sink.unblock;
    seconds_accel_sink.unblock;
    brk_m_t_10s_sink.unblock;
    accel_m_t_10s_sink.unblock;
    small_spd_v_m_sink.unblock;
    large_spd_v_m_sink.unblock;
    

    tc_wait_for(10 us);

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

    -- 
    -- INTEGER ARRAY FIELDS
    --
    -- "seconds in band"
    tc_check(secs_in_b_sink.pq_ready, true);
    while not secs_in_b_sink.cq_get_dvalid loop
      secs_in_b_sink.cq_next;
    end loop;
    tc_check(secs_in_b_sink.cq_get_d_nat, 10, "seconds in band: 10");
    secs_in_b_sink.cq_next;
    while not secs_in_b_sink.cq_get_dvalid loop
      secs_in_b_sink.cq_next;
    end loop;
    tc_check(secs_in_b_sink.cq_get_d_nat, 20, "seconds in band: 20");
    secs_in_b_sink.cq_next;
    while not secs_in_b_sink.cq_get_dvalid loop
      secs_in_b_sink.cq_next;
    end loop;
    tc_check(secs_in_b_sink.cq_get_d_nat, 30, "seconds in band: 30");
    secs_in_b_sink.cq_next;
    while not secs_in_b_sink.cq_get_dvalid loop
      secs_in_b_sink.cq_next;
    end loop;
    tc_check(secs_in_b_sink.cq_get_d_nat, 40, "seconds in band: 40");
    secs_in_b_sink.cq_next;
    while not secs_in_b_sink.cq_get_dvalid loop
      secs_in_b_sink.cq_next;
    end loop;
    tc_check(secs_in_b_sink.cq_get_d_nat, 50, "seconds in band: 50");
    secs_in_b_sink.cq_next;
    while not secs_in_b_sink.cq_get_dvalid loop
      secs_in_b_sink.cq_next;
    end loop;
    tc_check(secs_in_b_sink.cq_get_d_nat, 60, "seconds in band: 60");

    -- "miles in time range"
    tc_check(miles_in_time_sink.pq_ready, true);
    while not miles_in_time_sink.cq_get_dvalid loop
      miles_in_time_sink.cq_next;
    end loop;
    tc_check(miles_in_time_sink.cq_get_d_nat, 1191, "miles in time range: 1191");
    miles_in_time_sink.cq_next;
    while not miles_in_time_sink.cq_get_dvalid loop
      miles_in_time_sink.cq_next;
    end loop;
    tc_check(miles_in_time_sink.cq_get_d_nat, 524, "miles in time range: 524");
    miles_in_time_sink.cq_next;
    while not miles_in_time_sink.cq_get_dvalid loop
      miles_in_time_sink.cq_next;
    end loop;
    tc_check(miles_in_time_sink.cq_get_d_nat, 1722, "miles in time range: 1722");
    miles_in_time_sink.cq_next;
    while not miles_in_time_sink.cq_get_dvalid loop
      miles_in_time_sink.cq_next;
    end loop;
    tc_check(miles_in_time_sink.cq_get_d_nat, 398, "miles in time range: 398");
    miles_in_time_sink.cq_next;
    while not miles_in_time_sink.cq_get_dvalid loop
      miles_in_time_sink.cq_next;
    end loop;
    tc_check(miles_in_time_sink.cq_get_d_nat, 1648, "miles in time range: 1648");
    miles_in_time_sink.cq_next;
    while not miles_in_time_sink.cq_get_dvalid loop
      miles_in_time_sink.cq_next;
    end loop;
    tc_check(miles_in_time_sink.cq_get_d_nat, 755, "miles in time range: 755");

    -- "constant speed miles in band"
    tc_check(const_spd_m_in_b_sink.pq_ready, true);
    while not const_spd_m_in_b_sink.cq_get_dvalid loop
      const_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(const_spd_m_in_b_sink.cq_get_d_nat, 1922, "constant speed miles in band: 1922");
    const_spd_m_in_b_sink.cq_next;
    while not const_spd_m_in_b_sink.cq_get_dvalid loop
      const_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(const_spd_m_in_b_sink.cq_get_d_nat, 1889, "constant speed miles in band: 1889");
    const_spd_m_in_b_sink.cq_next;
    while not const_spd_m_in_b_sink.cq_get_dvalid loop
      const_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(const_spd_m_in_b_sink.cq_get_d_nat, 679, "constant speed miles in band: 679");
    const_spd_m_in_b_sink.cq_next;
    while not const_spd_m_in_b_sink.cq_get_dvalid loop
      const_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(const_spd_m_in_b_sink.cq_get_d_nat, 140, "constant speed miles in band: 140");
    const_spd_m_in_b_sink.cq_next;
    while not const_spd_m_in_b_sink.cq_get_dvalid loop
      const_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(const_spd_m_in_b_sink.cq_get_d_nat, 1441, "constant speed miles in band: 1441");
    const_spd_m_in_b_sink.cq_next;
    while not const_spd_m_in_b_sink.cq_get_dvalid loop
      const_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(const_spd_m_in_b_sink.cq_get_d_nat, 210, "constant speed miles in band: 210");

    -- "varying speed miles in band"
    tc_check(var_spd_m_in_b_sink.pq_ready, true);
    while not var_spd_m_in_b_sink.cq_get_dvalid loop
      var_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(var_spd_m_in_b_sink.cq_get_d_nat, 99, "varying speed miles in band: 99");
    var_spd_m_in_b_sink.cq_next;
    while not var_spd_m_in_b_sink.cq_get_dvalid loop
      var_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(var_spd_m_in_b_sink.cq_get_d_nat, 431, "varying speed miles in band: 431");
    var_spd_m_in_b_sink.cq_next;
    while not var_spd_m_in_b_sink.cq_get_dvalid loop
      var_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(var_spd_m_in_b_sink.cq_get_d_nat, 1647, "varying speed miles in band: 1647");
    var_spd_m_in_b_sink.cq_next;
    while not var_spd_m_in_b_sink.cq_get_dvalid loop
      var_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(var_spd_m_in_b_sink.cq_get_d_nat, 1414, "varying speed miles in band: 1414");
    var_spd_m_in_b_sink.cq_next;
    while not var_spd_m_in_b_sink.cq_get_dvalid loop
      var_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(var_spd_m_in_b_sink.cq_get_d_nat, 562, "varying speed miles in band: 562");
    var_spd_m_in_b_sink.cq_next;
    while not var_spd_m_in_b_sink.cq_get_dvalid loop
      var_spd_m_in_b_sink.cq_next;
    end loop;
    tc_check(var_spd_m_in_b_sink.cq_get_d_nat, 83, "varying speed miles in band: 83");

    -- "seconds decel"
    tc_check(seconds_decel_sink.pq_ready, true);
    while not seconds_decel_sink.cq_get_dvalid loop
      seconds_decel_sink.cq_next;
    end loop;
    tc_check(seconds_decel_sink.cq_get_d_nat, 98, "seconds decel: 98");
    seconds_decel_sink.cq_next;
    while not seconds_decel_sink.cq_get_dvalid loop
      seconds_decel_sink.cq_next;
    end loop;
    tc_check(seconds_decel_sink.cq_get_d_nat, 1857, "seconds decel: 1857");
    seconds_decel_sink.cq_next;
    while not seconds_decel_sink.cq_get_dvalid loop
      seconds_decel_sink.cq_next;
    end loop;
    tc_check(seconds_decel_sink.cq_get_d_nat, 675, "seconds decel: 675");
    seconds_decel_sink.cq_next;
    while not seconds_decel_sink.cq_get_dvalid loop
      seconds_decel_sink.cq_next;
    end loop;
    tc_check(seconds_decel_sink.cq_get_d_nat, 1749, "seconds decel: 1749");
    seconds_decel_sink.cq_next;
    while not seconds_decel_sink.cq_get_dvalid loop
      seconds_decel_sink.cq_next;
    end loop;
    tc_check(seconds_decel_sink.cq_get_d_nat, 581, "seconds decel: 581");
    seconds_decel_sink.cq_next;
    while not seconds_decel_sink.cq_get_dvalid loop
      seconds_decel_sink.cq_next;
    end loop;
    tc_check(seconds_decel_sink.cq_get_d_nat, 896, "seconds decel: 896");

     -- "seconds accel"
     tc_check(seconds_accel_sink.pq_ready, true);
     while not seconds_accel_sink.cq_get_dvalid loop
       seconds_accel_sink.cq_next;
     end loop;
     tc_check(seconds_accel_sink.cq_get_d_nat, 387, "seconds accel: 387");
     seconds_accel_sink.cq_next;
     while not seconds_accel_sink.cq_get_dvalid loop
       seconds_accel_sink.cq_next;
     end loop;
     tc_check(seconds_accel_sink.cq_get_d_nat, 1379, "seconds accel: 1379");
     seconds_accel_sink.cq_next;
     while not seconds_accel_sink.cq_get_dvalid loop
       seconds_accel_sink.cq_next;
     end loop;
     tc_check(seconds_accel_sink.cq_get_d_nat, 1950, "seconds accel: 1950");
     seconds_accel_sink.cq_next;
     while not seconds_accel_sink.cq_get_dvalid loop
       seconds_accel_sink.cq_next;
     end loop;
     tc_check(seconds_accel_sink.cq_get_d_nat, 1205, "seconds accel: 1205");
     seconds_accel_sink.cq_next;
     while not seconds_accel_sink.cq_get_dvalid loop
       seconds_accel_sink.cq_next;
     end loop;
     tc_check(seconds_accel_sink.cq_get_d_nat, 1442, "seconds accel: 1442");
     seconds_accel_sink.cq_next;
     while not seconds_accel_sink.cq_get_dvalid loop
       seconds_accel_sink.cq_next;
     end loop;
     tc_check(seconds_accel_sink.cq_get_d_nat, 1507, "seconds accel: 1507");

     -- "braking more than 10s"
    tc_check(brk_m_t_10s_sink.pq_ready, true);
    while not brk_m_t_10s_sink.cq_get_dvalid loop
      brk_m_t_10s_sink.cq_next;
    end loop;
    tc_check(brk_m_t_10s_sink.cq_get_d_nat, 1678, "braking more than 10s: 1678");
    brk_m_t_10s_sink.cq_next;
    while not brk_m_t_10s_sink.cq_get_dvalid loop
      brk_m_t_10s_sink.cq_next;
    end loop;
    tc_check(brk_m_t_10s_sink.cq_get_d_nat, 1880, "braking more than 10s: 1880");
    brk_m_t_10s_sink.cq_next;
    while not brk_m_t_10s_sink.cq_get_dvalid loop
      brk_m_t_10s_sink.cq_next;
    end loop;
    tc_check(brk_m_t_10s_sink.cq_get_d_nat, 308, "braking more than 10s: 308");
    brk_m_t_10s_sink.cq_next;
    while not brk_m_t_10s_sink.cq_get_dvalid loop
      brk_m_t_10s_sink.cq_next;
    end loop;
    tc_check(brk_m_t_10s_sink.cq_get_d_nat, 1065, "braking more than 10s: 1065");
    brk_m_t_10s_sink.cq_next;
    while not brk_m_t_10s_sink.cq_get_dvalid loop
      brk_m_t_10s_sink.cq_next;
    end loop;
    tc_check(brk_m_t_10s_sink.cq_get_d_nat, 1541, "braking more than 10s: 1541");
    brk_m_t_10s_sink.cq_next;
    while not brk_m_t_10s_sink.cq_get_dvalid loop
      brk_m_t_10s_sink.cq_next;
    end loop;
    tc_check(brk_m_t_10s_sink.cq_get_d_nat, 717, "braking more than 10s: 717");

    -- "accel more than 10s"
    tc_check(accel_m_t_10s_sink.pq_ready, true);
    while not accel_m_t_10s_sink.cq_get_dvalid loop
      accel_m_t_10s_sink.cq_next;
    end loop;
    tc_check(accel_m_t_10s_sink.cq_get_d_nat, 147, "accel more than 10s: 147");
    accel_m_t_10s_sink.cq_next;
    while not accel_m_t_10s_sink.cq_get_dvalid loop
      accel_m_t_10s_sink.cq_next;
    end loop;
    tc_check(accel_m_t_10s_sink.cq_get_d_nat, 845, "accel more than 10s: 845");
    accel_m_t_10s_sink.cq_next;
    while not accel_m_t_10s_sink.cq_get_dvalid loop
      accel_m_t_10s_sink.cq_next;
    end loop;
    tc_check(accel_m_t_10s_sink.cq_get_d_nat, 923, "accel more than 10s: 923");
    accel_m_t_10s_sink.cq_next;
    while not accel_m_t_10s_sink.cq_get_dvalid loop
      accel_m_t_10s_sink.cq_next;
    end loop;
    tc_check(accel_m_t_10s_sink.cq_get_d_nat, 254, "accel more than 10s: 254");
    accel_m_t_10s_sink.cq_next;
    while not accel_m_t_10s_sink.cq_get_dvalid loop
      accel_m_t_10s_sink.cq_next;
    end loop;
    tc_check(accel_m_t_10s_sink.cq_get_d_nat, 1223, "accel more than 10s: 1223");
    accel_m_t_10s_sink.cq_next;
    while not accel_m_t_10s_sink.cq_get_dvalid loop
      accel_m_t_10s_sink.cq_next;
    end loop;
    tc_check(accel_m_t_10s_sink.cq_get_d_nat, 1427, "accel more than 10s: 1427");

    -- "small speed var miles"
    tc_check(small_spd_v_m_sink.pq_ready, true);
    while not small_spd_v_m_sink.cq_get_dvalid loop
      small_spd_v_m_sink.cq_next;
    end loop;
    tc_check(small_spd_v_m_sink.cq_get_d_nat, 867, "small speed var miles: 867");
    small_spd_v_m_sink.cq_next;
    while not small_spd_v_m_sink.cq_get_dvalid loop
      small_spd_v_m_sink.cq_next;
    end loop;
    tc_check(small_spd_v_m_sink.cq_get_d_nat, 1460, "small speed var miles: 1460");
    small_spd_v_m_sink.cq_next;
    while not small_spd_v_m_sink.cq_get_dvalid loop
      small_spd_v_m_sink.cq_next;
    end loop;
    tc_check(small_spd_v_m_sink.cq_get_d_nat, 1661, "small speed var miles: 1661");
    small_spd_v_m_sink.cq_next;
    while not small_spd_v_m_sink.cq_get_dvalid loop
      small_spd_v_m_sink.cq_next;
    end loop;
    tc_check(small_spd_v_m_sink.cq_get_d_nat, 1291, "small speed var miles: 1291");
    small_spd_v_m_sink.cq_next;
    while not small_spd_v_m_sink.cq_get_dvalid loop
      small_spd_v_m_sink.cq_next;
    end loop;
    tc_check(small_spd_v_m_sink.cq_get_d_nat, 1631, "small speed var miles: 1631");
    small_spd_v_m_sink.cq_next;
    while not small_spd_v_m_sink.cq_get_dvalid loop
      small_spd_v_m_sink.cq_next;
    end loop;
    tc_check(small_spd_v_m_sink.cq_get_d_nat, 410, "small speed var miles: 410");

    -- "large speed var miles"
    tc_check(large_spd_v_m_sink.pq_ready, true);
    while not large_spd_v_m_sink.cq_get_dvalid loop
      large_spd_v_m_sink.cq_next;
    end loop;
    tc_check(large_spd_v_m_sink.cq_get_d_nat, 1580, "large speed var miles: 1580");
    large_spd_v_m_sink.cq_next;
    while not large_spd_v_m_sink.cq_get_dvalid loop
      large_spd_v_m_sink.cq_next;
    end loop;
    tc_check(large_spd_v_m_sink.cq_get_d_nat, 1387, "large speed var miles: 1387");
    large_spd_v_m_sink.cq_next;
    while not large_spd_v_m_sink.cq_get_dvalid loop
      large_spd_v_m_sink.cq_next;
    end loop;
    tc_check(large_spd_v_m_sink.cq_get_d_nat, 1713, "large speed var miles: 1713");
    large_spd_v_m_sink.cq_next;
    while not large_spd_v_m_sink.cq_get_dvalid loop
      large_spd_v_m_sink.cq_next;
    end loop;
    tc_check(large_spd_v_m_sink.cq_get_d_nat, 360, "large speed var miles: 360");
    large_spd_v_m_sink.cq_next;
    while not large_spd_v_m_sink.cq_get_dvalid loop
      large_spd_v_m_sink.cq_next;
    end loop;
    tc_check(large_spd_v_m_sink.cq_get_d_nat, 1837, "large speed var miles: 1837");
    large_spd_v_m_sink.cq_next;
    while not large_spd_v_m_sink.cq_get_dvalid loop
      large_spd_v_m_sink.cq_next;
    end loop;
    tc_check(large_spd_v_m_sink.cq_get_d_nat, 92, "large speed var miles: 92");



    tc_pass;
    wait;
  end process;

end test_case;