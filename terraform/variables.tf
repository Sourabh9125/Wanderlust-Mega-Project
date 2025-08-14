variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null  # Will use Azure CLI context if not provided
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = null  # Will use Azure CLI context if not provided
}
variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  default     = null  # Will use Azure CLI context if not provided
}
variable "client_id" {
  description = "Azure Client ID"
  type        = string
  default     = null  # Will use Azure CLI context if not provided
}
variable "env" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
  
}