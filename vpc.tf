# VPCの作成
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.pj_name}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# パブリックサブネットの作成
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.pj_name}-public-subnet-${count.index + 1}"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.pj_name}-igw"
  }
}

# ルートテーブルの作成
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.pj_name}-public-rt"
  }
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

