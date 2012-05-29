require 'test_helper'
require 'rdoc_helper.rb'

module RubyApi
  class RDocHelperTest < ActiveSupport::TestCase
    setup do
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

    should "find class methods in a module" do
      assert @rdoc.singleton_methods("Math").include?("sqrt")
      assert_equal [], @rdoc.singleton_methods("ArgumentError")
    end

    should "find instance methods in a module" do
      assert @rdoc.instance_methods("Array").include?("each")
    end

    should "find constants in a module" do
      assert @rdoc.constants("Math").include?("PI")
      assert_equal [], @rdoc.constants("Array")
    end
  end
end
