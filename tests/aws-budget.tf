module "aws_budget" {
  source                = "../aws-budget"
  monthly_budget        = 1000 #USD
  subscriber_email_list = ["my-email@example.org"]
}