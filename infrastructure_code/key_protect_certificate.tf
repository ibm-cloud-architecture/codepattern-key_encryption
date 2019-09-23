##############################################################################
# This file creates a certificate for an already created KMS instance
# Before that resource is destroyed, it will delete the root key
#
# Prereqs For Terraform: 
# > jq bash parsing package
# > kms_cert.txt
# > kms_cert_id.txt
#
# Depends On:
# > Provisioned Key Protect instance
#   - ibm_resource_instance.kms
#
# Requires:
# > IBM Cloud API Key
#   - var.ibmcloud_apikey
# > IBM Cloud Region
#   - var.ibm_region
# > IBM Cloud IAM Token
#   - data.null_data_source.iam_auth_token.outputs["token"]
# 
# Outputs: 
# > kms_cert.txt
#   - A text file containing the JSON root key
# > kms_cert_id.txt
#   - A text file containing the KMS root key id
# > null_data_source.key_protect_root_key
#   - A data source that outputs both the root key and the root key id
##############################################################################


##############################################################################
# Create KMS Root Key
# Writes data to kms_cert.txt and kms_cert_id.txt
##############################################################################

resource "null_resource" "key_protect_create_key" {
  provisioner "local-exec" {
    command = <<EOT

REGION=${var.ibm_region}
API_KEY=${var.ibmcloud_apikey}
KMS_INSTANCE_ID=${element(split(":", ibm_resource_instance.kms.id), 7)}
ROOT_KEY_NAME=${var.kms_root_key_name}

TOKEN=$(echo $(curl -k -X POST \
      --header "Content-Type: application/x-www-form-urlencoded" \
      --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
      --data-urlencode "apikey=$API_KEY" \
      "https://iam.cloud.ibm.com/identity/token") | jq -r .access_token)

CERT=$(curl -X POST \
https://$REGION.kms.cloud.ibm.com/api/v2/keys \
-H "authorization: Bearer $TOKEN" \
-H "bluemix-instance: $KMS_INSTANCE_ID" \
-H 'content-type: application/vnd.ibm.kms.key+json' \
-d '{
  "metadata": {
    "collectionType": "application/vnd.ibm.kms.key+json",
    "collectionTotal": 1
  },
  "resources": [
  {
    "type": "application/vnd.ibm.kms.key+json",
    "name": "'$ROOT_KEY_NAME'",
    "description": "key used for demonstration in multizone",
    "extractable": false
    }
  ]
}' | jq ".resources[0]")
echo $CERT
echo "$CERT" >> config/kms_cert.txt
echo $CERT | jq '.id' | cut -d '"' -f 2 | tr -d '\n' >> config/kms_cert_id.txt
echo $CERT | jq '.crn' | cut -d '"' -f 2 | tr -d '\n' >> config/kms_cert_crn.txt
    EOT
  }
  depends_on = ["ibm_resource_instance.kms"]
}

##############################################################################


#############################################################################
# Destroys key protect root key before the kms instance is destroyed
##############################################################################

resource "null_resource" "destroy_key_protect" {
    provisioner "local-exec" {
      when = "destroy"
      command = <<EOT

API_KEY=${var.ibmcloud_apikey}
REGION=${var.ibm_region}
KMS_INSTANCE_ID=${element(split(":", ibm_resource_instance.kms.id), 7)}
KMS_ID_TXT_FILE=config/kms_cert_id.txt

TOKEN=$(echo $(curl -k -X POST \
      --header "Content-Type: application/x-www-form-urlencoded" \
      --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
      --data-urlencode "apikey=$API_KEY" \
      "https://iam.cloud.ibm.com/identity/token") | jq ".access_token" | cut -d '"' -f 2)

KEY_ID=$(cat $KMS_ID_TXT_FILE)

curl -X DELETE \
"https://$REGION.kms.cloud.ibm.com/api/v2/keys/$KEY_ID" \
-H "authorization: Bearer $TOKEN" \
-H "bluemix-instance: $KMS_INSTANCE_ID" \
-H 'accept: application/vnd.ibm.kms.key+json'

      EOT
    }
  depends_on = ["ibm_resource_instance.kms"]
}

##############################################################################


##############################################################################
# Outputs the JSON root key and JSON root key id when the script finishes
#
# Reference as:
# - data.null_data_source.key_protect_root_key.outputs["root_key"]
# - data.null_data_source.key_protect_root_key.outputs["root_key_id"]
# - data.null_data_source.key_protect_root_key.outputs["root_key_crn"]
##############################################################################

data "null_data_source" "key_protect_root_key" {
  inputs = {
    root_key     = "${file("${path.module}/config/kms_cert.txt")}"
    root_key_id  = "${file("${path.module}/config/kms_cert_id.txt")}"
    root_key_crn = "${file("${path.module}/config/kms_cert_crn.txt")}"
  }
  depends_on = ["null_resource.key_protect_create_key"]
}
##############################################################################