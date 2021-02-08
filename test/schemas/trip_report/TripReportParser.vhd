library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;
use work.trip_report_pkg.all;
use work.tr_field_pkg.all;


entity TripReportParser is
  generic (
    EPC                                              : natural := 8;
        
    -- 
    -- INTEGER FIELDS
    --
    TIMEZONE_INT_WIDTH                               : natural := 16;
    TIMEZONE_INT_P_PIPELINE_STAGES                   : natural := 1;
    TIMEZONE_BUFFER_D                                : natural := 1;

    VIN_INT_WIDTH                                    : natural := 16;
    VIN_INT_P_PIPELINE_STAGES                        : natural := 1;
    VIN_BUFFER_D                                     : natural := 1;

    ODOMETER_INT_WIDTH                               : natural := 16;
    ODOMETER_INT_P_PIPELINE_STAGES                   : natural := 1;
    ODOMETER_BUFFER_D                                : natural := 1;

    AVGSPEED_INT_WIDTH                               : natural := 16;
    AVGSPEED_INT_P_PIPELINE_STAGES                   : natural := 1;
    AVGSPEED_BUFFER_D                                : natural := 1;

    ACCEL_DECEL_INT_WIDTH                            : natural := 16;
    ACCEL_DECEL_INT_P_PIPELINE_STAGES                : natural := 1;
    ACCEL_DECEL_BUFFER_D                             : natural := 1;

    SPEED_CHANGES_INT_WIDTH                          : natural := 16;
    SPEED_CHANGES_INT_P_PIPELINE_STAGES              : natural := 1;
    SPEED_CHANGES_BUFFER_D                           : natural := 1;

    -- 
    -- BOOLEAN FIELDS
    --
    HYPERMILING_BUFFER_D                              : natural := 1;
    ORIENTATION_BUFFER_D                              : natural := 1;

    -- 
    -- INTEGER ARRAY FIELDS
    --
    SEC_IN_BAND_INT_WIDTH                             : natural := 16;
    SEC_IN_BAND_INT_P_PIPELINE_STAGES                 : natural := 1;
    SEC_IN_BAND_BUFFER_D                              : natural := 1;

    MILES_IN_TIME_RANGE_INT_WIDTH                     : natural := 16;
    MILES_IN_TIME_RANGE_INT_P_PIPELINE_STAGES         : natural := 1; 
    MILES_IN_TIME_RANGE_BUFFER_D                      : natural := 1; 


    CONST_SPEED_MILES_IN_BAND_INT_WIDTH               : natural := 16;
    CONST_SPEED_MILES_IN_BAND_INT_P_PIPELINE_STAGES   : natural := 1; 
    CONST_SPEED_MILES_IN_BAND_BUFFER_D                : natural := 1; 


    VARY_SPEED_MILES_IN_BAND_INT_WIDTH                : natural := 16;
    VARY_SPEED_MILES_IN_BAND_INT_P_PIPELINE_STAGES    : natural := 1; 
    VARY_SPEED_MILES_IN_BAND_BUFFER_D                 : natural := 1; 


    SEC_DECEL_INT_WIDTH                               : natural := 16;
    SEC_DECEL_INT_P_PIPELINE_STAGES                   : natural := 1; 
    SEC_DECEL_BUFFER_D                                : natural := 1; 
                  
                  
    SEC_ACCEL_INT_WIDTH                               : natural := 16;
    SEC_ACCEL_INT_P_PIPELINE_STAGES                   : natural := 1; 
    SEC_ACCEL_BUFFER_D                                : natural := 1; 
                  
                  
    BRAKING_INT_WIDTH                                 : natural := 16;
    BRAKING_INT_P_PIPELINE_STAGES                     : natural := 1; 
    BRAKING_BUFFER_D                                  : natural := 1; 


    ACCEL_INT_WIDTH                                   : natural := 16;
    ACCEL_INT_P_PIPELINE_STAGES                       : natural := 1; 
    ACCEL_BUFFER_D                                    : natural := 1; 


    SMALL_SPEED_VAR_INT_WIDTH                         : natural := 16;
    SMALL_SPEED_VAR_INT_P_PIPELINE_STAGES             : natural := 1; 
    SMALL_SPEED_VAR_BUFFER_D                          : natural := 1; 


    LARGE_SPEED_VAR_INT_WIDTH                         : natural := 16;
    LARGE_SPEED_VAR_INT_P_PIPELINE_STAGES             : natural := 1; 
    LARGE_SPEED_VAR_BUFFER_D                          : natural := 1;

    -- 
    -- STRING FIELDS
    --
    TIMESTAMP_BUFFER_D                          : natural := 1;

    END_REQ_EN                                  : boolean := false
    );              
    port (              
    clk                                         : in  std_logic;
    reset                                       : in  std_logic;
    
    in_valid                                    : in  std_logic;
    in_ready                                    : out std_logic;
    in_data                                     : in  std_logic_vector(8*EPC-1 downto 0);
    in_last                                     : in  std_logic_vector(2*EPC-1 downto 0);
    in_stai                                     : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
    in_endi                                     : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
    in_strb                                     : in  std_logic_vector(EPC-1 downto 0);
    
    end_req                                     : in  std_logic := '0';
    end_ack                                     : out std_logic;
    
    timezone_valid                              : out std_logic;
    timezone_ready                              : in  std_logic;
    timezone_strb                               : out std_logic;
    timezone_data                               : out std_logic_vector(TIMEZONE_INT_WIDTH-1 downto 0);
    timezone_last                               : out std_logic_vector(1 downto 0);

    --    
    -- INTEGER FIELDS   
    --    
    vin_valid                                   : out std_logic;
    vin_ready                                   : in  std_logic;
    vin_data                                    : out std_logic_vector(VIN_INT_WIDTH-1 downto 0);
    vin_strb                                    : out std_logic;
    vin_last                                    : out std_logic_vector(1 downto 0);
        
    odometer_valid                              : out std_logic;
    odometer_ready                              : in  std_logic;
    odometer_data                               : out std_logic_vector(ODOMETER_INT_WIDTH-1 downto 0);
    odometer_strb                               : out std_logic;
    odometer_last                               : out std_logic_vector(1 downto 0);

    avgspeed_valid                              : out std_logic;
    avgspeed_ready                              : in  std_logic;
    avgspeed_data                               : out std_logic_vector(AVGSPEED_INT_WIDTH-1 downto 0);
    avgspeed_strb                               : out std_logic;
    avgspeed_last                               : out std_logic_vector(1 downto 0);

    accel_decel_valid                           : out std_logic;
    accel_decel_ready                           : in  std_logic;
    accel_decel_data                            : out std_logic_vector(ACCEL_DECEL_INT_WIDTH-1 downto 0);
    accel_decel_strb                            : out std_logic;
    accel_decel_last                            : out std_logic_vector(1 downto 0);

    speed_changes_valid                         : out std_logic;
    speed_changes_ready                         : in  std_logic;
    speed_changes_data                          : out std_logic_vector(SPEED_CHANGES_INT_WIDTH-1 downto 0);
    speed_changes_strb                          : out std_logic;
    speed_changes_last                          : out std_logic_vector(1 downto 0);

    --    
    -- BOOLEAN FIELDS   
    --    
    hypermiling_valid                           : out std_logic;
    hypermiling_ready                           : in  std_logic;
    hypermiling_data                            : out std_logic;
    hypermiling_strb                            : out std_logic;
    hypermiling_last                            : out std_logic_vector(1 downto 0);

    orientation_valid                           : out std_logic;
    orientation_ready                           : in  std_logic;
    orientation_data                            : out std_logic;
    orientation_strb                            : out std_logic;
    orientation_last                            : out std_logic_vector(1 downto 0);

    --    
    -- INTEGER ARRAY FIELDS   
    --    
    sec_in_band_valid                           : out std_logic;
    sec_in_band_ready                           : in  std_logic;
    sec_in_band_data                            : out std_logic_vector(SEC_IN_BAND_INT_WIDTH-1 downto 0);
    sec_in_band_strb                            : out std_logic;
    sec_in_band_last                            : out std_logic_vector(2 downto 0);

    miles_in_time_range_valid                   : out std_logic;
    miles_in_time_range_ready                   : in  std_logic;
    miles_in_time_range_data                    : out std_logic_vector(MILES_IN_TIME_RANGE_INT_WIDTH-1 downto 0);
    miles_in_time_range_strb                    : out std_logic;
    miles_in_time_range_last                    : out std_logic_vector(2 downto 0);


    const_speed_miles_in_band_valid             : out std_logic;
    const_speed_miles_in_band_ready             : in  std_logic;
    const_speed_miles_in_band_data              : out std_logic_vector(CONST_SPEED_MILES_IN_BAND_INT_WIDTH-1 downto 0);
    const_speed_miles_in_band_strb              : out std_logic;
    const_speed_miles_in_band_last              : out std_logic_vector(2 downto 0);


    vary_speed_miles_in_band_valid              : out std_logic;
    vary_speed_miles_in_band_ready              : in  std_logic;
    vary_speed_miles_in_band_data               : out std_logic_vector(VARY_SPEED_MILES_IN_BAND_INT_WIDTH-1 downto 0);
    vary_speed_miles_in_band_strb               : out std_logic;
    vary_speed_miles_in_band_last               : out std_logic_vector(2 downto 0);


    sec_decel_valid                             : out std_logic;
    sec_decel_ready                             : in  std_logic;
    sec_decel_data                              : out std_logic_vector(SEC_DECEL_INT_WIDTH-1 downto 0);
    sec_decel_strb                              : out std_logic;
    sec_decel_last                              : out std_logic_vector(2 downto 0);
      
      
    sec_accel_valid                             : out std_logic;
    sec_accel_ready                             : in  std_logic;
    sec_accel_data                              : out std_logic_vector(SEC_ACCEL_INT_WIDTH-1 downto 0);
    sec_accel_strb                              : out std_logic;
    sec_accel_last                              : out std_logic_vector(2 downto 0);
      
      
    braking_valid                               : out std_logic;
    braking_ready                               : in  std_logic;
    braking_data                                : out std_logic_vector(BRAKING_INT_WIDTH-1 downto 0);
    braking_strb                                : out std_logic;
    braking_last                                : out std_logic_vector(2 downto 0);


    accel_valid                                 : out std_logic;
    accel_ready                                 : in  std_logic;
    accel_data                                  : out std_logic_vector(ACCEL_INT_WIDTH-1 downto 0);
    accel_strb                                  : out std_logic;
    accel_last                                  : out std_logic_vector(2 downto 0);


    small_speed_var_valid                       : out std_logic;
    small_speed_var_ready                       : in  std_logic;
    small_speed_var_data                        : out std_logic_vector(SMALL_SPEED_VAR_INT_WIDTH-1 downto 0);
    small_speed_var_strb                        : out std_logic;
    small_speed_var_last                        : out std_logic_vector(2 downto 0);


    large_speed_var_valid                       : out std_logic;
    large_speed_var_ready                       : in  std_logic;
    large_speed_var_data                        : out std_logic_vector(LARGE_SPEED_VAR_INT_WIDTH-1 downto 0);
    large_speed_var_strb                        : out std_logic;
    large_speed_var_last                        : out std_logic_vector(2 downto 0);

    --    
    -- STRING FIELDS   
    -- 
    timestamp_valid                             : out std_logic;
    timestamp_ready                             : in  std_logic;
    timestamp_data                              : out std_logic_vector(8*EPC-1 downto 0);
    timestamp_last                              : out std_logic_vector(3*EPC-1 downto 0);
    timestamp_stai                              : out std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
    timestamp_endi                              : out std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
    timestamp_strb                              : out std_logic_vector(EPC-1 downto 0)
  );
