## claranet-proj


Per avere il progetto in locale, usare il comando per clonare su percorso desiderato:
```
cd path
git clone https://github.com/drob92/claranet-proj
```

In alternativa, per configurare manualmente tutto da capo:

## STEP 1 
### Installazione AWS CLI da .exe scaricato sul sito web ufficiale:
https://aws.amazon.com/it/cli/

### Creare istanza EC2 su AWS 
https://eu-west-1.console.aws.amazon.com/console/home?region=eu-west-1#

### Scaricare la chiave privata .pem relativa all'istanza EC2 per effettuare connessione SSH nei passaggi successivi

## STEP 2 
Eseguire da prompt dei comandi in locale: 
```
aws configure
```
## STEP 3 
Inserire i parametri configurati secondo l'istanza EC2
```
AWS Access Key ID: ************
AWS Secret Access Key: ************
Default region name: eu-west-1
Default output format: json
```
## STEP 4 
Eseguire check con il cmd

```
aws sts get-caller-identity
```

## STEP 5 
Installazione Terraform da .exe scaricato dal sito web ufficiale
https://developer.hashicorp.com/terraform/install?product_intent=terraform
## STEP 6 
Creare cartella 
```
mkdir path/claranet-proj/terraform
```
## STEP 7 
Creare al suo interno il file main.tf con il seguente contenuto
Una VPC, una subnet, un Internet Gateway e un'istanza EC2.
```
# main.tf
# Definisci il provider AWS
provider "aws" {
  region = "eu-west-1" 
}

# Crea una VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Subnet pubblica
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"  # Cambiata con la regione definita nell'istanza EC2
}

# Gateway per l'accesso alla rete pubblica
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route table associata alla subnet pubblica
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

# Istanza EC2
resource "aws_instance" "web" {
  ami           = "ami-0a8b4cd432b1c3063"  # ID Machine Image per Amazon Linux 2 nella regione eu-west-1, da ricavare dall'istanza EC2
  instance_type = "t2.micro"
  
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  
  tags = {
    Name = "WordPress-Server"
  }
}
```
## STEP 8 
Inizializzare terraform da prompt, così da creare tutte le risorse definite nel file main.tf
```
cd path/claranet-proj/terraform
terraform init
terraform apply
```

## STEP 8 
Con il prompt dei comandi con il login di AWS, recarsi sulla cartella dove viene tenuta salvata la chiave .pem. 
```
cd path/claranet-proj 
ssh -i proj_chiavi.pem ec2-user@inserire-ec2-public-ip
```
Installare e configurare Wordpress
```
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rmdir wordpress
sudo rm latest.tar.gz
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
```

## STEP 9 
Creazione MySql tramite Amazon RDS. Quindi andare nel servizio RDS, "Create database" e scegliere "MySQL" come motore.


Finita l'installazione di WP e del DB, all'interno del file wp-config.php del 
```
sudo nano /path/wordpress/wp-config.php
```
Configurare le voci e salvare:
	
```
define('DB_NAME', 'inserire-database-name');
define('DB_USER', 'inserire-username');
define('DB_PASSWORD', 'inserire-password');
define('DB_HOST', 'inserire-rds-endpoint:3306');
```


## STEP 10
Testare accesso da browser (ip non piu valido)
	http://ec2-3-252-72-19.eu-west-1.compute.amazonaws.com
	http://ec2-3-252-72-19.eu-west-1.compute.amazonaws.com/wp-admin


### Note
- Ho rimosso manualmente l'eseguibile di terraform che viene installato su terraform/.terraform/providers/registry.terraform.io/hashicorp/aws/5.64.0/windows_386/terraform-provider-aws_v5.64.0_x5.exe.
Occupava 500mb e non era possibile caricarlo con il mio piano GitHub. In caso di esecuzione di tutto il sistema, ripristinare il file nel path di appartenza 
- Chiavi, db e istanze attivate su cloud, sono state cessate ed eliminate.