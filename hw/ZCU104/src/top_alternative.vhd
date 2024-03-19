-----------------------------------------------------------
-- VHDL
-- Top-level design for Zyng PS-PL shared AXI BRGM memory
-----------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity top is
    port (
        -- Add your additional output ports here
        led_out_0: out std_logic;
        led_out_1: out std_logic;
        led_out_2: out std_logic;
        led_out_3: out std_logic
    );
end top;

architecture arch of top is

-- BRAM port A, PS access through software
signal bram_porta_0_addr: std_logic_vector(12 downto 0);
signal clk: std_logic;
signal bram_porta_0_din: std_logic_vector(31 downto 0);
signal bram_porta_0_dout: std_logic_vector(31 downto 0);
signal bram_porta_0_en: std_logic;
signal rst: std_logic;
signal bram_porta_0_we: std_logic_vector(3 downto 0);

-- BRAM port B, PL access
signal bram_portb_0_addr: std_logic_vector(10 downto 0) := (others => '0');
signal bram_portb_0_din: std_logic_vector(31 downto 0) := (others => '0');
signal bram_portb_0_dout: std_logic_vector(31 downto 0);
signal bram_portb_0_we: std_logic := '0';

-- LED indicator storage 
signal led_out_reg: std_logic_vector(31 downto 0) := (others => '0');
signal all_addrs_initialized : std_logic := '0';

begin


-- Zyng system black
zynq_ps_interface_inst: entity work.block_design_wrapper
port map (
	BRAM_PORTA_0_addr => bram_porta_0_addr,
	BRAM_PORTA_0_clk => clk,
	BRAM_PORTA_0_din => bram_porta_0_din,
	BRAM_PORTA_0_dout => bram_porta_0_dout,
	BRAM_PORTA_0_en => bram_porta_0_en,
	BRAM_PORTA_0_rst => rst,
	BRAM_PORTA_0_we => bram_porta_0_we
);

-- BRAM memory 2K by 32-bit
blk_mem_gen_0_inst: entity work.blk_mem_gen_0
	port map (
		-- Zynga PS access through software
		clka => clk,
		ena => bram_porta_0_en,
		wea => bram_porta_0_we(0 downto 0),
		addra => bram_porta_0_addr(12 downto 2),
		dina => bram_porta_0_din,
		douta => bram_porta_0_dout,
		-- PL fafric access
		clkb => clk,
        enb => '1',
		web (0)=> bram_portb_0_we,
		addrb => bram_portb_0_addr,
		dinb => bram_portb_0_din,
		doutb => bram_portb_0_dout
);


-- Write 32-bit counter data into BRAM
process (clk)
begin
	if rising_edge(clk) then
		if rst='1' then
			bram_portb_0_addr <= (others => '0');
			bram_portb_0_din <= (others => '0');
			bram_portb_0_we <= '0';
			led_out_reg <= (others => '0');
			all_addrs_initialized <= '0';
		else
			if all_addrs_initialized = '0' then
			     
			     led_out_reg <= (others => '0');
			     
			     if (bram_portb_0_addr /= X"7FF") then
				    bram_portb_0_addr <= bram_portb_0_addr + 1;
				    bram_portb_0_din <= bram_portb_0_din + 1;
				    bram_portb_0_we <= '1';
				 else
				    all_addrs_initialized <= '1';
				 end if;
				 
			else
			--------------
			    bram_portb_0_addr <= (others => '0'); -- set address to zero
			    led_out_reg <= bram_portb_0_dout;
			--------------
				bram_portb_0_we <= '0';
			end if;
	end if;
end if;
end process;

-- Connect LED signals to FPGA pins
led_out_0 <= led_out_reg(0);
led_out_1 <= led_out_reg(1);
led_out_2 <= led_out_reg(2);
led_out_3 <= led_out_reg(3);

end arch;