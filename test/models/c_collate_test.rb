require "test_helper"

class CCollateTest < ActiveSupport::TestCase
  fixtures :c_collates

  test "it is configured with default collation and ctype" do
    connection = CCollate.new.class.connection
    assert_equal(connection.collation, "C")
    assert_equal(connection.ctype, "C")
  end

  test "sorts like Ruby" do
    ordered_names = CCollate.order(:name).pluck(:name)
    assert_equal(ordered_names, ordered_names.sort)
  end
end
