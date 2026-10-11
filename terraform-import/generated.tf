resource "aws_instance" "web" {
  ami                                  = "ami-0d27e0fb3bac4d724"
  associate_public_ip_address          = true
  availability_zone                    = "us-east-1d"
  instance_type                        = "t3.micro"
  key_name                             = "albkey"
  security_groups                      = ["launch-wizard-1"]
  subnet_id                            = "subnet-083e80eded2e75550"
  tags = {
    Name = "dev-app-serve"
  }
  tags_all = {
    Name = "dev-app-server"
  }
}