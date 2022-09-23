library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;
use work.nested_battery_status_pkg.all;
use work.TestMisc_pkg.all;

entity NestedBattSchemaParser is
  generic (
    EPC                   : natural := 8;
    INT_WIDTH             : natural := 16;
    INT_P_PIPELINE_STAGES : natural := 2;
    END_REQ_EN            : boolean := false
  );
  port (
      clk                   : in  std_logic;
      reset                 : in  std_logic;

      -- Stream(
      --     Bits(8),
      --     t=EPC,
      --     d=NESTING_LEVEL,
      --     c=8
      -- )
      in_valid              : in  std_logic;
      in_ready              : out std_logic;
      in_data               : in  std_logic_vector(8*EPC-1 downto 0);
      in_last               : in  std_logic_vector(2*EPC-1 downto 0);
      in_stai               : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi               : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb               : in  std_logic_vector(EPC-1 downto 0);

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
      out_strb              : out std_logic;
      out_last              : out std_logic_vector(3 downto 0)

  );
end entity;


architecture arch of NestedBattSchemaParser is

  signal outer_kv_ready        : std_logic;
  signal outer_kv_valid        : std_logic;
  signal outer_kv_vec          : std_logic_vector(EPC*8+EPC-1 downto 0);
  signal outer_kv_data         : std_logic_vector(EPC*8-1 downto 0);
  signal outer_kv_stai         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_kv_endi         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal outer_kv_strb         : std_logic_vector(EPC-1 downto 0);
  signal outer_kv_last         : std_logic_vector(EPC*3-1 downto 0);

  signal inner_kv_ready        : std_logic;
  signal inner_kv_valid        : std_logic;
  signal inner_kv_vec          : std_logic_vector(EPC*8+EPC-1 downto 0);
  signal inner_kv_data         : std_logic_vector(EPC*8-1 downto 0);
  signal inner_kv_stai         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_kv_endi         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal inner_kv_strb         : std_logic_vector(EPC-1 downto 0);
  signal inner_kv_last         : std_logic_vector(EPC*5-1 downto 0);

  signal array_ready        : std_logic;
  signal array_valid        : std_logic;
  signal array_data         : std_logic_vector(EPC*8-1 downto 0);
  signal array_stai         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal array_endi         : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal array_strb         : std_logic_vector(EPC-1 downto 0);
  signal array_last         : std_logic_vector(EPC*4-1 downto 0);
 
  signal rec_ready             : std_logic;
  signal rec_valid             : std_logic;
  signal rec_vec               : std_logic_vector(EPC+EPC*8-1 downto 0);
  signal rec_data              : std_logic_vector(EPC*8-1 downto 0);
  signal rec_tag               : std_logic_vector(EPC-1 downto 0);
  signal rec_empty             : std_logic_vector(EPC-1 downto 0);
  signal rec_stai              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal rec_endi              : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal rec_strb              : std_logic_vector(EPC-1 downto 0);
  signal rec_last              : std_logic_vector(EPC*5-1 downto 0);

  signal matcher_str_valid     : std_logic;
  signal matcher_str_ready     : std_logic;
  signal matcher_str_data      : std_logic_vector(EPC*8-1 downto 0);
  signal matcher_str_mask      : std_logic_vector(EPC-1 downto 0);
  signal matcher_str_last      : std_logic_vector(EPC-1 downto 0);

  signal matcher_match_valid   : std_logic;
  signal matcher_match_ready   : std_logic;
  signal matcher_match         : std_logic_vector(EPC-1 downto 0);

  
  signal filter_ready          : std_logic;
  signal filter_valid          : std_logic;
  signal filter_data           : std_logic_vector(EPC*8-1 downto 0);
  signal filter_tag            : std_logic_vector(EPC-1 downto 0);
  signal filter_stai           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal filter_endi           : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal filter_last           : std_logic_vector(EPC*5-1 downto 0);
  
