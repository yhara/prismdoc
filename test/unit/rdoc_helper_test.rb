require 'test_helper'
require 'rdoc_helper.rb'

module RubyApi
  class RDocHelperTest < ActiveSupport::TestCase
    setup do
      @rdoc = RDocHelper.new(Version["1.9.3"])
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

    should "extract module document" do
      assert_match /Array/, @rdoc.module_doc("Array")
    end

    should "extract singleton method document" do
      assert_match /Array/, @rdoc.singleton_method_doc("Array", "new")
    end

    should "extract instance method document" do
      assert_match /enumerator/, @rdoc.instance_method_doc("Array", "each")
    end

    should "extract constant document" do
      assert_nil @rdoc.constant_doc("Math", "PI")
    end

    should "convert rdoc to html" do
      assert_match /<pre>/, RDocHelper.html("example:\n  p 1")
    end
  end
end
