require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "~> 8.0.0.beta1" # originally observed in Rails 7.2
  gem "pg"
end

require "active_record"
require "minitest/autorun"
require "logger"

DB_DEFAULTS = {
  adapter: "postgresql",
  encoding: "unicode",
  username: "postgres",
  password: "password",
  port: 5433,
  host: "localhost"
}

DEFAULT_DB_CONFIG = DB_DEFAULTS.merge(
  database: "primary"
)

COLLATE_C_DB_CONFIG = DB_DEFAULTS.merge(
  database: "collate_c",
  collation: "C",
  ctype: "C",
  template: "template0"
)

def create_database(options)
  db_name = options[:database]
  ActiveRecord::Base.establish_connection(DB_DEFAULTS.merge(database: "postgres"))
  existing_databases = ActiveRecord::Base.connection.select_values("SELECT datname FROM pg_database;")
  unless existing_databases.include?(db_name)
    ActiveRecord::Base.connection.create_database(db_name, options)
  end
end

def with_default_connection
  ActiveRecord::Base.establish_connection(DEFAULT_DB_CONFIG)
  yield
end

def with_collate_c_connection
  ActiveRecord::Base.establish_connection(COLLATE_C_DB_CONFIG)
  yield
end

def define_schema
  ActiveRecord::Schema.define do
    create_table "things", force: :cascade do |t|
      t.string "name"
    end
  end
end

# Create the databases with appropriate collations
create_database(DEFAULT_DB_CONFIG)
create_database(COLLATE_C_DB_CONFIG)

# Define schema in both databases
with_default_connection { define_schema }
with_collate_c_connection { define_schema }

ActiveRecord::Base.logger = Logger.new(STDOUT)

class Thing < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def create_things
    [ "Walt Disneyland", "Walt Disney World" ].each do |name|
      Thing.create(name: name)
    end
  end

  def test_db_settings
    with_default_connection do
      connection = ActiveRecord::Base.connection
      assert_equal("en_US.utf8", connection.collation)
      assert_equal("en_US.utf8", connection.ctype)
    end

    with_collate_c_connection do
      connection = ActiveRecord::Base.connection
      assert_equal("C", connection.collation)
      assert_equal("C", connection.ctype)
    end
  end

  def test_default_connection_order
    # This fails, but should it?
    with_default_connection do
      order_by_assertions
    end
  end

  def test_collate_c_connection_order
    with_collate_c_connection do
      order_by_assertions
    end
  end

  def test_default_connection_with_collate_specified
    # Passes if specifying collate
    with_default_connection do
      create_things
    database_order = Thing.order('name COLLATE "C"').pluck(:name)
    expected_order = database_order.sort
    assert_equal(expected_order, database_order)
    end
  end

  private

  def order_by_assertions
    create_things
    database_order = Thing.order(:name).pluck(:name)
    expected_order = database_order.sort
    assert_equal(expected_order, database_order)
  end
end
