provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "terraform-cluster" {
  cidr_block = "10.240.0.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
      Name = "${var.cluster-name}"
  }
}
resource "aws_vpc_dhcp_options" "Kubernetes-DHCP-option" {
  domain_name          = "eu-cental-1.compute.internal"
  domain_name_servers  = ["AmazonProvidedDNS"]

  tags = {
    Name = "Kubernetes-DHCP"
  }
}


resource "aws_subnet" "kubernetes-main-subnet" {
    vpc_id = "${aws_vpc.terraform-cluster.id}"
    cidr_block = "10.240.0.0/24"

    tags = {
        Name = "Kubernetes-subnet"
    }
}

resource "aws_internet_gateway" "Kubernetes-ign"
{
    vpc_id = "${aws_vpc.terraform-cluster.id}"

    tags = {
        Name = "External cluster gateway for ${var.cluster-name} VPC"
    }
}

resource "aws_default_route_table" "Kubernetes-route-table" {
  default_route_table_id = "${aws_vpc.terraform-cluster.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Kubernetes-ign.id}"
  }

  tags = {
    Name = "Route table for ${var.cluster-name} VPC"
  }
}

resource "aws_security_group" "Kubernetes-security-group" {
  name        = "Access in/out Kubernetes"
  description = "Allow all traffic from inside, allow SSH, icmp, HTTPS from outside"
  vpc_id      = "${aws_vpc.terraform-cluster.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ALL"
    cidr_blocks = ["10.240.0.0/24"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ALL"
    cidr_blocks = ["10.200.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 6443
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = -1
    protocol        = "ICMP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "Kubernetes-nlb" {
  name               = "Kubernetes-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.kubernetes-main-subnet.id}" ]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "Kubernetes-target-group" {
  name        = "Kubernetes-target-group"
  port        = "6443"
  protocol    = "tcp"
  target_type = "ip"
  vpc_id      = "${aws_vpc.terraform-cluster.id}"
}

resource "aws_lb_target_group_attachment" "Targets-registration" {
  target_group_arn = "${aws_lb_target_group.Kubernetes-target-group.arn}"
  target_id        = "10.240.0.1{0,1,2}"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.Kubernetes-nlb.arn}"
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.Kubernetes-target-group.arn}"
  }
}

resource "aws_eip" "lb" {

  instance = "${aws_lb.Kubernetes-nlb.arn}"
  vpc      = true
}

resource "aws_instance" "controller-0" {
    count = 1

    ami = "ami-0eaec5838478eb0ba"
    subnet_id = "${aws_subnet.kubernetes-main-subnet.id}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.kubernetes-main-subnet.id}"
    security_groups = [
        "${aws_security_group.Kubernetes-security-group.id}"
    ]
    private_ip = "10.240.0.10"
    key_name = "${var.key_name}"
    user_data = "name=controller-1"
    associate_public_ip_address = true
    tags {
        Name = "controller-0"
        Type = "k8s-master"
    }
}
resource "aws_instance" "worker-0" {
    count = 1

    ami = "ami-0eaec5838478eb0ba"
    subnet_id = "${aws_subnet.subnet.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.kubernetes-main-subnet.id}"
    security_groups = [
        "${aws_security_group.Kubernetes-security-group.id}"]
    private_ip = "10.240.0.20"
    associate_public_ip_address = true
    user_data =  "name=worker-0|pod-cidr=10.200.0.0/24"
    tags {
        Name = "worker-0"
        Type = "k8s-node"
    }
}