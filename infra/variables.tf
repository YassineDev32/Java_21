variable "region" {
  default = "fra1"
}

variable "image" {
  default = "ubuntu-22-04-x64"
}

variable "droplets" {
  description = "List of droplets to create"
  type = list(object({
    name = string
    size = string
    tag  = string
  }))
}
