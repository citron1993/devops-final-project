output "public_ip" {
  description = "Public IP address of the website server."
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "HTTP URL for the deployed website."
  value       = "http://${aws_instance.web.public_ip}"
}
