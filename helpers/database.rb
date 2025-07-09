require 'pg'
require 'dotenv/load' # Loads .env file into ENV

# Create a database connection to PostgreSQL using ENV variables
def connect_database
  PG.connect(
    host: ENV['DB_HOST'],
    port: ENV['DB_PORT'],
    dbname: ENV['DB_NAME'],
    user: ENV['DB_USER'],
    password: ENV['DB_PASSWORD'],
  )
end
