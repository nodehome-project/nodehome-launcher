<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
<%@ page import="io.nodehome.svm.common.CPWalletUtil"%>
<%@ page import="io.nodehome.svm.common.biz.CoinListVO" %>
<%@ page import="io.nodehome.svm.common.util.EtcUtils"%>
<%@ page import="io.nodehome.svm.common.util.StringUtil"%>
<%@ page import="io.nodehome.svm.common.util.DateUtil"%>
<%@ page import="io.nodehome.cmm.FouriMessageSource"%>
<%@ page import="io.nodehome.cmm.service.GlobalProperties"%>

<!DOCTYPE html>
<html>
	<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title></title>
    <!-- Required meta tags -->
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta content="width=device-width, initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=no;" name="viewport" />    
    
    <!-- bootstrap 3.3.7 -->
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <link href="/bootstrap/assets/css/material-common.css" rel="stylesheet">
    
    <!-- Platform JS -->
    <script src="/js/loader.js"></script>
    <script src="/js/tapp_interface.js"></script>    
	<link rel="stylesheet" href="/css/jquery-confirm.min.css">
	<script src="/js/jquery-confirm.min.js"></script>
	
	<script>
		// Script to run as soon as loaded from the web
		$(function() {
			
		});
		
		// Function to call as soon as it is loaded from the App
		function AWI_OnLoadFromApp(dtype) {
			 // Activate AWI_XXX method
			 AWI_ENABLE = true;
			 AWI_DEVICE = dtype;
			 
			 var sANM = AWI_getAccountConfig("ACCOUNT_NM"); // Account_NAME	
			 $('#txt_MemName').val(sANM);
		}

		// NULL Compare
		function checkNull(string) {
			if (string==null || string=='') {
				return true;
			} else {
				return false;
			}
		}
	
		// length Compare
		function checkLen(string) {
			if (checkNull(string)==false) {
				return string.length;
			}
		}
	
		// number Compare
		function onlyNum(objEv) {
			var numPattern = /([^0-9])/;
			numPattern = objEv.value.match(numPattern);
			if (numPattern != null) {
				$.alert("<spring:message code="user.msg.onlynum" />");
				objEv.value="";
				objEv.focus();
				return false;
			}
		}  
		
	    function chkForm() {
	    	var objForm = document.changeform;
	    	
	    	if (checkNull(objForm.txt_OldMemPwd.value)==true) {
	    		$.alert("<spring:message code="user.msg.CurrentPassword" />");
				objForm.txt_OldMemPwd.value="";
				return false;
			}
			
			if (checkNull(objForm.txt_MemPwd.value)==true) {
				$.alert("<spring:message code="user.msg.NewPassword" />");
				objForm.txt_MemPwd.value="";
				return false;
			}
			
			if (checkNull(objForm.txt_MemPwd2.value)==true) {
				$.alert("<spring:message code="user.msg.NewPasswordConfirm" />");
				objForm.txt_MemPwd2.value="";
				return false;
			}
			
			if(objForm.txt_MemPwd.value != objForm.txt_MemPwd2.value) {
				$.alert("<spring:message code="user.msg.NewPasswordDifferent" />");
				return false;
			}
			
			// Password check
			var joReturn = AWI_checkPassword(document.getElementById('txt_OldMemPwd').value);
			if (joReturn == 'OK') {
				// Password change
				var joReturn2 = AWI_changePassword(document.getElementById('txt_OldMemPwd').value, document.getElementById('txt_MemPwd').value);
				if (joReturn2 == 'OK') {
					location.href='/index.jsp';
				} else {
					$.alert("<spring:message code="user.msg.ChangePasswordFail" />");
				}
			} else {
				$.alert("<spring:message code="user.msg.ChangePasswordLoginFail" />");
			}			
		}	    
	    
	 	// Scroll when input is clicked : S
		wgt = $("body").width(); // width default
		hgt = $("body").height(); // height default
				
		$(document).ready(function(){
		    $("input").focusin(function(){
		    	//$(this).css("background-color", "red");
		    	$("body").height(hgt + 400); 
		    	
		    	// After the field height value is calculated input
		    	hcnt = 50; // height default
		    	if (this.name == "txt_OldMemPwd") { Thcnt = hcnt + (74*1) };
		    	if (this.name == "txt_MemPwd") { Thcnt = hcnt + (74*2) };
		    	if (this.name == "txt_MemPwd2") { Thcnt = hcnt + (74*3) };
		    	window.scrollTo(0,Thcnt); // Margin from above
		    });
		    
		});
		// Scroll when input is clicked : E
		
		// Call loading script when loading time : S
		$(document).ready(function(){
			var loading = $('<div id="loading" class="loading"></div><img id="loading_img" alt="loading" src="/images/viewLoading.gif" />').appendTo(document.body).hide();
			$( document ).ajaxStart( function() {
				loading.show();
			} );
			$( document ).ajaxStop( function() {
				loading.hide();
			} );
		});
		// Call loading script when loading time : E
    </script>
  	</head>
  <body>
  
	<div class="container">

		<div class="row">
		    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
					        
				<h2>Change Password <br /><small></small></h2>
				<hr class="colorgraph">
				
				<hr/>
		
				<form name="changeform" id="changeform" method="post" onsubmit="return false;">
				  <div class="form-group">
				    <label for="name"><spring:message code="user.text.CurrentName" /></label>
				    <input type="text" class="form-control" name="txt_MemName" id="txt_MemName"  readonly />
				  </div>
				  <div class="form-group">
				    <label for="name"><spring:message code="user.text.CurrentPassword" /></label>
				    <input type="password" class="form-control" name="txt_OldMemPwd" id="txt_OldMemPwd" placeholder="<spring:message code="user.text.CurrentPassword" />" />
				  </div>
				  <div class="form-group">
				    <label for="pwd"><spring:message code="user.text.NewPassword" /></label>
				    <input type="password" class="form-control" name="txt_MemPwd" id="txt_MemPwd" placeholder="<spring:message code="user.text.NewPassword" />" />
				  </div>
				  <div class="form-group">
				    <label for="pwd"><spring:message code="user.text.NewPasswordConfirm" /></label>
				    <input type="password" class="form-control" name="txt_MemPwd2" id="txt_MemPwd2" placeholder="<spring:message code="user.text.NewPasswordConfirm" />" />
				  </div>
				  
				  <div style="width:100%;text-align:center;">
				  	<button type="button" class="btn btn-primary btn-lg" style="width:100%;text-align:center;" onclick="chkForm();"><span class="glyphicon glyphicon-log-in" style="margin-right:10px;"></span><spring:message code="user.button.ChangePassword" /></button>
				  </div>
				  <div style="width:100%; height:20px; text-align:center;"></div>
				  
				</form> 
				
			</div>
		</div>
	</div>
	
  </body>

</html>

