library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;


package tr_field_pkg is
  component timezone_f is
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
        in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
        in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
        in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
        in_strb                             : in  std_logic_vector(EPC-1 downto 0);


        out_valid                           : out std_logic;
        out_ready                           : in  std_logic;
        out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
        out_empty                           : out std_logic;
        out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0)
        );
  end component;

  component vin_f is
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
      in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
      in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb                             : in  std_logic_vector(EPC-1 downto 0);


      out_valid                           : out std_logic;
      out_ready                           : in  std_logic;
      out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
      out_empty                           : out std_logic;
      out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0)
      );
  end component;

  component odometer_f is
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
      in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
      in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb                             : in  std_logic_vector(EPC-1 downto 0);


      out_valid                           : out std_logic;
      out_ready                           : in  std_logic;
      out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
      out_empty                           : out std_logic;
      out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0)
      );
  end component;

  component avg_speed_f is
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
      in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
      in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb                             : in  std_logic_vector(EPC-1 downto 0);


      out_valid                           : out std_logic;
      out_ready                           : in  std_logic;
      out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
      out_empty                           : out std_logic;
      out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0)
      );
  end component;

  component s_acc_dec_f is
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
      in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
      in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb                             : in  std_logic_vector(EPC-1 downto 0);


      out_valid                           : out std_logic;
      out_ready                           : in  std_logic;
      out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
      out_empty                           : out std_logic;
      out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0)
      );
  end component;

  component e_spd_chg_f is
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
      in_empty                            : in  std_logic_vector(EPC-1 downto 0) := (others => '0');
      in_stai                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
      in_endi                             : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
      in_strb                             : in  std_logic_vector(EPC-1 downto 0);


      out_valid                           : out std_logic;
      out_ready                           : in  std_logic;
      out_data                            : out std_logic_vector(INT_WIDTH-1 downto 0);
      out_empty                           : out std_logic;
      out_last                            : out std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0)
      );
  end component;
end tr_field_pkg;
