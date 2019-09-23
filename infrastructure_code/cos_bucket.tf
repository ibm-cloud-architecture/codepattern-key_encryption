##############################################################################
# This file creates a certificate for an already created KMS instance
# Before that resource is destroyed, it will delete the root key
#
# Depends On:
# > Provisioned Cloud Object Storage instance
#   - ibm_resource_instance.cos
#
# Requires:
# > IBM Cloud Region
#   - var.ibm_region
# > IBM Cloud IAM Token
#   - data.null_data_source.iam_auth_token.outputs["token"]
# > Bucket Name
#   - var.cos_bucket_name
# > Key Protect Key Crn
#   - file("${path.module}/config/kms_cert_crn.txt")
##############################################################################

resource "null_resource" "create_cos_bucket" {
  provisioner "local-exec" {

    command = <<EOT

REGION=${var.ibm_region}
COS_ID=${element(split(":", ibm_resource_instance.cos.id), 7)}
BUCKET_NAME=${var.cos_bucket_name}
API_KEY=${var.ibmcloud_apikey}
KMS_KEY_CRN=${file("${path.module}/config/kms_cert_crn.txt")}


TOKEN=$(echo $(curl -k -X POST \
      --header "Content-Type: application/x-www-form-urlencoded" \
      --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
      --data-urlencode "apikey=$API_KEY" \
      "https://iam.cloud.ibm.com/identity/token") | jq -r .access_token)

curl -X PUT \
    https://s3.$REGION.objectstorage.softlayer.net/$BUCKET_NAME \
    -H 'Accept: */*' \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: text/xml' \
    -H 'accept-encoding: gzip, deflate' \
    -H 'cache-control: no-cache' \
    -H 'content-length: ' \
    -H "ibm-service-instance-id: $COS_ID" \
    -H 'ibm-sse-kp-encryption-algorithm: AES256' \
    -H "ibm-sse-kp-customer-root-key-crn: $KMS_KEY_CRN"    
    
EOT
  }
  depends_on = ["ibm_resource_instance.cos", "null_resource.iam_auth_policy", "null_resource.key_protect_create_key"]
}

##############################################################################