library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.UtilInt_pkg.all;


package trip_report_pkg is
    component TripReportParser is
      generic (
        EPC                                     : natural := 8;
        
        -- 
        -- INTEGER FIELDS
        --
        TIMEZONE_INT_WIDTH                      : natural := 16;
        TIMEZONE_INT_P_PIPELINE_STAGES          : natural := 1;
        TIMEZONE_BUFFER_D                       : natural := 1;

        VIN_INT_WIDTH                           : natural := 16;
        VIN_INT_P_PIPELINE_STAGES               : natural := 1;
        VIN_BUFFER_D                            : natural := 1;

        ODOMETER_INT_WIDTH                      : natural := 16;
        ODOMETER_INT_P_PIPELINE_STAGES          : natural := 1;
        ODOMETER_BUFFER_D                       : natural := 1;

        AVG_SPEED_INT_WIDTH                     : natural := 16;
        AVG_SPEED_INT_P_PIPELINE_STAGES         : natural := 1;
        AVG_SPEED_BUFFER_D                      : natural := 1;

        S_ACC_DEC_INT_WIDTH                     : natural := 16;
        S_ACC_DEC_INT_P_PIPELINE_STAGES         : natural := 1;
        S_ACC_DEC_BUFFER_D                      : natural := 1;

        E_SPD_CHG_INT_WIDTH                     : natural := 16;
        E_SPD_CHG_INT_P_PIPELINE_STAGES         : natural := 1;
        E_SPD_CHG_BUFFER_D                      : natural := 1;

        -- 
        -- BOOLEAN FIELDS
        --
        HYPER_MILING_BUFFER_D                   : natural := 1;
        ORIENTATION_BUFFER_D                    : natural := 1;

        -- 
        -- INTEGER ARRAY FIELDS
        --
        SECS_IN_B_INT_WIDTH                     : natural := 16;
        SECS_IN_B_INT_P_PIPELINE_STAGES         : natural := 1;
        SECS_IN_B_BUFFER_D                      : natural := 1;

        MILES_IN_TIME_INT_WIDTH                 : natural := 16;
        MILES_IN_TIME_INT_P_PIPELINE_STAGES     : natural := 1; 
        MILES_IN_TIME_BUFFER_D                  : natural := 1; 


        CONST_SPD_M_IN_B_INT_WIDTH              : natural := 16;
        CONST_SPD_M_IN_B_INT_P_PIPELINE_STAGES  : natural := 1; 
        CONST_SPD_M_IN_B_BUFFER_D               : natural := 1; 


        VAR_SPD_M_IN_B_INT_WIDTH                : natural := 16;
        VAR_SPD_M_IN_B_INT_P_PIPELINE_STAGES    : natural := 1; 
        VAR_SPD_M_IN_B_BUFFER_D                 : natural := 1; 


        SECONDS_DECEL_INT_WIDTH                 : natural := 16;
        SECONDS_DECEL_INT_P_PIPELINE_STAGES     : natural := 1; 
        SECONDS_DECEL_BUFFER_D                  : natural := 1; 


        SECONDS_ACCEL_INT_WIDTH                 : natural := 16;
        SECONDS_ACCEL_INT_P_PIPELINE_STAGES     : natural := 1; 
        SECONDS_ACCEL_BUFFER_D                  : natural := 1; 


        BRK_M_T_10S_INT_WIDTH                   : natural := 16;
        BRK_M_T_10S_INT_P_PIPELINE_STAGES       : natural := 1; 
        BRK_M_T_10S_BUFFER_D                    : natural := 1; 


        ACCEL_M_T_10S_INT_WIDTH                 : natural := 16;
        ACCEL_M_T_10S_INT_P_PIPELINE_STAGES     : natural := 1; 
        ACCEL_M_T_10S_BUFFER_D                  : natural := 1; 


        SMALL_SPD_V_M_INT_WIDTH                 : natural := 16;
        SMALL_SPD_V_M_INT_P_PIPELINE_STAGES     : natural := 1; 
        SMALL_SPD_V_M_BUFFER_D                  : natural := 1; 


        LARGE_SPD_V_M_INT_WIDTH                 : natural := 16;
        LARGE_SPD_V_M_INT_P_PIPELINE_STAGES     : natural := 1; 
        LARGE_SPD_V_M_BUFFER_D                  : natural := 1;

        -- 
        -- STRING FIELDS
        --
        TIMESTAMP_BUFFER_D                      : natural := 1;

        END_REQ_EN                              : boolean := false
      );              
      port (              
        clk                                     : in  std_logic;
        reset                                   : in  std_logic;

        in_valid                                : in  std_logic;
        in_ready                                : out std_logic;
        in_data                                 : in  std_logic_vector(8*EPC-1 downto 0);
        in_last                                 : in  std_logic_vector(2*EPC-1 downto 0);
        in_stai                                 : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
        in_endi                                 : in  std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
        in_strb                                 : in  std_logic_vector(EPC-1 downto 0);

        end_req                                 : in  std_logic := '0';
        end_ack                                 : out std_logic;

        timezone_valid                          : out std_logic;
        timezone_ready                          : in  std_logic;
        timezone_strb                           : out std_logic;
        timezone_data                           : out std_logic_vector(TIMEZONE_INT_WIDTH-1 downto 0);
        timezone_last                           : out std_logic_vector(1 downto 0);

        --    
        -- INTEGER FIELDS   
        --    
        vin_valid                               : out std_logic;
        vin_ready                               : in  std_logic;
        vin_data                                : out std_logic_vector(VIN_INT_WIDTH-1 downto 0);
        vin_strb                                : out std_logic;
        vin_last                                : out std_logic_vector(1 downto 0);

        odometer_valid                          : out std_logic;
        odometer_ready                          : in  std_logic;
        odometer_data                           : out std_logic_vector(ODOMETER_INT_WIDTH-1 downto 0);
        odometer_strb                           : out std_logic;
        odometer_last                           : out std_logic_vector(1 downto 0);

        avg_speed_valid                         : out std_logic;
        avg_speed_ready                         : in  std_logic;
        avg_speed_data                          : out std_logic_vector(AVG_SPEED_INT_WIDTH-1 downto 0);
        avg_speed_strb                          : out std_logic;
        avg_speed_last                          : out std_logic_vector(1 downto 0);

        s_acc_dec_valid                         : out std_logic;
        s_acc_dec_ready                         : in  std_logic;
        s_acc_dec_data                          : out std_logic_vector(S_ACC_DEC_INT_WIDTH-1 downto 0);
        s_acc_dec_strb                          : out std_logic;
        s_acc_dec_last                          : out std_logic_vector(1 downto 0);

        e_spd_chg_valid                         : out std_logic;
        e_spd_chg_ready                         : in  std_logic;
        e_spd_chg_data                          : out std_logic_vector(E_SPD_CHG_INT_WIDTH-1 downto 0);
        e_spd_chg_strb                          : out std_logic;
        e_spd_chg_last                          : out std_logic_vector(1 downto 0);

        --    
        -- BOOLEAN FIELDS   
        --    
        hyper_miling_valid                      : out std_logic;
        hyper_miling_ready                      : in  std_logic;
        hyper_miling_data                       : out std_logic;
        hyper_miling_strb                       : out std_logic;
        hyper_miling_last                       : out std_logic_vector(1 downto 0);

        orientation_valid                       : out std_logic;
        orientation_ready                       : in  std_logic;
        orientation_data                        : out std_logic;
        orientation_strb                        : out std_logic;
        orientation_last                        : out std_logic_vector(1 downto 0);

        --    
        -- INTEGER ARRAY FIELDS   
        --    
        secs_in_b_valid                         : out std_logic;
        secs_in_b_ready                         : in  std_logic;
        secs_in_b_data                          : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        secs_in_b_strb                          : out std_logic;
        secs_in_b_last                          : out std_logic_vector(2 downto 0);

        miles_in_time_valid                     : out std_logic;
        miles_in_time_ready                     : in  std_logic;
        miles_in_time_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        miles_in_time_strb                      : out std_logic;
        miles_in_time_last                      : out std_logic_vector(2 downto 0);


        const_spd_m_in_b_valid                  : out std_logic;
        const_spd_m_in_b_ready                  : in  std_logic;
        const_spd_m_in_b_data                   : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        const_spd_m_in_b_strb                   : out std_logic;
        const_spd_m_in_b_last                   : out std_logic_vector(2 downto 0);


        var_spd_m_in_b_valid                    : out std_logic;
        var_spd_m_in_b_ready                    : in  std_logic;
        var_spd_m_in_b_data                     : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        var_spd_m_in_b_strb                     : out std_logic;
        var_spd_m_in_b_last                     : out std_logic_vector(2 downto 0);


        seconds_decel_valid                     : out std_logic;
        seconds_decel_ready                     : in  std_logic;
        seconds_decel_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        seconds_decel_strb                      : out std_logic;
        seconds_decel_last                      : out std_logic_vector(2 downto 0);


        seconds_accel_valid                     : out std_logic;
        seconds_accel_ready                     : in  std_logic;
        seconds_accel_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        seconds_accel_strb                      : out std_logic;
        seconds_accel_last                      : out std_logic_vector(2 downto 0);


        brk_m_t_10s_valid                       : out std_logic;
        brk_m_t_10s_ready                       : in  std_logic;
        brk_m_t_10s_data                        : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        brk_m_t_10s_strb                        : out std_logic;
        brk_m_t_10s_last                        : out std_logic_vector(2 downto 0);


        accel_m_t_10s_valid                     : out std_logic;
        accel_m_t_10s_ready                     : in  std_logic;
        accel_m_t_10s_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        accel_m_t_10s_strb                      : out std_logic;
        accel_m_t_10s_last                      : out std_logic_vector(2 downto 0);


        small_spd_v_m_valid                     : out std_logic;
        small_spd_v_m_ready                     : in  std_logic;
        small_spd_v_m_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        small_spd_v_m_strb                      : out std_logic;
        small_spd_v_m_last                      : out std_logic_vector(2 downto 0);


        large_spd_v_m_valid                     : out std_logic;
        large_spd_v_m_ready                     : in  std_logic;
        large_spd_v_m_data                      : out std_logic_vector(SECS_IN_B_INT_WIDTH-1 downto 0);
        large_spd_v_m_strb                      : out std_logic;
        large_spd_v_m_last                      : out std_logic_vector(2 downto 0);

        --    
        -- STRING FIELDS   
        -- 
        timestamp_valid                         : out std_logic;
        timestamp_ready                         : in  std_logic;
        timestamp_data                          : out std_logic_vector(8*EPC-1 downto 0);
        timestamp_last                          : out std_logic_vector(3*EPC-1 downto 0);
        timestamp_stai                          : out std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '0');
        timestamp_endi                          : out std_logic_vector(log2ceil(EPC)-1 downto 0) := (others => '1');
        timestamp_strb                          : out std_logic_vector(EPC-1 downto 0)
      );
    end component;
end trip_report_pkg;



