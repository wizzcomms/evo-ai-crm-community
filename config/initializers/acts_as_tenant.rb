ActsAsTenant.configure do |config|
  # Keep tenant optional during rollout so legacy endpoints keep working.
  config.require_tenant = false
end
