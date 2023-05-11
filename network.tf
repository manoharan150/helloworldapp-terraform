
resource "oci_core_vcn" "vcn_main" {
  compartment_id = oci_identity_compartment.network_compartment.id
  cidr_blocks    = ["10.0.0.0/22", "172.168.0.0/24"]
  display_name   = "vcn-main"
  dns_label      = "vcnmain"
  is_ipv6enabled = false
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "nat-gateway"
  route_table_id = oci_core_vcn.vcn_main.default_route_table_id
}

resource "oci_core_route_table" "nat_gateway_route_table" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "NAT gateway Route table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "internet-gateway"
  route_table_id = oci_core_vcn.vcn_main.default_route_table_id
}

resource "oci_core_route_table" "internet_gateway_route_table" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "internet gateway route table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "vcn-app-private-subnet" {
  compartment_id             = oci_identity_compartment.network_compartment.id
  vcn_id                     = oci_core_vcn.vcn_main.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "app-private-subnet"
  dns_label                  = "appsubnet"
  route_table_id             = oci_core_route_table.nat_gateway_route_table.id
  security_list_ids          = [oci_core_security_list.app-security-list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "vcn-bastion-public-subnet" {
  compartment_id             = oci_identity_compartment.network_compartment.id
  vcn_id                     = oci_core_vcn.vcn_main.id
  cidr_block                 = "172.168.0.0/29"
  display_name               = "bastion-public-subnet"
  dns_label                  = "bastionsubnet"
  route_table_id             = oci_core_route_table.internet_gateway_route_table.id
  security_list_ids          = [oci_core_security_list.bastion-security-list.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "vcn-lb-public-subnet" {
  compartment_id             = oci_identity_compartment.network_compartment.id
  vcn_id                     = oci_core_vcn.vcn_main.id
  cidr_block                 = "10.0.2.0/24"
  display_name               = "lb-public-subnet"
  dns_label                  = "lbsubnet"
  route_table_id             = oci_core_route_table.internet_gateway_route_table.id
  security_list_ids          = [oci_core_security_list.lb-security-list.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "vcn-monitoring-public-subnet" {
  compartment_id             = oci_identity_compartment.network_compartment.id
  vcn_id                     = oci_core_vcn.vcn_main.id
  cidr_block                 = "10.0.3.0/24"
  display_name               = "monitoring-public-subnet"
  dns_label                  = "monitorsubnet"
  route_table_id             = oci_core_route_table.internet_gateway_route_table.id
  security_list_ids          = [oci_core_security_list.monitoring-security-list.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_security_list" "app-security-list" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "app security list"
  ingress_security_rules {
    stateless   = false
    source      = "172.168.0.0/29"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 8080
      max = 8080
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 8081
      max = 8081
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_security_list" "bastion-security-list" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "bastion secuirty list"
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "10.0.3.0/24"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_security_list" "lb-security-list" {
  compartment_id = oci_identity_compartment.network_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "lb secuirty list"
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 8080
      max = 8080
    }
  }
}

resource "oci_core_security_list" "monitoring-security-list" {
  compartment_id = oci_identity_compartment.monitoring_compartment.id
  vcn_id         = oci_core_vcn.vcn_main.id
  display_name   = "monitoring secuirty list"
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 3000
      max = 3000
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 9090
      max = 9090
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "10.0.1.0/24"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 8080
      max = 8081
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 80
      max = 80
    }
  }
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 443
      max = 443
    }
  }  
}
