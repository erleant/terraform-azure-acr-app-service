#Prefix for Corporation
variable "corp" {
  default = "Terraform"
}

#Corporate Naming Convention Prefix for Virtual Machine Environments -"${var.corp}-${var.mgmt}-vm01"
variable "mgmt" {
  description = "corporate naming convention prefix"
  default     = "management"

}

#Specify type of resource being deployed here - "${var.corp}-${var.mgmt}-${var.webres[0]}-01"
variable "webres" {
  default = ["vm", "webapp", "slb", "appgw"]
}
