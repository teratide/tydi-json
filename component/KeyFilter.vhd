library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Stream_pkg.all;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;

entity KeyFilter is
  generic (
      ELEMENTS_PER_TRANSFER : natural := 1;
      OUTER_NESTING_LEVEL   : natural := 1;
      DLY_COMP_BUFF_DEPTH   : natural := 1
      );
  port (
      clk                   : in  std_logic;
      reset                 : in  std_logic;

      in_valid              : in  std_logic;
      in_ready              : out std_logic;
      in_data               : in  JsonRecordParser_out_t(data(8*ELEMENTS_PER_TRANSFER-1 downto 0));
      in_last               : in  std_logic_vector((OUTER_NESTING_LEVEL+1)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
      in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
      in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1');

      matcher_str_valid     : out std_logic;
      matcher_str_ready     : in  std_logic;
      matcher_str_data      : out std_logic_vector(ELEMENTS_PER_TRANSFER*8-1 downto 0);
      matcher_str_strb      : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);
      matcher_str_last      : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

      matcher_match_valid   : in  std_logic;
      matcher_match_ready   : out std_logic;
      matcher_match         : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

      out_valid             : out std_logic;
      out_ready             : in  std_logic;
      out_data              : out std_logic_vector(ELEMENTS_PER_TRANSFER*8-1 downto 0);
      out_last              : out std_logic_vector((OUTER_NESTING_LEVEL+1)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      out_empty             : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      out_stai              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
      out_endi              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
      out_strb              : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1')

  );
end entity;

architecture behavioral of KeyFilter is

  signal matcher_str_valid_s     : std_logic;
  signal matcher_str_ready_s     : std_logic;
  signal matcher_str_data_s      : std_logic_vector(ELEMENTS_PER_TRANSFER*8-1 downto 0);
  signal matcher_str_strb_s      : std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);
  signal matcher_str_last_s      : std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

  signal matcher_match_valid_s   : std_logic;
  signal matcher_match_ready_s   : std_logic;
  signal matcher_match_s         : std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

  signal buff_in_valid           : std_logic;
  signal buff_in_ready           : std_logic;
  signal buff_in_data            : std_logic_vector(ELEMENTS_PER_TRANSFER*(2 + 8)-1 downto 0);

  signal buff_out_valid          : std_logic;
  signal buff_out_ready          : std_logic;
  signal buff_out_data           : std_logic_vector(ELEMENTS_PER_TRANSFER*(2 + 8)-1 downto 0);

  begin

    dly_comp_buff: StreamBuffer
      generic map (
        DATA_WIDTH              => ELEMENTS_PER_TRANSFER*(2 + 8),
        MIN_DEPTH               => DLY_COMP_BUFF_DEPTH
      )
      port map (
        clk                     => clk,
        reset                   => reset,
        in_valid                => buff_in_valid,
        in_ready                => buff_in_ready,
        in_data                 => buff_in_data,
        out_valid               => buff_out_valid,
        out_ready               => buff_out_ready,
        out_data                => buff_out_data
      );

    clk_proc: process (clk) is
      constant IDXW : natural := log2ceil(ELEMENTS_PER_TRANSFER);
  
      -- Input holding register.
      type in_type is record
        data  : std_logic_vector(7 downto 0);
        last  : std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0);
        empty : std_logic;
        strb  : std_logic;
      end record;
  
      variable comm  : comm_t;
  
      type in_array is array (natural range <>) of in_type;
      variable id : in_array(0 to ELEMENTS_PER_TRANSFER-1);
      variable iv : std_logic := '0';
      variable ir : std_logic := '0';
  
      -- Output holding register.
      type out_type is record
        data  : std_logic_vector(7 downto 0);
        tag   : std_logic;
        last  : std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0);
        empty : std_logic;
        strb  : std_logic;
      end record;
  
      type out_array is array (natural range <>) of out_type;
      variable od : out_array(0 to ELEMENTS_PER_TRANSFER-1);
      variable ov : std_logic := '0';
  
      variable stai    : unsigned(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0);
      variable endi    : unsigned(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0);

  
      -- Enumeration type for our state machine.
      type state_t is (STATE_IDLE,
                       STATE_RECORD,
                       STATE_KEY, 
                       STATE_VALUE);
  
      -- State variable
      variable state : state_t;
  
    begin
    
      if rising_edge(clk) then
  
        -- Latch input holding register if we said we would.
        if to_x01(ir) = '1' then
          iv := in_valid;
          stai      := to_unsigned(0, stai'length);
          endi      := to_unsigned(ELEMENTS_PER_TRANSFER-1, endi'length);
          for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
            id(idx).data  := in_data.data(8*idx+7 downto 8*idx);
            id(idx).last  := in_last((OUTER_NESTING_LEVEL+1)*(idx+1)-1 downto (OUTER_NESTING_LEVEL+1)*(idx)+1);
            comm          := in_data.comm;
            id(idx).empty := in_empty(idx);
            id(idx).strb  := in_strb(idx);
            if idx < unsigned(in_stai) then
              id(idx).strb := '0';
            elsif idx > unsigned(in_endi) then
              id(idx).strb := '0';
            else
              id(idx).strb := in_strb(idx);
            end if;
          end loop;
        end if;
  
        -- Clear output holding register if transfer was accepted.
        if to_x01(out_ready) = '1' then
          ov := '0';
        end if;
  
        -- Do processing when both registers are ready.
        if to_x01(iv) = '1' and to_x01(out_ready) = '1' then
          for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
  
            -- Default behavior.
            od(idx).data                                  := id(idx).data;
            od(idx).tag                                   := '0';
            od(idx).last(OUTER_NESTING_LEVEL-1 downto 0)  := id(idx).last & "00";
            od(idx).empty                                 := id(idx).empty;
            od(idx).strb                                  := '0';
            
            idx_int := to_unsigned(idx, idx_int'length);
  
            -- Element-wise processing only when the lane is valid.
            if to_x01(id(idx).strb) = '1' and comm = ENABLE then
            end if;
  
          end loop;  
        end if;
  
        -- Handle reset.
        if to_x01(reset) /= '0' then
          ir    := '0';
          ov    := '0';

        end if;
  
        -- Forward output holding register.
        out_valid <= to_x01(ov);
        ir := not iv and not reset;
        in_ready <= ir;
        for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
          out_data.data(8*idx+7 downto 8*idx) <= od(idx).data;
          out_data.tag(idx)  <= od(idx).tag;
          out_last((OUTER_NESTING_LEVEL+1)*(idx+1)-1 downto (OUTER_NESTING_LEVEL+1)*idx) <= od(idx).last;
          out_empty(idx) <= od(idx).empty;
          out_stai <= std_logic_vector(stai);
          out_endi <= std_logic_vector(endi);
          out_strb(idx) <= od(idx).strb;
        end loop;
      end if;
    end process;
  end architecture;