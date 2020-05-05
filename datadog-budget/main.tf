locals {
  alerts_enabled      = var.datadog_enable_monitor ? 1 : 0
  alert_query_from    = var.aws_account_id == "*" ? "*" : "account_id:${var.aws_account_id}"
  alert_title_account = var.aws_account_id == "*" ? "{{account_id.name}}" : "(${var.aws_account_id}/${terraform.workspace})"

  # If dashboard title has a default value and specific AWS account ID is set, then add suffix to default name
  datadog_dashboard_title = var.datadog_dashboard_title == "AWS Cost Dashboard" && var.aws_account_id != "*" ? "AWS Cost Dashboard (${var.aws_account_id}/${terraform.workspace})" : var.datadog_dashboard_title

  datadog_monitor_message = <<-EOT
      {{#is_warning}}
      There may be some abnormal usage of service {{servicename.name}}. Worth checking dashboards.
      {{/is_warning}}
      {{#is_alert}}
      There is an existing abnormal usage of service {{servicename.name}}. Please check dashboards and usage of services to avoid huge billings at the end of the month.
      {{/is_alert}}
      {{#is_recovery}}
      Recovered
      {{/is_recovery}}

      Notify: @${join(" @", var.subscriber_email_list)}
    EOT

  query_group_by = "account_id,servicename"
}