end TripReportParser;

architecture arch of TripReportParser is

  signal rec_ready        : std_logic;
  signal rec_valid        : std_logic;
  signal rec_data         : std_logic_vector(EPC + EPC*8-1 downto 0);
  signal rec_stai         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal rec_endi         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal rec_strb         : std_logic_vector(EPC-1 downto 0);
  signal rec_empty        : std_logic_vector(EPC-1 downto 0);
  signal rec_last         : std_logic_vector(EPC*3-1 downto 0);

  signal tag_dbg : std_logic_vector(EPC-1 downto 0);

  

  
  -- 
  -- INTEGER FIELDS
  --
  signal timezone_i_valid      : std_logic;
  signal timezone_i_ready      : std_logic;

  signal vin_i_valid           : std_logic;
  signal vin_i_ready           : std_logic;

  signal odometer_i_valid      : std_logic;
  signal odometer_i_ready      : std_logic;

  signal avgspeed_i_valid      : std_logic;
  signal avgspeed_i_ready      : std_logic;

  signal accel_decel_i_valid   : std_logic;
  signal accel_decel_i_ready   : std_logic;

  signal speed_changes_i_valid : std_logic;
  signal speed_changes_i_ready : std_logic;

  -- 
  -- BOOLEAN FIELDS
  --
  signal hypermiling_i_valid   : std_logic;
  signal hypermiling_i_ready   : std_logic;

  signal orientation_i_valid   : std_logic;
  signal orientation_i_ready   : std_logic;

  -- 
  -- INTEGER ARRAY FIELDS
  --
  signal sec_in_band_i_valid                : std_logic;
  signal sec_in_band_i_ready                : std_logic;

  signal miles_in_time_range_i_valid        : std_logic;
  signal miles_in_time_range_i_ready        : std_logic;

  signal const_speed_miles_in_band_i_valid  : std_logic;
  signal const_speed_miles_in_band_i_ready  : std_logic;

  signal vary_speed_miles_in_band_i_valid   : std_logic;
  signal vary_speed_miles_in_band_i_ready   : std_logic;

  signal sec_decel_i_valid                  : std_logic;
  signal sec_decel_i_ready                  : std_logic;

  signal sec_accel_i_valid                  : std_logic;
  signal sec_accel_i_ready                  : std_logic;

  signal braking_i_valid                    : std_logic;
  signal braking_i_ready                    : std_logic;

  signal accel_i_valid                      : std_logic;
  signal accel_i_ready                      : std_logic;

  signal small_speed_var_i_valid            : std_logic;
  signal small_speed_var_i_ready            : std_logic;

  signal large_speed_var_i_valid            : std_logic;
  signal large_speed_var_i_ready            : std_logic;

  -- 
  -- STRING FIELDS
  --
  signal timestamp_i_valid        : std_logic;
  signal timestamp_i_ready        : std_logic;

