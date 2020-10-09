library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;


package battery_status_pkg is
    component BattSchemaParser is
        generic (
          ELEMENTS_PER_TRANSFER : natural := 8;
          INT_PARSER_BUFFER_D   : natural := 4;
          INT_WIDTH             : natural := 16
        );
        port (
            clk                   : in  std_logic;
            reset                 : in  std_logic;

            -- Stream(
            --     Bits(8),
            --     t=ELEMENTS_PER_TRANSFER,
            --     d=NESTING_LEVEL,
            --     c=8
            -- )
            in_valid              : in  std_logic;
            in_ready              : out std_logic;
            in_data               : in  comp_in_t(data(8*ELEMENTS_PER_TRANSFER-1 downto 0));
            in_last               : in  std_logic_vector(2*ELEMENTS_PER_TRANSFER-1 downto 0);
            in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
            in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
            in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

            end_req               : in  std_logic := '0';
            end_ack               : out std_logic;



            -- Stream(
            --     Bits(64),
            --     d=NESTING_LEVEL,
            --     c=2
            -- )
            out_valid             : out std_logic;
            out_ready             : in  std_logic;
            out_data              : out std_logic_vector(INT_WIDTH-1 downto 0);
            out_empty             : out std_logic;
            out_last              : out std_logic_vector(2 downto 0)

        );
    end component;
end battery_status_pkg;



