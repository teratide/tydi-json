library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;


library work;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;


entity JsonArrayParser is
  generic (
      ELEMENTS_PER_TRANSFER : natural := 1;
      OUTER_NESTING_LEVEL   : natural := 1;
      INNER_NESTING_LEVEL   : natural := 0
      );
  port (
      clk                   : in  std_logic;
      reset                 : in  std_logic;

      -- Stream(
      --     Bits(9),
      --     t=ELEMENTS_PER_TRANSFER,
      --     d=NESTING_LEVEL,
      --     c=8
      -- )
      in_valid              : in  std_logic;
      in_ready              : out std_logic;
      in_data               : in  comp_in_t(data(8*ELEMENTS_PER_TRANSFER-1 downto 0));
      --in_last               : in  std_logic_vector(NESTING_LEVEL*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      in_last               : in  std_logic_vector((OUTER_NESTING_LEVEL+1)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      in_empty              : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      in_stai               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
      in_endi               : in  std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
      in_strb               : in  std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1');

      -- Stream(
      --     Bits(9),
      --     t=ELEMENTS_PER_TRANSFER,
      --     d=NESTING_LEVEL,
      --     c=8
      -- )
      --
      out_valid             : out std_logic;
      out_ready             : in  std_logic;
      --out_data              : out std_logic_vector(8*ELEMENTS_PER_TRANSFER-1 downto 0);
      out_data              : out std_logic_vector(8*ELEMENTS_PER_TRANSFER-1 downto 0);
      --out_last              : out std_logic_vector(NESTING_LEVEL*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      out_last              : out std_logic_vector((OUTER_NESTING_LEVEL+2)*ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      out_empty             : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '0');
      out_stai              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '0');
      out_endi              : out std_logic_vector(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0) := (others => '1');
      out_strb              : out std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0) := (others => '1')

  );
end entity;

architecture behavioral of JsonArrayParser is
begin
  clk_proc: process (clk) is
    constant IDXW : natural := log2ceil(ELEMENTS_PER_TRANSFER);

    -- Input holding register.
    type in_type is record
      data  : std_logic_vector(7 downto 0);
      empty : std_logic;
      --last  : std_logic_vector(NESTING_LEVEL-1 downto 0);
      last  : std_logic_vector(OUTER_NESTING_LEVEL-1 downto 0);
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
      --last  : std_logic_vector(NESTING_LEVEL-1 downto 0);
      last  : std_logic_vector(OUTER_NESTING_LEVEL+1 downto 0);
      empty : std_logic;
      strb  : std_logic;
    end record;

    type out_array is array (natural range <>) of out_type;
    variable od : out_array(0 to ELEMENTS_PER_TRANSFER-1);
    variable ov : std_logic := '0';
    variable out_r : std_logic := '0';

    variable handshaked : boolean;

    variable stai    : unsigned(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0);
    variable endi    : unsigned(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0);
    variable idx_int : unsigned(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0);

    variable tag     : kv_tag_t;

    -- Enumeration type for our state machine.
    type state_t is (STATE_IDLE,
                     STATE_ARRAY, 
                     STATE_BLOCK);

    -- State variable
    variable state : state_t;
    variable state_ab : state_t;
    variable processed : std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

    variable has_valid : boolean; --this needs to be tidied up


    variable nesting_level_th : std_logic_vector(INNER_NESTING_LEVEL downto 0) := (others => '0');
    variable nesting_extra    : std_logic_vector(INNER_NESTING_LEVEL downto 1) := (others => '0');


  begin
    if rising_edge(clk) then

      -- Latch input holding register if we said we would.
      if to_x01(ir) = '1' then
        iv := in_valid;
        out_r := out_ready;
        processed := (others => '0');
        stai      := to_unsigned(0, stai'length);
        endi      := to_unsigned(ELEMENTS_PER_TRANSFER-1, endi'length);
        tag       := KEY;
        for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
          id(idx).data := in_data.data(8*idx+7 downto 8*idx);
          id(idx).empty:= in_empty(idx);
          id(idx).last := in_last((OUTER_NESTING_LEVEL+1)*(idx+1)-1 downto (OUTER_NESTING_LEVEL+1)*idx+1);
          comm := in_data.comm;
          id(idx).data := in_data.data(8*idx+7 downto 8*idx);
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
      ir                 := '1';
      handshaked         := false;
      has_valid          := false;

      if out_valid = '1' and out_ready = '1' then
        handshaked := true;
      end if;

      -- Do processing when both registers are ready.
      if to_x01(iv) = '1' and to_x01(ov) /= '1' then
        for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop

          -- Default behavior.
          od(idx).data       := id(idx).data;
          od(idx).last(OUTER_NESTING_LEVEL+1 downto 0)       := id(idx).last & "00";
          od(idx).empty      := id(idx).empty;
          od(idx).strb       := '0';
          
          idx_int := to_unsigned(idx, idx_int'length);

          -- Element-wise processing only when the lane is valid.
          if to_x01(id(idx).strb) = '1' and processed(idx) = '0' and comm = ENABLE then

            if (id(idx).empty) = '1' then
              od(idx).strb := '1';
              ov := '1';
            end if;

            -- Keep track of nesting.
            case id(idx).data is
              when X"7B" => -- '{'
                nesting_level_th := nesting_level_th(nesting_level_th'high-1 downto 0) & '1';
              when X"5B" => -- '['
                nesting_level_th := nesting_level_th(nesting_level_th'high-1 downto 0) & '1';
              when X"7D" => -- '}'
                nesting_level_th := '0' &nesting_level_th(nesting_level_th'high downto 1);
              when X"5D" => -- ']'
                nesting_level_th := '0' &nesting_level_th(nesting_level_th'high downto 1);
              when others =>
                nesting_level_th := nesting_level_th;
            end case;

            nesting_extra := nesting_level_th(nesting_level_th'high downto 1);


            case state is
              when STATE_BLOCK =>
                endi  := idx_int-1;
                ir    := '0';
                state := STATE_BLOCK;
                if handshaked or not has_valid then
                  handshaked := false;
                  ir         := '1';
                  case id(idx).data is
                    when X"5B" => -- '['
                      stai := idx_int+1;
                      state := STATE_ARRAY;
                    when X"5D" => -- ']'
                      endi := idx_int-1;
                      od(idx-1).last(0) := '1';
                      od(idx-1).last(1) := '1';
                      state := STATE_IDLE;
                    when others =>
                      stai := idx_int;
                      od(idx).strb := '1';
                      ov := '1';
                      state := state_ab;
                  end case;
                end if;

              when STATE_IDLE =>
                processed(idx) := '1';
                case id(idx).data is
                  when X"5B" => -- '['
                    stai := idx_int+1;
                    state := STATE_ARRAY;
                  when others =>
                    stai := idx_int+1;
                    state := STATE_IDLE;
                end case;

              when STATE_ARRAY =>
                processed(idx) := '1';
                has_valid := true;
                case id(idx).data is
                  when X"5D" => -- ']'
                    if or_reduce(nesting_extra) = '0' then
                      handshaked := false;
                      state := STATE_BLOCK;
                      state_ab := STATE_IDLE;
                      if idx = 0 then
                        od(idx).empty := '1';
                        od(idx).strb := '1';
                        endi := idx_int;
                        od(idx).last(0) := '1';
                        od(idx).last(1) := '1';
                        ov := '1';
                      else
                        endi := idx_int-1;
                        od(idx-1).last := od(idx).last;
                        od(idx-1).last(0) := '1';
                        od(idx-1).last(1) := '1';
                        ov := '1';
                        --state := STATE_ARRAY;
                      end if;
                    end if;
                  when X"2C" => -- ','
                    if or_reduce(nesting_extra) = '0' then
                      handshaked := false;
                      state := STATE_BLOCK;
                      state_ab := STATE_ARRAY;
                      if idx = 0 then
                        od(idx).empty := '1';
                        od(idx).strb := '1';
                        endi := idx_int-1;
                        od(idx).last(0) := '1';
                        ov := '1';
                      else
                        endi := idx_int-1;
                        od(idx-1).last(0) := '1';
                        ov := '1';
                        --state := STATE_ARRAY;
                      end if;
                    end if;
                  when others =>
                    od(idx).strb := '1';
                    ov := '1';
                    state := STATE_ARRAY;
                end case;
            end case;
          end if;
          -- Clear state upon any last, to prevent broken elements from messing
          -- up everything.
          if or_reduce(id(idx).last) /= '0' then
            --state := STATE_IDLE;
          end if;
        end loop;
      end if;

      -- Handle reset.
      if to_x01(reset) /= '0' then
        ir    := '0';
        ov    := '0';
        state := STATE_IDLE;
      end if;

      -- Forward output holding register.
      out_valid <= to_x01(ov);
      in_ready <= ir and not reset;
      for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
        out_data(8*idx+7 downto 8*idx) <= od(idx).data;
        out_last((OUTER_NESTING_LEVEL+2)*(idx+1)-1 downto (OUTER_NESTING_LEVEL+2)*idx) <= od(idx).last;
        out_empty(idx) <= od(idx).empty;
        out_stai <= std_logic_vector(stai);
        out_endi <= std_logic_vector(endi);
        out_strb(idx) <= od(idx).strb;
      end loop;
    end if;
  end process;
end architecture;