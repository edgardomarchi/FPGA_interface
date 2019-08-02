library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rtl_system is
  generic (
    -- Users to add parameters here

    -- User parameters ends

    -- Do not modify the parameters beyond this line
    -- Parameters of Axi Slave Bus Interface S_AXI
    C_S_AXI_DATA_WIDTH : integer := 32;
    C_S_AXI_ADDR_WIDTH : integer := 6;

    -- Parameters of Axi Master Bus Interface M_AXIS
    C_M_AXIS_TDATA_WIDTH : integer := 32;
    C_M_AXIS_START_COUNT : integer := 32
    );
  port (
    -- Users to add ports here

    -- User ports ends

    -- Do not modify the ports beyond this line
    -- Ports of Axi Slave Bus Interface S_AXI
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_awprot  : in  std_logic_vector(2 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;
    s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    s_axi_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    -- Ports of Axi Streaming Slave Bus Interface S_AXIS
    S_AXIS_ACLK    : in  std_logic;
    S_AXIS_ARESETN : in  std_logic;
    S_AXIS_TREADY  : out std_logic;
    S_AXIS_TDATA   : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
    S_AXIS_TSTRB   : in  std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
    S_AXIS_TLAST   : in  std_logic;
    S_AXIS_TVALID  : in  std_logic

    -- Ports of Axi Streaming Master Bus Interface M_AXIS
    m_axis_aclk    : in  std_logic;
    m_axis_aresetn : in  std_logic;
    m_axis_tvalid  : out std_logic;
    m_axis_tdata   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    m_axis_tstrb   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
    m_axis_tlast   : out std_logic;
    m_axis_tready  : in  std_logic
    );
end rtl_system;

architecture arch_imp of rtl_system is

  -- component declaration
  component rtl_system_S_AXI is
    generic (
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 6
      );
    port (
      -- Puertos internos
      reg0_o        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      reg1_o        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      reg2_o        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      reg3_o        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      -- Puertos AXI
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic
      );
  end component rtl_system_S_AXI;

  component rtl_system_S_AXIS is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line
    -- AXI4Stream sink: Data Width
    C_S_AXIS_TDATA_WIDTH : integer := 32
    );
  port (
    -- Users to add ports here

    -- User ports ends

    -- Do not modify the ports beyond this line
    S_AXIS_ACLK    : in  std_logic;
    S_AXIS_ARESETN : in  std_logic;
    S_AXIS_TREADY  : out std_logic;
    S_AXIS_TDATA   : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
    S_AXIS_TSTRB   : in  std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
    S_AXIS_TLAST   : in  std_logic;
    S_AXIS_TVALID  : in  std_logic
    );
    end rtl_system_S_AXIS;

  component rtl_system_M_AXIS is
    generic (
      C_M_AXIS_TDATA_WIDTH : integer := 32
      );
    port (
      -- Users to add ports here
      we_i           : in  std_logic;
      data_i         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      data_last_i    : in  std_logic;
      clk_i          : in  std_logic;   -- Clock proveniente de AXI.
      rst_o          : out std_logic;   -- Activo alto.
      -- Fin puertos de usuario
      M_AXIS_ACLK    : in  std_logic;
      M_AXIS_ARESETN : in  std_logic;
      M_AXIS_TVALID  : out std_logic;
      M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TLAST   : out std_logic;
      M_AXIS_TREADY  : in  std_logic
      );
  end component rtl_system_M_AXIS;

  signal rst : std_logic;

  -- Registros de configuración
  signal reg0 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal reg1 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal reg2 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal reg3 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  
begin

  rst <= not rstn_i;

  -- Instantiation of Axi Bus Interface S_AXI
  rtl_system_S_AXI_inst: rtl_system_S_AXI
    generic map (
      C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
      )
    port map (
      reg0_o        => reg0,
      reg1_o        => reg1,
      reg2_o        => reg2,
      reg3_o        => reg3,
      S_AXI_ACLK    => s_axi_aclk,
      S_AXI_ARESETN => s_axi_aresetn,
      S_AXI_AWADDR  => s_axi_awaddr,
      S_AXI_AWPROT  => s_axi_awprot,
      S_AXI_AWVALID => s_axi_awvalid,
      S_AXI_AWREADY => s_axi_awready,
      S_AXI_WDATA   => s_axi_wdata,
      S_AXI_WSTRB   => s_axi_wstrb,
      S_AXI_WVALID  => s_axi_wvalid,
      S_AXI_WREADY  => s_axi_wready,
      S_AXI_BRESP   => s_axi_bresp,
      S_AXI_BVALID  => s_axi_bvalid,
      S_AXI_BREADY  => s_axi_bready,
      S_AXI_ARADDR  => s_axi_araddr,
      S_AXI_ARPROT  => s_axi_arprot,
      S_AXI_ARVALID => s_axi_arvalid,
      S_AXI_ARREADY => s_axi_arready,
      S_AXI_RDATA   => s_axi_rdata,
      S_AXI_RRESP   => s_axi_rresp,
      S_AXI_RVALID  => s_axi_rvalid,
      S_AXI_RREADY  => s_axi_rready
      );

  -- Instantiation of Axi Bus Interface M_AXIS
  rtl_system_M_AXIS: rtl_system_M_AXIS
    generic map (
      -- DATA_WIDTH           => (SAMPLE_BIT_DEPTH + ceil2power(MAX_NUM_AVRG-1))*CHANNELS,
      C_M_AXIS_TDATA_WIDTH => C_M_AXIS_TDATA_WIDTH
      )
    port map (
      -- Users to add ports here
      we_i           => dv_avrg,
      data_i         => data_IQ_averaged,
      data_last_i    => last_avrg,
      clk_i          => clk_Tsample_i,
      rst_o          => open,           -- Activo alto.
      -- Fin puertos de usuario
      M_AXIS_ACLK    => m_axis_aclk,
      M_AXIS_ARESETN => m_axis_aresetn,
      M_AXIS_TVALID  => m_axis_tvalid,
      M_AXIS_TDATA   => m_axis_tdata,
      M_AXIS_TSTRB   => m_axis_tstrb,
      M_AXIS_TLAST   => m_axis_tlast,
      M_AXIS_TREADY  => m_axis_tready
      );



end arch_imp;
