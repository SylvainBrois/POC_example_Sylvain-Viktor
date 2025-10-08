output "instance_public_ip" {
  value = aws_instance.webapp.public_ip
}

output "web_url" {
  value = "http://${aws_instance.webapp.public_ip}"
}
