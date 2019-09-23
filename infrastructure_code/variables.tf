##############################################################
# This terraform file contains the variables and default values for
# this architecture. Default values will be used unless changed at deployment time.
##############################################################


##############################################################
# Classic IaaS API Key
##############################################################

variable classiciaas_apikey {
  description = "The Infrastructure API Key needed to deploy all IaaS resources"
  default     = ""
}

##############################################################
# Classic IaaS User Name
##############################################################

variable classiciaas_username {
  description = "The IBM Cloud classic infrastructure username (email)"
  default     = ""
}

##############################################################
# IBM Cloud API Key
##############################################################

variable ibmcloud_apikey {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  default     = ""
}

##############################################################
# IBM Cloud Region
##############################################################

variable ibm_region {
  description = "IBM Cloud region where all resources will be deployed"
  default     = "us-south"
}

##############################################################
# Resource Group ID
##############################################################

variable resource_group_id {
  description = "the ID of the resource group to use for all depoying resource instances and policies. access via CLI ibmcloud resource groups"
  default     = ""
}

##############################################################
# Plan for Key Protect
##############################################################

variable kms_plan {
  description = "the plan to use for provisioning key protect instance"
  default     = "tiered-pricing"
}

##############################################################
# Service Endpoints for for Key Protect
##############################################################

variable service_end_points {
  description = "Sets whether the end point for resource instances are public or private"
  default = "private"
}

##############################################################
# Name for the Key Protect root key
##############################################################

variable "kms_root_key_name" {
  description = "Name of Key Protect root key"
  default     = "todd"
}

#############################################################
# Cloud Object Storage Plan
##############################################################

variable cos_plan {
  description = "certificate manager plan"
  default     = "standard"
}

#############################################################
# Cloud Object Storage Bucket Name
##############################################################

variable "cos_bucket_name" {
  description = "Name of COS Bucket"
  default     = "jv-test-bucket"
}

#############################################################
# Account ID for Service Policies
##############################################################

variable account_id {
  description = "Account ID, obtain in UI under manage/account/account settings/ID:"
  default     = ""
}