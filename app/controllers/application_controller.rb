class ApplicationController < ActionController::Base
  include RequestExceptionHandler
  include SwitchLocale
  include Pundit::Authorization

  set_current_tenant_through_filter
  skip_before_action :verify_authenticity_token, raise: false

  before_action :set_current_account_tenant
  around_action :switch_locale
  around_action :handle_with_exception, unless: :skip_exception_handling?

  private

  def skip_exception_handling?
    # Skip exception handling for specific controllers if needed
    # Originally was checking for devise_controller? but Devise is not installed
    false
  end

  def pundit_user
    {
      user: Current.user,
      service_authenticated: Current.service_authenticated
    }
  end

  def set_current_account_tenant
    tenant = find_tenant_from_header || find_tenant_from_subdomain || Account.default
    set_current_tenant(tenant)
    Current.account = tenant || RuntimeConfig.account
  rescue ActiveRecord::StatementInvalid, NameError
    # During bootstrap (before migrations) fallback to legacy single-tenant runtime config.
    Current.account = RuntimeConfig.account
  end

  def find_tenant_from_subdomain
    return nil if request.subdomain.blank? || request.subdomain == 'www'

    Account.find_by(subdomain: request.subdomain.downcase)
  end

  def find_tenant_from_header
    account_id = request.headers['X-Account-ID'].presence
    return nil unless account_id

    Account.find_by(id: account_id)
  end
end
ApplicationController.include_mod_with('Concerns::ApplicationControllerConcern')
