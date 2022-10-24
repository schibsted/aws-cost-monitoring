resource "datadog_monitor" "aws_cost_monitor" {
  count        = local.alerts_enabled
  name         = "Abnormal spendings on AWS service {{servicename.name}} on account ${local.alert_title_account}"
  query        = "${datadog_monitor.aws_service_anomaly.0.id} && ${datadog_monitor.aws_service_minimal_cost.0.id}"
  include_tags = true
  locked       = false
  message      = local.datadog_monitor_message
  type         = "composite"
  tags         = var.monitor_tags
}

resource "datadog_monitor" "aws_service_anomaly" {
  count            = local.alerts_enabled
  evaluation_delay = 900
  include_tags     = true
  locked           = false
  message          = "sub monitor. Check datadog_monitor.aws_cost_monitor"

  name                = "(sub/anomaly) Abnormal spendings on AWS service {{servicename.name}} on account ${local.alert_title_account}"
  new_host_delay      = 300
  notify_audit        = false
  notify_no_data      = false
  query               = "avg(last_2w):anomalies(diff(max:aws.billing.estimated_charges{${local.alert_query_from}} by {${local.query_group_by}}.rollup(max, ${var.metric_rollup_period})), '${var.anomaly_algorithm}', ${var.anomaly_algorithm_deviation}, direction='${var.anomaly_alerting_direction}', alert_window='last_1d', interval=7200, count_default_zero='true', seasonality='weekly') >= 1"
  renotify_interval   = 0
  require_full_window = false
  tags                = var.monitor_tags
  threshold_windows = {
    "recovery_window" = "last_1h"
    "trigger_window"  = "last_1d"
  }
  thresholds = {
    "critical"          = "1.0"
    "critical_recovery" = "0.0"
    "warning"           = "0.5"
  }
  timeout_h = 0
  type      = "query alert"

  lifecycle {
    ignore_changes = [silenced]
  }
}

resource "datadog_monitor" "aws_service_minimal_cost" {
  count            = local.alerts_enabled
  evaluation_delay = 900
  include_tags     = true
  locked           = false
  message          = "sub monitor. Check datadog_monitor.aws_cost_monitor"

  name                = "(sub/minimal) Abnormal spendings on AWS service {{servicename.name}} on account ${local.alert_title_account}"
  new_host_delay      = 300
  no_data_timeframe   = 172800
  notify_audit        = false
  notify_no_data      = true
  query               = "min(last_1d):diff(max:aws.billing.estimated_charges{${local.alert_query_from}} by {${local.query_group_by}}.rollup(max, ${var.metric_rollup_period})) > ${var.minimal_alerting_value}"
  renotify_interval   = 0
  require_full_window = false
  tags                = var.monitor_tags
  thresholds = {
    "critical" = var.minimal_alerting_value
  }
  timeout_h = 0
  type      = "query alert"

  lifecycle {
    ignore_changes = [silenced]
  }
}

# Mute all sub monitors
resource "datadog_downtime" "aws_service_anomaly" {
  count      = local.alerts_enabled
  scope      = ["*"]
  monitor_id = datadog_monitor.aws_service_anomaly.0.id

  lifecycle {
    ignore_changes = [start, active]
  }
}

resource "datadog_downtime" "aws_service_minimal_cost" {
  count      = local.alerts_enabled
  scope      = ["*"]
  monitor_id = datadog_monitor.aws_service_minimal_cost.0.id

  lifecycle {
    ignore_changes = [start, active]
  }
}
