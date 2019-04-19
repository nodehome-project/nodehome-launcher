<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script type="text/javascript" src="/js/slider/libs/jquery-1.11.0.min.js"></script>
<script src="/js/tapp_interface.js"></script>
  
<script type="text/javascript">
	var j_curWID;
	var j_curANM;
	
	// Function to call as soon as it is loaded from the App
	function AWI_OnLoadFromApp(dtype) {
		// Activate AWI_XXX method
		AWI_ENABLE = true;
	    AWI_DEVICE = dtype;
	    
		var chk = AWI_isCheckedPassword();
		if(chk=="OK") {
			location.href="/launcher";			
		} else {
			location.href="/user/login";
		}
	}
</script>
	