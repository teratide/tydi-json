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
    EPC                                 : natural := 8;
    
    -- 
    -- INTEGER FIELDS
    --
    TIMEZONE_INT_WIDTH                  : natural := 16;
    TIMEZONE_INT_P_PIPELINE_STAGES      : natural := 1;
    TIMEZONE_BUFFER_D                   : natural := 1;
    
    VIN_INT_WIDTH                       : natural := 16;
    VIN_INT_P_PIPELINE_STAGES           : natural := 1;
    VIN_BUFFER_D                        : natural := 1;

    ODOMETER_INT_WIDTH                  : natural := 16;
    ODOMETER_INT_P_PIPELINE_STAGES      : natural := 1;
    ODOMETER_BUFFER_D                   : natural := 1;

    AVG_SPEED_INT_WIDTH                 : natural := 16;
    AVG_SPEED_INT_P_PIPELINE_STAGES     : natural := 1;
    AVG_SPEED_BUFFER_D                  : natural := 1;

    S_ACC_DEC_INT_WIDTH                 : natural := 16;
    S_ACC_DEC_INT_P_PIPELINE_STAGES     : natural := 1;
    S_ACC_DEC_BUFFER_D                  : natural := 1;

    E_SPD_CHG_INT_WIDTH                 : natural := 16;
    E_SPD_CHG_INT_P_PIPELINE_STAGES     : natural := 1;
    E_SPD_CHG_BUFFER_D                  : natural := 1;

    -- 
    -- BOOLEAN FIELDS
    --
    HYPER_MILING_BUFFER_D               : natural := 1;
    ORIENTATION_BUFFER_D                : natural := 1;

    END_REQ_EN                          : boolean := false
  );              
  port (              
    clk                                 : in  std_logic;
    reset                               : in  std_logic;

    in_valid                            : in  std_logic;
    in_ready                            : out std_logic;
    in_data                             : in  std_logic_vector(8*EPC-1 downto 0);
    in_last                             : in  std_logic_vector(2*EPC-1 downto 0);
    in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
    in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
    in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
    in_strb                             : in  std_logic_vector(EPC-1 downto 0);

    end_req                             : in  std_logic := '0';
    end_ack                             : out std_logic;

    timezone_valid                      : out std_logic;
    timezone_ready                      : in  std_logic;
    timezone_data                       : out std_logic_vector(TIMEZONE_INT_WIDTH-1 downto 0);
    timezone_empty                      : out std_logic;
    timezone_last                       : out std_logic_vector(1 downto 0);

    -- 
    -- INTEGER FIELDS
    --
    vin_valid                           : out std_logic;
    vin_ready                           : in  std_logic;
    vin_data                            : out std_logic_vector(VIN_INT_WIDTH-1 downto 0);
    vin_empty                           : out std_logic;
    vin_last                            : out std_logic_vector(1 downto 0);

    odometer_valid                      : out std_logic;
    odometer_ready                      : in  std_logic;
    odometer_data                       : out std_logic_vector(ODOMETER_INT_WIDTH-1 downto 0);
    odometer_empty                      : out std_logic;
    odometer_last                       : out std_logic_vector(1 downto 0);

    avg_speed_valid                     : out std_logic;
    avg_speed_ready                     : in  std_logic;
    avg_speed_data                      : out std_logic_vector(AVG_SPEED_INT_WIDTH-1 downto 0);
    avg_speed_empty                     : out std_logic;
    avg_speed_last                      : out std_logic_vector(1 downto 0);

    s_acc_dec_valid                     : out std_logic;
    s_acc_dec_ready                     : in  std_logic;
    s_acc_dec_data                      : out std_logic_vector(S_ACC_DEC_INT_WIDTH-1 downto 0);
    s_acc_dec_empty                     : out std_logic;
    s_acc_dec_last                      : out std_logic_vector(1 downto 0);

    e_spd_chg_valid                     : out std_logic;
    e_spd_chg_ready                     : in  std_logic;
    e_spd_chg_data                      : out std_logic_vector(E_SPD_CHG_INT_WIDTH-1 downto 0);
    e_spd_chg_empty                     : out std_logic;
    e_spd_chg_last                      : out std_logic_vector(1 downto 0);

    -- 
    -- BOOLEAN FIELDS
    --
    hyper_miling_valid                  : out std_logic;
    hyper_miling_ready                  : in  std_logic;
    hyper_miling_data                   : out std_logic;
    hyper_miling_empty                  : out std_logic;
    hyper_miling_last                   : out std_logic_vector(1 downto 0);

    orientation_valid                   : out std_logic;
    orientation_ready                   : in  std_logic;
    orientation_data                    : out std_logic;
    orientation_empty                   : out std_logic;
    orientation_last                    : out std_logic_vector(1 downto 0)
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
  

begin

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
      in_empty                    => in_empty,
      in_stai                     => in_stai,
      in_endi                     => in_endi,
      out_data                    => rec_data,
      out_stai                    => rec_stai,
      out_endi                    => rec_endi,
      out_ready                   => rec_ready,
      out_valid                   => rec_valid,
      out_strb                    => rec_strb,
      out_last                    => rec_last,
      out_empty                   => rec_empty
    );

  sync_i: StreamSync
    generic map (
      NUM_INPUTS              => 1,
      NUM_OUTPUTS             => 8
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
      out_ready(0)            => timezone_i_ready,
      out_ready(1)            => vin_i_ready,
      out_ready(2)            => odometer_i_ready,
      out_ready(3)            => avg_speed_i_ready,
      out_ready(4)            => s_acc_dec_i_ready,
      out_ready(5)            => e_spd_chg_i_ready,
      out_ready(6)            => hyper_miling_i_ready,
      out_ready(7)            => orientation_i_ready
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => timezone_valid,
      out_ready             => timezone_ready,
      out_data              => timezone_data,
      out_empty             => timezone_empty,
      out_last              => timezone_last
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => vin_valid,
      out_ready             => vin_ready,
      out_data              => vin_data,
      out_empty             => vin_empty,
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => odometer_valid,
      out_ready             => odometer_ready,
      out_data              => odometer_data,
      out_empty             => odometer_empty,
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => avg_speed_valid,
      out_ready             => avg_speed_ready,
      out_data              => avg_speed_data,
      out_empty             => avg_speed_empty,
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => s_acc_dec_valid,
      out_ready             => s_acc_dec_ready,
      out_data              => s_acc_dec_data,
      out_empty             => s_acc_dec_empty,
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => e_spd_chg_valid,
      out_ready             => e_spd_chg_ready,
      out_data              => e_spd_chg_data,
      out_empty             => e_spd_chg_empty,
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => hyper_miling_valid,
      out_ready             => hyper_miling_ready,
      out_data              => hyper_miling_data,
      out_empty             => hyper_miling_empty,
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
      in_empty              => rec_empty,
      in_strb               => rec_strb,
      out_valid             => orientation_valid,
      out_ready             => orientation_ready,
      out_data              => orientation_data,
      out_empty             => orientation_empty,
      out_last              => orientation_last
    );

end arch;