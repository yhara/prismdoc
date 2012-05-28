require 'test_helper'
require 'rdoc_helper.rb'

module RubyApi
  class RDocHelperTest < ActiveSupport::TestCase
    def setup
      @rdoc = RDocHelper.new("1.9.3")
    end

    should "get list of modules" do
      assert @rdoc.modules.include?("Array")
    end

    should "detect modules" do
      assert @rdoc.module?("Math")
      assert @rdoc.module?("Array")
      assert @rdoc.module?("BasicObject")
      assert !@rdoc.module?("XXX")
    end

    should "detect classes" do
      assert @rdoc.class?("Array")
      assert @rdoc.class?("BasicObject")
      assert !@rdoc.class?("Enumerable")
    end

    should "detect name of superclass" do
      assert_equal "BasicObject", @rdoc.superclass("Object")
      assert_equal "Object", @rdoc.superclass("Array")
      assert_equal "Numeric", @rdoc.superclass("Integer")
      assert_equal nil, @rdoc.superclass("BasicObject")
    end
  end
end
