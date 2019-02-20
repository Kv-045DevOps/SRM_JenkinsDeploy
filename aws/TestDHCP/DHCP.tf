provider "aws" {
    region = "eu-central-1"
}
resource "aws_vpc_dhcp_options" "Kubernetes-DHCP-option" {
  domain_name          = "eu-cental-1.compute.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]

  tags = {
    Name = "Kubernetes-DHCP"
  }
}

# output "Kubernetes-DHCP-option" {
#   value = "${aws_vpc_dhcp_options.Kubernetes-DHCP-option.*}"
# }