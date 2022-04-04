resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_name}-network"
  auto_create_subnetworks = true
}

resource "google_dns_managed_zone" "dns_private_zone" {
  name        = "${var.project_name}-private-zone"
  dns_name    = "${var.project_name}.example.com."
  description = "Private DNS zone for ${var.project_name}"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_compute_firewall" "compute_ssh_firewall" {
  name    = "${var.project_name}-ssh-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-tunnel"]
}

resource "google_compute_firewall" "compute_internal_firewall" {
  name    = "${var.project_name}-internal-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_tags = ["k8s"]
  target_tags = ["k8s"]
}

resource "google_compute_instance" "k8s-instances" {
  for_each = var.k8s_nodes

  name         = each.key
  machine_type = each.value
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  tags = ["k8s"]

  network_interface {
    network = google_compute_network.vpc_network.self_link

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("${path.module}/scripts/user-data.sh")

  service_account {
    email  = google_service_account.k8s_service_account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_dns_record_set" "node_dns" {
  for_each = var.k8s_nodes

  name = "${each.key}.${google_dns_managed_zone.dns_private_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.dns_private_zone.name

  rrdatas = [google_compute_instance.k8s-instances[each.key].network_interface[0].access_config[0].nat_ip]
}