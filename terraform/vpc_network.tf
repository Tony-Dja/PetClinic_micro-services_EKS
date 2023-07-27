resource "aws_vpc" "test-env-petclinic" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "test-env-petclinic"
  }
}

resource "aws_subnet" "subnet-uno" {
  cidr_block        = cidrsubnet(aws_vpc.test-env-petclinic.cidr_block, 3, 1)
  vpc_id            = aws_vpc.test-env-petclinic.id
  // availability_zone = "eu-west-3"
  tags = {
    Name = "subnet-uno-petclinic"
  }
}


resource "aws_internet_gateway" "test-env-petclinic-gw" {
  vpc_id = aws_vpc.test-env-petclinic.id
  tags = {
    Name = "test-env-petclinic-gw"
  }
}

resource "aws_route_table" "route-table-test-env-petclinic" {
  vpc_id = aws_vpc.test-env-petclinic.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-env-petclinic-gw.id
  }
  tags = {
    Name = "test-env-route-table--petclinic"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.route-table-test-env-petclinic.id
}