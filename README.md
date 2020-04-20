# AWS Cost Monitoring

This repository contains terraform module ready to use for everyone that would like to add AWS cost monitoring to their AWS accounts

## Usage

### AWS Budget

```ruby
module "aws_budget" {
  source                = "github.com/schibsted/aws-cost-monitoring//aws-budget"
  monthly_budget        = 1000 #USD
  subscriber_email_list = ["my-email@example.org"]
}
```

### Datadog dashboard and monitors

```ruby
module "aws_budget" {
  source                = "github.com/schibsted/aws-cost-monitoring//datadog-budget"
  monthly_budget        = 1000 #USD
  subscriber_email_list = ["my-email@example.org"]
}
```

## Resources created

- [`aws_budgets_budget.monthly`](https://www.terraform.io/docs/providers/aws/r/budgets_budget.html): Monthly budget including basic notifications when overspending
