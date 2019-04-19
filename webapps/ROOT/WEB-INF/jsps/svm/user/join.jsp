<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="io.nodehome.cmm.service.GlobalProperties"%>
<%@ page import="io.nodehome.svm.common.util.security.WalletKeySource" %>
<%@ page import="java.util.HashMap"%>

<!DOCTYPE html>
<html>
	<head>
    <title></title>
    <!-- Required meta tags -->
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta name="viewport" content="width=device-width">
    <!-- <meta content="width=device-width, initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=no;" name="viewport" /> -->     
    
    <!-- bootstrap 3.3.7 -->
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    
    <!-- Platform JS -->   
    <script src="/js/loader.js"></script>
    <script src="/js/tapp_interface.js"></script>    
	<script>
   		$.ajaxSetup({ async:false }); // AJAX calls in order
    
		// Script to run as soon as loaded from the web
		$(function() {
		});
		
		// Function to call as soon as it is loaded from the App
		function AWI_OnLoadFromApp(dtype) {
			 // Activate AWI_XXX method
			 AWI_ENABLE = true;
			 AWI_DEVICE = dtype;
		}
	</script>
    <script type="text/javascript">	
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
				alertMassage("<spring:message code="user.msg.onlynum" />");
				objEv.value="";
				objEv.focus();
				return false;
			}
		}  
		
	    function chkForm() {
	    	
	    	var objForm = document.joinform;
	    	if (checkNull(objForm.txt_MemName.value)==true) {
	    		alertMassage("<spring:message code="user.msg.name" />");
				objForm.txt_MemName.value="";
				return false;
			}
			if (checkNull(objForm.txt_MemPwd.value)==true) {
				alertMassage("<spring:message code="user.msg.password" />");
				objForm.txt_MemPwd.value="";
				return false;
			}
			if (checkNull(objForm.txt_MemPwd2.value)==true) {
				alertMassage("<spring:message code="user.msg.passwordconfirm" />");
				objForm.txt_MemPwd2.value="";
				return false;
			}
			if(objForm.txt_MemPwd.value != objForm.txt_MemPwd2.value) {
				alertMassage("<spring:message code="user.msg.passworddifferent" />");
				return false;
			}
			// newAccount
	    	var sWid = null;
	    	var sName = null;
	    	var sResult = null;
	    	
	    	// newAccount call
			sName = objForm.txt_MemName.value;
			
			// setPassword call
			var mpass = document.getElementById('txt_MemPwd').value;
			sResult = AWI_setPassword(mpass);
			AWI_setAccountConfig("ACCOUNT_NM",sName); 	// NAME Save
			
			// 기본 지갑 생성
			sReturn = AWI_newWallet();
			var joReturn = JSON.parse(sReturn);
			if (joReturn['result'] == 'OK') {
				AWI_setAccountConfig(joReturn['walletId'],sName); 
			}
			
			location.href='/user/login';	
		}
	    
	    
	    function AWI_CallFromApp(strJson) {
			var joRoot = JSON.parse(strJson);  
			var joFunc = joRoot.func;
		}
	    
	    
	 	// Scroll when input is clicked : S
		/* wgt = $("body").width(); // width default
		hgt = $("body").height(); // height default
				
		$(document).ready(function(){
		    $("input").focusin(function(){
		    	//$(this).css("background-color", "red");
		    	$("body").height(hgt + 400); 
		    	
		    	// After the field height value is calculated input
		    	hcnt = 50; // height default
		    	if (this.name == "txt_MemName") { Thcnt = hcnt };
		    	if (this.name == "txt_MemPwd") { Thcnt = hcnt + (74*1) };
		    	if (this.name == "txt_MemPwd2") { Thcnt = hcnt + (74*2) };
		    	window.scrollTo(0,Thcnt); // Margin from above
		    });
		}); */
		// Scroll when input is clicked : E
		
		var loading = $('<div id="loading" class="loading"></div><img id="loading_img" alt="loading" src="/images/viewLoading.gif" />').appendTo(document.body).hide();
		//loading.show();
		//loading.hide();
    </script>
  	</head>
  
  
<body>

	<div class="container">

		<div class="row">
		    <div class="col-xs-12 col-sm-8 col-md-6 col-sm-offset-2 col-md-offset-3">
				<form name="joinform" id="joinform" method="post">
					<h2>Please Sign Up <br /><small>It's free and always will be.</small></h2>
					<hr class="colorgraph">
					<div class="form-group">
						<input type="text" name="txt_MemName" id="txt_MemName" class="form-control input-lg" placeholder="<spring:message code="user.text.name" />" maxlength="30" tabindex="1" />
					</div>
					<div class="row">
						<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
								<input type="password" name="txt_MemPwd" id="txt_MemPwd" class="form-control input-lg" placeholder="<spring:message code="user.text.password" />" maxlength="30" tabindex="2" />
							</div>
						</div>
						<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
								<input type="password" name="txt_MemPwd2" id="txt_MemPwd2" class="form-control input-lg" placeholder="<spring:message code="user.text.confirmpassword" />" maxlength="30" tabindex="3" />
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-xs-4 col-sm-3 col-md-3">
							<span class="button-checkbox">
								<button type="button" class="btn" data-color="info" tabindex="7">I Agree</button>
		                        <input type="checkbox" name="t_and_c" id="t_and_c" class="hidden" value="1" />
							</span>
						</div>
						<div class="col-xs-8 col-sm-9 col-md-9">
							 By clicking <strong class="label label-primary">Register</strong>, you agree to the <a href="#" data-toggle="modal" data-target="#t_and_c_m">Terms and Conditions</a> set out by this site, including our Cookie Use.
						</div>
					</div>
					
					<hr class="colorgraph">
					<div class="row">
						<div class="col-xs-12"><input type="button" value="Register" class="btn btn-success btn-block btn-lg" onclick="chkForm();" tabindex="4" /></div>
					</div>
				</form>
			</div>
		</div>
		<!-- Modal -->
		<div class="modal fade" id="t_and_c_m" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
						<h4 class="modal-title" id="myModalLabel">Terms & Conditions</h4>
					</div>
					<div class="modal-body">
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
						<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Similique, itaque, modi, aliquam nostrum at sapiente consequuntur natus odio reiciendis perferendis rem nisi tempore possimus ipsa porro delectus quidem dolorem ad.</p>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" data-dismiss="modal">I Agree</button>
					</div>
				</div><!-- /.modal-content -->
			</div><!-- /.modal-dialog -->
		</div><!-- /.modal -->
	</div>
	
</body>

</html>
