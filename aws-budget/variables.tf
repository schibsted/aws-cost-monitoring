variable "monthly_budget_name" {
  type    = string
  default = "Monthly AWS Budget"
}

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

variable "forecast_threshold_percent" {
  type    = string
  default = 110
}

variable "include_discount" {
  type    = bool
  default = false
}
