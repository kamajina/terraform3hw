data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}
variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
  }))
  default = [
    {
      vm_name     = "main"
      cpu         = 2
      ram         = 2
      disk_volume = 10
    },
    {
      vm_name     = "replica"
      cpu         = 2
      ram         = 1
      disk_volume = 15
    }
  ]
}

locals {
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}

resource "yandex_compute_instance" "db_vm" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }
  
  name        = each.value.vm_name
  platform_id = "standard-v2"
  
  allow_stopping_for_update = true

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = 20
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }
  
  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${local.ssh_public_key}"
  }
}
