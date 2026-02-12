provider "zedcloud" {
    zedcloud_url = "https://zedcontrol.gmwtus.zededa.net" #### Pick the cluster where you will be executing these commands against.
  # Configuration options
    zedcloud_token = var.zedcloud_token
}
