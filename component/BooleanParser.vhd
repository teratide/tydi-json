library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;

-- TODO

entity BooleanParser is
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
      --     d=NESTING_LEVEL+1,
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
end entity;

architecture behavioral of BooleanParser is
    begin
      clk_proc: process (clk) is
        constant IDXW : natural := log2ceil(ELEMENTS_PER_TRANSFER);
    
        -- Input holding register.
        type in_type is record
          data  : std_logic_vector(7 downto 0);
          --last  : std_logic_vector(NESTING_LEVEL-1 downto 0);
          last  : std_logic;
          empty : std_logic;
          strb  : std_logic;
        end record;
    
        type in_array is array (natural range <>) of in_type;
        variable id : in_array(0 to ELEMENTS_PER_TRANSFER-1);
        variable iv : std_logic := '0';
        variable ir : std_logic := '0';
    
        -- Output holding register.
        type out_type is record
          data  : std_logic_vector(7 downto 0);
          last  : std_logic_vector(NESTING_LEVEL-1 downto 0);
        end record;
    
        type out_array is array (natural range <>) of out_type;
        variable od : out_array(0 to ELEMENTS_PER_TRANSFER-1);
        variable ov : std_logic := '0';
        variable out_r : std_logic := '0';
        
        -- Enumeration type for our state machine.
        type state_t is (STATE_IDLE,
                         STATE_DONE);
    
        -- State variable
        variable state : state_t;

        variable comm  : comm_t;

        variable val : boolean;
    
      begin
        if rising_edge(clk) then
    
          -- Latch input holding register if we said we would.
          if to_x01(ir) = '1' then
            iv := in_valid;
            out_r := out_ready;
            for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
              id(idx).data := in_data.data(8*idx+7 downto 8*idx);
              --id(idx).last := in_data(NESTING_LEVEL*(idx+1)-1 downto NESTING_LEVEL*idx);
              comm := in_data.comm;
              id(idx).last := in_last(idx);
              id(idx).empty := in_empty(idx);
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
          ir                   := '1';

          -- Do processing when both registers are ready.
          if to_x01(iv) = '1' and to_x01(ov) /= '1' then
            for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
              -- Element-wise processing only when the lane is valid.
              if to_x01(id(idx).strb) = '1' and comm = ENABLE and to_x01(id(idx).empty) = '0' then
                case id(idx).data is
                  when X"66" => -- 'f'
                      ov := '1';
                      state := STATE_DONE;
                      val:= false;
                  when X"46" => -- 'F'
                      ov := '1';
                      state := STATE_DONE;
                      val:= false;
                  when X"74" => -- 't'
                      ov := '1';    
                      state := STATE_DONE;
                      val:= true;
                  when X"54" => -- 'T'
                      ov := '1';
                      state := STATE_DONE;
                      val:= true;
                  when others =>
                      state := STATE_IDLE;
                end case;
             end if;

              -- Clear state upon any last, to prevent broken elements from messing
              -- up everything.
              if id(idx).last /= '0' then
                state := STATE_IDLE;
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
          out_data <= '1' when val else '0';
          in_ready <= ir and not reset;
          
        end if;
      end process;
    end architecture;