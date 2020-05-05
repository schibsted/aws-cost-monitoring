# AWS Cost Monitoring

This repository contains terraform module ready to use for everyone that would like to add AWS cost monitoring to their AWS accounts

## Usage

### AWS Budget

```ruby
module "aws_budget" {
  source                = "github.com/schibsted/aws-cost-monitoring//aws-budget"
  monthly_budget        = "1000.0" # USD
  subscriber_email_list = ["my-email@example.org"]
}
```

### Datadog dashboard and monitors

```ruby
module "datadog_monitors" {
  source                 = "github.com/schibsted/aws-cost-monitoring//datadog-budget"
  monthly_budget         = "1000.0" # USD, for dashboard coloring
  subscriber_email_list  = ["my-email@example.org"]
  minimal_alerting_value = "1" # minimal per day value to alert with anomaly detection
}
```

## Resources created

### AWS Budget

- [`aws_budgets_budget.monthly`](https://www.terraform.io/docs/providers/aws/r/budgets_budget.html): Monthly budget including basic notifications when overspending

### Datadog dashboard and monitors

- [`datadog_monitor.aws_aws_cost_monitor`](https://www.terraform.io/docs/providers/datadog/r/monitor.html): Composite monitor constructed as a conjunction of monitors `aws_service_anomaly` and `aws_service_minimal_cost`
- [`datadog_monitor.aws_service_anomaly`](https://www.terraform.io/docs/providers/datadog/r/monitor.html): (submonitor) Per AWS service anomaly detection monitors group
- [`datadog_monitor.aws_service_minimal_cost`](https://www.terraform.io/docs/providers/datadog/r/monitor.html): (submonitor) Per AWS service threshold detection (by default: 0 to avoid false alarms due to counter reset on the beginning of the month). Useful when adjusting to ignore low-cost services if they produce a lot of noise.
- [`datadog_downtime.aws_service_anomaly`](https://www.terraform.io/docs/providers/datadog/r/downtime.html): Mutes `aws_service_anomaly` submonitor
- [`datadog_downtime.aws_service_minimal_cost`](https://www.terraform.io/docs/providers/datadog/r/downtime.html): Mutes `aws_service_minimal_cost` submonitor

* [`datadog_dashboard.aws_cost_dashboard`](https://www.terraform.io/docs/providers/datadog/r/dashboard.html): AWS cost dashboard
