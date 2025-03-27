resource "azurerm_cosmosdb_account" "db" {
  name                = "${var.project}-mongodb-${var.env}-${random_id.random_suffix.hex}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  is_virtual_network_filter_enabled     = false

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    prefix            = "${var.project}-mongodb-${random_id.random_suffix.hex}"
    location          = azurerm_resource_group.default.location
    failover_priority = 0
  }

  tags = {
      project = var.project
      environment = var.env
  }
}

resource "azurerm_cosmosdb_mongo_database" "default" {
  name                = "customers_and_orders"
  resource_group_name = azurerm_cosmosdb_account.db.resource_group_name
  account_name        = azurerm_cosmosdb_account.db.name
  throughput          = 400
}

resource "azurerm_cosmosdb_mongo_collection" "customerView" {
  name                = "customerView"
  resource_group_name = azurerm_resource_group.default.name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_mongo_database.default.name

  default_ttl_seconds = "777"
  shard_key           = "_id"
  throughput          = 400
}

output "mongodb" {
  value = "${join("/", slice(split("/", azurerm_cosmosdb_account.db.connection_strings[0]), 0, 3))}/customers_and_orders?ssl=true"
}
