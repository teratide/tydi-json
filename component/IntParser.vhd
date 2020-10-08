library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


library work;
use work.UtilInt_pkg.all;
use work.Json_pkg.all;

entity IntParser is
  generic (
      ELEMENTS_PER_TRANSFER : natural := 1;
      NESTING_LEVEL         : natural := 1;
      BITWIDTH              : natural := 64;
      SIGNED                : boolean := false -- Signed not supported yet!
      );
  port (
      clk                   : in  std_logic;
      reset                 : in  std_logic;

      -- Stream(
      --     Bits(8),
      --     t=ELEMENTS_PER_TRANSFER,
      --     d=NESTING_LEVEL,
      --     c=7
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
      out_data              : out std_logic_vector(BITWIDTH-1 downto 0);
      out_empty             : out std_logic;
      out_last              : out std_logic_vector(NESTING_LEVEL-1 downto 0)

  );
end entity;

architecture behavioral of IntParser is
    signal processed_dbg : std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);
    signal stall_dbg : std_logic;
    begin
      clk_proc: process (clk) is
        constant IDXW : natural := log2ceil(ELEMENTS_PER_TRANSFER);
    
        -- Input holding register.
        type in_type is record
          data  : std_logic_vector(7 downto 0);
          last  : std_logic_vector(NESTING_LEVEL downto 0);
          empty : std_logic;
          strb  : std_logic;
        end record;
    
        type in_array is array (natural range <>) of in_type;
        variable id   : in_array(0 to ELEMENTS_PER_TRANSFER-1);
        variable stai : unsigned(log2ceil(ELEMENTS_PER_TRANSFER)-1 downto 0);
        variable iv   : std_logic := '0';
        variable ir   : std_logic := '0';
    
        -- Output holding register.
        type out_type is record
          data  : std_logic_vector(7 downto 0);
        end record;
    
        type out_array is array (natural range <>) of out_type;
        variable od : out_array(0 to ELEMENTS_PER_TRANSFER-1);
        variable ol : std_logic_vector(NESTING_LEVEL-1 downto 0);
        variable ov : std_logic := '0';
        variable oe : std_logic := '0';
        variable out_r : std_logic := '0';
        
        -- Enumeration type for our state machine.
        type state_t is (STATE_IDLE,
                         STATE_DONE);
    
        -- State variable
        variable state : state_t;
        variable comm  : comm_t;
        variable val   : boolean;

        -- Stall the input when there are characters
        -- for multiple integers in the input transaction.
        variable stall : boolean;
                
        -- Mark the processed characters in the 
        -- current transaction.
        variable processed : std_logic_vector(ELEMENTS_PER_TRANSFER-1 downto 0);

        variable in_shr  : std_logic_vector(BITWIDTH+(BITWIDTH-4)/3-1 downto 0) := (others => '0');
        variable bcd_shr : std_logic_vector(BITWIDTH+(BITWIDTH-4)/3-1 downto 0) := (others => '0');
        variable bin_shr : std_logic_vector(BITWIDTH-1 downto 0) := (others => '0');

    
      begin
        if rising_edge(clk) then
    
          -- Latch input holding register if we said we would.
          if to_x01(ir) = '1' then
            iv := in_valid;
            if to_x01(iv) = '1'then
              comm := in_data.comm;
              processed := (others => '0');
              for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop
                id(idx).data := in_data.data(8*idx+7 downto 8*idx);
                id(idx).last := in_last((NESTING_LEVEL+1)*(idx+1)-1 downto (NESTING_LEVEL+1)*idx);
                comm := in_data.comm;
                stai := unsigned(in_stai);
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
          end if;
    
          -- Clear output holding register if transfer was accepted.
          if to_x01(out_ready) = '1' then
            ov := '0';
            stall := false;
          end if;
          ol := (others => '0');
          oe := '0';

          for idx in 0 to ELEMENTS_PER_TRANSFER-1 loop

            if to_x01(ov) /= '1' and processed(idx) = '0' and not stall then
              bin_shr := (others => '0');
              if to_x01(id(idx).strb) = '1' then

                ol := ol or id(idx).last(NESTING_LEVEL downto 1);

                if comm = ENABLE and to_x01(id(idx).empty) = '1' then
                  oe := '1';
                end if;

                if comm = ENABLE and id(idx).data(7 downto 4) = X"3"
                    and to_x01(id(idx).empty) = '0' then
                  oe := '0';
                  in_shr := in_shr(in_shr'high-4 downto 0) & id(idx).data(3 downto 0);
                end if;

                if id(idx).last(0) /= '0'  then
                  bcd_shr := in_shr;
                  in_shr  := (others => '0');
                  processed(idx) := '1';
                  stall := true;
                  oe := '0';
                  ov := '1';
                end if;
              end if;

              if not stall then
                processed(idx) := '1';
              end if;

            end if;
            if stall then
              ir := '0';
            else
              ir := or_reduce(processed);
              if or_reduce(ol) and or_reduce(processed) then
                ov := '1';  
              end if;
            end if;
          end loop;

          for i in bin_shr'range loop
            bin_shr := bcd_shr(0) & bin_shr(bin_shr'left downto 1);
            bcd_shr := '0' & bcd_shr(bcd_shr'high downto 1);
            for idx in 0 to (BITWIDTH+(BITWIDTH-4)/3)/4-1 loop
              if unsigned(bcd_shr(idx*4+3 downto idx*4)) >= 8 then
                bcd_shr(idx*4+3 downto idx*4) := std_logic_vector(unsigned(unsigned(bcd_shr(idx*4+3 downto idx*4)) - 3));
              end if;
            end loop;
          end loop;

          -- Handle reset.
          if to_x01(reset) /= '0' then
            ir    := '0';
            ov    := '0';
            in_shr  := (others => '0');
            bin_shr := (others => '0');
            processed := (others => '0');
          end if;
    
          -- Forward output holding register.
          out_valid <= to_x01(ov);
          out_data <= bin_shr;
          out_last <= ol;
          out_empty <= oe;
          in_ready <= ir and not reset;

          processed_dbg <= processed;
          stall_dbg <= '1' when stall else '0';
        end if;
      end process;
    end architecture;