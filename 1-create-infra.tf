# ---------- Create Projects ----------
resource "zedcloud_project" "tf_quvia_demo_1" {
  name            = "TF-QUVIA-DEMO"
  title           = "TF-QUVIA-DEMO"
  type            = "TAG_TYPE_PROJECT"
  tag_level_settings    {
    interface_ordering = "INTERFACE_ORDERING_ENABLED"
    flow_log_transmission   = "NETWORK_INSTANCE_FLOW_LOG_TRANSMISSION_ENABLED"
  }
  edgeview_policy {
      type          = "POLICY_TYPE_EDGEVIEW"
    edgeview_policy {
      access_allow_change = true
      edgeview_allow = true
      edgeviewcfg {
        app_policy {
          allow_app = true
        }
        dev_policy {
          allow_dev = true
        }
        jwt_info {
          disp_url = "zedcloud.gmwtus.zededa.net/api/v1/edge-view"
          allow_sec = 18000
          num_inst = 1
          encrypt = true
        }
        ext_policy {
          allow_ext = true
        }
      }
      max_expire_sec = 2592000
      max_inst = 3
    }
  }
}

# ---------- Create Datastores ----------
resource "zedcloud_datastore" "tf_quvia_sjc_ds_1" {
  name    = "TF-QUVIA-SJC-DS"
  title   = "TF-QUVIA-SJC-DS"
  ds_fqdn = "http://172.16.8.129"
  ds_type = "DATASTORE_TYPE_HTTP"
  ds_path = "iso"
  project_access_list = []
}

resource "zedcloud_datastore" "tf_quvia_atl_ds" {
  name    = "TF-QUVIA-ATL-DS"
  title   = "TF-QUVIA-ATL-DS"
  ds_fqdn = "http://192.168.0.101:88"
  ds_type = "DATASTORE_TYPE_HTTP"
  ds_path = ""
  project_access_list = []
}

# #######Create a Azure Blob datastore
resource "zedcloud_datastore" "demo_az_blob_ds" {
  name    = "TF-ZED-DEMO-AZ-DS"
  title   = "TF-ZED-DEMO-AZ-DS"
  api_key = var.azure_blob_api_key
  ds_fqdn = "<azure blob URL>"
  secret {
    api_passwd = var.azure_blob_api_passwd
  }
  ds_type = "DATASTORE_TYPE_AZUREBLOB"

  ds_path = "< blob name >"
}

resource "zedcloud_datastore" "demo_s3_bucket_ds" {
  name          = "TF-ZED-DEMO-S3-DS"
  title         = "TF-ZED-DEMO-S3-DS"
  api_key       = var.s3_api_key
  ds_fqdn       = "<azure blob URL>"
  secret {
    api_passwd  = var.s3_api_passwd
  }
  ds_type       = "DATASTORE_TYPE_AWSS3"

  ds_path       = "< bucket name >"
}


##--------------------- Container registry ---------------------------------
resource "zedcloud_datastore" "tf_quvia_docker_hub_1" {
  ds_fqdn = "docker://docker.io"
  ds_type = "DATASTORE_TYPE_CONTAINERREGISTRY"
  name    = "TF-QUVIA-DOCKER-HUB"
  title   = "TF-QUVIA-DOCKER-HUB"
  project_access_list = []
}

# ---------- Creating EVE Network Port Config per Project ----------
resource "zedcloud_network" "tf_quvia_edge_net_1" {
  name        = "TF-Q-NET-1"
  title       = "TF-Q-NET-1"
  description = "Network (DHCP)"
  enterprise_default = false
  kind        = "NETWORK_KIND_V4"
  ip {
    dhcp = "NETWORK_DHCP_TYPE_CLIENT"
  }
  project_id = zedcloud_project.tf_quvia_demo_1.id
}

##------------- Static + Proxy configuration ------------------------------
resource "zedcloud_network" "demo_eve_net_port_static_w_proxy" {
  name               = "DEMO-EVE-STATIC-IP-192-168-2-0-24-w-proxy"
  title              = "DEMO-EVE-STATIC-IP-192-168-2-0-24-w-proxy"
  description        = "This tells EVE use static IP 192.168.2.x for management port"
  enterprise_default = false
  kind               = "NETWORK_KIND_V4_ONLY"
  ip {
    dhcp             = "NETWORK_DHCP_TYPE_STATIC"
    gateway          = "192.168.2.1"
    subnet           = "192.168.2.0/24"
    dns              = ["192.168.2.1"]
  }
  proxy {
    proxies {
      proto          = "NETWORK_PROXY_PROTO_HTTP"
      server         = "192.168.2.50"
      port           = 3128 
    }
    proxies {
      proto          = "NETWORK_PROXY_PROTO_HTTPS"
      server         = "192.168.2.50"
      port           = 3128 
    }
    proxies {
      proto          = "NETWORK_PROXY_PROTO_SOCKS"
      server         = ""
      port           = 0
    }
    proxies {
      proto          = "NETWORK_PROXY_PROTO_FTP"
      server         = ""
      port           = 0
    }
  }
  project_id = zedcloud_project.tf_quvia_demo_1.id


}


