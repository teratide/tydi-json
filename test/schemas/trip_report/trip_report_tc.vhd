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
  signal timezone_ready                       : std_logic;
  signal timezone_valid                       : std_logic;
  signal timezone_dvalid                      : std_logic;
  signal timezone_data                        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal timezone_last                        : std_logic_vector(1 downto 0);
  signal timezone_strb                        : std_logic;

  signal vin_ready                            : std_logic;
  signal vin_valid                            : std_logic;
  signal vin_strb                             : std_logic;
  signal vin_dvalid                           : std_logic;
  signal vin_data                             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal vin_last                             : std_logic_vector(1 downto 0);

  signal odometer_ready                       : std_logic;
  signal odometer_valid                       : std_logic;
  signal odometer_strb                        : std_logic;
  signal odometer_dvalid                      : std_logic;
  signal odometer_data                        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal odometer_last                        : std_logic_vector(1 downto 0);

  signal avgspeed_ready                       : std_logic;
  signal avgspeed_valid                       : std_logic;
  signal avgspeed_strb                        : std_logic;
  signal avgspeed_dvalid                      : std_logic;
  signal avgspeed_data                        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal avgspeed_last                        : std_logic_vector(1 downto 0);

  signal accel_decel_ready                    : std_logic;
  signal accel_decel_valid                    : std_logic;
  signal accel_decel_strb                     : std_logic;
  signal accel_decel_dvalid                   : std_logic;
  signal accel_decel_data                     : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal accel_decel_last                     : std_logic_vector(1 downto 0);

  signal speed_changes_ready                  : std_logic;
  signal speed_changes_valid                  : std_logic;
  signal speed_changes_strb                   : std_logic;
  signal speed_changes_dvalid                 : std_logic;
  signal speed_changes_data                   : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal speed_changes_last                   : std_logic_vector(1 downto 0);

  -- 
  -- BOOLEAN FIELDS
  --
  signal hypermiling_valid                    : std_logic;
  signal hypermiling_ready                    : std_logic;
  signal hypermiling_data                     : std_logic;
  signal hypermiling_strb                     : std_logic;
  signal hypermiling_dvalid                   : std_logic;
  signal hypermiling_last                     : std_logic_vector(1 downto 0);

  signal orientation_valid                    : std_logic;
  signal orientation_ready                    : std_logic;
  signal orientation_data                     : std_logic;
  signal orientation_strb                     : std_logic;
  signal orientation_dvalid                   : std_logic;
  signal orientation_last                     : std_logic_vector(1 downto 0);
  
  -- 
  -- INTEGER ARRAY FIELDS
  --
  signal sec_in_band_ready                    : std_logic;
  signal sec_in_band_valid                    : std_logic;
  signal sec_in_band_strb                     : std_logic;
  signal sec_in_band_dvalid                   : std_logic;
  signal sec_in_band_data                     : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal sec_in_band_last                     : std_logic_vector(2 downto 0);

  signal miles_in_time_range_ready            : std_logic;
  signal miles_in_time_range_valid            : std_logic;
  signal miles_in_time_range_strb             : std_logic;
  signal miles_in_time_range_dvalid           : std_logic;
  signal miles_in_time_range_data             : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal miles_in_time_range_last             : std_logic_vector(2 downto 0);

  signal const_speed_miles_in_band_ready      : std_logic;
  signal const_speed_miles_in_band_valid      : std_logic;
  signal const_speed_miles_in_band_strb       : std_logic;
  signal const_speed_miles_in_band_dvalid     : std_logic;
  signal const_speed_miles_in_band_data       : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal const_speed_miles_in_band_last       : std_logic_vector(2 downto 0);

  signal vary_speed_miles_in_band_ready       : std_logic;
  signal vary_speed_miles_in_band_valid       : std_logic;
  signal vary_speed_miles_in_band_strb        : std_logic;
  signal vary_speed_miles_in_band_dvalid      : std_logic;
  signal vary_speed_miles_in_band_data        : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal vary_speed_miles_in_band_last        : std_logic_vector(2 downto 0);

  signal sec_decel_ready                      : std_logic;
  signal sec_decel_valid                      : std_logic;
  signal sec_decel_strb                       : std_logic;
  signal sec_decel_dvalid                     : std_logic;
  signal sec_decel_data                       : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal sec_decel_last                       : std_logic_vector(2 downto 0);

  signal sec_accel_ready                      : std_logic;
  signal sec_accel_valid                      : std_logic;
  signal sec_accel_strb                       : std_logic;
  signal sec_accel_dvalid                     : std_logic;
  signal sec_accel_data                       : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal sec_accel_last                       : std_logic_vector(2 downto 0);

  signal braking_ready                        : std_logic;
  signal braking_valid                        : std_logic;
  signal braking_strb                         : std_logic;
  signal braking_dvalid                       : std_logic;
  signal braking_data                         : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal braking_last                         : std_logic_vector(2 downto 0);

  signal accel_ready                          : std_logic;
  signal accel_valid                          : std_logic;
  signal accel_strb                           : std_logic;
  signal accel_dvalid                         : std_logic;
  signal accel_data                           : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal accel_last                           : std_logic_vector(2 downto 0);

  signal small_speed_var_ready                : std_logic;
  signal small_speed_var_valid                : std_logic;
  signal small_speed_var_strb                 : std_logic;
  signal small_speed_var_dvalid               : std_logic;
  signal small_speed_var_data                 : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal small_speed_var_last                 : std_logic_vector(2 downto 0);

  signal large_speed_var_ready                : std_logic;
  signal large_speed_var_valid                : std_logic;
  signal large_speed_var_strb                 : std_logic;
  signal large_speed_var_dvalid               : std_logic;
  signal large_speed_var_data                 : std_logic_vector(INTEGER_WIDTH-1 downto 0);
  signal large_speed_var_last                 : std_logic_vector(2 downto 0);

  -- 
  -- STRING FIELDS
  --
  signal timestamp_valid                      : std_logic;
  signal timestamp_ready                      : std_logic;
  signal timestamp_data                       : std_logic_vector(8*EPC-1 downto 0);
  signal timestamp_last                       : std_logic_vector(3*EPC-1 downto 0);
  signal timestamp_stai                       : std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
  signal timestamp_endi                       : std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
  signal timestamp_strb                       : std_logic_vector(EPC-1 downto 0);

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
      TIMEZONE_INT_WIDTH                            => INTEGER_WIDTH,
      TIMEZONE_INT_P_PIPELINE_STAGES                => INT_P_PIPELINE_STAGES,
      TIMEZONE_BUFFER_D                             => 1,

      VIN_INT_WIDTH                                 => INTEGER_WIDTH,
      VIN_INT_P_PIPELINE_STAGES                     => INT_P_PIPELINE_STAGES,
      VIN_BUFFER_D                                  => 1,

      ODOMETER_INT_WIDTH                            => INTEGER_WIDTH,
      ODOMETER_INT_P_PIPELINE_STAGES                => INT_P_PIPELINE_STAGES,
      ODOMETER_BUFFER_D                             => 1,

      AVGSPEED_INT_WIDTH                            => INTEGER_WIDTH,
      AVGSPEED_INT_P_PIPELINE_STAGES                => INT_P_PIPELINE_STAGES,
      AVGSPEED_BUFFER_D                             => 1,

      ACCEL_DECEL_INT_WIDTH                         => INTEGER_WIDTH,
      ACCEL_DECEL_INT_P_PIPELINE_STAGES             => INT_P_PIPELINE_STAGES,
      ACCEL_DECEL_BUFFER_D                          => 1,

      SPEED_CHANGES_INT_WIDTH                       => INTEGER_WIDTH,
      SPEED_CHANGES_INT_P_PIPELINE_STAGES           => INT_P_PIPELINE_STAGES,
      SPEED_CHANGES_BUFFER_D                        => 1,

      --    
      -- BOOLEAN FIELDS   
      --    
      HYPERMILING_BUFFER_D                          => 1,
      ORIENTATION_BUFFER_D                          => 1,

      --    
      -- INTEGER ARRAY FIELDS   
      --    
      SEC_IN_BAND_INT_WIDTH                               => INTEGER_WIDTH,
      SEC_IN_BAND_INT_P_PIPELINE_STAGES                   => INT_P_PIPELINE_STAGES,
      SEC_IN_BAND_BUFFER_D                                => 1,

      MILES_IN_TIME_RANGE_INT_WIDTH                       => INTEGER_WIDTH,
      MILES_IN_TIME_RANGE_INT_P_PIPELINE_STAGES           => INT_P_PIPELINE_STAGES,
      MILES_IN_TIME_RANGE_BUFFER_D                        => 1,

      CONST_SPEED_MILES_IN_BAND_INT_WIDTH                 => INTEGER_WIDTH,
      CONST_SPEED_MILES_IN_BAND_INT_P_PIPELINE_STAGES     => INT_P_PIPELINE_STAGES,
      CONST_SPEED_MILES_IN_BAND_BUFFER_D                  => 1,

      VARY_SPEED_MILES_IN_BAND_INT_WIDTH                  => INTEGER_WIDTH,
      VARY_SPEED_MILES_IN_BAND_INT_P_PIPELINE_STAGES      => INT_P_PIPELINE_STAGES,
      VARY_SPEED_MILES_IN_BAND_BUFFER_D                   => 1,

      SEC_DECEL_INT_WIDTH                                 => INTEGER_WIDTH,
      SEC_DECEL_INT_P_PIPELINE_STAGES                     => INT_P_PIPELINE_STAGES,
      SEC_DECEL_BUFFER_D                                  => 1,

      SEC_ACCEL_INT_WIDTH                                 => INTEGER_WIDTH,
      SEC_ACCEL_INT_P_PIPELINE_STAGES                     => INT_P_PIPELINE_STAGES,
      SEC_ACCEL_BUFFER_D                                  => 1,

      BRAKING_INT_WIDTH                                   => INTEGER_WIDTH,
      BRAKING_INT_P_PIPELINE_STAGES                       => INT_P_PIPELINE_STAGES,
      BRAKING_BUFFER_D                                    => 1,

      ACCEL_INT_WIDTH                                     => INTEGER_WIDTH,
      ACCEL_INT_P_PIPELINE_STAGES                         => INT_P_PIPELINE_STAGES,
      ACCEL_BUFFER_D                                      => 1,

      SMALL_SPEED_VAR_INT_WIDTH                           => INTEGER_WIDTH,
      SMALL_SPEED_VAR_INT_P_PIPELINE_STAGES               => INT_P_PIPELINE_STAGES,
      SMALL_SPEED_VAR_BUFFER_D                            => 1,

      LARGE_SPEED_VAR_INT_WIDTH                           => INTEGER_WIDTH,
      LARGE_SPEED_VAR_INT_P_PIPELINE_STAGES               => INT_P_PIPELINE_STAGES,
      LARGE_SPEED_VAR_BUFFER_D                            => 1,

      END_REQ_EN                                          => false
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
      timezone_strb                         => timezone_strb,

      vin_data                              => vin_data,
      vin_valid                             => vin_valid,
      vin_ready                             => vin_ready,
      vin_last                              => vin_last,
      vin_strb                              => vin_strb,

      odometer_data                         => odometer_data,
      odometer_valid                        => odometer_valid,
      odometer_ready                        => odometer_ready,
      odometer_last                         => odometer_last,
      odometer_strb                         => odometer_strb,

      avgspeed_data                         => avgspeed_data,
      avgspeed_valid                        => avgspeed_valid,
      avgspeed_ready                        => avgspeed_ready,
      avgspeed_last                         => avgspeed_last,
      avgspeed_strb                         => avgspeed_strb,

      accel_decel_data                      => accel_decel_data,
      accel_decel_valid                     => accel_decel_valid,
      accel_decel_ready                     => accel_decel_ready,
      accel_decel_last                      => accel_decel_last,
      accel_decel_strb                      => accel_decel_strb,

      speed_changes_data                    => speed_changes_data,
      speed_changes_valid                   => speed_changes_valid,
      speed_changes_ready                   => speed_changes_ready,
      speed_changes_last                    => speed_changes_last,
      speed_changes_strb                    => speed_changes_strb,

      hypermiling_data                      => hypermiling_data,
      hypermiling_valid                     => hypermiling_valid,
      hypermiling_ready                     => hypermiling_ready,
      hypermiling_last                      => hypermiling_last,
      hypermiling_strb                      => hypermiling_strb,

      orientation_data                      => orientation_data,
      orientation_valid                     => orientation_valid,
      orientation_ready                     => orientation_ready,
      orientation_last                      => orientation_last,
      orientation_strb                      => orientation_strb,

      sec_in_band_data                      => sec_in_band_data,
      sec_in_band_valid                     => sec_in_band_valid,
      sec_in_band_ready                     => sec_in_band_ready,
      sec_in_band_last                      => sec_in_band_last,
      sec_in_band_strb                      => sec_in_band_strb,

      miles_in_time_range_data              => miles_in_time_range_data,
      miles_in_time_range_valid             => miles_in_time_range_valid,
      miles_in_time_range_ready             => miles_in_time_range_ready,
      miles_in_time_range_last              => miles_in_time_range_last,
      miles_in_time_range_strb              => miles_in_time_range_strb,

      const_speed_miles_in_band_data        => const_speed_miles_in_band_data,
      const_speed_miles_in_band_valid       => const_speed_miles_in_band_valid,
      const_speed_miles_in_band_ready       => const_speed_miles_in_band_ready,
      const_speed_miles_in_band_last        => const_speed_miles_in_band_last,
      const_speed_miles_in_band_strb        => const_speed_miles_in_band_strb,

      vary_speed_miles_in_band_data         => vary_speed_miles_in_band_data,
      vary_speed_miles_in_band_valid        => vary_speed_miles_in_band_valid,
      vary_speed_miles_in_band_ready        => vary_speed_miles_in_band_ready,
      vary_speed_miles_in_band_last         => vary_speed_miles_in_band_last,
      vary_speed_miles_in_band_strb         => vary_speed_miles_in_band_strb,

      sec_decel_data                        => sec_decel_data,
      sec_decel_valid                       => sec_decel_valid,
      sec_decel_ready                       => sec_decel_ready,
      sec_decel_last                        => sec_decel_last,
      sec_decel_strb                        => sec_decel_strb,

      sec_accel_data                        => sec_accel_data,
      sec_accel_valid                       => sec_accel_valid,
      sec_accel_ready                       => sec_accel_ready,
      sec_accel_last                        => sec_accel_last,
      sec_accel_strb                        => sec_accel_strb,

      braking_data                          => braking_data,
      braking_valid                         => braking_valid,
      braking_ready                         => braking_ready,
      braking_last                          => braking_last,
      braking_strb                          => braking_strb,

      accel_data                            => accel_data,
      accel_valid                           => accel_valid,
      accel_ready                           => accel_ready,
      accel_last                            => accel_last,
      accel_strb                            => accel_strb,

      small_speed_var_data                  => small_speed_var_data,
      small_speed_var_valid                 => small_speed_var_valid,
      small_speed_var_ready                 => small_speed_var_ready,
      small_speed_var_last                  => small_speed_var_last,
      small_speed_var_strb                  => small_speed_var_strb,

      large_speed_var_data                  => large_speed_var_data,
      large_speed_var_valid                 => large_speed_var_valid,
      large_speed_var_ready                 => large_speed_var_ready,
      large_speed_var_last                  => large_speed_var_last,
      large_speed_var_strb                  => large_speed_var_strb,

      timestamp_data                        => timestamp_data,
      timestamp_valid                       => timestamp_valid,
      timestamp_ready                       => timestamp_ready,
      timestamp_last                        => timestamp_last
      );

    -- String fields are not tested currently
    timestamp_ready <= '1';

    -- 
    -- INTEGER FIELDS
    --
    timezone_dvalid <= timezone_strb;
    vin_dvalid <= vin_strb;
    odometer_dvalid <= odometer_strb;
    avgspeed_dvalid <= avgspeed_strb;
    accel_decel_dvalid <= accel_decel_strb;
    speed_changes_dvalid <= speed_changes_strb;

    -- 
    -- BOOLEAN FIELDS
    --
    hypermiling_dvalid <= hypermiling_strb;
    orientation_dvalid <= orientation_strb;

    -- 
    -- INTEGER ARRAY FIELDS
    --
    sec_in_band_dvalid <= sec_in_band_strb;
    miles_in_time_range_dvalid <= miles_in_time_range_strb;
    const_speed_miles_in_band_dvalid <= const_speed_miles_in_band_strb;
    vary_speed_miles_in_band_dvalid <= vary_speed_miles_in_band_strb;
    sec_decel_dvalid <= sec_decel_strb;
    sec_accel_dvalid <= sec_accel_strb;
    braking_dvalid <= braking_strb;
    accel_dvalid <= accel_strb;
    small_speed_var_dvalid <= small_speed_var_strb;
    large_speed_var_dvalid <= large_speed_var_strb;


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

    avgspeed_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "avgspeed_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => avgspeed_valid,
      ready                     => avgspeed_ready,
      data                      => avgspeed_data,
      dvalid                    => avgspeed_dvalid
    );

    accel_decel_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "accel_decel_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => accel_decel_valid,
      ready                     => accel_decel_ready,
      data                      => accel_decel_data,
      dvalid                    => accel_decel_dvalid
    );

    speed_changes_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "speed_changes_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => speed_changes_valid,
      ready                     => speed_changes_ready,
      data                      => speed_changes_data,
      dvalid                    => speed_changes_dvalid
    );

    -- 
    -- BOOLEAN FIELDS
    --
    hypermiling_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "hypermiling_sink",
      ELEMENT_WIDTH             => 1,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => hypermiling_valid,
      ready                     => hypermiling_ready,
      data(0)                   => hypermiling_data,
      dvalid                    => hypermiling_dvalid
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

    sec_in_band_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "sec_in_band_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => sec_in_band_valid,
      ready                     => sec_in_band_ready,
      data                      => sec_in_band_data,
      dvalid                    => sec_in_band_dvalid
    );

    miles_in_time_range_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "miles_in_time_range_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => miles_in_time_range_valid,
      ready                     => miles_in_time_range_ready,
      data                      => miles_in_time_range_data,
      dvalid                    => miles_in_time_range_dvalid
    );

    const_speed_miles_in_band_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "const_speed_miles_in_band_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => const_speed_miles_in_band_valid,
      ready                     => const_speed_miles_in_band_ready,
      data                      => const_speed_miles_in_band_data,
      dvalid                    => const_speed_miles_in_band_dvalid
    );

    vary_speed_miles_in_band_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "vary_speed_miles_in_band_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => vary_speed_miles_in_band_valid,
      ready                     => vary_speed_miles_in_band_ready,
      data                      => vary_speed_miles_in_band_data,
      dvalid                    => vary_speed_miles_in_band_dvalid
    );

    sec_decel_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "sec_decel_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => sec_decel_valid,
      ready                     => sec_decel_ready,
      data                      => sec_decel_data,
      dvalid                    => sec_decel_dvalid
    );

    sec_accel_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "sec_accel_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => sec_accel_valid,
      ready                     => sec_accel_ready,
      data                      => sec_accel_data,
      dvalid                    => sec_accel_dvalid
    );

    braking_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "braking_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => braking_valid,
      ready                     => braking_ready,
      data                      => braking_data,
      dvalid                    => braking_dvalid
    );

    accel_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "accel_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => accel_valid,
      ready                     => accel_ready,
      data                      => accel_data,
      dvalid                    => accel_dvalid
    );

    small_speed_var_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "small_speed_var_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => small_speed_var_valid,
      ready                     => small_speed_var_ready,
      data                      => small_speed_var_data,
      dvalid                    => small_speed_var_dvalid
    );

    large_speed_var_sink_i: StreamSink_mdl
    generic map (
      NAME                      => "large_speed_var_sink",
      ELEMENT_WIDTH             => INTEGER_WIDTH,
      COUNT_MAX                 => 1,
      COUNT_WIDTH               => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      valid                     => large_speed_var_valid,
      ready                     => large_speed_var_ready,
      data                      => large_speed_var_data,
      dvalid                    => large_speed_var_dvalid
    );

  random_tc: process is
    variable src                    : streamsource_type;

    -- 
    -- INTEGER FIELDS
    --
    variable timezone_sink          : streamsink_type;
    variable vin_sink               : streamsink_type;
    variable odometer_sink          : streamsink_type;
    variable avgspeed_sink          : streamsink_type;
    variable accel_decel_sink       : streamsink_type;
    variable speed_changes_sink     : streamsink_type;

    -- 
    -- BOOLEAN FIELDS
    --
    variable hypermiling_sink      : streamsink_type;
    variable orientation_sink      : streamsink_type;

    -- 
    -- INTEGER ARRAY FIELDS
    --
    variable sec_in_band_sink                 : streamsink_type;
    variable miles_in_time_range_sink         : streamsink_type;
    variable const_speed_miles_in_band_sink   : streamsink_type;
    variable vary_speed_miles_in_band_sink    : streamsink_type;
    variable sec_decel_sink                   : streamsink_type;
    variable sec_accel_sink                   : streamsink_type;
    variable braking_sink                     : streamsink_type;
    variable accel_sink                       : streamsink_type;
    variable small_speed_var_sink             : streamsink_type;
    variable large_speed_var_sink             : streamsink_type;
    

  begin
    tc_open("TripReportParser", "test");

    src.initialize("src");

    -- 
    -- INTEGER FIELDS
    --
    timezone_sink.initialize("timezone_sink");
    vin_sink.initialize("vin_sink");
    odometer_sink.initialize("odometer_sink");
    avgspeed_sink.initialize("avgspeed_sink");
    accel_decel_sink.initialize("accel_decel_sink");
    speed_changes_sink.initialize("speed_changes_sink");

    -- 
    -- BOOLEAN FIELDS
    --
    hypermiling_sink.initialize("hypermiling_sink");
    orientation_sink.initialize("orientation_sink");

    -- 
    -- INTEGER ARRAY FIELDS
    --
    sec_in_band_sink.initialize("sec_in_band_sink");
    miles_in_time_range_sink.initialize("miles_in_time_range_sink");
    const_speed_miles_in_band_sink.initialize("const_speed_miles_in_band_sink");
    vary_speed_miles_in_band_sink.initialize("vary_speed_miles_in_band_sink");
    sec_decel_sink.initialize("sec_decel_sink");
    sec_accel_sink.initialize("sec_accel_sink");
    braking_sink.initialize("braking_sink");
    accel_sink.initialize("accel_sink");
    small_speed_var_sink.initialize("small_speed_var_sink");
    large_speed_var_sink.initialize("large_speed_var_sink");


    -- 
    -- TEST DATA
    --
    src.push_str("{ ");
    src.push_str(" ""timezone"" : 42,");
    src.push_str(" ""timestamp"" : ""2005-09-09T11:59:06-10:00"",");
    src.push_str(" ""vin"" : 124,");
    src.push_str(" ""odometer"" : 68000,");
    src.push_str(" ""avgspeed"" : 54,");
    src.push_str(" ""accel_decel"" : 687,");
    src.push_str(" ""speed_changes"" : 99,");
    src.push_str(" ""hypermiling"" : true,");
    src.push_str(" ""orientation"" : false,");
    src.push_str(" ""sec_in_band"" : [10, 20, 30],");
    src.push_str(" ""miles_in_time_range"" : [1191, 524, 1722],");
    src.push_str(" ""const_speed_miles_in_band"" : [1922, 1889, 679],");
    src.push_str(" ""vary_speed_miles_in_band"" : [99, 431, 1647],");
    src.push_str(" ""sec_decel"" : [98, 1857, 675],");
    src.push_str(" ""sec_accel"" : [387, 1379, 1950],");
    src.push_str(" ""braking"" : [1678, 1880, 308],");
    src.push_str(" ""accel"" : [147, 845, 923],");
    src.push_str(" ""small_speed_var"" : [867, 1460, 1661],");
    src.push_str(" ""large_speed_var"" : [1580, 1387, 1713],");
    src.push_str(" }\n");

    src.push_str("{ ");
    src.push_str(" ""timezone"" : 68,");
    src.push_str(" ""timestamp"" : ""2005-09-09T11:59:06-11:00"",");
    src.push_str(" ""vin"" : 125,");
    src.push_str(" ""odometer"" : 76000,");
    src.push_str(" ""avgspeed"" : 62,");
    src.push_str(" ""accel_decel"" : 4561,");
    src.push_str(" ""speed_changes"" : 111,");
    src.push_str(" ""hypermiling"" : false,");
    src.push_str(" ""orientation"" : true,");
    src.push_str(" ""sec_in_band"" : [40, 50, 60],");
    src.push_str(" ""miles_in_time_range"" : [398, 1648, 755],");
    src.push_str(" ""const_speed_miles_in_band"" : [140, 1441, 210],");
    src.push_str(" ""vary_speed_miles_in_band"" : [1414, 562, 83],");
    src.push_str(" ""sec_decel"" : [1749, 581, 896],");
    src.push_str(" ""sec_accel"" : [1205, 1442, 1507],");
    src.push_str(" ""braking"" : [1065, 1541, 717],");
    src.push_str(" ""accel"" : [254, 1223, 1427],");
    src.push_str(" ""small_speed_var"" : [1291, 1631, 410],");
    src.push_str(" ""large_speed_var"" : [360, 1837, 92],");
    src.push_str(" }\n");

    
    
    
    src.transmit;
    
    -- 
    -- INTEGER FIELDS
    --
    timezone_sink.unblock;
    vin_sink.unblock;
    odometer_sink.unblock;
    avgspeed_sink.unblock;
    accel_decel_sink.unblock;
    speed_changes_sink.unblock;

    -- 
    -- BOOLEAN FIELDS
    --
    hypermiling_sink.unblock;
    orientation_sink.unblock;

    -- 
    -- INTEGER ARRAY FIELDS
    --
    sec_in_band_sink.unblock;
    miles_in_time_range_sink.unblock;
    const_speed_miles_in_band_sink.unblock;
    vary_speed_miles_in_band_sink.unblock;
    sec_decel_sink.unblock;
    sec_accel_sink.unblock;
    braking_sink.unblock;
    accel_sink.unblock;
    small_speed_var_sink.unblock;
    large_speed_var_sink.unblock;
    

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

    -- "avgspeed"
    tc_check(avgspeed_sink.pq_ready, true);
    while not avgspeed_sink.cq_get_dvalid loop
      avgspeed_sink.cq_next;
    end loop;
    tc_check(avgspeed_sink.cq_get_d_nat, 54, "avgspeed: 54");
    avgspeed_sink.cq_next;
    while not avgspeed_sink.cq_get_dvalid loop
      avgspeed_sink.cq_next;
    end loop;
    tc_check(avgspeed_sink.cq_get_d_nat, 62, "avgspeed: 62");

    -- "accel_decel"
    tc_check(accel_decel_sink.pq_ready, true);
    while not accel_decel_sink.cq_get_dvalid loop
      accel_decel_sink.cq_next;
    end loop;
    tc_check(accel_decel_sink.cq_get_d_nat, 687, "accel_decel: 687");
    accel_decel_sink.cq_next;
    while not accel_decel_sink.cq_get_dvalid loop
      accel_decel_sink.cq_next;
    end loop;
    tc_check(accel_decel_sink.cq_get_d_nat, 4561, "accel_decel: 4561");

    -- "speed_changes"
    tc_check(speed_changes_sink.pq_ready, true);
    while not speed_changes_sink.cq_get_dvalid loop
      speed_changes_sink.cq_next;
    end loop;
    tc_check(speed_changes_sink.cq_get_d_nat, 99, "speed_changes: 99");
    speed_changes_sink.cq_next;
    while not speed_changes_sink.cq_get_dvalid loop
      speed_changes_sink.cq_next;
    end loop;
    tc_check(speed_changes_sink.cq_get_d_nat, 111, "speed_changes: 111");

    -- 
    -- BOOLEAN FIELDS
    --

    -- "hypermiling"
    tc_check(hypermiling_sink.pq_ready, true);
    while not hypermiling_sink.cq_get_dvalid loop
      hypermiling_sink.cq_next;
    end loop;
    tc_check(hypermiling_sink.cq_get_d_nat, 1, "hypermiling: true");
    hypermiling_sink.cq_next;
    while not hypermiling_sink.cq_get_dvalid loop
      hypermiling_sink.cq_next;
    end loop;
    tc_check(hypermiling_sink.cq_get_d_nat, 0, "hypermiling: false");

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
    -- "sec_in_band"
    tc_check(sec_in_band_sink.pq_ready, true);
    while not sec_in_band_sink.cq_get_dvalid loop
      sec_in_band_sink.cq_next;
    end loop;
    tc_check(sec_in_band_sink.cq_get_d_nat, 10, "sec_in_band: 10");
    sec_in_band_sink.cq_next;
    while not sec_in_band_sink.cq_get_dvalid loop
      sec_in_band_sink.cq_next;
    end loop;
    tc_check(sec_in_band_sink.cq_get_d_nat, 20, "sec_in_band: 20");
    sec_in_band_sink.cq_next;
    while not sec_in_band_sink.cq_get_dvalid loop
      sec_in_band_sink.cq_next;
    end loop;
    tc_check(sec_in_band_sink.cq_get_d_nat, 30, "sec_in_band: 30");
    sec_in_band_sink.cq_next;
    while not sec_in_band_sink.cq_get_dvalid loop
      sec_in_band_sink.cq_next;
    end loop;
    tc_check(sec_in_band_sink.cq_get_d_nat, 40, "sec_in_band: 40");
    sec_in_band_sink.cq_next;
    while not sec_in_band_sink.cq_get_dvalid loop
      sec_in_band_sink.cq_next;
    end loop;
    tc_check(sec_in_band_sink.cq_get_d_nat, 50, "sec_in_band: 50");
    sec_in_band_sink.cq_next;
    while not sec_in_band_sink.cq_get_dvalid loop
      sec_in_band_sink.cq_next;
    end loop;
    tc_check(sec_in_band_sink.cq_get_d_nat, 60, "sec_in_band: 60");

    -- "miles_in_time_range"
    tc_check(miles_in_time_range_sink.pq_ready, true);
    while not miles_in_time_range_sink.cq_get_dvalid loop
      miles_in_time_range_sink.cq_next;
    end loop;
    tc_check(miles_in_time_range_sink.cq_get_d_nat, 1191, "miles_in_time_range: 1191");
    miles_in_time_range_sink.cq_next;
    while not miles_in_time_range_sink.cq_get_dvalid loop
      miles_in_time_range_sink.cq_next;
    end loop;
    tc_check(miles_in_time_range_sink.cq_get_d_nat, 524, "miles_in_time_range: 524");
    miles_in_time_range_sink.cq_next;
    while not miles_in_time_range_sink.cq_get_dvalid loop
      miles_in_time_range_sink.cq_next;
    end loop;
    tc_check(miles_in_time_range_sink.cq_get_d_nat, 1722, "miles_in_time_range: 1722");
    miles_in_time_range_sink.cq_next;
    while not miles_in_time_range_sink.cq_get_dvalid loop
      miles_in_time_range_sink.cq_next;
    end loop;
    tc_check(miles_in_time_range_sink.cq_get_d_nat, 398, "miles_in_time_range: 398");
    miles_in_time_range_sink.cq_next;
    while not miles_in_time_range_sink.cq_get_dvalid loop
      miles_in_time_range_sink.cq_next;
    end loop;
    tc_check(miles_in_time_range_sink.cq_get_d_nat, 1648, "miles_in_time_range: 1648");
    miles_in_time_range_sink.cq_next;
    while not miles_in_time_range_sink.cq_get_dvalid loop
      miles_in_time_range_sink.cq_next;
    end loop;
    tc_check(miles_in_time_range_sink.cq_get_d_nat, 755, "miles_in_time_range: 755");

    -- "const_speed_miles_in_band"
    tc_check(const_speed_miles_in_band_sink.pq_ready, true);
    while not const_speed_miles_in_band_sink.cq_get_dvalid loop
      const_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(const_speed_miles_in_band_sink.cq_get_d_nat, 1922, "const_speed_miles_in_band: 1922");
    const_speed_miles_in_band_sink.cq_next;
    while not const_speed_miles_in_band_sink.cq_get_dvalid loop
      const_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(const_speed_miles_in_band_sink.cq_get_d_nat, 1889, "const_speed_miles_in_band: 1889");
    const_speed_miles_in_band_sink.cq_next;
    while not const_speed_miles_in_band_sink.cq_get_dvalid loop
      const_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(const_speed_miles_in_band_sink.cq_get_d_nat, 679, "const_speed_miles_in_band: 679");
    const_speed_miles_in_band_sink.cq_next;
    while not const_speed_miles_in_band_sink.cq_get_dvalid loop
      const_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(const_speed_miles_in_band_sink.cq_get_d_nat, 140, "const_speed_miles_in_band: 140");
    const_speed_miles_in_band_sink.cq_next;
    while not const_speed_miles_in_band_sink.cq_get_dvalid loop
      const_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(const_speed_miles_in_band_sink.cq_get_d_nat, 1441, "const_speed_miles_in_band: 1441");
    const_speed_miles_in_band_sink.cq_next;
    while not const_speed_miles_in_band_sink.cq_get_dvalid loop
      const_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(const_speed_miles_in_band_sink.cq_get_d_nat, 210, "const_speed_miles_in_band: 210");

    -- "vary_speed_miles_in_band"
    tc_check(vary_speed_miles_in_band_sink.pq_ready, true);
    while not vary_speed_miles_in_band_sink.cq_get_dvalid loop
      vary_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(vary_speed_miles_in_band_sink.cq_get_d_nat, 99, "vary_speed_miles_in_band: 99");
    vary_speed_miles_in_band_sink.cq_next;
    while not vary_speed_miles_in_band_sink.cq_get_dvalid loop
      vary_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(vary_speed_miles_in_band_sink.cq_get_d_nat, 431, "vary_speed_miles_in_band: 431");
    vary_speed_miles_in_band_sink.cq_next;
    while not vary_speed_miles_in_band_sink.cq_get_dvalid loop
      vary_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(vary_speed_miles_in_band_sink.cq_get_d_nat, 1647, "vary_speed_miles_in_band: 1647");
    vary_speed_miles_in_band_sink.cq_next;
    while not vary_speed_miles_in_band_sink.cq_get_dvalid loop
      vary_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(vary_speed_miles_in_band_sink.cq_get_d_nat, 1414, "vary_speed_miles_in_band: 1414");
    vary_speed_miles_in_band_sink.cq_next;
    while not vary_speed_miles_in_band_sink.cq_get_dvalid loop
      vary_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(vary_speed_miles_in_band_sink.cq_get_d_nat, 562, "vary_speed_miles_in_band: 562");
    vary_speed_miles_in_band_sink.cq_next;
    while not vary_speed_miles_in_band_sink.cq_get_dvalid loop
      vary_speed_miles_in_band_sink.cq_next;
    end loop;
    tc_check(vary_speed_miles_in_band_sink.cq_get_d_nat, 83, "vary_speed_miles_in_band: 83");

    -- "sec_decel"
    tc_check(sec_decel_sink.pq_ready, true);
    while not sec_decel_sink.cq_get_dvalid loop
      sec_decel_sink.cq_next;
    end loop;
    tc_check(sec_decel_sink.cq_get_d_nat, 98, "sec_decel: 98");
    sec_decel_sink.cq_next;
    while not sec_decel_sink.cq_get_dvalid loop
      sec_decel_sink.cq_next;
    end loop;
    tc_check(sec_decel_sink.cq_get_d_nat, 1857, "sec_decel: 1857");
    sec_decel_sink.cq_next;
    while not sec_decel_sink.cq_get_dvalid loop
      sec_decel_sink.cq_next;
    end loop;
    tc_check(sec_decel_sink.cq_get_d_nat, 675, "sec_decel: 675");
    sec_decel_sink.cq_next;
    while not sec_decel_sink.cq_get_dvalid loop
      sec_decel_sink.cq_next;
    end loop;
    tc_check(sec_decel_sink.cq_get_d_nat, 1749, "sec_decel: 1749");
    sec_decel_sink.cq_next;
    while not sec_decel_sink.cq_get_dvalid loop
      sec_decel_sink.cq_next;
    end loop;
    tc_check(sec_decel_sink.cq_get_d_nat, 581, "sec_decel: 581");
    sec_decel_sink.cq_next;
    while not sec_decel_sink.cq_get_dvalid loop
      sec_decel_sink.cq_next;
    end loop;
    tc_check(sec_decel_sink.cq_get_d_nat, 896, "sec_decel: 896");

     -- "sec_accel"
     tc_check(sec_accel_sink.pq_ready, true);
     while not sec_accel_sink.cq_get_dvalid loop
       sec_accel_sink.cq_next;
     end loop;
     tc_check(sec_accel_sink.cq_get_d_nat, 387, "sec_accel: 387");
     sec_accel_sink.cq_next;
     while not sec_accel_sink.cq_get_dvalid loop
       sec_accel_sink.cq_next;
     end loop;
     tc_check(sec_accel_sink.cq_get_d_nat, 1379, "sec_accel: 1379");
     sec_accel_sink.cq_next;
     while not sec_accel_sink.cq_get_dvalid loop
       sec_accel_sink.cq_next;
     end loop;
     tc_check(sec_accel_sink.cq_get_d_nat, 1950, "sec_accel: 1950");
     sec_accel_sink.cq_next;
     while not sec_accel_sink.cq_get_dvalid loop
       sec_accel_sink.cq_next;
     end loop;
     tc_check(sec_accel_sink.cq_get_d_nat, 1205, "sec_accel: 1205");
     sec_accel_sink.cq_next;
     while not sec_accel_sink.cq_get_dvalid loop
       sec_accel_sink.cq_next;
     end loop;
     tc_check(sec_accel_sink.cq_get_d_nat, 1442, "sec_accel: 1442");
     sec_accel_sink.cq_next;
     while not sec_accel_sink.cq_get_dvalid loop
       sec_accel_sink.cq_next;
     end loop;
     tc_check(sec_accel_sink.cq_get_d_nat, 1507, "sec_accel: 1507");

     -- "braking"
    tc_check(braking_sink.pq_ready, true);
    while not braking_sink.cq_get_dvalid loop
      braking_sink.cq_next;
    end loop;
    tc_check(braking_sink.cq_get_d_nat, 1678, "braking: 1678");
    braking_sink.cq_next;
    while not braking_sink.cq_get_dvalid loop
      braking_sink.cq_next;
    end loop;
    tc_check(braking_sink.cq_get_d_nat, 1880, "braking: 1880");
    braking_sink.cq_next;
    while not braking_sink.cq_get_dvalid loop
      braking_sink.cq_next;
    end loop;
    tc_check(braking_sink.cq_get_d_nat, 308, "braking: 308");
    braking_sink.cq_next;
    while not braking_sink.cq_get_dvalid loop
      braking_sink.cq_next;
    end loop;
    tc_check(braking_sink.cq_get_d_nat, 1065, "braking: 1065");
    braking_sink.cq_next;
    while not braking_sink.cq_get_dvalid loop
      braking_sink.cq_next;
    end loop;
    tc_check(braking_sink.cq_get_d_nat, 1541, "braking: 1541");
    braking_sink.cq_next;
    while not braking_sink.cq_get_dvalid loop
      braking_sink.cq_next;
    end loop;
    tc_check(braking_sink.cq_get_d_nat, 717, "braking: 717");

    -- "accel"
    tc_check(accel_sink.pq_ready, true);
    while not accel_sink.cq_get_dvalid loop
      accel_sink.cq_next;
    end loop;
    tc_check(accel_sink.cq_get_d_nat, 147, "accel: 147");
    accel_sink.cq_next;
    while not accel_sink.cq_get_dvalid loop
      accel_sink.cq_next;
    end loop;
    tc_check(accel_sink.cq_get_d_nat, 845, "accel: 845");
    accel_sink.cq_next;
    while not accel_sink.cq_get_dvalid loop
      accel_sink.cq_next;
    end loop;
    tc_check(accel_sink.cq_get_d_nat, 923, "accel: 923");
    accel_sink.cq_next;
    while not accel_sink.cq_get_dvalid loop
      accel_sink.cq_next;
    end loop;
    tc_check(accel_sink.cq_get_d_nat, 254, "accel: 254");
    accel_sink.cq_next;
    while not accel_sink.cq_get_dvalid loop
      accel_sink.cq_next;
    end loop;
    tc_check(accel_sink.cq_get_d_nat, 1223, "accel: 1223");
    accel_sink.cq_next;
    while not accel_sink.cq_get_dvalid loop
      accel_sink.cq_next;
    end loop;
    tc_check(accel_sink.cq_get_d_nat, 1427, "accel: 1427");

    -- "small_speed_var"
    tc_check(small_speed_var_sink.pq_ready, true);
    while not small_speed_var_sink.cq_get_dvalid loop
      small_speed_var_sink.cq_next;
    end loop;
    tc_check(small_speed_var_sink.cq_get_d_nat, 867, "small_speed_var: 867");
    small_speed_var_sink.cq_next;
    while not small_speed_var_sink.cq_get_dvalid loop
      small_speed_var_sink.cq_next;
    end loop;
    tc_check(small_speed_var_sink.cq_get_d_nat, 1460, "small_speed_var: 1460");
    small_speed_var_sink.cq_next;
    while not small_speed_var_sink.cq_get_dvalid loop
      small_speed_var_sink.cq_next;
    end loop;
    tc_check(small_speed_var_sink.cq_get_d_nat, 1661, "small_speed_var: 1661");
    small_speed_var_sink.cq_next;
    while not small_speed_var_sink.cq_get_dvalid loop
      small_speed_var_sink.cq_next;
    end loop;
    tc_check(small_speed_var_sink.cq_get_d_nat, 1291, "small_speed_var: 1291");
    small_speed_var_sink.cq_next;
    while not small_speed_var_sink.cq_get_dvalid loop
      small_speed_var_sink.cq_next;
    end loop;
    tc_check(small_speed_var_sink.cq_get_d_nat, 1631, "small_speed_var: 1631");
    small_speed_var_sink.cq_next;
    while not small_speed_var_sink.cq_get_dvalid loop
      small_speed_var_sink.cq_next;
    end loop;
    tc_check(small_speed_var_sink.cq_get_d_nat, 410, "small_speed_var: 410");

    -- "large_speed_var"
    tc_check(large_speed_var_sink.pq_ready, true);
    while not large_speed_var_sink.cq_get_dvalid loop
      large_speed_var_sink.cq_next;
    end loop;
    tc_check(large_speed_var_sink.cq_get_d_nat, 1580, "large_speed_var: 1580");
    large_speed_var_sink.cq_next;
    while not large_speed_var_sink.cq_get_dvalid loop
      large_speed_var_sink.cq_next;
    end loop;
    tc_check(large_speed_var_sink.cq_get_d_nat, 1387, "large_speed_var: 1387");
    large_speed_var_sink.cq_next;
    while not large_speed_var_sink.cq_get_dvalid loop
      large_speed_var_sink.cq_next;
    end loop;
    tc_check(large_speed_var_sink.cq_get_d_nat, 1713, "large_speed_var: 1713");
    large_speed_var_sink.cq_next;
    while not large_speed_var_sink.cq_get_dvalid loop
      large_speed_var_sink.cq_next;
    end loop;
    tc_check(large_speed_var_sink.cq_get_d_nat, 360, "large_speed_var: 360");
    large_speed_var_sink.cq_next;
    while not large_speed_var_sink.cq_get_dvalid loop
      large_speed_var_sink.cq_next;
    end loop;
    tc_check(large_speed_var_sink.cq_get_d_nat, 1837, "large_speed_var: 1837");
    large_speed_var_sink.cq_next;
    while not large_speed_var_sink.cq_get_dvalid loop
      large_speed_var_sink.cq_next;
    end loop;
    tc_check(large_speed_var_sink.cq_get_d_nat, 92, "large_speed_var: 92");



    tc_pass;
    wait;
  end process;

end test_case;