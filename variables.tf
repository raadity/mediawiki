variable "count-ec2" {
    default = 1
  }
variable "region" {
  description = "AWS region for hosting our your network"
  default = "us-east-1"
}
variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default = "."
}
variable "key_name" {
  # name = "pemkey"
  description = "Key name for SSHing into EC2"
  default = "johnsnow"
}

variable "amis" {
  default = "ami-01fc429821bf1f4b4"
}
