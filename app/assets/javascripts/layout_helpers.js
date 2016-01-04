window.PINGO.currentLanguage = function(){
	return jQuery("html").attr("lang");
};

window.PINGO.Init = function(){
	jQuery(document).ready(function() {
		jQuery("*[data-toggle='popover']").popover({html: true, trigger: 'hover'});
		jQuery("*[data-toggle='tooltip']").tooltip();
		jQuery("*[data-toggle='button']").button();
	});
};
window.PINGO.Init();
