var j$=jQuery.noConflict();

j$(document).ready(function() {
    listenImportSelected();
    listenDeleteSelected();

    j$('#start_date').datepicker({dateFormat: 'yy-mm-dd'});
    j$('#end_date').datepicker({dateFormat: 'yy-mm-dd'});
    j$('#start_date').datepicker('setDate', getParameterByName('start_date'));
    j$('#end_date').datepicker('setDate', getParameterByName('end_date'));

    j$("#filter_form").validate({
      rules: {
        'start_date': { formatDate: true },
        'end_date': {
          formatDate: true,
          greaterThan: "#start_date"
        }
      },
      errorPlacement: function(error, element) {
        if (element.attr("name") == "start_date") {
          error.insertAfter("#start_date_error");
        } else if (element.attr("name") == "end_date") {
          error.insertAfter("#end_date_error");
        } else
           error.insertAfter(element);
      }
    });

    j$.validator.addMethod("formatDate",
      function(value, element) {
        if (value == "")  return true;
            return value.match(/^\d\d\d\d?\-\d\d?\-\d\d$/);
        },
        "Format yyyy-mm-dd"
    );

    j$.validator.addMethod("greaterThan",
      function(value, element, params) {
        element_id=params;
        if (value == "")  return true;
            if (!/Invalid|NaN/.test(new Date(value))) {
                return new Date(value) >= new Date(j$(element_id).val());
            }

            return isNaN(value) && isNaN($(element_id).val()) || (parseFloat(value) > parseFloat(j$(element_id).val()));
        },'Must be greater than start date');
});