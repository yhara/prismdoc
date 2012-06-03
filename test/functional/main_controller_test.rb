require 'test_helper'

class MainControllerTest < ActionController::TestCase
  test "should get show" do
    get :show_module, lang: "en", version: "1.9.3", library: "_builtin", module: "Object"
    assert_response :success
  end

end
