##############################################################################
# Creates a Key Protect instance
##############################################################################

resource "ibm_resource_instance" "kms" {
  name              = "test-kms"
  service           = "kms"
  plan              = "${var.kms_plan}"
  location          = "${var.ibm_region}" 
  resource_group_id = "${var.resource_group_id}"

  parameters = {
    service-endpoints = "${var.service_end_points}"
  }
  
  //User can increase timeouts 
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

##############################################################################