# ---------- Create Brand and Model----------
resource "zedcloud_brand" "tf_quvia_dell_brand" {
  name        = "TF-Dell-Brand"
  title       = "TF-Dell-Brand"
  origin_type = "ORIGIN_LOCAL"
  logo        = {
    url       = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Dell_logo_2016.svg/120px-Dell_logo_2016.svg.png"
  }
}

##------- no SRIOV
resource "zedcloud_model" "tf_quvia_dell_model" {
  name          = "TF-Quvia-Dell-XR5610"
  title         = "TF-Quvia-Dell-XR5610"
  brand_id      = zedcloud_brand.tf_quvia_dell_brand.id
  origin_type   = "ORIGIN_LOCAL"
  state         =  "SYS_MODEL_STATE_ACTIVE"
  type          = "AMD64"
  attr          =  {
    memory      = "63433M"
    storage     = "894G"
    Cpus        = "48"
  }
 io_member_list {
      ztype         = "IO_TYPE_HDMI"
      usage         = "ADAPTER_USAGE_APP_SHARED"
      phylabel      = "VGA"
      logicallabel  = "VGA"
      cost          = 0
      assigngrp     = ""
      phyaddrs      = { 
        Ifname = "VGA"
        PciLong = "0000:03:00.0" }
    }
  io_member_list {
      ztype        = "IO_TYPE_USB_CONTROLLER"
      usage        = "ADAPTER_USAGE_APP_SHARED"
      phylabel     = "USB"
      assigngrp    = "group"
      phyaddrs     = { 
        Ifname     = "USB"
        PciLong    = "0000:00:14.0" }
      logicallabel = "USB"
      cost         = 0
    }
  io_member_list {
      ztype        = "IO_TYPE_COM"
      phylabel     = "COM1"
      assigngrp    = "COM1"
      phyaddrs     = { 
        Ioports = "3f8-3ff"
        Irq = 16
        Serial = "/dev/ttyS0" }
      logicallabel = "COM1"
      cost         = 0
    }
  io_member_list {
      ztype        = "IO_TYPE_COM"
      phylabel     = "COM2"
      assigngrp    = "COM2"
      phyaddrs     = { 
        Ioports = "2f8-2ff"
        Irq = 16
        Serial = "/dev/ttyS1" }
      logicallabel = "COM2"
      cost         = 0
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth0"
      logicallabel  = "eth0"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth0"
      phyaddrs      = { 
        Ifname = "eth0"
        PciLong = "0000:17:00.0" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH_PF"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth1"
      logicallabel  = "eth1"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth1"
      phyaddrs      = { 
        Ifname = "eth1"
        PciLong = "0000:17:00.1" }
      vfs {
        count = 4
      } 
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH_PF"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth2"
      logicallabel  = "eth2"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth2"
      phyaddrs      = { 
        Ifname = "eth2"
        PciLong = "0000:17:00.2" }
      vfs {
        count = 4
      } 
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH_PF"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth3"
      logicallabel  = "eth3"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth3"
      phyaddrs      = { 
        Ifname = "eth3"
        PciLong = "0000:17:00.3" }
      vfs {
        count = 4
      } 
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth4"
      logicallabel  = "eth4"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth4"
      phyaddrs      = { 
        Ifname = "eth4"
        PciLong = "0000:6f:00.0" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth5"
      logicallabel  = "eth5"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth5"
      phyaddrs      = { 
        Ifname = "eth5"
        PciLong = "0000:6f:00.1" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth6"
      logicallabel  = "eth6"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth6"
      phyaddrs      = { 
        Ifname = "eth6"
        PciLong = "0000:6f:00.2" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth7"
      logicallabel  = "eth7"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth7"
      phyaddrs      = { 
        Ifname = "eth7"
        PciLong = "0000:6f:00.3" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth8"
      logicallabel  = "eth8"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth8"
      phyaddrs      = { 
        Ifname = "eth8"
        PciLong = "0000:43:00.0" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth9"
      logicallabel  = "eth9"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth9"
      phyaddrs      = { 
        Ifname = "eth9"
        PciLong = "0000:43:00.1" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth10"
      logicallabel  = "eth10"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth10"
      phyaddrs      = { 
        Ifname = "eth10"
        PciLong = "0000:43:00.2" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth11"
      logicallabel  = "eth11"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth11"
      phyaddrs      = { 
        Ifname = "eth11"
        PciLong = "0000:43:00.3" }  
    }

}

##------- SRIOV
resource "zedcloud_model" "demo_dell_xr5610_model_sriov" {
  name          = "TF-Quvia-Dell-XR5610-SRIOV"
  title         = "TF-Quvia-Dell-XR5610-SRIOV"
  brand_id      = zedcloud_brand.tf_quvia_dell_brand.id
  origin_type   = "ORIGIN_LOCAL"
  state         =  "SYS_MODEL_STATE_ACTIVE"
  type          = "AMD64"
  attr          =  {
    memory      = "63433M"
    storage     = "894G"
    Cpus        = "48"
  }
 io_member_list {
      ztype         = "IO_TYPE_HDMI"
      usage         = "ADAPTER_USAGE_APP_SHARED"
      phylabel      = "VGA"
      logicallabel  = "VGA"
      cost          = 0
      assigngrp     = ""
      phyaddrs      = { 
        Ifname = "VGA"
        PciLong = "0000:03:00.0" }
    }
  io_member_list {
      ztype        = "IO_TYPE_USB_CONTROLLER"
      usage        = "ADAPTER_USAGE_APP_SHARED"
      phylabel     = "USB"
      assigngrp    = "group"
      phyaddrs     = { 
        Ifname     = "USB"
        PciLong    = "0000:00:14.0" }
      logicallabel = "USB"
      cost         = 0
    }
  io_member_list {
      ztype        = "IO_TYPE_COM"
      phylabel     = "COM1"
      assigngrp    = "COM1"
      phyaddrs     = { 
        Ioports = "3f8-3ff"
        Irq = 16
        Serial = "/dev/ttyS0" }
      logicallabel = "COM1"
      cost         = 0
    }
  io_member_list {
      ztype        = "IO_TYPE_COM"
      phylabel     = "COM2"
      assigngrp    = "COM2"
      phyaddrs     = { 
        Ioports = "2f8-2ff"
        Irq = 16
        Serial = "/dev/ttyS1" }
      logicallabel = "COM2"
      cost         = 0
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth0"
      logicallabel  = "eth0"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth0"
      phyaddrs      = { 
        Ifname = "eth0"
        PciLong = "0000:17:00.0" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH_PF"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth1"
      logicallabel  = "eth1"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth1"
      phyaddrs      = { 
        Ifname = "eth1"
        PciLong = "0000:17:00.1" }
      vfs {
        count = 4
      } 
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH_PF"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth2"
      logicallabel  = "eth2"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth2"
      phyaddrs      = { 
        Ifname = "eth2"
        PciLong = "0000:17:00.2" }
      vfs {
        count = 4
      } 
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH_PF"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth3"
      logicallabel  = "eth3"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth3"
      phyaddrs      = { 
        Ifname = "eth3"
        PciLong = "0000:17:00.3" }
      vfs {
        count = 4
      } 
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth4"
      logicallabel  = "eth4"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth4"
      phyaddrs      = { 
        Ifname = "eth4"
        PciLong = "0000:6f:00.0" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth5"
      logicallabel  = "eth5"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth5"
      phyaddrs      = { 
        Ifname = "eth5"
        PciLong = "0000:6f:00.1" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth6"
      logicallabel  = "eth6"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth6"
      phyaddrs      = { 
        Ifname = "eth6"
        PciLong = "0000:6f:00.2" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth7"
      logicallabel  = "eth7"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth7"
      phyaddrs      = { 
        Ifname = "eth7"
        PciLong = "0000:6f:00.3" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth8"
      logicallabel  = "eth8"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth8"
      phyaddrs      = { 
        Ifname = "eth8"
        PciLong = "0000:43:00.0" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth9"
      logicallabel  = "eth9"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth9"
      phyaddrs      = { 
        Ifname = "eth9"
        PciLong = "0000:43:00.1" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth10"
      logicallabel  = "eth10"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth10"
      phyaddrs      = { 
        Ifname = "eth10"
        PciLong = "0000:43:00.2" }
    }
  io_member_list {
      ztype         = "IO_TYPE_ETH"
      usage         = "ADAPTER_USAGE_MANAGEMENT"
      phylabel      = "eth11"
      logicallabel  = "eth11"
      usage_policy   = {
        FreeUplink = false
      }
      cost          = 0
      assigngrp     = "eth11"
      phyaddrs      = { 
        Ifname = "eth11"
        PciLong = "0000:43:00.3" }  
    }

}

# ---------- Create Edge Nodes ---------------------------
resource "zedcloud_edgenode" "tf_quvia_edge_node_1" {
  name           = "TF-QUVIA-NODE-1"
  title          = "TF-QUVIA-NODE-1"
  project_id     = zedcloud_project.tf_quvia_demo_1.id
  model_id       = zedcloud_model.tf_quvia_dell_model.id
  onboarding_key = var.onboarding_key
  serialno       = "4W5T144"
  description    = "Demo"
  admin_state    = "ADMIN_STATE_ACTIVE"

  config_item { ## Optional
    key          = "debug.enable.ssh"
    string_value = var.ssh_pub_key
  }

  config_item { ## Optional
    key        = "debug.disable.dhcp.all-ones.netmask"
    bool_value = true # Using bool_value for boolean flags
  }

  config_item { ## Optional
    key        = "debug.enable.console"
    bool_value = true
  }

  config_item { ## Optional
    key        = "debug.enable.vga"
    bool_value = true
  }

  config_item { ## Optional
    key        = "debug.enable.usb"
    bool_value = true
  }

  config_item { ## Optional
    key        = "process.cloud-init.multipart"
    bool_value = true
  }

  edgeviewconfig {
    generation_id = 0
    token         = var.edgeview_token
    app_policy {
      allow_app = true
    }
    dev_policy {
      allow_dev = true
    }
    ext_policy {
      allow_ext = true
    }
    jwt_info {
      allow_sec  = 18000
      disp_url   = "zedcloud.gmwtus.zededa.net/api/v1/edge-view"
      encrypt    = true
      expire_sec = "0"
      num_inst   = 3
    }
  }

  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "COM1"
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "COM2"
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth0"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf0"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf1"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf2"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf3"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth2vf0"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth2vf2"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth2vf3"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf0"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf1"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf2"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf3"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  # interfaces {
  #     cost       = 0
  #     intf_usage = "ADAPTER_USAGE_APP_SHARED"
  #     intfname   = "USB" # This should match an assigngrp from your model for a USB device
  #     netname    = ""
  #     tags       = {}
  # }
}

resource "zedcloud_edgenode" "demo_en_dell_xr5610_sriov" {
  name           = "TF-QUVIA-NODE-1"
  title          = "TF-QUVIA-NODE-1"
  project_id     = zedcloud_project.tf_quvia_demo_1.id
  model_id       = zedcloud_model.demo_dell_xr5610_model_sriov.id
  onboarding_key = var.onboarding_key
  serialno       = "4W5T144"
  description    = "Demo"
  admin_state    = "ADMIN_STATE_ACTIVE"

  config_item { ## Optional
    key          = "debug.enable.ssh"
    string_value = var.ssh_pub_key
  }

  config_item { ## Optional
    key        = "debug.disable.dhcp.all-ones.netmask"
    bool_value = true # Using bool_value for boolean flags
  }

  config_item { ## Optional
    key        = "debug.enable.console"
    bool_value = true
  }

  config_item { ## Optional
    key        = "debug.enable.vga"
    bool_value = true
  }

  config_item { ## Optional
    key        = "debug.enable.usb"
    bool_value = true
  }

  config_item { ## Optional
    key        = "process.cloud-init.multipart"
    bool_value = true
  }

  edgeviewconfig {  ## Optional
    generation_id = 0
    token         = var.edgeview_token
    app_policy {
      allow_app = true
    }
    dev_policy {
      allow_dev = true
    }
    ext_policy {
      allow_ext = true
    }
    jwt_info {
      allow_sec  = 18000
      disp_url   = "zedcloud.gmwtus.zededa.net/api/v1/edge-view"
      encrypt    = true
      expire_sec = "0"
      num_inst   = 3
    }
  }

  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "COM1"
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "COM2"
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth0"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth1"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf0"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf1"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf2"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth1vf3"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth2"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth2vf0"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth2vf2"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth2vf3"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth3"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf0"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf1"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf2"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_APP_DIRECT"
    intfname   = "eth3vf3"
    netname    = ""
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth4"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth5"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth6"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth7"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth8"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
  interfaces {
    cost       = 0
    intf_usage = "ADAPTER_USAGE_MANAGEMENT"
    intfname   = "eth9"
    netname    = zedcloud_network.tf_quvia_edge_net_1.name
    tags       = {}
  }
}

# #---------- Create Images ------------------------------
resource "zedcloud_image" "demo_sjc_ub_image_1" {
  datastore_id        = zedcloud_datastore.tf_quvia_atl_ds.id
  image_type          = "IMAGE_TYPE_APPLICATION"
  image_arch          = "AMD64"
  image_format        = "QCOW2"
  image_sha256        = var.ubuntu_image_sha256
  image_size_bytes    = 618925568
  name                = "TF-UBUNTU-24-IMAGE"
  title               = "TF-UBUNTU-24-IMAGE"
  project_access_list = []
  image_rel_url       = "noble-server-cloudimg-amd64.img"
}

# ---------- Create network Instances (For worlkoads) ----------
resource "zedcloud_network_instance" "tf_wan_1" {
  name = "TF-MGMT"
  title = "TF-MGMT"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = "eth0"
  device_id = zedcloud_edgenode.tf_quvia_edge_node_1.id
  depends_on = []
}

resource "zedcloud_network_instance" "tf_net_1" {
  name = "TF-NET1"
  title = "TF-NET1"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = "" ## if not physical port mapping its internal conn. only
  device_id = zedcloud_edgenode.tf_quvia_edge_node_1.id
  depends_on = []
}

resource "zedcloud_network_instance" "tf_net_2" {
  name = "TF-NET2"
  title = "TF-NET2"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = "" ## if not physical port mapping its internal conn. only
  device_id = zedcloud_edgenode.tf_quvia_edge_node_1.id
  depends_on = []
}

resource "zedcloud_network_instance" "tf_lan_1" {
  name = "TF-LAN1"
  title = "TF-LAN1"
  kind = "NETWORK_INSTANCE_KIND_SWITCH"
  type = "NETWORK_INSTANCE_DHCP_TYPE_UNSPECIFIED"
  port = "eth1" 
  device_id = zedcloud_edgenode.demo_en_dell_xr5610_sriov.id
  depends_on = []
}

# ---------- Create Marketplace Apps  -----------------------------#
resource "zedcloud_application" "tf_ubuntu_24_app_atl_1_nic" {
  name                  = "TF-UBUNTU-24-ATL-APP"
  title                 = "TF-UBUNTU-24-ATL-APP"
  user_defined_version  = "24.0"
  networks              = 1
  manifest {
    ac_kind         = "VMManifest"
    ac_version      = "1.2.0"
    name            = "TF-UBUNTU-24-ATL-APP"
    vmmode          = "HV_HVM"
    enablevnc       = true
    app_type        = "APP_TYPE_VM"
    deployment_type = "DEPLOYMENT_TYPE_STAND_ALONE"
    cpu_pinning_enabled = false
    resources {
      name          = "cpus"
      value         = 2
    }
  desc {
    app_category = "APP_CATEGORY_CLOUD_APPLICATION"
    category = "APP_CATEGORY_UNSPECIFIED"
      logo        = {
      url       = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ubuntu-logo-2022.svg/250px-Ubuntu-logo-2022.svg.png" 
    }
  }
    resources {
      name          = "memory"
      value         = 1194304
    }
  images {
    imagename       = zedcloud_image.demo_sjc_ub_image_1.name
    imageformat     = "QCOW2"
    cleartext       = false
    drvtype         = "HDD"
    ignorepurge     = true
    maxsize         = 20971520
    target          = "Disk"
    }
  interfaces {
    name = "eth0"
    type = ""
    directattach = false
    privateip = false
   acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
   }
  configuration {
    custom_config {
      add = true
      name = "cloud-config"
      override = true
      template        = base64encode(file("./cinit/app_cinit.txt")) ## Test file in working directoy cinit/iosxe_config.txt
    }
   }
    resources {
      name          = "storage"
      value         = 20971520
    } 
  }
}

resource "zedcloud_application" "tf_ubuntu_24_app_atl_3_nic" {
  name                  = "TF-UBUNTU-24-ATL-APP"
  title                 = "TF-UBUNTU-24-ATL-APP"
  user_defined_version  = "24.0"
  networks              = 3
  manifest {
    ac_kind         = "VMManifest"
    ac_version      = "1.2.0"
    name            = "TF-UBUNTU-24-ATL-APP"
    vmmode          = "HV_HVM"
    enablevnc       = true
    app_type        = "APP_TYPE_VM"
    deployment_type = "DEPLOYMENT_TYPE_STAND_ALONE"
    cpu_pinning_enabled = false
    resources {
      name          = "cpus"
      value         = 2
    }
  desc {
    app_category = "APP_CATEGORY_CLOUD_APPLICATION"
    category = "APP_CATEGORY_UNSPECIFIED"
      logo        = {
      url       = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ubuntu-logo-2022.svg/250px-Ubuntu-logo-2022.svg.png" 
    }
  }
    resources {
      name          = "memory"
      value         = 1194304
    }
  images {
    imagename       = zedcloud_image.demo_sjc_ub_image_1.name
    imageformat     = "QCOW2"
    cleartext       = false
    drvtype         = "HDD"
    ignorepurge     = true
    maxsize         = 20971520
    target          = "Disk"
    }
  interfaces {
    name = "eth0"
    type = ""
    directattach = false
    privateip = false
   acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
   }
  interfaces {
    name = "eth1"
    type = ""
    directattach = false
    privateip = false
   acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
   }
  interfaces {
    name = "eth2"
    type = ""
    directattach = false
    privateip = false
   acls {
      matches { ### Outbound rule 
        type = "ip"
        value = "0.0.0.0/0"
      }
    }
   }
  configuration {
    custom_config {
      add = true
      name = "cloud-config"
      override = true
      template        = base64encode(file("./cinit/app_cinit.txt")) ## Test file in working directoy cinit/iosxe_config.txt
    }
   }
    resources {
      name          = "storage"
      value         = 20971520
    } 
  }
}


##---------- Sample VM 1 (one interface example) ----------
resource "zedcloud_application_instance" "tf_vm_deploy_1" {
  name              = "TF-vm-1"
  title             = "TF-vm-1"
  project_id        = zedcloud_project.tf_quvia_demo_1.id
  app_id            = zedcloud_application.tf_ubuntu_24_app_atl_1_nic.id
  activate          = true
  custom_config {
    add             = true
    allow_storage_resize = true
    field_delimiter = "###"
    name            = "cloud-config"
    override        = true
    template        = base64encode(file("./cinit/iosxe_config.txt")) ## Test file in working directoy cinit/iosxe_config.txt
  }
  device_id         = zedcloud_edgenode.tf_quvia_edge_node_1.id
  drives {
    imagename       = zedcloud_image.demo_sjc_ub_image_1.name
    cleartext       = false
    ignorepurge     = true
    maxsize         = 67108864
    preserve        = false
    target          = "Disk"
    drvtype         = "HDD"
    readonly        = false
  }
  interfaces {
    intfname = "eth0"
    intforder = 1
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.tf_wan_1.name
    privateip = false
  }
}

##---------- 3 interface sample (addmore as neede)----------------
resource "zedcloud_application_instance" "tf_cisco_deploy_2" {
  name              = "TF-vm-2"
  title             = "TF-vm-2"
  project_id        = zedcloud_project.tf_quvia_demo_1.id
  app_id            = zedcloud_application.tf_ubuntu_24_app_atl_3_nic.id
  activate          = true
  custom_config {
    add             = true
    allow_storage_resize = true
    field_delimiter = "###"
    name            = "cloud-config"
    override        = true
    template        = base64encode(file("./cinit/vm-1.txt")) ##text file in working directory cinit/vm-1.txt
  }
  device_id         = zedcloud_edgenode.tf_quvia_edge_node_1.id
  drives {
    imagename       = zedcloud_image.demo_sjc_ub_image_1.name
    cleartext       = false
    ignorepurge     = true
    maxsize         = 67108864
    preserve        = false
    target          = "Disk"
    drvtype         = "HDD"
    readonly        = false
  }
  interfaces {
    intfname = "eth0"
    intforder = 1
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.tf_wan_1.name
    privateip = false
  }
  interfaces {
    intfname = "eth1"
    intforder = 2
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.tf_net_1.name
    privateip = false
  }
  interfaces {
    intfname = "eth2"
    intforder = 3
    directattach = false
    access_vlan_id = 0
    default_net_instance = false
    ipaddr = ""
    macaddr = ""
    netinstname = zedcloud_network_instance.tf_net_2.name
    privateip = false
  }
}
