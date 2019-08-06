library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rtl_system_M_AXIS is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    C_M_AXIS_TDATA_WIDTH : integer := 32
    );
  port (
    -- Users to add ports here
    we_i        : in  std_logic;
    data_i      : in  std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    data_last_i : in  std_logic;
    clk_i       : in  std_logic;        -- User logic clock.
    rst_o       : out std_logic;        -- Active high (@M_AXIS_ACLK).

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global ports
    M_AXIS_ACLK    : in  std_logic; -- Clock proveniente de AXI.
    --
    M_AXIS_ARESETN : in  std_logic;
    -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
    M_AXIS_TVALID  : out std_logic;
    -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
    M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
    -- TLAST indicates the boundary of a packet.
    M_AXIS_TLAST   : out std_logic;
    -- TREADY indicates that the slave can accept a transfer in the current cycle.
    M_AXIS_TREADY  : in  std_logic
    );
end rtl_system_M_AXIS;

architecture arch_imp of rtl_system_M_AXIS is

  component rtl_system_m_axis_block_fifo
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(C_M_AXIS_TDATA_WIDTH downto 0);  -- Se agrega el "last"
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH downto 0);
      full   : out std_logic;
      empty  : out std_logic;
      valid  : out std_logic
      );
  end component;

  signal fifo_data_in  : std_logic_vector(C_M_AXIS_TDATA_WIDTH downto 0);
  signal fifo_data_out : std_logic_vector(C_M_AXIS_TDATA_WIDTH downto 0);

  signal rst        : std_logic;
  signal fifo_empty : std_logic;
  signal fifo_valid : std_logic;
  signal ren        : std_logic;

begin

  fifo_data_in <= data_last_i & data_i;

  FIFO : rtl_system_m_axis_block_fifo
    port map(
      rst    => rst,
      wr_clk => clk_i,
      rd_clk => M_AXIS_ACLK,
      -- Puerto de lectura
      dout   => fifo_data_out,
      empty  => fifo_empty,
      valid  => fifo_valid,
      rd_en  => ren,
      -- Puerto de escritura
      din    => fifo_data_in,
      wr_en  => we_i,
      full   => open
      );

  ren <= not fifo_empty and M_AXIS_TREADY;

  M_AXIS_TDATA <= fifo_data_out(C_M_AXIS_TDATA_WIDTH-1 downto 0);
  M_AXIS_TLAST  <= fifo_data_out(C_M_AXIS_TDATA_WIDTH) and fifo_valid and M_AXIS_TREADY;
  M_AXIS_TSTRB  <= (others => '1');
  M_AXIS_TVALID <= fifo_valid and M_AXIS_TREADY;

  rst   <= not M_AXIS_ARESETN;
  rst_o <= rst;

end arch_imp;
