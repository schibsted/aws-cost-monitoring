variable "monthly_budget" {
  type = string
}

variable "subscriber_email_list" {
  type = list(string)
}

variable "actual_threshold_percent" {
  type    = string
  default = 100
}

variable "actual_warning_threshold_percent" {
  type    = string
  default = 95
}

variable "forecast_threshold_percent" {
  type    = string
  default = 110
}

variable "forecast_warning_threshold_percent" {
  type    = string
  default = 100
}

variable "anomaly_algorithm" {
  type    = string
  default = "agile"
}

variable "anomaly_alerting_direction" {
  type    = string
  default = "above"
}

variable "metric_rollup_period" {
  type    = number
  default = 86400
}

variable "anomaly_algorithm_deviation" {
  type    = number
  default = 3
}

variable "datadog_enable_monitor" {
  type    = bool
  default = true
}

variable "datadog_dashboard_title" {
  type    = string
  default = "AWS Cost Dashboard"
}

variable "datadog_enable_dashboard" {
  type    = bool
  default = true
}

variable "aws_account_id" {
  type    = string
  default = "*"
}

variable "minimal_alerting_value" {
  type        = string
  description = "Minimal absolute value to be alerted on (this is value per rollup time. If rollup is set to 86400 then this value is cost per day.)"
  default     = "0"
}

variable "monitor_tags" {
  type    = list(string)
  default = []
}

variable "aws_services" {
  type = list(string)
  default = [
    "amazonapigateway",
    "amazoncloudfront",
    "amazoncloudwatch",
    "amazondynamodb",
    "amazonec2",
    "amazonecr",
    "amazonecs",
    "amazonefs",
    "amazonelasticache",
    "amazonkinesis",
    "amazonrds",
    "amazonroute53",
    "amazons3",
    "amazonses",
    "amazonsns",
    "awsbudgets",
    "awscloudtrail",
    "awsdatatransfer",
    "awsglue",
    "awskms",
    "awslambda",
    "awsmarketplace",
    "awsqueueservice",
    "awsxray"
  ]
}
