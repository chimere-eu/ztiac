resource "outscale_security_group" "sg" {
  description = "Chimere demo security group"
  net_id      = "vpc-df549e2d"
}

resource "outscale_security_group_rule" "sg_rule_ssh" {
  flow              = "Inbound"
  security_group_id = outscale_security_group.sg.id
  rules {
    from_port_range = "22"
    to_port_range   = "22"
    ip_protocol     = "tcp"
    ip_ranges       = var.allowed_cidr
  }
}


module "vm" {
  source             = "github.com/chimere-eu/ztiac/modules/compute"
  subnet_id          = "subnet-663cb334"
  security_group_ids = [outscale_security_group.sg.security_group_id]
  vm_type            = var.vm_type
  image_id           = var.image_id
  keypair_name       = outscale_keypair.my_keypair.keypair_name
  name               = "chimere-demo"
  user_data          = <<-EOF
  #!/bin/bash
  apt update
  apt install nginx -y
EOF
  user_data_type     = "shell"
  assign_public_ip   = true
  chimere = [
    {
      port        = 22
      vault_token = "s.tT2NRwf547tvcZrgRGaeuc4z"
      secret_url  = "http://10.1.0.5:8200/v1/kv/data/secret1"
      urls        = ["test.ssh", "something"]
      name        = "ssh"
      address     = "127.0.0.1"
    },
    {
      port        = 80
      vault_token = "s.tT2NRwf547tvcZrgRGaeuc4z"
      secret_url  = "http://10.1.0.5:8200/v1/kv/data/secret1"
      urls        = ["service.nginx", "nginx"]
      name        = "web"
      address     = "127.0.0.1"
    }
  ]
}


resource "outscale_keypair" "my_keypair" {
  keypair_name = "chimere-example-keypair"
  public_key   = file(var.public_key_path)
}

output "public_ip" {
  value = module.vm.public_ip
}