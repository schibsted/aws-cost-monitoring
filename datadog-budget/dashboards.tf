resource "datadog_dashboard" "aws_cost_dashboard" {
  count       = var.datadog_enable_monitor ? 1 : 0
  title       = local.datadog_dashboard_title
  description = "AWS Cost dashboard with anomalies"
  layout_type = "ordered"

  template_variable {
    name    = "account_id"
    default = var.aws_account_id
    prefix  = "account_id"
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Budget"

      widget {
        query_value_definition {
          autoscale = false
          precision = 2
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
        query_value_definition {
          autoscale = true
          precision = 2
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
        toplist_definition {
          title = "Max of aws.billing.estimated_charges over $account_id by servicename"

          request {
            q = "top(max:aws.billing.estimated_charges{$account_id} by {servicename}, 10, 'last', 'desc')"
          }
        }
      }
    }
  }
  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Anomalies"

      widget {
        change_definition {
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
        alert_graph_definition {
          alert_id = "17757110"
          title    = "Alert: Abnormal spendings on AWS service {{servicename.name}} on account {{account_id.name}}"
          viz_type = "timeseries"
        }
      }
    }
  }
  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Per AWS Service Chart"

      dynamic "widget" {
        for_each = var.aws_services
        content {
          timeseries_definition {
            show_legend = false
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

