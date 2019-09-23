##############################################################################
# Creates a Cloud Object
##############################################################################

resource "ibm_resource_instance" "cos" {
  name              = "test-cos"
  service           = "cloud-object-storage"
  plan              = "${var.cos_plan}"
  location          = "global" 
  resource_group_id = "${var.resource_group_id}"
  tags              = ["multizone"]

  parameters = {
    service-endpoints = "${var.service_end_points}"
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }

  depends_on = ["null_resource.key_protect_create_key"]

}

##############################################################################