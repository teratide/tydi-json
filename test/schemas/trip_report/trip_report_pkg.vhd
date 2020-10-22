library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;


package trip_report_pkg is
    component TripReportParser is
        generic (
          EPC                                 : natural := 8;
          TIMEZONE_INT_WIDTH                  : natural := 16;
          TIMEZONE_INT_P_PIPELINE_STAGES      : natural := 1;
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

          timezone_valid                           : out std_logic;
          timezone_ready                           : in  std_logic;
          timezone_data                            : out std_logic_vector(TIMEZONE_INT_WIDTH-1 downto 0);
          timezone_empty                           : out std_logic;
          timezone_last                            : out std_logic_vector(1 downto 0)
        );
    end component;
end trip_report_pkg;



