library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;
use work.UtilInt_pkg.all;
use work.tr_field_matcher_pkg.all;
use work.tr_field_pkg.all;
use work.Json_pkg.all;


entity large_speed_var_f is
    generic (
      EPC                                 : natural := 8;
      OUTER_NESTING_LEVEL                 : natural := 2;
      INT_WIDTH                           : natural := 16;
      INT_P_PIPELINE_STAGES               : natural := 1;
      BUFER_DEPTH                         : natural := 1
    );
    port (
      clk                                 : in  std_logic;
      reset                               : in  std_logic;

      in_valid                            : in  std_logic;
      in_ready                            : out std_logic;
      in_data                             : in  std_logic_vector(EPC + 8*EPC-1 downto 0);
      in_last                             : in  std_logic_vector((OUTER_NESTING_LEVEL+1)*EPC-1 downto 0);
      in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb                             : in  std_logic_vector(EPC-1 downto 0);

      out_valid                           : out std_logic;
      out_ready                           : in  std_logic;
      out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
      out_strb                            : out std_logic;
      out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL downto 0)
    );
end entity;

architecture arch of large_speed_var_f is

  constant BUFF_WIDTH          : integer := EPC*(1 + 8 + OUTER_NESTING_LEVEL+2);
  constant BUFF_DATA_STAI      : integer := 0;
  constant BUFF_DATA_ENDI      : integer := EPC*8-1;

  constant BUFF_STRB_STAI      : integer := EPC*8;
  constant BUFF_STRB_ENDI      : integer := EPC*8 + EPC -1;
  constant BUFF_LAST_STAI      : integer := EPC*8 + EPC;
  constant BUFF_LAST_ENDI      : integer := EPC*8 + EPC + (OUTER_NESTING_LEVEL+2)*EPC-1;

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
  signal filter_strb           : std_logic_vector(EPC-1 downto 0);
  signal filter_last           : std_logic_vector(EPC*(OUTER_NESTING_LEVEL+1)-1 downto 0);

  signal buff_in_valid         : std_logic;
  signal buff_in_ready         : std_logic;
  signal buff_in_data          : std_logic_vector(BUFF_WIDTH-1 downto 0);

  signal buff_out_valid        : std_logic;
  signal buff_out_ready        : std_logic;
  signal buff_out_data         : std_logic_vector(BUFF_WIDTH-1 downto 0);

  signal array_ready           : std_logic;
  signal array_valid           : std_logic;
  signal array_data            : std_logic_vector(EPC*8-1 downto 0);
  signal array_stai            : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal array_endi            : std_logic_vector(log2ceil(EPC)-1 downto 0);
  signal array_strb            : std_logic_vector(EPC-1 downto 0);
  signal array_last            : std_logic_vector(EPC*(OUTER_NESTING_LEVEL+2)-1 downto 0);

  signal parser_in_data        : std_logic_vector(EPC*8-1 downto 0);
  signal parser_in_strb        : std_logic_vector(EPC-1 downto 0);
  signal parser_in_last        : std_logic_vector(EPC*(OUTER_NESTING_LEVEL+2)-1 downto 0);

begin


  key_filter_i: KeyFilter
  generic map (
    EPC                       => EPC,
    OUTER_NESTING_LEVEL       => OUTER_NESTING_LEVEL
  )
  port map (
    clk                       => clk,
    reset                     => reset,
    in_valid                  => in_valid,
    in_ready                  => in_ready,
    in_data                   => in_data,
    in_strb                   => in_strb,
    in_last                   => in_last,
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
    out_last                  => filter_last
  );

  matcher_i: large_speed_var_f_m
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

  --Buffer interface packing and unpacking
  buff_in_data(BUFF_DATA_ENDI downto BUFF_DATA_STAI)    <= array_data;
  buff_in_data(BUFF_STRB_ENDI downto BUFF_STRB_STAI)    <= array_strb;
  buff_in_data(BUFF_LAST_ENDI downto BUFF_LAST_STAI)    <= array_last;

  parser_in_data  <= buff_out_data(BUFF_DATA_ENDI downto BUFF_DATA_STAI);
  parser_in_strb  <= buff_out_data(BUFF_STRB_ENDI downto BUFF_STRB_STAI);
  parser_in_last  <= buff_out_data(BUFF_LAST_ENDI downto BUFF_LAST_STAI);

  buff_i: StreamBuffer
  generic map (
    DATA_WIDTH                => BUFF_WIDTH,
    MIN_DEPTH                 => BUFER_DEPTH
  )
  port map (
    clk                       => clk,
    reset                     => reset,
    in_valid                  => array_valid,
    in_ready                  => array_ready,
    in_data                   => buff_in_data,
    out_valid                 => buff_out_valid,
    out_ready                 => buff_out_ready,
    out_data                  => buff_out_data
  );


  array_parser_i: JsonArrayParser
    generic map (
      EPC                       => EPC,
      OUTER_NESTING_LEVEL       => 2,
      INNER_NESTING_LEVEL       => 0
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => filter_valid,
      in_ready                  => filter_ready,
      in_data                   => filter_data,
      in_last                   => filter_last,
      in_strb                   => filter_strb,
      out_data                  => array_data,
      out_valid                 => array_valid,
      out_ready                 => array_ready,
      out_last                  => array_last,
      out_stai                  => array_stai,
      out_endi                  => array_endi,
      out_strb                  => array_strb
    );

    intparser_i: IntParser
    generic map (
      EPC                       => EPC,
      NESTING_LEVEL             => 3,
      BITWIDTH                  => INT_WIDTH,
      PIPELINE_STAGES           => INT_P_PIPELINE_STAGES
    )
    port map (
      clk                       => clk,
      reset                     => reset,
      in_valid                  => buff_out_valid,
      in_ready                  => buff_out_ready,
      in_data                   => parser_in_data,
      in_last                   => parser_in_last,
      in_strb                   => parser_in_strb,
      out_data                  => out_data,
      out_valid                 => out_valid,
      out_ready                 => out_ready,
      out_last                  => out_last,
      out_strb                 => out_strb
    );


end arch;
