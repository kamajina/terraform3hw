resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = yandex_compute_instance.web_vm
    databases  = yandex_compute_instance.db_vm
    storage    = [yandex_compute_instance.storage]
  })
  filename = "${abspath(path.module)}/ansible_inventory.ini"
}
