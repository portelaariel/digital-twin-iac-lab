variable "enable_backup_twin" {
  description = "Create backup server in Digital Twin"
  type        = bool
  default     = false
}

variable "enable_backup_real" {
  description = "Create backup server in Real environment"
  type        = bool
  default     = false
}