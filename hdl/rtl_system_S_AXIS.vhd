library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtl_system_S_AXIS is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line
    -- AXI4Stream sink: Data Width
    C_S_AXIS_TDATA_WIDTH : integer := 32
    );
  port (
    -- Users to add ports here
    dv_o           : out  std_logic;
    data_o         : out  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
    data_last_o    : out  std_logic;
    clk_i          : in   std_logic;   -- Clock proveniente de la lógica.
    rst_o          : out std_logic;    -- Activo alto.
    -- User ports ends
    -- Do not modify the ports beyond this line
    -- AXI4Stream sink: Clock
    S_AXIS_ACLK    : in  std_logic;
    -- AXI4Stream sink: Reset
    S_AXIS_ARESETN : in  std_logic;
    -- Ready to accept data in
    S_AXIS_TREADY  : out std_logic;
    -- Data in
    S_AXIS_TDATA   : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
    -- Byte qualifier
    S_AXIS_TSTRB   : in  std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
    -- Indicates boundary of last packet
    S_AXIS_TLAST   : in  std_logic;
    -- Data is in valid
    S_AXIS_TVALID  : in  std_logic
    );
end rtl_system_S_AXIS;

architecture arch_imp of rtl_system_S_AXIS is

  component rtl_system_s_axis_block_fifo
  port (
    rst    : in  std_logic;
    wr_clk : in  std_logic;
    rd_clk : in  std_logic;
    din    : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH downto 0);  -- Se agrega el "last"
    wr_en  : in  std_logic;
    rd_en  : in  std_logic;
    dout   : out std_logic_vector(C_S_AXIS_TDATA_WIDTH downto 0);
    full   : out std_logic;
    empty  : out std_logic;
    valid  : out std_logic
    );
end component;

signal fifo_data_in  : std_logic_vector(C_S_AXIS_TDATA_WIDTH downto 0);
signal fifo_data_out : std_logic_vector(C_S_AXIS_TDATA_WIDTH downto 0);

signal rst        : std_logic;
signal fifo_empty : std_logic;
signal fifo_full  : std_logic;
signal fifo_valid : std_logic;
signal ren        : std_logic;

begin

fifo_data_in <= S_AXIS_TLAST & S_AXIS_TDATA;

FIFO : rtl_system_s_axis_block_fifo
  port map(
    rst    => rst,
    wr_clk => S_AXIS_ACLK,
    rd_clk => clk_i,
    -- Puerto de lectura
    dout   => fifo_data_out,
    empty  => fifo_empty,
    valid  => fifo_valid,
    rd_en  => ren,
    -- Puerto de escritura
    din    => fifo_data_in,
    wr_en  => S_AXIS_TVALID,
    full   => fifo_full
    );

S_AXIS_TREADY <= not fifo_full;
ren <= not fifo_empty;

data_o <= fifo_data_out((C_S_AXIS_TDATA_WIDTH-1) downto 0);
data_last_o <= fifo_data_out(C_S_AXIS_TDATA_WIDTH) and fifo_valid;
dv_o <= fifo_valid;

rst   <= not S_AXIS_ARESETN;
rst_o <= rst;

end arch_imp;
