require 'test_helper'

module RubyApi
  class LibraryEntryTest < ActiveSupport::TestCase
    fixtures :all

    setup do
      @builtin = Entry["_builtin", "1.9.3"]
    end

    should "return fullname of inner modules" do
      assert_equal "_builtin;Object", @builtin.fullname_of("Object")
      assert_equal "_builtin;Object", @builtin.fullname_of(Entry.where(name: "Object", version_id: Version["1.9.3"].id).first)
    end
  end
end

