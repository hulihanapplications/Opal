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


// JQuery Functions
jQuery.fn.toggle = function(transition_time) { // hide object
	if (transition_time == null){transition_time  = 400}
	
	 if(this.css("display") == "none") // The Element is currently Hidden
	 	this.reveal();
 	 else // The Element is currently Visible	 
 		this.conceal();	
}

jQuery.fn.reveal = function(transition_time) { // hide object
	if (transition_time == null){transition_time  = 400}
	this.slideDown(transition_time)	  		      				
}

jQuery.fn.conceal = function(transition_time) { // show object
	//alert("Concealing...")
	if (transition_time == null){transition_time  = 400}
	this.slideUp(transition_time)	  		      				
}
	
jQuery.fn.delayed_conceal = function(timeout) { // hide object after time has passed
	if (timeout == null){timeout = 5000}
	var $this = $(this); // keep chain: http://docs.jquery.com/Plugins/Authoring
    setTimeout(function() {
		$this.conceal();	  		      				
    }, timeout);			      				
}

jQuery.fn.delayed_reveal = function(timeout) { // show object after time has passed
	if (timeout == null){timeout = 5000}
	var $this = $(this); // keep chain: http://docs.jquery.com/Plugins/Authoring
    setTimeout(function() {
		$this.reveal();	  		      				
    }, timeout);			      				
}


$(document).ready(function() {
		// Ready Tab Functions
	    $("ul.plugin_tabs_horizontal").tabs("div.plugin_panes_horizontal > div", {effect: 'slide', fadeOutSpeed: 400}); // effects: slide, fade, default, ajax, horizontal
		$("ul.plugin_tabs_vertical").tabs("div.plugin_panes_vertical > div", {effect: 'slide', fadeOutSpeed: 400}); // effects: slide, fade, default, ajax, horizontal
		$("#accordion").tabs("#accordion div.pane", {tabs: 'h2.accordion_tab', effect: 'slide', initialIndex: null});// effects: slide, fade, default, ajax, horizontal
		$("ul.tabs").tabs("div.panes > div");
				
		// Enable ColorBox
		$("a[rel='colorbox']").colorbox();

		// Hovering
		$(".hoverable").mouseover(
		  function () { // focus
		  	//alert("hovering..")
			$(this).addClass('hover');
		  }	
		);	
		$(".hoverable").mouseout(
		  function () { // focus
			$(this).removeClass('hover');
		  }	
		);			
		
		/* Input States */
		$(":input").focus(function(){
			//alert($(this).attr("type"))
			if($(this).attr("type") != "submit")
			{
				$(this).addClass('selected');
			}
		});		
		
		$(":input").blur(function(){
			$(this).removeClass('selected');
		});		
		
});