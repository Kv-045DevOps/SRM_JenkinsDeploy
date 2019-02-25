provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "cluster" {
  cidr_block = "10.240.0.0/24"

  tags = {
      Name = "vpc for k8s cluster"
  }
}

resource "aws_subnet" "subnet" {
    vpc_id = "${aws_vpc.cluster.id}"
    cidr_block = "10.240.0.0/24"

    tags = {
        Name = "subnet for  k8s cluster"
    }
}

resource "aws_instance" "controller" {
    count = 1

    ami = "ami-0bdf93799014acdc4"
    subnet_id = "${aws_subnet.subnet.id}"
    instance_type = "t2.medium"
    key_name = "andrew_2"
    associate_public_ip_address = true
    tags {
        Name = "controller-${count.index}"
    }
}

resource "aws_instance" "worker" {
    count = 2

    ami = "ami-0bdf93799014acdc4"
    subnet_id = "${aws_subnet.subnet.id}"
    instance_type = "t2.medium"
    key_name = "andrew_2"
    associate_public_ip_address = true
    tags {
        Name = "worker-${count.index}"
        Type = "k8s-node"
    }
}

resource "aws_internet_gateway" "ign"
{
    vpc_id = "${aws_vpc.cluster.id}"

    tags = {
        Name = "IGN for k8s cluster"
    }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = "${aws_vpc.cluster.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ign.id}"
  }

  tags = {
    Name = "default table for k8s cluster"
  }
}

output "ip_ec2" {
  value = "${aws_instance.controller.public_ip}"
}

output "ip_ec22" {
  value = "${aws_instance.worker.*.public_ip}"
}
