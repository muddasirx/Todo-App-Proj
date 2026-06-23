terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure if you want remote state (recommended once this is "real"):
 backend "s3" {
    bucket       = "m-todo-proj-tfstate"
    key          = "terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

# CloudFront + ACM-for-CloudFront MUST be requested in us-east-1, regardless of
# which region the rest of the stack lives in. If var.aws_region != "us-east-1",
# this alias is what makes the ACM cert request actually succeed.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
