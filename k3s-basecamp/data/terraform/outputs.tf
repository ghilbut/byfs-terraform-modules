output ebs_cp_zookeeper_ids {
  value = [aws_ebs_volume.cp_zookeeper.*.id]
}

output ebs_cp_kafka_ids {
  value = [aws_ebs_volume.cp_kafka.*.id]
}

output ebs_vpn_id {
  value = aws_ebs_volume.vpn.id
}

output mysql_host {
  value = aws_db_instance.mysql.address
}

output mysql_port {
  value = aws_db_instance.mysql.port
}

output mysql_database {
  value = random_string.mysql_database.result
}

output mysql_username {
  value = random_string.mysql_username.result
  sensitive = true
}

output mysql_password {
  value = random_password.mysql_password.result
  sensitive = true
}

output mysql_password_secret {
  value = {
    arn = aws_secretsmanager_secret.mysql_password.arn
    id  = aws_secretsmanager_secret.mysql_password.id
  }
  sensitive = true
}
