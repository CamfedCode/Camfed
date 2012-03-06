document.observe("dom:loaded", function() {
    listenImportSelected();
    listenDeleteSelected();
})

function listenImportSelected()
{
  $$('input.import_selected').each(function(import_selected){
    $(import_selected).observe("click", function(){
      $(import_selected).form.action = '/surveys/import_selected'
    })
  })
}

function listenDeleteSelected()
{
  $$('input.delete_selected').each(function(delete_selected){
    $(delete_selected).observe("click", function(event){
      if(confirm('Are you sure you want to delete the selected surveys will all their data?'))
      {
        var form = $(delete_selected).form
        form.action = '/surveys/destroy_selected'
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'delete');
        form.appendChild(m);
      }
      else
      {
        Event.stop(event);
      }
    })
  })
}