class CamfedSalesforceObjectsPage
  include PageObject

  direct_url "#{EnvConfig.get :camfed, :url}/salesforce_objects"
  div :notice, :class => 'notice'

  def disable_salesforce_object_link name
    browser.link(:text => name).parent.parent.link(:text => 'Disable')
  end

  def enable_salesforce_object_link name
    browser.link(:text => name).parent.parent.link(:text => 'Enable')
  end

  def disable_salesforce_object name
    disable_salesforce_object_link(name).click if disable_salesforce_object_link(name).exists?
  end

  def enable_salesforce_object name
    enable_salesforce_object_link(name).click if enable_salesforce_object_link(name).exists?
  end
end