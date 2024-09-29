require "test_helper"

class DefaultCollateTest < ActiveSupport::TestCase
  fixtures :default_collates

  test "configured with default collation and ctype" do
    connection = DefaultCollate.new.class.connection
    assert_equal(connection.collation, "en_US.utf8")
    assert_equal(connection.ctype, "en_US.utf8")
  end

  test "sorts like Ruby (fails)" do
    ordered_names = DefaultCollate.order(:name).pluck(:name)
    assert_equal(ordered_names, ordered_names.sort)
  end

  test "sorts like Ruby when setting collate" do
    order_by = Arel.sql('name COLLATE "C"')
    ordered_names = DefaultCollate.order(order_by).pluck(:name)
    assert_equal(ordered_names, ordered_names.sort)
  end
end
