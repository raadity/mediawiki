# data "aws_ami_ids" "rhel_ami" {
#   owners = ["309956199498"]
# }
# data "aws_ami" "rhel_ami_latest" {
#   most_recent = true
#   owners      = ["309956199498"]
#   filter {
#     name   = "name"
#     values = ["RHEL-8.4.0_HVM-*"]
#   }
# }
data "aws_availability_zones" "allzones" {}

resource "aws_launch_configuration" "mediawiki-launch-config" {
    name = "mediawiki_launch_config"
    # image_id = data.aws_ami.rhel_latest.image_id
    instance_type = "t2.micro"
    security_groups = [aws_security_group.mediawiki-sg.id]
    key_name = var.key_name
    image_id = "ami-02e0bb36c61bb9715"
    # user_data =<<-EOF
    #         #! /bin/bash
    #         sudo yum install update -y
    #     EOF
}



resource "aws_autoscaling_group" "mediawiki-asg" {
    name = "mediawiki-asg"
    vpc_zone_identifier = [aws_subnet.mediawiki-public.id]
    launch_configuration = aws_launch_configuration.mediawiki-launch-config.name
    load_balancers = [ aws_elb.mediawiki_elb.id ]
    health_check_type = "ELB"    
    min_size = 1
    max_size = 2
    desired_capacity = 1
}

resource "aws_security_group" "mediawiki-elb-sg" {

  name = "mediawiki-elb-sg"
  vpc_id = "${aws_vpc.mediawiki-vpc.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_elb" "mediawiki_elb" {
    name = "mediawiki-elb"
    # availability_zones = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
    # availability_zones = [ "${data.aws_availability_zones.allzones.names[0]}" ]
    subnets = [ aws_subnet.mediawiki-public.id ]
    security_groups = [ aws_security_group.mediawiki-elb-sg.id ]
    listener {
        instance_port = "80"
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 2
    #   target = "http:8080/"
      target = "tcp:22"

      interval = 20
    }
    # instances = [ aws_autoscaling_group.instances.name ]
    connection_draining = "false"
    tags={
        Name = "mediawiki-elb"
    }
}
