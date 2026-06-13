terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.19.0"
    }    
  }

# Value of bucket, region is static  
# Value of key must be changed for every execution
  required_version = ">= 1.3"
}