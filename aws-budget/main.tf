resource "aws_budgets_budget" "monthly" {
  name         = var.monthly_budget_name
  budget_type  = "COST"
  limit_amount = var.monthly_budget
  limit_unit   = "USD"

  # "If you didn't specify an end date, AWS set your end date to 06/15/87 00:00 UTC."
  time_period_end = "2087-06-15_00:00"

  # Start is required
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  cost_types {
    include_credit             = false
    include_discount           = false
    include_other_subscription = false
    include_recurring          = false
    include_refund             = false
    include_subscription       = false
    include_support            = false
    include_tax                = false
    include_upfront            = false
    use_blended                = false
    use_amortized              = true
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.actual_threshold_percent
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.subscriber_email_list
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.forecast_threshold_percent
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.subscriber_email_list
  }
}
