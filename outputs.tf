# Outputs for compartment

output "bastion_public_ip" {
  value = oci_core_instance.bastion-compute.public_ip
}

output "app_private_ip" {
  value = oci_core_instance.app-compute.private_ip
}

output "lb_public_ip" {
  value = oci_load_balancer_load_balancer.lb_app.ip_addresses[0]
}

output "monitoring_public_ip" {
  value = oci_core_instance.monitoring-compute.public_ip
}

output "monitoring_private_ip" {
  value = oci_core_instance.monitoring-compute.private_ip
}
