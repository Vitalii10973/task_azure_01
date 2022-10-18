variable "resource_group_name" {
  default = "my-Web-App_109"
}

variable "resource_group_location" {
  default = "East US"
}

variable "backend_address_pool_name" {
    default = "my-WebApp-10973363"
}

variable "frontend_port_name" {
    default = "myFrontendPort"
}

variable "frontend_ip_configuration_name" {
    default = "myAGIPConfig"
}

variable "http_setting_name" {
    default = "myHTTPsetting2"
}

variable "listener_name" {
    default = "myListener"
}

variable "request_routing_rule_name" {
    default = "myRoutingRule"
}

variable "redirect_configuration_name" {
    default = "myRedirectConfig"
}
