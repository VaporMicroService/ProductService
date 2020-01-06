import FluentPostgreSQL
import Vapor
import Avenue

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    //Load Environment
    Environment.dotenv(filename: "\(try Environment.detect().name).env")
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    let psqlConfig: PostgreSQLDatabaseConfig!
    if let url = Environment.get("PSQL_DATABASE_URL") {
        psqlConfig = PostgreSQLDatabaseConfig(url: url, transport: .unverifiedTLS)
    } else {
        psqlConfig = try PostgreSQLDatabaseConfig.default()
    }
    // Configure a PostgreSQL database
    let postgre = PostgreSQLDatabase(config: psqlConfig)
    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .psql)
    databases.add(database: postgre, as: .psql)
    services.register(databases)
    // Configure migrations
    var migrations = MigrationConfig()
    //📋 Tables
    migrations.add(model: Vendor.self, database: .psql)
    migrations.add(model: Customer.self, database: .psql)
    migrations.add(model: Order.self, database: .psql)
    migrations.add(model: Event.self, database: .psql)
    migrations.add(model: List.self, database: .psql)
    migrations.add(model: Product.self, database: .psql)
    //📋 Pivots tables
    migrations.add(model: ListProduct.self, database: .psql)
    migrations.add(model: EventProductList.self, database: .psql)
    migrations.add(model: OrderProduct.self, database: .psql)
    migrations.add(model: CustomerOrder.self, database: .psql)
    
    
    services.register(migrations)

    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
