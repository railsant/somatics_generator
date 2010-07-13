require 'test_helper'
<% if options[:authenticated] %>
require '<%= controller_file_name %>_controller'

# Re-raise errors caught by the controller.
class <%= controller_class_name %>Controller; def rescue_action(e) raise e end; end
<% end -%>

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  <% if options[:authenticated] %>  
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include <%= class_name %>AuthenticatedTestHelper

  fixtures :<%= table_name %>
  <% end -%>
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create <%= file_name %>" do
    assert_difference('<%= class_name %>.count') do
      post :create, :<%= file_name %> => { }
    end

    assert_redirected_to <%= file_name %>_path(assigns(:<%= file_name %>))
  end

  test "should show <%= file_name %>" do
    get :show, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end

  test "should update <%= file_name %>" do
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
    assert_redirected_to <%= file_name %>_path(assigns(:<%= file_name %>))
  end

  test "should destroy <%= file_name %>" do
    assert_difference('<%= class_name %>.count', -1) do
      delete :destroy, :id => <%= table_name %>(:one).to_param
    end

    assert_redirected_to <%= table_name %>_path
  end

<% if options[:authenticated] %>
  def test_should_allow_signup
    assert_difference '<%= class_name %>.count' do
      create_<%= file_name %>
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:login => nil)
      assert assigns(:<%= file_name %>).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:password => nil)
      assert assigns(:<%= file_name %>).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:password_confirmation => nil)
      assert assigns(:<%= file_name %>).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference '<%= class_name %>.count' do
      create_<%= file_name %>(:email => nil)
      assert assigns(:<%= file_name %>).errors.on(:email)
      assert_response :success
    end
  end
  <% if options[:include_activation] %>
  def test_should_sign_up_user_with_activation_code
    create_<%= file_name %>
    assigns(:<%= file_name %>).reload
    assert_not_nil assigns(:<%= file_name %>).activation_code
  end

  def test_should_activate_user
    assert_nil <%= class_name %>.authenticate('aaron', 'test')
    get :activate, :activation_code => <%= table_name %>(:aaron).activation_code
    assert_redirected_to '/<%= controller_routing_path %>/new'
    assert_not_nil flash[:notice]
    assert_equal <%= table_name %>(:aaron), <%= class_name %>.authenticate('aaron', 'monkey')
  end
  
  def test_should_not_activate_user_without_key
    get :activate
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # in the event your routes deny this, we'll just bow out gracefully.
  end

  def test_should_not_activate_user_with_blank_key
    get :activate, :activation_code => ''
    assert_nil flash[:notice]
  rescue ActionController::RoutingError
    # well played, sir
  end<% end %>

  protected
    def create_<%= file_name %>(options = {})
      post :create, :<%= file_name %> => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
<% end %>
end
