function toggle_box(id) // This Function Hides/Shows an element
{
	// Animation Choices(Appearing): 
	//		show
	//		fadeIn
	//		slideDown
	//		fadeTo(opacity	
	//		Custom(you can make your own jQuery Effects, too).
	// Animation Choices(For Disappearing): 
	//		hide
	//		fadeOut
	//		slideUp
	//		fadeTo(opacity
	//		Custom(you can make your own jQuery Effects, too).
	 var transition_time = 400 // transition time in ms 
	 element = document.getElementById(id)
	 if(element.style.display == "none") // The Element is currently Hidden
		 $(element).slideDown(transition_time) // toggle box using jquery
 	 else // The Element is currently Visible	 
 		 $(element).slideUp(transition_time) // toggle box using jquery
}

function replace_box(id_to_hide, id_to_show) // This function hides the first element and shows the second(which should already be hidden)
{
	// Animation Choices(Appearing): 
	//		show
	//		fadeIn
	//		slideDown
	//		fadeTo(opacity	
	//		Custom(you can make your own jQuery Effects, too).
	// Animation Choices(For Disappearing): 
	//		hide
	//		fadeOut
	//		slideUp
	//		fadeTo(opacity
	//		Custom(you can make your own jQuery Effects, too).
	element_to_hide = document.getElementById(id_to_hide)
	element_to_show = document.getElementById(id_to_show)
	var transition_time = 400 // transition time in ms 
	$(element_to_hide).slideUp(transition_time) // toggle box using jquery
	$(element_to_show).slideDown(transition_time) // toggle box using jquery
}

function toggle_box_s(id) // This Function Hides/Shows an element, using scriptaculous
{
	// Animation Choices(Appearing): 
	//		Appear
	//		BlindDown
	//		Fold
	//		Highlight
	//		Shake
	//		SlideDown
	// Animation Choices(For Disappearing): 
	//		BlindUp
	//		DropOut
	//		Fade
	//		Pulsate
	//		Shrink
	//		SlideUp
	//		Squish
	//		Puff
	//		SwitchOff
	 element = document.getElementById(id)
	 if(element.style.display == "none") // The Element is currently Hidden
 		 new Effect.Appear(element, {duration:0.5}); // Show Element(Must be a Appearing effect listed above)
 	 else // The Element is currently Visible
 		 new Effect.Fade(element, {duration:0.5}); // Hide Element(Must be an Disappearing effect listed above)
}
function replace_box_s(id_to_hide, id_to_show) // This function hides the first element and shows the second(which should already be hidden)
{
	// Animation Choices(Appearing): 
	//		Appear
	//		BlindDown
	//		Fold
	//		Highlight
	//		Shake
	//		SlideDown
	// Animation Choices(For Disappearing): 
	//		BlindUp
	//		DropOut
	//		Fade
	//		Pulsate
	//		Shrink
	//		SlideUp
	//		Squish
	//		Puff
	//		SwitchOff
	element_to_hide = document.getElementById(id_to_hide)
	element_to_show = document.getElementById(id_to_show)
 	new Effect.Shrink(element_to_hide, {duration:0.5}); // Hide Element(Must be a Disappearing effect listed above)
	new Effect.Appear(element_to_show, {duration:0.5}); // Show Element(Must be an Appearing effect listed above)

}

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

// Tab JS For User Section
/********************************************************************************************/

var req;
function callPage(pageUrl, divElementId, loadinglMessage, pageErrorMessage) {
     document.getElementById(divElementId).innerHTML = loadinglMessage;
     try {
     req = new XMLHttpRequest(); /* e.g. Firefox */
     } catch(e) {
       try {
       req = new ActiveXObject("Msxml2.XMLHTTP");  /* some versions IE */
       } catch (e) {
         try {
         req = new ActiveXObject("Microsoft.XMLHTTP");  /* some versions IE */
         } catch (E) {
          req = false;
         } 
       } 
     }
     req.onreadystatechange = function() {responsefromServer(divElementId, pageErrorMessage);};
     req.open("GET",pageUrl,true);
     req.send(null);
  }

function responsefromServer(divElementId, pageErrorMessage) {
   var output = '';
   if(req.readyState == 4) {
      if(req.status == 200) {
         output = req.responseText;
         document.getElementById(divElementId).innerHTML = output;
         } else {
         document.getElementById(divElementId).innerHTML = pageErrorMessage+"\n"+output;
         }
      }
  }
  
/* This Function is for Tab Panels */
function activeTab(tab)
	{   
        // Delesect all other tabs(change their css class) and activate the selected tab
		document.getElementById("tab1").className = "";
		document.getElementById("tab2").className = "";
		document.getElementById("tab3").className = "";
		document.getElementById("tab4").className = "";
		document.getElementById("tab"+tab).className = "active"; // make the current tab "active"
		if(tab == 1) // If your tabs are more, then you can use 'switch' condition instead of 'if' condition for better practice
		{callPage('/user/main/summary', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br> Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');}
		else if(tab == 2)
		{callPage('/user/main/add_item', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /> <br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');}
		else if(tab == 3)
		{callPage('/user/main/view_items', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');}
		else if(tab == 4)
		callPage('/user/main/view_settings', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');
	}	
function activeAdminTab(tab) // function for admin tabs
	{   
        // Delesect all other tabs(change their css class) and activate the selected tab
		document.getElementById("tab1").className = "";
		document.getElementById("tab2").className = "";
		document.getElementById("tab3").className = "";
		document.getElementById("tab4").className = "";
		document.getElementById("tab"+tab).className = "active"; // make the current tab "active"
		if(tab == 1) // Admin Tab
		callPage('/admin/main/summary', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');
		else if(tab == 2) // Admin Tab
		callPage('/admin/main/summary', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');
		else if(tab == 3) // Admin Tab
		callPage('/admin/main/users', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');
		else if(tab == 4) // Admin Tab
		callPage('/admin/main/settings', 'content', '<img src=\"/themes/hulihan_applications_3rd_gen/images/loading.gif\" /><br>Content is loading, Please Wait...', 'Error in Loading page <img src=\"images/error_caution.gif\" />');
	}	

function loading(id)
{
	 element = document.getElementById(id)
	 element.innerHTML = "<div class='loading'><img src='/themes/hulihan_applications_3rd_gen/images/loading.gif' class='loading'></div>"
}
