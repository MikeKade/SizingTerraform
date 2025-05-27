output "instance_details" {
  description = "Client instance and EBS volume details"
  value = {
    instances = [
      for i in aws_instance.this : {
        id         = i.id
        private_ip = i.private_ip
        name       = i.tags.Name
      }
    ]

    # EBS Volume Info

    ebs_volumes = [
      for v in aws_ebs_volume.this : {
        id   = v.id
        size = v.size
        type = v.type
      }
    ]
  }
}
