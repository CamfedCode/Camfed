// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function selectSurveyIds(checked){
	$$('div.survey_name input').each(function(check_box) {check_box.checked = checked })
}

function selectImportHistoryIds(checked){
	$$('div.import_history_div input').each(function(check_box) {check_box.checked = checked })
}

function showHideHelp(){
	$$('div.help').each(function(help) {help.toggle(); });
}

 function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.href);
        if (results == null)
            return "";
        else
            return decodeURIComponent(results[1].replace(/\+/g, " "));
    }