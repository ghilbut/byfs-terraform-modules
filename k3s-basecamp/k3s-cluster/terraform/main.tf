locals {
  az_suffixes = ["a", "b"]

  private_cidrs = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]

  tags = merge(
    var.tags,
    {
      owner   = "terraform"
      service = "k3s-basecamp"
      purpose = "initial management environment"
    },
  )
}

locals {
  k3s_host       = "k3s.${var.domain_name}"
  revision       = "featrue/k3s-basecamp-terraform"
  #revision       = "master"
}
