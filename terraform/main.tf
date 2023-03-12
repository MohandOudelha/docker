resource "null_resource" "export_database" {

  # Provisioner pour exporter la base de données
  provisioner "local-exec" {
    command = "mysqldump -h ${var.db_host} -P ${var.db_port} -u ${var.db_user} -p${var.db_password} ${var.db_name} > ${var.export_dir}/${var.export_file}"
  }
}


resource "docker_container" "import_database" {

  # Définition des variables pour le conteneur Docker
  name = "mysql_import"
  image = "mysql:latest"
  env {
    MYSQL_ROOT_PASSWORD = "${var.db_password}"
    MYSQL_DATABASE = "${var.db_name}"
    MYSQL_USER = "${var.db_user}"
    MYSQL_PASSWORD = "${var.db_password}"
  }
  ports {
    internal = "3306"
    external = "${var.docker_db_port}"
  }

  # Provisioner pour importer la base de données
  provisioner "local-exec" {
    command = "docker exec -i ${docker_container.import_database.name} mysql -u ${var.db_user} -p${var.db_password} ${var.db_name} < ${var.import_file}"
  }
}
