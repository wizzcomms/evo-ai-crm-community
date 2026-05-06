namespace :branding do
  desc 'Updates branding configurations from environment variables or defaults'
  task update: :environment do
    configurable_items = {
      # The installation wide name that would be used in the dashboard, title etc.
      'INSTALLATION_NAME' => 'WizzDesk',
      # The thumbnail that would be used for favicon (512px X 512px)
      'LOGO_THUMBNAIL' => '/brand-assets/logo_thumbnail.png',
      # The logo that would be used on the dashboard, login page etc.
      'LOGO' => '/brand-assets/logo.svg',
      # The logo that would be used on the dashboard, login page etc. for dark mode
      'LOGO_DARK' => '/brand-assets/logo_dark.png',
      # The URL that would be used in emails under the section “Powered By”
      'BRAND_URL' => 'https://wizzcomms.com',
      # The URL that would be used in the widget under the section “Powered By”
      'WIDGET_BRAND_URL' => 'https://wizzcomms.com',
      # The name that would be used in emails and the widget
      'BRAND_NAME' => 'WizzDesk',
      # The terms of service URL displayed in Signup Page
      'TERMS_URL' => 'https://wizzcomms.com/terms-of-service',
      # The privacy policy URL displayed in the app
      'PRIVACY_URL' => 'https://wizzcomms.com/privacy-policy',
      # Display default WizzDesk metadata like favicons and upgrade warnings
      'DISPLAY_MANIFEST' => true
    }

    configurable_items.each do |config_name, default_value|
      value = if default_value.in?([true, false])
                ENV.fetch(config_name, default_value.to_s) == 'true'
              else
                ENV.fetch(config_name, default_value)
              end

      InstallationConfig.find_by!(name: config_name).update!(value: value)
      puts "Updated '#{config_name}' to '#{value}'."
    end

    puts 'Branding configuration update finished.'
  end
end
