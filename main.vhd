library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port ( clk : in STD_LOGIC;           
           buttons_port, switches_port: in STD_LOGIC_VECTOR (7 downto 0);
           char21, char43, LEDS_port: out STD_LOGIC_VECTOR (7 downto 0)
           );
end main;

architecture Behavioral of main is
  component kcpsm6 
  generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                  interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
           scratch_pad_memory_size : integer := 64);
  port (                   address : out std_logic_vector(11 downto 0);
                       instruction : in std_logic_vector(17 downto 0);
                       bram_enable : out std_logic;
                           in_port : in std_logic_vector(7 downto 0);
                          out_port : out std_logic_vector(7 downto 0);
                           port_id : out std_logic_vector(7 downto 0);
                      write_strobe : out std_logic;
                    k_write_strobe : out std_logic;
                       read_strobe : out std_logic;
                         interrupt : in std_logic;
                     interrupt_ack : out std_logic;
                             sleep : in std_logic;
                             reset : in std_logic;
                               clk : in std_logic);
end component;

  component V1_KCPSM3                             
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;

signal       instr_adr : std_logic_vector(11 downto 0);
signal           instr : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0) := (others => '0');
signal         port_id : std_logic_vector(7 downto 0);
signal           wr_en : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal    kcpsm6_sleep : std_logic;
signal    kcpsm6_reset : std_logic;
signal     data_choice : std_logic_vector (7 downto 0) := (others => '0');

signal       cpu_reset : std_logic;
signal             rdl : std_logic;
signal     int_request : std_logic;

begin
 processor: kcpsm6
   generic map (                 hwbuild => X"00", 
                        interrupt_vector => X"3FF",
                 scratch_pad_memory_size => 64)
   port map(      address => instr_adr,
              instruction => instr,
              bram_enable => bram_enable,
                  port_id => port_id,      --change back to open
             write_strobe => wr_en,
           k_write_strobe => open,
                 out_port => out_port,
              read_strobe => open,
                  in_port => data_choice,
                interrupt => '0',
            interrupt_ack => open,
                    sleep => '0',
                    reset => rdl,
                      clk => clk);
                      
  program_rom: V1_KCPSM3                    --Name to match your PSM file
                        generic map(             C_FAMILY => "7S",   --Family 'S6', 'V6' or '7S'
                                        C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                                     C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
                        port map(      address => instr_adr,      
                                   instruction => instr,
                                        enable => bram_enable,
                                           rdl => rdl,
                                           clk => clk);
                                           
    process(clk)
    begin    
        if (rising_edge(clk)) then        
           -- if  wr_en = '1' then
               --result <= out_port;
               case port_id is                
                when "00000010" => data_choice <= buttons_port;
                when "00000011" => data_choice <= switches_port;
                
                when "00000100" => char21 <= out_port;
                when "00000101" => char43 <= out_port;
                when "00000110" => LEDS_port <= out_port;
                                                                                 
                when others => data_choice <= (others => '0');

                
                end case;   
           -- end if;
        end if;       
    end process;                                                                  
end Behavioral;
