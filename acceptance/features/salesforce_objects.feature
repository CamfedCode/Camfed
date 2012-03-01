Feature: Salesforce Objects

Scenario: Enable a Salesforce object to be used in Camfed
  Given I am logged into Camfed
  And the 'School' Salesforce object is disabled
  When I enabled the 'School' Salesforce object
  Then the 'School' Salesforce object is enabled