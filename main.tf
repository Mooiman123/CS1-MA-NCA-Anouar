provider "aws" {
  region = "eu-central-1"
}
 
resource "aws_budgets_budget" "monthly_cost_budget" {
  name              = "MonthlyCostBudget"
  budget_type       = "COST"
  limit_amount      = "10"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
 
  # ✅ Cost filter moet een BLOK zijn, geen map
  cost_filter {
    name   = "Service"
    values = ["AmazonEC2"]
  }
 
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = ["Anouardg@outlook.com"]
  }
}
 