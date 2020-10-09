library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;


package Json_pkg is
    type kv_tag_t is (KEY,
                     VALUE);

    type comm_t is (ENABLE,
                    DISABLE);

    type JsonRecordParser_out_t is record
        tag   : std_logic_vector; 
        data  : std_logic_vector;
    end record ;

    type comp_in_t is record
        comm  : comm_t ; 
        data  : std_logic_vector ;
    end record ;

    component JsonRecordParser is
        generic (
          ELEMENTS_PER_TRANSFER : natural := 1;
          OUTER_NESTING_LEVEL   : natural := 1;
          INNER_NESTING_LEVEL   : natural := 1;
          END_REQ_EN            : boolean := false
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
            in_last               : in  std_logic_vector((OUTER_NESTING_LEVEL+1)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
            in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
            in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1');

            end_req               : in  std_logic := '0';
            end_ack               : out std_logic;


            -- Stream(
            --     Bits(8),
            --     t=ELEMENTS_PER_TRANSFER,
            --     d=NESTING_LEVEL,
            --     c=8
            -- )
            --
            out_valid             : out std_logic;
            out_ready             : in  std_logic;
            out_data              : out JsonRecordParser_out_t(tag(ELEMENTS_PER_TRANSFER-1 downto 0), data(8*ELEMENTS_PER_TRANSFER-1 downto 0));
            out_last              : out std_logic_vector((OUTER_NESTING_LEVEL+2)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            out_empty             : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            out_stai              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
            out_endi              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
            out_strb              : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1')

        );
    end component;

    component JsonArrayParser is
        generic (
            ELEMENTS_PER_TRANSFER : natural := 1;
            OUTER_NESTING_LEVEL   : natural := 1;
            INNER_NESTING_LEVEL   : natural := 0;
            ELEMENT_COUNTER_BW    : natural := 4
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
            in_last               : in  std_logic_vector((OUTER_NESTING_LEVEL+1)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
            in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
            in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1');
      
            -- Stream(
            --     Bits(8),
            --     t=ELEMENTS_PER_TRANSFER,
            --     d=NESTING_LEVEL,
            --     c=8
            -- )
            --
            out_valid             : out std_logic;
            out_ready             : in  std_logic;
            out_data              : out std_logic_vector(8*ELEMENTS_PER_TRANSFER-1 downto 0);
            out_last              : out std_logic_vector((OUTER_NESTING_LEVEL+2)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            out_empty             : out  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            out_stai              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
            out_endi              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
            out_strb              : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1')


            -- out_count_valid       : out std_logic;
            -- out_count_ready       : in  std_logic := '1';
            -- out_count_data        : out std_logic_vector(ELEMENT_COUNTER_BW-1 downto 0)
      
        );
      end component;


    component BooleanParser is
        generic (
            ELEMENTS_PER_TRANSFER : natural := 1;
            NESTING_LEVEL         : natural := 1
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
            in_last               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
            in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
            in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
            in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1');
    
            -- Stream(
            --     Bits(1),
            --     d=NESTING_LEVEL,
            --     c=8
            -- )
            out_valid             : out std_logic;
            out_ready             : in  std_logic;
            out_data              : out std_logic
    
        );
    end component;

    component IntParser is
      generic (
          ELEMENTS_PER_TRANSFER : natural := 1;
          NESTING_LEVEL         : natural := 1;
          BITWIDTH              : natural := 8;
          SIGNED                : boolean := false -- Signed is not supported yet!
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
          in_last               : in  std_logic_vector((NESTING_LEVEL+1)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
          in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
          in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
          in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
          in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1');
    
          -- Stream(
          --     Bits(64),
          --     d=NESTING_LEVEL,
          --     c=2
          -- )
          out_valid             : out std_logic;
          out_ready             : in  std_logic;
          out_data              : out std_logic_vector(63 downto 0);
          out_empty             : out std_logic;
          out_last              : out std_logic_vector(NESTING_LEVEL-1 downto 0)
      );
    end component;
end Json_pkg;



