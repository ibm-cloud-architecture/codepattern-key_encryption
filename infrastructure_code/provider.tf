##############################################################################
# Creates the IBM Terraform Provider
##############################################################################

provider "ibm" {
  ibmcloud_api_key   = "${var.ibmcloud_apikey}"
  softlayer_username = "${var.classiciaas_username}"
  softlayer_api_key  = "${var.classiciaas_apikey}"
  region             = "${var.ibm_region}"
  generation         = 1
  ibmcloud_timeout   = 60
}

##############################################################################