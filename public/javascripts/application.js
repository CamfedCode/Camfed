// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function selectSurveyIds(checked){
	$$('div.survey_name input').each(function(check_box) {check_box.checked = checked })
}