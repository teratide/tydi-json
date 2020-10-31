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
    EPC                                     : natural := 8;
    
    -- 
    -- INTEGER FIELDS
    --
    TIMEZONE_INT_WIDTH                      : natural := 16;
    TIMEZONE_INT_P_PIPELINE_STAGES          : natural := 1;
    TIMEZONE_BUFFER_D                       : natural := 1;

    VIN_INT_WIDTH                           : natural := 16;
    VIN_INT_P_PIPELINE_STAGES               : natural := 1;
    VIN_BUFFER_D                            : natural := 1;

    ODOMETER_INT_WIDTH                      : natural := 16;
    ODOMETER_INT_P_PIPELINE_STAGES          : natural := 1;
    ODOMETER_BUFFER_D                       : natural := 1;

    AVG_SPEED_INT_WIDTH                     : natural := 16;
    AVG_SPEED_INT_P_PIPELINE_STAGES         : natural := 1;
    AVG_SPEED_BUFFER_D                      : natural := 1;

    S_ACC_DEC_INT_WIDTH                     : natural := 16;
    S_ACC_DEC_INT_P_PIPELINE_STAGES         : natural := 1;
    S_ACC_DEC_BUFFER_D                      : natural := 1;

    E_SPD_CHG_INT_WIDTH                     : natural := 16;
    E_SPD_CHG_INT_P_PIPELINE_STAGES         : natural := 1;
    E_SPD_CHG_BUFFER_D                      : natural := 1;

    -- 
    -- BOOLEAN FIELDS
    --
    HYPER_MILING_BUFFER_D                   : natural := 1;
    ORIENTATION_BUFFER_D                    : natural := 1;

    -- 
    -- INTEGER ARRAY FIELDS
    --
    SECS_IN_B_INT_WIDTH                     : natural := 16;
    SECS_IN_B_INT_P_PIPELINE_STAGES         : natural := 1;
    SECS_IN_B_BUFFER_D                      : natural := 1;

    MILES_IN_TIME_INT_WIDTH                 : natural := 16;
    MILES_IN_TIME_INT_P_PIPELINE_STAGES     : natural := 1; 
    MILES_IN_TIME_BUFFER_D                  : natural := 1; 


    CONST_SPD_M_IN_B_INT_WIDTH              : natural := 16;
    CONST_SPD_M_IN_B_INT_P_PIPELINE_STAGES  : natural := 1; 
    CONST_SPD_M_IN_B_BUFFER_D               : natural := 1; 


    VAR_SPD_M_IN_B_INT_WIDTH                : natural := 16;
    VAR_SPD_M_IN_B_INT_P_PIPELINE_STAGES    : natural := 1; 
    VAR_SPD_M_IN_B_BUFFER_D                 : natural := 1; 


    SECONDS_DECEL_INT_WIDTH                 : natural := 16;
    SECONDS_DECEL_INT_P_PIPELINE_STAGES     : natural := 1; 
    SECONDS_DECEL_BUFFER_D                  : natural := 1; 


    SECONDS_ACCEL_INT_WIDTH                 : natural := 16;
    SECONDS_ACCEL_INT_P_PIPELINE_STAGES     : natural := 1; 
    SECONDS_ACCEL_BUFFER_D                  : natural := 1; 


    BRK_M_T_10S_INT_WIDTH                   : natural := 16;
    BRK_M_T_10S_INT_P_PIPELINE_STAGES       : natural := 1; 
    BRK_M_T_10S_BUFFER_D                    : natural := 1; 


    ACCEL_M_T_10S_INT_WIDTH                 : natural := 16;
    ACCEL_M_T_10S_INT_P_PIPELINE_STAGES     : natural := 1; 
    ACCEL_M_T_10S_BUFFER_D                  : natural := 1; 


    SMALL_SPD_V_M_INT_WIDTH                 : natural := 16;
    SMALL_SPD_V_M_INT_P_PIPELINE_STAGES     : natural := 1; 
    SMALL_SPD_V_M_BUFFER_D                  : natural := 1; 


    LARGE_SPD_V_M_INT_WIDTH                 : natural := 16;
    LARGE_SPD_V_M_INT_P_PIPELINE_STAGES     : natural := 1; 
    LARGE_SPD_V_M_BUFFER_D                  : natural := 1;

    -- 
    -- STRING FIELDS
    --
    TIMESTAMP_BUFFER_D                      : natural := 1;

    END_REQ_EN                              : boolean := false
  );              
  port (              
    clk                                     : in  std_logic;
    reset                                   : in  std_logic;

    in_valid                                : in  std_logic;
    in_ready                                : out std_logic;
    in_data                                 : in  std_logic_vector(8*EPC-1 downto 0);
    in_last                                 : in  std_logic_vector(2*EPC-1 downto 0);
    in_stai                                 : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
    in_endi                                 : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
    in_strb                                 : in  std_logic_vector(EPC-1 downto 0);

    end_req                                 : in  std_logic := '0';
    end_ack                                 : out std_logic;

    timezone_valid                          : out std_logic;
    timezone_ready                          : in  std_logic;
    timezone_data                           : out std_logic_vector(TIMEZONE_INT_WIDTH-1 downto 0);
    timezone_strb                           : out std_logic;
    timezone_last                           : out std_logic_vector(1 downto 0);

    --    
    -- INTEGER FIELDS   
    --    
    vin_valid                               : out std_logic;
    vin_ready                               : in  std_logic;
    vin_data                                : out std_logic_vector(VIN_INT_WIDTH-1 downto 0);
    vin_strb                                : out std_logic;
    vin_last                                : out std_logic_vector(1 downto 0);

    odometer_valid                          : out std_logic;
    odometer_ready                          : in  std_logic;
    odometer_data                           : out std_logic_vector(ODOMETER_INT_WIDTH-1 downto 0);
    odometer_strb                           : out std_logic;
    odometer_last                           : out std_logic_vector(1 downto 0);

    avg_speed_valid                         : out std_logic;
    avg_speed_ready                         : in  std_logic;
    avg_speed_data                          : out std_logic_vector(AVG_SPEED_INT_WIDTH-1 downto 0);
    avg_speed_strb                          : out std_logic;
    avg_speed_last                          : out std_logic_vector(1 downto 0);

    s_acc_dec_valid                         : out std_logic;
    s_acc_dec_ready                         : in  std_logic;
    s_acc_dec_data                          : out std_logic_vector(S_ACC_DEC_INT_WIDTH-1 downto 0);
    s_acc_dec_strb                          : out std_logic;
    s_acc_dec_last                          : out std_logic_vector(1 downto 0);

    e_spd_chg_valid                         : out std_logic;
    e_spd_chg_ready                         : in  std_logic;
    e_spd_chg_data                          : out std_logic_vector(E_SPD_CHG_INT_WIDTH-1 downto 0);
    e_spd_chg_strb                          : out std_logic;
    e_spd_chg_last                          : out std_logic_vector(1 downto 0);

    --    
    -- BOOLEAN FIELDS   
    --    
    hyper_miling_valid                      : out std_logic;
    hyper_miling_ready                      : in  std_logic;
    hyper_miling_data                       : out std_logic;
    hyper_miling_strb                       : out std_logic;
    hyper_miling_last                       : out std_logic_vector(1 downto 0);

    orientation_valid                       : out std_logic;
    orientation_ready                       : in  std_logic;
    orientation_data                        : out std_logic;
    orientation_strb                        : out std_logic;
    orientation_last                        : out std_logic_vector(1 downto 0);

    --    
    -- INTEGER ARRAY FIELDS   
    --    
    secs_in_b_valid                         : out std_logic;
    secs_in_b_ready                         : in  std_logic;
    secs_in_b_data                          : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    secs_in_b_strb                          : out std_logic;
    secs_in_b_last                          : out std_logic_vector(2 downto 0);

    miles_in_time_valid                     : out std_logic;
    miles_in_time_ready                     : in  std_logic;
    miles_in_time_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    miles_in_time_strb                      : out std_logic;
    miles_in_time_last                      : out std_logic_vector(2 downto 0);


    const_spd_m_in_b_valid                  : out std_logic;
    const_spd_m_in_b_ready                  : in  std_logic;
    const_spd_m_in_b_data                   : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    const_spd_m_in_b_strb                   : out std_logic;
    const_spd_m_in_b_last                   : out std_logic_vector(2 downto 0);


    var_spd_m_in_b_valid                    : out std_logic;
    var_spd_m_in_b_ready                    : in  std_logic;
    var_spd_m_in_b_data                     : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    var_spd_m_in_b_strb                     : out std_logic;
    var_spd_m_in_b_last                     : out std_logic_vector(2 downto 0);


    seconds_decel_valid                     : out std_logic;
    seconds_decel_ready                     : in  std_logic;
    seconds_decel_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    seconds_decel_strb                      : out std_logic;
    seconds_decel_last                      : out std_logic_vector(2 downto 0);


    seconds_accel_valid                     : out std_logic;
    seconds_accel_ready                     : in  std_logic;
    seconds_accel_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    seconds_accel_strb                      : out std_logic;
    seconds_accel_last                      : out std_logic_vector(2 downto 0);


    brk_m_t_10s_valid                       : out std_logic;
    brk_m_t_10s_ready                       : in  std_logic;
    brk_m_t_10s_data                        : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    brk_m_t_10s_strb                        : out std_logic;
    brk_m_t_10s_last                        : out std_logic_vector(2 downto 0);


    accel_m_t_10s_valid                     : out std_logic;
    accel_m_t_10s_ready                     : in  std_logic;
    accel_m_t_10s_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    accel_m_t_10s_strb                      : out std_logic;
    accel_m_t_10s_last                      : out std_logic_vector(2 downto 0);


    small_spd_v_m_valid                     : out std_logic;
    small_spd_v_m_ready                     : in  std_logic;
    small_spd_v_m_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    small_spd_v_m_strb                      : out std_logic;
    small_spd_v_m_last                      : out std_logic_vector(2 downto 0);


    large_spd_v_m_valid                     : out std_logic;
    large_spd_v_m_ready                     : in  std_logic;
    large_spd_v_m_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
    large_spd_v_m_strb                      : out std_logic;
    large_spd_v_m_last                      : out std_logic_vector(2 downto 0);

    --    
    -- STRING FIELDS   
    -- 
    timestamp_valid                         : out std_logic;
    timestamp_ready                         : in  std_logic;
    timestamp_data                          : out std_logic_vector(8*EPC-1 downto 0);
    timestamp_last                          : out std_logic_vector(3*EPC-1 downto 0);
    timestamp_stai                          : out std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
    timestamp_endi                          : out std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
    timestamp_strb                          : out std_logic_vector(EPC-1 downto 0)
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
  signal timezone_i_valid  : std_logic;
  signal timezone_i_ready  : std_logic;

  signal vin_i_valid       : std_logic;
  signal vin_i_ready       : std_logic;

  signal odometer_i_valid  : std_logic;
  signal odometer_i_ready  : std_logic;

  signal avg_speed_i_valid : std_logic;
  signal avg_speed_i_ready : std_logic;

  signal s_acc_dec_i_valid : std_logic;
  signal s_acc_dec_i_ready : std_logic;

  signal e_spd_chg_i_valid : std_logic;
  signal e_spd_chg_i_ready : std_logic;

  -- 
  -- BOOLEAN FIELDS
  --
  signal hyper_miling_i_valid  : std_logic;
  signal hyper_miling_i_ready  : std_logic;

  signal orientation_i_valid   : std_logic;
  signal orientation_i_ready   : std_logic;

  -- 
  -- INTEGER ARRAY FIELDS
  --
  signal secs_in_b_i_valid        : std_logic;
  signal secs_in_b_i_ready        : std_logic;

  signal miles_in_time_i_valid    : std_logic;
  signal miles_in_time_i_ready    : std_logic;

  signal const_spd_m_in_b_i_valid : std_logic;
  signal const_spd_m_in_b_i_ready : std_logic;

  signal var_spd_m_in_b_i_valid   : std_logic;
  signal var_spd_m_in_b_i_ready   : std_logic;

  signal seconds_decel_i_valid    : std_logic;
  signal seconds_decel_i_ready    : std_logic;

  signal seconds_accel_i_valid    : std_logic;
  signal seconds_accel_i_ready    : std_logic;

  signal brk_m_t_10s_i_valid      : std_logic;
  signal brk_m_t_10s_i_ready      : std_logic;

  signal accel_m_t_10s_i_valid    : std_logic;
  signal accel_m_t_10s_i_ready    : std_logic;

  signal small_spd_v_m_i_valid    : std_logic;
  signal small_spd_v_m_i_ready    : std_logic;

  signal large_spd_v_m_i_valid    : std_logic;
  signal large_spd_v_m_i_ready    : std_logic;

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
      out_valid(3)            => avg_speed_i_valid,
      out_valid(4)            => s_acc_dec_i_valid,
      out_valid(5)            => e_spd_chg_i_valid,
      out_valid(6)            => hyper_miling_i_valid,
      out_valid(7)            => orientation_i_valid,
      out_valid(8)            => secs_in_b_i_valid,
      out_valid(9)            => miles_in_time_i_valid,
      out_valid(10)           => const_spd_m_in_b_i_valid,
      out_valid(11)           => var_spd_m_in_b_i_valid,
      out_valid(12)           => seconds_decel_i_valid,
      out_valid(13)           => seconds_accel_i_valid,
      out_valid(14)           => brk_m_t_10s_i_valid,
      out_valid(15)           => accel_m_t_10s_i_valid,
      out_valid(16)           => small_spd_v_m_i_valid,
      out_valid(17)           => large_spd_v_m_i_valid,
      out_valid(18)           => timestamp_i_valid,


      out_ready(0)            => timezone_i_ready,
      out_ready(1)            => vin_i_ready,
      out_ready(2)            => odometer_i_ready,
      out_ready(3)            => avg_speed_i_ready,
      out_ready(4)            => s_acc_dec_i_ready,
      out_ready(5)            => e_spd_chg_i_ready,
      out_ready(6)            => hyper_miling_i_ready,
      out_ready(7)            => orientation_i_ready,
      out_ready(8)            => secs_in_b_i_ready,
      out_ready(9)            => miles_in_time_i_ready,
      out_ready(10)           => const_spd_m_in_b_i_ready,
      out_ready(11)           => var_spd_m_in_b_i_ready,
      out_ready(12)           => seconds_decel_i_ready,
      out_ready(13)           => seconds_accel_i_ready,
      out_ready(14)           => brk_m_t_10s_i_ready,
      out_ready(15)           => accel_m_t_10s_i_ready,
      out_ready(16)           => small_spd_v_m_i_ready,
      out_ready(17)           => large_spd_v_m_i_ready,
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

    avg_speed_f_i: avg_speed_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => AVG_SPEED_INT_WIDTH,
      INT_P_PIPELINE_STAGES => AVG_SPEED_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => AVG_SPEED_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => avg_speed_i_valid,
      in_ready              => avg_speed_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => avg_speed_valid,
      out_ready             => avg_speed_ready,
      out_data              => avg_speed_data,
      out_strb              => avg_speed_strb,
      out_last              => avg_speed_last
    );

    s_acc_dec_f_i: s_acc_dec_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => S_ACC_DEC_INT_WIDTH,
      INT_P_PIPELINE_STAGES => S_ACC_DEC_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => S_ACC_DEC_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => s_acc_dec_i_valid,
      in_ready              => s_acc_dec_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => s_acc_dec_valid,
      out_ready             => s_acc_dec_ready,
      out_data              => s_acc_dec_data,
      out_strb              => s_acc_dec_strb,
      out_last              => s_acc_dec_last
    );

    e_spd_chg_f_i: e_spd_chg_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => E_SPD_CHG_INT_WIDTH,
      INT_P_PIPELINE_STAGES => E_SPD_CHG_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => E_SPD_CHG_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => e_spd_chg_i_valid,
      in_ready              => e_spd_chg_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => e_spd_chg_valid,
      out_ready             => e_spd_chg_ready,
      out_data              => e_spd_chg_data,
      out_strb              => e_spd_chg_strb,
      out_last              => e_spd_chg_last
    );

    hyper_miling_f_i: hyper_miling_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      BUFER_DEPTH           => VIN_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => hyper_miling_i_valid,
      in_ready              => hyper_miling_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => hyper_miling_valid,
      out_ready             => hyper_miling_ready,
      out_data              => hyper_miling_data,
      out_strb              => hyper_miling_strb,
      out_last              => hyper_miling_last
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

    secs_in_b_f_i: secs_in_b_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SECS_IN_B_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SECS_IN_B_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SECS_IN_B_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => secs_in_b_i_valid,
      in_ready              => secs_in_b_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => secs_in_b_valid,
      out_ready             => secs_in_b_ready,
      out_data              => secs_in_b_data,
      out_strb              => secs_in_b_strb,
      out_last              => secs_in_b_last
    );

    miles_in_time_i: miles_in_time_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => MILES_IN_TIME_INT_WIDTH,
      INT_P_PIPELINE_STAGES => MILES_IN_TIME_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => MILES_IN_TIME_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => miles_in_time_i_valid,
      in_ready              => miles_in_time_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => miles_in_time_valid,
      out_ready             => miles_in_time_ready,
      out_data              => miles_in_time_data,
      out_strb              => miles_in_time_strb,
      out_last              => miles_in_time_last
    );

    const_spd_m_in_b_i: const_spd_m_in_b_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => CONST_SPD_M_IN_B_INT_WIDTH,
      INT_P_PIPELINE_STAGES => CONST_SPD_M_IN_B_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => CONST_SPD_M_IN_B_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => const_spd_m_in_b_i_valid,
      in_ready              => const_spd_m_in_b_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => const_spd_m_in_b_valid,
      out_ready             => const_spd_m_in_b_ready,
      out_data              => const_spd_m_in_b_data,
      out_strb              => const_spd_m_in_b_strb,
      out_last              => const_spd_m_in_b_last
    );

    var_spd_m_in_b_i: var_spd_m_in_b_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => VAR_SPD_M_IN_B_INT_WIDTH,
      INT_P_PIPELINE_STAGES => VAR_SPD_M_IN_B_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => VAR_SPD_M_IN_B_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => var_spd_m_in_b_i_valid,
      in_ready              => var_spd_m_in_b_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => var_spd_m_in_b_valid,
      out_ready             => var_spd_m_in_b_ready,
      out_data              => var_spd_m_in_b_data,
      out_strb              => var_spd_m_in_b_strb,
      out_last              => var_spd_m_in_b_last
    );

    seconds_decel_i: seconds_decel_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SECONDS_DECEL_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SECONDS_DECEL_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SECONDS_DECEL_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => seconds_decel_i_valid,
      in_ready              => seconds_decel_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => seconds_decel_valid,
      out_ready             => seconds_decel_ready,
      out_data              => seconds_decel_data,
      out_strb              => seconds_decel_strb,
      out_last              => seconds_decel_last
    );

    seconds_accel_i: seconds_accel_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SECONDS_ACCEL_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SECONDS_ACCEL_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SECONDS_ACCEL_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => seconds_accel_i_valid,
      in_ready              => seconds_accel_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => seconds_accel_valid,
      out_ready             => seconds_accel_ready,
      out_data              => seconds_accel_data,
      out_strb              => seconds_accel_strb,
      out_last              => seconds_accel_last
    );

    brk_m_t_10s_i: brk_m_t_10s_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => BRK_M_T_10S_INT_WIDTH,
      INT_P_PIPELINE_STAGES => BRK_M_T_10S_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => BRK_M_T_10S_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => brk_m_t_10s_i_valid,
      in_ready              => brk_m_t_10s_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => brk_m_t_10s_valid,
      out_ready             => brk_m_t_10s_ready,
      out_data              => brk_m_t_10s_data,
      out_strb              => brk_m_t_10s_strb,
      out_last              => brk_m_t_10s_last
    );

    accel_m_t_10s_i: accel_m_t_10s_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => ACCEL_M_T_10S_INT_WIDTH,
      INT_P_PIPELINE_STAGES => ACCEL_M_T_10S_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => ACCEL_M_T_10S_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => accel_m_t_10s_i_valid,
      in_ready              => accel_m_t_10s_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => accel_m_t_10s_valid,
      out_ready             => accel_m_t_10s_ready,
      out_data              => accel_m_t_10s_data,
      out_strb              => accel_m_t_10s_strb,
      out_last              => accel_m_t_10s_last
    );

    small_spd_v_m_i: small_spd_v_m_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => SMALL_SPD_V_M_INT_WIDTH,
      INT_P_PIPELINE_STAGES => SMALL_SPD_V_M_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => SMALL_SPD_V_M_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => small_spd_v_m_i_valid,
      in_ready              => small_spd_v_m_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => small_spd_v_m_valid,
      out_ready             => small_spd_v_m_ready,
      out_data              => small_spd_v_m_data,
      out_strb              => small_spd_v_m_strb,
      out_last              => small_spd_v_m_last
    );

    large_spd_v_m_i: large_spd_v_m_f
    generic map (
      EPC                   => EPC,
      OUTER_NESTING_LEVEL   => 2,
      INT_WIDTH             => LARGE_SPD_V_M_INT_WIDTH,
      INT_P_PIPELINE_STAGES => LARGE_SPD_V_M_INT_P_PIPELINE_STAGES,
      BUFER_DEPTH           => LARGE_SPD_V_M_BUFFER_D
    )
    port map (
      clk                   => clk,
      reset                 => reset,
      in_valid              => large_spd_v_m_i_valid,
      in_ready              => large_spd_v_m_i_ready,
      in_data               => rec_data,
      in_last               => rec_last,
      in_strb               => rec_strb,
      out_valid             => large_spd_v_m_valid,
      out_ready             => large_spd_v_m_ready,
      out_data              => large_spd_v_m_data,
      out_strb              => large_spd_v_m_strb,
      out_last              => large_spd_v_m_last
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