# Encrypt content in IBM Cloud Object Storage With Key Protect


### Architecture Goals

The goals of this code pattern are to 
1. Given a service [IBM Cloud Object Storage]() that stores data at rest, integrate it with [Key Protect](https://cloud.ibm.com/docs/services/key-protect?topic=key-protect-about) and assign a key for encryption
2.  Demonstrate the architecture using IBM Key Protext to manage your [BYOK](https://cloud.ibm.com/docs/services/key-protect?topic=key-protect-importing-keys) when encrypting data at rest
3. Demonastrate the IBM Cloud terraform provider-based scripts used to deploy and configure the architecture 

---
### Description

This code pattern provides the necessary scripts to provision a service (IBM COS and a bucket) to store data at rest and a key Protext instance with access control policies for ICOS Bucket to read from Key protextr. Then a Key is created and used by the ICOS bucket.

<kbd>![Serviced-scenario](./.imgs/arch.png)</kbd>

---
### Process

This terraform script:
1. Gets an IAM Auth Token with [iam_auth_token.tf](../../assets/iam_auth_token.tf)
2. Creates a Key Protect resource
3. Creates a root certificate for the Key Protect instance with [key_protect_certificate.tf](../../assets/key_protect_certificate.tf)
4. Creates a Cloud Object Storage resource
5. Creates an IAM Policy to let COS read from Key Protect
6. Creates a COS Bucket using the KMS Root key
7. Deletes the root certificate with [key_protect_certificate.tf](../../assets/key_protect_certificate.tf) when the Key Protect resource is destroyed