module.exports =
  development:
    client: "postgres"
    connection:
      database: "kuwaitandme_development"
      user:     "kuwaitandme_dev"
      password: "kuwaitandme"
    pool:
      min: 2
      max: 10
    migrations: tableName: "migrations"


  staging:
    client: "postgres"
    connection:
      host: "kuwaitandme.com"
      database: "kuwaitandme_production"
      user:     "kuwaitandme_prod"
      password: "c85320d9ddb90c13f4a215f1f0a87b531ab33310"
    pool:
      min: 2
      max: 10
    migrations: tableName: "migrations"


  production:
    client: "postgres"
    connection:
      database: "kuwaitandme_development"
      user:     "kuwaitandme_dev"
      password: "kuwaitandme"
    pool:
      min: 2
      max: 10
    migrations: tableName: "migrations"