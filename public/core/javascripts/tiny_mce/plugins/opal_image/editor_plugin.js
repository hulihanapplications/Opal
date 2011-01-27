/* 
 * 	Opal Images TinyMCE Plugin
 * 	Written By: Hulihan Applications for Opal
 * 	www.hulihanapplications.com 
 */

(function() {
	tinymce.create('tinymce.plugins.opal_image', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mce_opal_image', function() {
				// Internal image object like a flash placeholder
				if (ed.dom.getAttrib(ed.selection.getNode(), 'class').indexOf('mceItem') != -1)
					return;
				
				if(opal_setting["item_id"] != null) // set item id
				{
					//alert(opal_setting["item_id"] )
					action_url = "/pages/tinymce_images?item_id=" + opal_setting["item_id"]			
				}
				else{ // no item id set 
					action_url = "/pages/tinymce_images"			
				}
				
				ed.windowManager.open({
					file : action_url, // + get_url_vars()["item_id"],
					width : 680 + parseInt(ed.getLang('advimage.delta_width', 0)),
					height : 485 + parseInt(ed.getLang('advimage.delta_height', 0)),
					inline : 1,
					scrollbars: true
				}, {
					plugin_url : url
				});
			});

			// Register buttons
			ed.addButton('opal_image', {
				title : 'Insert/Upload Image',
				cmd : 'mce_opal_image',
         		image : url + '/img/image.png'				
			});
		},

		getInfo : function() {
			return {
				longname : 'Opal Image',
				author : 'Hulihan Applications',
				authorurl : 'http://www.hulihanapplications.com',
				infourl : 'http://www.hulihanapplications.com/projects/opal',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('opal_image', tinymce.plugins.opal_image);
})();