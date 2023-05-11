resource "oci_load_balancer_load_balancer" "lb_app" {
  compartment_id = oci_identity_compartment.network_compartment.id
  display_name   = "lb_app"
  ip_mode        = "IPV4"
  is_private     = "false"
  shape          = "10Mbps"  
#  shape          = "flexible"
#   shape_details {
#     maximum_bandwidth_in_mbps = 2
#     minimum_bandwidth_in_mbps = 8
#   }
  subnet_ids = [oci_core_subnet.vcn-lb-public-subnet.id]
}

resource "oci_load_balancer_backend_set" "lb_app_backend_set" {
  health_checker {
    interval_ms         = "10000"
    port                = "8080"
    protocol            = "HTTP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/hello-world"
  }
  load_balancer_id = oci_load_balancer_load_balancer.lb_app.id
  name             = "lb_backend_set"
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "lb_backend" {
  backendset_name  = oci_load_balancer_backend_set.lb_app_backend_set.name
  ip_address       = oci_core_instance.app-compute.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.lb_app.id
  port             = "8080"
  backup           = "false"
  drain            = "false"
  offline          = "false"
  weight           = "1"
}

resource "oci_load_balancer_listener" "lb_app_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.lb_app_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.lb_app.id
  name                     = "listener_lb_app"
  port                     = "80"
  protocol                 = "HTTP"
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "60"
  }
}