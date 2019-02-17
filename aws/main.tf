provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "cluster" {
  cidr_block = "10.1.1.0/24"

  tags = {
      Name = "${var.cluster-name}"
  }
}

resource "aws_subnet" "subnet" {
    vpc_id = "${aws_vpc.cluster.id}"
    cidr_block = "10.1.1.0/24"

    tags = {
        Name = "subnet"
    }
}

resource "aws_instance" "boss" {
    count = 2

    ami = "ami-0eaec5838478eb0ba"
    subnet_id = "${aws_subnet.subnet.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    associate_public_ip_address = true
    tags {
        Name = "${var.cluster-name}-boss-${count.index}"
        Type = "k8s-master"
    }
}
resource "aws_instance" "creep" {
    count = 2

    ami = "ami-0eaec5838478eb0ba"
    subnet_id = "${aws_subnet.subnet.id}"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    associate_public_ip_address = true
    tags {
        Name = "${var.cluster-name}-creep-${count.index}"
        Type = "k8s-node"
    }
}

resource "aws_internet_gateway" "ign"
{
    vpc_id = "${aws_vpc.cluster.id}"

    tags = {
        Name = "External cluster gateway for ${var.cluster-name} VPC"
    }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = "${aws_vpc.cluster.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ign.id}"
  }

  tags = {
    Name = "default table for ${var.cluster-name} VPC"
  }
}