terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.35"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.8"
    }
  }
}
