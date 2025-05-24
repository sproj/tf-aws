variable "ingress_rules" {
  description = "List of ingress rules to create"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "Protocol must be one of: tcp, udp, icmp, -1"
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : alltrue([
        for cidr in rule.cidr_blocks : can(cidrhost(cidr, 0))
      ])
    ])
    error_message = "All CIDR blocks must be valid CIDR notation (e.g., 10.0.0.0/16, 0.0.0.0/0)"
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : rule.from_port >= 0 && rule.from_port <= 65535
    ])
    error_message = "from_port must be between 0 and 65535"
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : rule.to_port >= 0 && rule.to_port <= 65535
    ])
    error_message = "to_port must be between 0 and 65535"
  }

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : rule.from_port <= rule.to_port
    ])
    error_message = "from_port must be less than or equal to to_port"
  }
}

variable "egress_rules" {
  description = "List of egress rules to create"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "")
  }))
  default = []

  # Same validations as ingress_rules
  validation {
    condition = alltrue([
      for rule in var.egress_rules : contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "Protocol must be one of: tcp, udp, icmp, -1"
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules : alltrue([
        for cidr in rule.cidr_blocks : can(cidrhost(cidr, 0))
      ])
    ])
    error_message = "All CIDR blocks must be valid CIDR notation"
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules : rule.from_port >= 0 && rule.from_port <= 65535
    ])
    error_message = "from_port must be between 0 and 65535"
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules : rule.to_port >= 0 && rule.to_port <= 65535
    ])
    error_message = "to_port must be between 0 and 65535"
  }

  validation {
    condition = alltrue([
      for rule in var.egress_rules : rule.from_port <= rule.to_port
    ])
    error_message = "from_port must be less than or equal to to_port"
  }
}

variable "name" {
  description = "Name for the security group"
  type        = string
}

variable "description" {
  description = "Description for the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create security group in"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}
