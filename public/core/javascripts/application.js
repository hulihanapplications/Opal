/* Opal Core JS */

function focus_main_menu_item(id)
{
	document.getElementById(id).className = "main_menu_item_hover"
}
function blur_main_menu_item(id)
{
	document.getElementById(id).className = "main_menu_item"
}

function focus_item_box(id)
{
	document.getElementById(id).className = "item_box_hover"
}
function blur_item_box(id)
{
	document.getElementById(id).className = "item_box"
}

function focus_input(id) // focus input boxes
{
	document.getElementById(id).className = "selected"
}
function blur_input(id)
{
	document.getElementById(id).className = ""
}

function change_class(id, classname)
{
	document.getElementById(id).className = classname
}



checked=false;
function toggle_all_checkboxes (form_id) {
	var aa= document.getElementById(form_id);
	 if (checked == false)
          {
           checked = true
          }
        else
          {
          checked = false
          }
	for (var i =0; i < aa.elements.length; i++) 
	{
	 aa.elements[i].checked = checked;
	}
      }
	  

// Toggle TinyMCE
function toggleEditor(id){

	if (!tinyMCE.get(id)) {
		tinyMCE.execCommand('mceAddControl', false, id);
	}
	else {
		tinyMCE.execCommand('mceRemoveControl', false, id);
	}
}	


function get_url_vars(){ // get url variables 
    var vars = [], hash;    
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
           
    for (var i = 0; i < hashes.length; i++) {    
        hash = hashes[i].split('=');        
        vars.push(hash[0]);        
        vars[hash[0]] = hash[1];  
    }     
    return vars;  
}

function submit(id) // submit a form with this particular id
{
	element = document.getElementById(id)
	element.submit();
}

/* jQuery Stuff */