provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.58"
}
provider "datadog" {
  version = "~> 2.7"
  api_key = "test"
  app_key = "test"
}
