// Some variables

var base= "/images/main_menu/"
var normal = new Array();
var on_mouse_over = new Array();
var images = new Array('main_button_read','main_button_write','main_button_listen','main_button_about', 'main_button_create');

// Pre-load Images
if (document.images)
{
	for (i=0; i<images.length; i++)
	{
		normal[i] = new Image;
		normal[i].src = base + images[i] + ".png"
		on_mouse_over[i] = new Image;
		on_mouse_over[i].src = base + images[i] + "_hover.png";
	}
}


// The functions: first mouseover, then mouseout

function over(no)
{
	if (document.images)
	{
		document.images[images[no]].src = on_mouse_over[no].src
	}
}

function out(no)
{
	if (document.images)
	{
		document.images[images[no]].src = normal[no].src
	}
}
