variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group."
  default     = "Norway East"
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the App Service Plan."
}

variable "app_service_name" {
  type        = string
  description = "The name of the App Service."
}

variable "sql_server_name" {
  type        = string
  description = "The name of the SQL Server."
}

variable "sql_database_name" {
  type        = string
  description = "The name of the SQL Database."
}

variable "sql_admin_username" {
  type        = string
  description = "The administrator login username for the SQL Server."
}

variable "sql_admin_password" {
  type        = string
  description = "The administrator login password for the SQL Server."
  sensitive   = true
}

variable "firewall_rule_name" {
  type        = string
  description = "The name of the SQL Server firewall rule."
}

variable "github_repo_url" {
  type        = string
  description = "The URL of the GitHub repository."
}