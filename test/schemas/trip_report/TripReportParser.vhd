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
    
    TIMEZONE_INT_WIDTH                  : natural := 16;
    TIMEZONE_INT_P_PIPELINE_STAGES      : natural := 1;
    TIMEZONE_BUFFER_D                   : natural := 1;
    
    VIN_INT_WIDTH                       : natural := 16;
    VIN_INT_P_PIPELINE_STAGES           : natural := 1;
    VIN_BUFFER_D                        : natural := 1;
    
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

    vin_valid                           : out std_logic;
    vin_ready                           : in  std_logic;
    vin_data                            : out std_logic_vector(VIN_INT_WIDTH-1 downto 0);
    vin_empty                           : out std_logic;
    vin_last                            : out std_logic_vector(1 downto 0)
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

  
  --Integer fields
  signal timezone_i_valid : std_logic;
  signal timezone_i_ready : std_logic;

  signal vin_i_valid : std_logic;
  signal vin_i_ready : std_logic;

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
      NUM_OUTPUTS             => 2
    )
    port map (
      clk                     => clk,
      reset                   => reset,
      in_valid(0)             => rec_valid,
      in_ready(0)             => rec_ready,
      out_valid(0)            => timezone_i_valid,
      out_valid(1)            => vin_i_valid,
      out_ready(0)            => timezone_i_ready,
      out_ready(1)            => vin_i_ready
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

end arch;