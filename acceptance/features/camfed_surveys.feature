Feature: Camfed Surveys

Scenario: Find a test survey in EPISurveyor, make sure it appears in Camfed, then delete it in Camfed
  Given I am logged into EPISurveyor
  And there is a 'test_form' survey in EPISurveyor

  Given I am logged into Camfed
  And there is no 'test_form' survey in Camfed

  When I refresh the surveys list in Camfed
  Then I should see the 'test_form' survey in Camfed

  When I delete the 'test_form' survey in Camfed
  Then I should not see the 'test_form' survey in Camfed