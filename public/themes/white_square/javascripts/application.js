function toggle_box(id) // This Function Hides/Shows an element
{
	 element = document.getElementById(id)
	 if(element.style.display == "none") // The Element is currently Hidden
	 	show_box(id)
 	 else // The Element is currently Visible	 
 		hide_box(id)
}

function replace_box(id_to_hide, id_to_show) // This function hides the first element and shows the second(which should already be hidden)
{
	hide_box(id_to_hide)
	show_box(id_to_show)
}

function show_box(id){
	// Animation Choices(Appearing): 
	//		show
	//		fadeIn
	//		slideDown
	//		fadeTo(opacity	
	//		Custom(you can make your own jQuery Effects, too).	
	element = document.getElementById(id)
	var transition_time = 400 // transition time in ms
	$(element).slideDown(transition_time) // toggle box using jquery	 
}

function hide_box(id){
	// Animation Choices(For Disappearing): 
	//		hide
	//		fadeOut
	//		slideUp
	//		fadeTo(opacity
	//		Custom(you can make your own jQuery Effects, too).	
	element = document.getElementById(id)
	var transition_time = 400 // transition time in ms
 	$(element).slideUp(transition_time)
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


function loading(id)
{
	 element = document.getElementById(id)
	 element.innerHTML = "<div class='loading'><img src='/themes/white_square/images/loading.gif' class='loading'></div>"
}




/* Opens and Closes Boxes With an expanding link */
function toggle_expanding_box(box_id, link_id)
{
	box_element = document.getElementById(box_id)
	link_element = document.getElementById(link_id)
	// Change the Open/Close Icon
	if(box_element.style.display == "none") // The Element is currently Hidden
	{
		link_element.innerHTML = '<img src="/themes/white_square/images/icons/close.png" class="icon" title="Close">' 
	}
 	else // The Element is currently Visible
 	{
		link_element.innerHTML = '<img src="/themes/white_square/images/icons/open.png" class="icon" title="Expand">' 	 	
	}
	toggle_box(box_id)	// show/hide
}
	  