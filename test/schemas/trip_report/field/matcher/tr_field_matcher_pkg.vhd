library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;

package tr_field_matcher_pkg is
  component timestamp_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component timezone_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component vin_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component avg_speed_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component odometer_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component s_acc_dec_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component e_spd_chg_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component hyper_miling_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component orientation_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component secs_in_b_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component miles_in_time_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component const_spd_m_in_b_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component var_spd_m_in_b_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component seconds_decel_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component seconds_accel_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component brk_m_t_10s_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component accel_m_t_10s_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component small_spd_v_m_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

  component large_spd_v_m_f_m is
    generic (
      BPC                         : positive := 1;
      BIG_ENDIAN                  : boolean := false;
      INPUT_REG_ENABLE            : boolean := false;
      S12_REG_ENABLE              : boolean := true;
      S23_REG_ENABLE              : boolean := true;
      S34_REG_ENABLE              : boolean := true;
      S45_REG_ENABLE              : boolean := true
  
    );
    port (
      clk                         : in  std_logic;
      reset                       : in  std_logic := '0';
      aresetn                     : in  std_logic := '1';
      clken                       : in  std_logic := '1';
      in_valid                    : in  std_logic := '1';
      in_ready                    : out std_logic;
      in_mask                     : in  std_logic_vector(BPC-1 downto 0) := (others => '1');
      in_data                     : in  std_logic_vector(BPC*8-1 downto 0);
      in_last                     : in  std_logic := '0';
      in_xlast                    : in  std_logic_vector(BPC-1 downto 0) := (others => '0');
      out_valid                   : out std_logic;
      out_ready                   : in  std_logic := '1';
      out_match                   : out std_logic_vector(0 downto 0);
      out_error                   : out std_logic;
      out_xmask                   : out std_logic_vector(BPC-1 downto 0);
      out_xmatch                  : out std_logic_vector(BPC*1-1 downto 0);
      out_xerror                  : out std_logic_vector(BPC-1 downto 0)
    );
  end component;

end tr_field_matcher_pkg;