begin
  record_parser_i: JsonRecordParser
    generic map (
      EPC                         => EPC,
      OUTER_NESTING_LEVEL         => 1,
      INNER_NESTING_LEVEL         => 2,
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
      out_data                    => outer_kv_vec,
      out_stai                    => outer_kv_stai,
      out_endi                    => outer_kv_endi,
      out_ready                   => outer_kv_ready,
      out_valid                   => outer_kv_valid,
      out_strb                    => outer_kv_strb,
      out_last                    => outer_kv_last
    );

    outer_kv_data <= outer_kv_vec(EPC*8-1 downto 0);

    array_parser_i: JsonArrayParser
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 2,
      INNER_NESTING_LEVEL       => 1
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => outer_kv_valid,
      in_ready                  => outer_kv_ready,
      in_data                   => outer_kv_data,
      in_last                   => outer_kv_last,
      in_strb                   => outer_kv_strb,
      out_data                  => array_data,
      out_valid                 => array_valid,
      out_ready                 => array_ready,
      out_last                  => array_last,
      out_stai                  => array_stai,
      out_endi                  => array_endi,
      out_strb                  => array_strb
    );

    inner_record_parser_i: JsonRecordParser
    generic map (
      EPC                         => EPC,
      OUTER_NESTING_LEVEL         => 3,
      INNER_NESTING_LEVEL         => 0,
      END_REQ_EN                  => END_REQ_EN
    )
    port map (
      clk                         => clk,
      reset                       => reset,
      in_valid                    => array_valid,
      in_ready                    => array_ready,
      in_data                     => array_data,
      in_strb                     => array_strb,
      in_last                     => array_last,
      in_stai                     => array_stai,
      in_endi                     => array_endi,
      out_data                    => inner_kv_vec,
      out_stai                    => inner_kv_stai,
      out_endi                    => inner_kv_endi,
      out_ready                   => inner_kv_ready,
      out_valid                   => inner_kv_valid,
      out_strb                    => inner_kv_strb,
      out_last                    => inner_kv_last
    );

    matcher: voltage_matcher
    generic map (
      BPC                       => EPC
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => matcher_str_valid,
      in_ready                  => matcher_str_ready,
      in_mask                   => matcher_str_mask,
      in_data                   => matcher_str_data,
      in_xlast                  => matcher_str_last,
      out_valid                 => matcher_match_valid,
      out_ready                 => matcher_match_ready,
      out_xmatch                => matcher_match
    );

    key_filter: KeyFilter
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 4
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => rec_valid,
      in_ready                  => rec_ready,
      in_data                   => rec_vec,
      in_strb                   => rec_strb,
      in_last                   => rec_last,
      matcher_str_valid         => matcher_str_valid,
      matcher_str_ready         => matcher_str_ready,
      matcher_str_data          => matcher_str_data,
      matcher_str_mask          => matcher_str_mask,
      matcher_str_last          => matcher_str_last,
      matcher_match_valid       => matcher_match_valid,
      matcher_match_ready       => matcher_match_ready,
      matcher_match             => matcher_match,
      out_valid                 => filter_valid,
      out_ready                 => filter_ready,
      out_data                  => filter_data,
      out_strb                  => filter_strb,
      out_stai                  => filter_stai,
      out_endi                  => filter_endi,
      out_last                  => filter_last
    );

    intparser_i: IntParser
    generic map (
      EPC                       => EPC,
      NESTING_LEVEL             => 4,
      BITWIDTH                  => INT_WIDTH,
      PIPELINE_STAGES           => INT_P_PIPELINE_STAGES
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => filter_valid,
      in_ready                  => filter_ready,
      in_data                   => filter_data,
      in_last                   => filter_last,
      in_strb                   => filter_strb,
      out_data                  => out_data,
      out_valid                 => out_valid,
      out_ready                 => out_ready,
      out_last                  => out_last,
      out_strb                  => out_strb
    );


end arch;