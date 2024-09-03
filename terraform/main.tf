# main.tf

# Definisci il provider AWS
provider "aws" {
  region = "eu-west-1"  # Cambia con la regione che hai configurato nell'AWS CLI
}

# Crea una VPC (Virtual Private Cloud)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Crea una subnet pubblica
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"  # Cambia con una AZ della tua regione
}

# Crea una Internet Gateway per permettere l'accesso alla rete pubblica
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Crea una route table associata alla subnet pubblica
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Esempio di un'istanza EC2 (server)

resource "aws_instance" "web" {
  ami           = "ami-0a8b4cd432b1c3063"  # AMI ID per Amazon Linux 2 nella regione eu-west-1
  instance_type = "t2.micro"
  
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  
  tags = {
    Name = "WordPress-Server"
  }
}



