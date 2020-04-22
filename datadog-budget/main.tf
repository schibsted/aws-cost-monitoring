resource "datadog_monitor" "aws_service_anomaly" {
  evaluation_delay = 900
  include_tags     = true
  locked           = false
  message          = <<-EOT
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

  name                = "Abnormal spendings on AWS service {{servicename.name}} on account {{account_id.name}}"
  new_host_delay      = 300
  no_data_timeframe   = 172800
  notify_audit        = false
  notify_no_data      = true
  query               = "avg(last_2w):anomalies(per_hour(max:aws.billing.estimated_charges{*} by {servicename,account_id}.rollup(max, ${var.anomaly_rollup_period})), '${var.anomaly_algorithm}', ${var.anomaly_algorithm_deviation}, direction='${var.anomaly_algorithm_direction}', alert_window='last_1d', interval=7200, count_default_zero='true', seasonality='weekly') >= 1"
  renotify_interval   = 0
  require_full_window = false
  tags                = []
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
}

resource "datadog_dashboard" "aws_cost_dashboard" {
  title        = "AWS Cost Dashboard"
  description  = "AWS Cost dashboard with anomalies"
  layout_type  = "ordered"
  is_read_only = true

  template_variable {
    name    = "account_id"
    default = "*"
    prefix  = "account_id"
  }

  widget {
    layout = {}

    group_definition {
      layout_type = "ordered"
      title       = "Budget"

      widget {
        layout = {}

        query_value_definition {
          autoscale = false
          precision = 2
          time      = {}
          title     = "Actual spendings"

          request {
            aggregator = "last"
            q          = "sum:aws.billing.actual_spend{$account_id}"

            conditional_formats {
              comparator = ">"
              hide_value = false
              palette    = "white_on_red"
              value      = var.monthly_budget * var.actual_threshold_percent / 100
            }
            conditional_formats {
              comparator = ">="
              hide_value = false
              palette    = "white_on_yellow"
              value      = var.monthly_budget * var.actual_warning_threshold_percent / 100
            }
            conditional_formats {
              comparator = "<"
              hide_value = false
              palette    = "white_on_green"
              value      = var.monthly_budget * var.actual_warning_threshold_percent / 100
            }
          }
        }
      }
      widget {
        layout = {}

        query_value_definition {
          autoscale = true
          precision = 2
          time      = {}
          title     = "Forecasted estimates"

          request {
            aggregator = "avg"
            q          = "sum:aws.billing.forecasted_spend{$account_id}"

            conditional_formats {
              comparator = ">"
              hide_value = false
              palette    = "white_on_red"
              value      = var.monthly_budget * var.forecast_threshold_percent / 100
            }
            conditional_formats {
              comparator = ">="
              hide_value = false
              palette    = "white_on_yellow"
              value      = var.monthly_budget * var.forecast_warning_threshold_percent / 100
            }
            conditional_formats {
              comparator = "<"
              hide_value = false
              palette    = "white_on_green"
              value      = var.monthly_budget * var.forecast_warning_threshold_percent / 100
            }
          }
        }
      }
      widget {
        layout = {}

        toplist_definition {
          time  = {}
          title = "Max of aws.billing.estimated_charges over $account_id by servicename"

          request {
            q = "top(max:aws.billing.estimated_charges{$account_id} by {servicename}, 10, 'last', 'desc')"
          }
        }
      }
    }
  }
  widget {
    layout = {}

    group_definition {
      layout_type = "ordered"
      title       = "Anomalies"

      widget {
        layout = {}

        change_definition {
          time  = {}
          title = "Max of aws.billing.estimated_charges over * by servicename"

          request {
            change_type   = "absolute"
            compare_to    = "month_before"
            increase_good = false
            order_by      = "change"
            order_dir     = "desc"
            q             = "max:aws.billing.estimated_charges{*} by {servicename}"
            show_present  = true
          }
        }
      }
      widget {
        layout = {}

        alert_graph_definition {
          alert_id = "17757110"
          time     = {}
          title    = "Alert: Abnormal spendings on AWS service {{servicename.name}} on account {{account_id.name}}"
          viz_type = "toplist"
        }
      }
    }
  }
  widget {
    layout = {}

    group_definition {
      layout_type = "ordered"
      title       = "Per AWS Service Chart"

      dynamic "widget" {
        for_each = var.aws_services
        content {
          layout = {}

          timeseries_definition {
            show_legend = false
            time        = {}
            title       = widget.value

            request {
              display_type = "line"
              q            = "anomalies(per_hour(max:aws.billing.estimated_charges{servicename:${widget.value},$account_id}.rollup(max, 86400)), 'agile', 3)"

              style {
                line_type  = "solid"
                line_width = "normal"
              }
            }

            yaxis {
              include_zero = true
              max          = "auto"
              min          = "auto"
              scale        = "linear"
            }
          }
        }
      }

    }
  }
}