begin


  tag_dbg <= rec_data(EPC + EPC*8-1 downto EPC*8);

  -- Main record parser
  record_parser_i: JsonRecordParser
    generic map (
      EPC                         => EPC,
      OUTER_NESTING_LEVEL         => 1,
      INNER_NESTING_LEVEL         => 1,
      END_REQ_EN                  => END_REQ_EN
    )
    port map (
      clk                         => clk,
      reset                       => reset,
      in_valid                    => in_valid,
      in_ready                    => in_ready,
      in_data                     => in_data,
      in_strb                     => in_strb,
      in_last                     => in_last,
      in_stai                     => in_stai,
      in_endi                     => in_endi,
      out_data                    => rec_data,
      out_stai                    => rec_stai,
      out_endi                    => rec_endi,
      out_ready                   => rec_ready,
      out_valid                   => rec_valid,
      out_strb                    => rec_strb,
      out_last                    => rec_last  
    );

  sync_i: StreamSync
    generic map (
      NUM_INPUTS              => 1,
      NUM_OUTPUTS             => 19
    )
    port map (
      clk                     => clk,
      reset                   => reset,
      in_valid(0)             => rec_valid,
      in_ready(0)             => rec_ready,

      out_valid(0)            => timezone_i_valid,
      out_valid(1)            => vin_i_valid,
      out_valid(2)            => odometer_i_valid,
      out_valid(3)            => avgspeed_i_valid,
      out_valid(4)            => accel_decel_i_valid,
      out_valid(5)            => speed_changes_i_valid,
      out_valid(6)            => hypermiling_i_valid,
      out_valid(7)            => orientation_i_valid,
      out_valid(8)            => sec_in_band_i_valid,
      out_valid(9)            => miles_in_time_range_i_valid,
      out_valid(10)           => const_speed_miles_in_band_i_valid,
      out_valid(11)           => vary_speed_miles_in_band_i_valid,
      out_valid(12)           => sec_decel_i_valid,
      out_valid(13)           => sec_accel_i_valid,
      out_valid(14)           => braking_i_valid,
      out_valid(15)           => accel_i_valid,
      out_valid(16)           => small_speed_var_i_valid,
      out_valid(17)           => large_speed_var_i_valid,
      out_valid(18)           => timestamp_i_valid,


      out_ready(0)            => timezone_i_ready,
      out_ready(1)            => vin_i_ready,
      out_ready(2)            => odometer_i_ready,
      out_ready(3)            => avgspeed_i_ready,
      out_ready(4)            => accel_decel_i_ready,
      out_ready(5)            => speed_changes_i_ready,
      out_ready(6)            => hypermiling_i_ready,
      out_ready(7)            => orientation_i_ready,
      out_ready(8)            => sec_in_band_i_ready,
      out_ready(9)            => miles_in_time_range_i_ready,
      out_ready(10)           => const_speed_miles_in_band_i_ready,
      out_ready(11)           => vary_speed_miles_in_band_i_ready,
      out_ready(12)           => sec_decel_i_ready,
      out_ready(13)           => sec_accel_i_ready,
      out_ready(14)           => braking_i_ready,
      out_ready(15)           => accel_i_ready,
      out_ready(16)           => small_speed_var_i_ready,
      out_ready(17)           => large_speed_var_i_ready,
      out_ready(18)           => timestamp_i_ready

    );

    timezone_f_i: timezone_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => TIMEZONE_INT_WIDTH,
      INT_P_PIPELINE_STAGES => TIMEZONE_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => TIMEZONE_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => timezone_i_valid,
      in_ready              => timezone_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => timezone_valid,
      out_ready             => timezone_ready,
      out_data              => timezone_data,
      out_last              => timezone_last,
      out_strb              => timezone_strb
    );

    vin_f_i: vin_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => VIN_INT_WIDTH,
      INT_P_PIPELINE_STAGES => VIN_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => VIN_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => vin_i_valid,
      in_ready              => vin_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => vin_valid,
      out_ready             => vin_ready,
      out_data              => vin_data,
      out_strb              => vin_strb,
      out_last              => vin_last
    );

    odometer_f_i: odometer_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => ODOMETER_INT_WIDTH,
      INT_P_PIPELINE_STAGES => ODOMETER_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => ODOMETER_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => odometer_i_valid,
      in_ready              => odometer_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => odometer_valid,
      out_ready             => odometer_ready,
      out_data              => odometer_data,
      out_strb              => odometer_strb,
      out_last              => odometer_last
    );

    avgspeed_f_i: avgspeed_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => AVGSPEED_INT_WIDTH,
      INT_P_PIPELINE_STAGES => AVGSPEED_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => AVGSPEED_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => avgspeed_i_valid,
      in_ready              => avgspeed_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => avgspeed_valid,
      out_ready             => avgspeed_ready,
      out_data              => avgspeed_data,
      out_strb              => avgspeed_strb,
      out_last              => avgspeed_last
    );

    accel_decel_f_i: accel_decel_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => ACCEL_DECEL_INT_WIDTH,
      INT_P_PIPELINE_STAGES => ACCEL_DECEL_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => ACCEL_DECEL_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => accel_decel_i_valid,
      in_ready              => accel_decel_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => accel_decel_valid,
      out_ready             => accel_decel_ready,
      out_data              => accel_decel_data,
      out_strb              => accel_decel_strb,
      out_last              => accel_decel_last
    );

    speed_changes_f_i: speed_changes_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SPEED_CHANGES_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SPEED_CHANGES_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SPEED_CHANGES_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => speed_changes_i_valid,
      in_ready              => speed_changes_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => speed_changes_valid,
      out_ready             => speed_changes_ready,
      out_data              => speed_changes_data,
      out_strb              => speed_changes_strb,
      out_last              => speed_changes_last
    );

    hypermiling_f_i: hypermiling_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      BUFER_DEPTH           => VIN_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => hypermiling_i_valid,
      in_ready              => hypermiling_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => hypermiling_valid,
      out_ready             => hypermiling_ready,
      out_data              => hypermiling_data,
      out_strb              => hypermiling_strb,
      out_last              => hypermiling_last
    );

    orientation_f_i: orientation_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      BUFER_DEPTH           => VIN_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => orientation_i_valid,
      in_ready              => orientation_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => orientation_valid,
      out_ready             => orientation_ready,
      out_data              => orientation_data,
      out_strb              => orientation_strb,
      out_last              => orientation_last
    );

    sec_in_band_f_i: sec_in_band_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SEC_IN_BAND_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SEC_IN_BAND_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SEC_IN_BAND_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => sec_in_band_i_valid,
      in_ready              => sec_in_band_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => sec_in_band_valid,
      out_ready             => sec_in_band_ready,
      out_data              => sec_in_band_data,
      out_strb              => sec_in_band_strb,
      out_last              => sec_in_band_last
    );

    miles_in_time_range_i: miles_in_time_range_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => MILES_IN_TIME_RANGE_INT_WIDTH,
      INT_P_PIPELINE_STAGES => MILES_IN_TIME_RANGE_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => MILES_IN_TIME_RANGE_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => miles_in_time_range_i_valid,
      in_ready              => miles_in_time_range_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => miles_in_time_range_valid,
      out_ready             => miles_in_time_range_ready,
      out_data              => miles_in_time_range_data,
      out_strb              => miles_in_time_range_strb,
      out_last              => miles_in_time_range_last
    );

    const_speed_miles_in_band_i: const_speed_miles_in_band_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => CONST_SPEED_MILES_IN_BAND_INT_WIDTH,
      INT_P_PIPELINE_STAGES => CONST_SPEED_MILES_IN_BAND_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => CONST_SPEED_MILES_IN_BAND_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => const_speed_miles_in_band_i_valid,
      in_ready              => const_speed_miles_in_band_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => const_speed_miles_in_band_valid,
      out_ready             => const_speed_miles_in_band_ready,
      out_data              => const_speed_miles_in_band_data,
      out_strb              => const_speed_miles_in_band_strb,
      out_last              => const_speed_miles_in_band_last
    );

    vary_speed_miles_in_band_i: vary_speed_miles_in_band_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => VARY_SPEED_MILES_IN_BAND_INT_WIDTH,
      INT_P_PIPELINE_STAGES => VARY_SPEED_MILES_IN_BAND_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => VARY_SPEED_MILES_IN_BAND_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => vary_speed_miles_in_band_i_valid,
      in_ready              => vary_speed_miles_in_band_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => vary_speed_miles_in_band_valid,
      out_ready             => vary_speed_miles_in_band_ready,
      out_data              => vary_speed_miles_in_band_data,
      out_strb              => vary_speed_miles_in_band_strb,
      out_last              => vary_speed_miles_in_band_last
    );

    sec_decel_i: sec_decel_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SEC_DECEL_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SEC_DECEL_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SEC_DECEL_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => sec_decel_i_valid,
      in_ready              => sec_decel_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => sec_decel_valid,
      out_ready             => sec_decel_ready,
      out_data              => sec_decel_data,
      out_strb              => sec_decel_strb,
      out_last              => sec_decel_last
    );

    sec_accel_i: sec_accel_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SEC_ACCEL_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SEC_ACCEL_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SEC_ACCEL_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => sec_accel_i_valid,
      in_ready              => sec_accel_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => sec_accel_valid,
      out_ready             => sec_accel_ready,
      out_data              => sec_accel_data,
      out_strb              => sec_accel_strb,
      out_last              => sec_accel_last
    );

    braking_i: braking_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => BRAKING_INT_WIDTH,
      INT_P_PIPELINE_STAGES => BRAKING_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => BRAKING_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => braking_i_valid,
      in_ready              => braking_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => braking_valid,
      out_ready             => braking_ready,
      out_data              => braking_data,
      out_strb              => braking_strb,
      out_last              => braking_last
    );

    accel_i: accel_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => ACCEL_INT_WIDTH,
      INT_P_PIPELINE_STAGES => ACCEL_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => ACCEL_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => accel_i_valid,
      in_ready              => accel_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => accel_valid,
      out_ready             => accel_ready,
      out_data              => accel_data,
      out_strb              => accel_strb,
      out_last              => accel_last
    );

    small_speed_var_i: small_speed_var_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SMALL_SPEED_VAR_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SMALL_SPEED_VAR_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SMALL_SPEED_VAR_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => small_speed_var_i_valid,
      in_ready              => small_speed_var_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => small_speed_var_valid,
      out_ready             => small_speed_var_ready,
      out_data              => small_speed_var_data,
      out_strb              => small_speed_var_strb,
      out_last              => small_speed_var_last
    );

    large_speed_var_i: large_speed_var_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => LARGE_SPEED_VAR_INT_WIDTH,
      INT_P_PIPELINE_STAGES => LARGE_SPEED_VAR_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => LARGE_SPEED_VAR_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => large_speed_var_i_valid,
      in_ready              => large_speed_var_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => large_speed_var_valid,
      out_ready             => large_speed_var_ready,
      out_data              => large_speed_var_data,
      out_strb              => large_speed_var_strb,
      out_last              => large_speed_var_last
    );

    timestamp_f_i: timestamp_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      BUFER_DEPTH           => TIMESTAMP_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => timestamp_i_valid,
      in_ready              => timestamp_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => timestamp_valid,
      out_ready             => timestamp_ready,
      out_data              => timestamp_data,
      out_last              => timestamp_last,
      out_strb              => timestamp_strb,
      out_stai              => timestamp_stai,
      out_endi              => timestamp_endi
    );

    
end arch;