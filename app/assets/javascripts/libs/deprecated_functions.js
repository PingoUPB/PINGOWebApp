window.PINGO.isMSIE = function(){
	var ua = navigator.userAgent.toString().toLowerCase();
	var match1 = ua.indexOf("msie");
	var match2 = ua.indexOf("trident");
	return (match1 >= 0) || (match2 >= 0);
};
