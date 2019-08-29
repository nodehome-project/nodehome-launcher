<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="io.nodehome.cmm.service.GlobalProperties"%>

<!DOCTYPE html>
<html>
	<head>
    <title></title>
    <!-- Required meta tags -->
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    
    <!-- bootstrap 3.3.7 -->
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>    
    <link href="/bootstrap/assets/css/material-login.css" rel="stylesheet">
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.4.2/css/all.css" integrity="sha384-/rXc/GQVaYpyDdyxK+ecHPVYJSN9bmVFBvjA/9eOB+pb3F2w2N6fc5qB9Ew5yIns" crossorigin="anonymous">
    
    <!-- Platform JS -->   
	<link rel="stylesheet" href="/css/jquery-confirm.min.css">
	<script src="/js/jquery-confirm.min.js"></script>
    <script src="/js/tapp_interface.js"></script>
	<link href="/css/style.css" rel="stylesheet" />
	<script>
		// Script to run as soon as loaded from the web
		$(function() {
			$('#loginform').click(function(){
				onMenu = false;
				$('#menu-box').animate({ top : "-300px" }, 300);
			});
		});

		var j_curANM;
		var j_curNetId;
		var j_chainID;
		var j_seedHost;
		
		// Function to call as soon as it is loaded from the App
		function AWI_OnLoadFromApp(dtype) {
			 // Activate AWI_XXX method
			 AWI_ENABLE = true;
	         AWI_DEVICE = dtype;
	 		 AWI_setTerminatePath('/user/login');
	 		
			 var chk = AWI_isCheckedPassword();
			 var sReturn = AWI_isAbleFingerprint();
			 var sRes = JSON.parse(sReturn);

			 var seedInfo = AWI_getSeedHostInfo();
		     if(seedInfo['result']=='OK') {
				 j_curNetId = seedInfo['netID'];
				 j_chainID = seedInfo['chainID'];
				 j_seedHost = seedInfo['seedHost'];
		     } else {
		    	 $.alert('체인 정보를 로딩하는데 실패 했습니다.');
		     }
			 if(j_curNetId!="biz") $('#goHostBtn').show();

			 var devModeState = AWI_getDevModeState();
			 if(devModeState['result']=='OK') {
				 $('#chgNetBtn').hide();
			 }
			 
			 AWI_setAppTitle("TApp");

			 j_curANM = AWI_getAccountConfig("ACCOUNT_NM");
			 if(j_curANM=="") {
				 $('#btnJoin').show();
			 }

			 if(sRes['result']=="OK" && j_curANM!="") {
				 $('#FingerC').show();
			 }

			 $('#net-name').html(j_curNetId);
		}
    	// NULL Compare
		function checkNull(string) {
			if (string==null || string=='') {
				return true;
			} else {
				return false;
			}
		}
		
    	// 지문인증 call
    	function Fingerprint() {
    		 var joCmd = null;
    		 var params = new Object();
    		 params['cmd'] = "showFingerprint";
    		 joCmd = {func:params};
    			if(AWI_DEVICE == 'ios') {
    				sReturn =  prompt(JSON.stringify(joCmd));	
    			} else if(AWI_DEVICE == 'android') {
    				sReturn =  window.AWI.callAppFunc(JSON.stringify(joCmd));	
    			} else { // windows
    				sReturn =  window.external.CallAppFunc(JSON.stringify(joCmd));	
    			}
			 var sRes = JSON.parse(sReturn);
    	}
    	
	    function chkForm() {
	    	var objForm = document.loginform;
	    	
	    	if (checkNull(objForm.txt_MemName.value)==true) {
	    		$.alert("<spring:message code="user.msg.name" />");
				objForm.txt_MemName.value="";
				return false;
			}
			
			if (checkNull(objForm.txt_MemPwd.value)==true) {
				$.alert("<spring:message code="user.msg.password" />");
				objForm.txt_MemPwd.value="";
				return false;
			}
			
			// Name check
			var sANM = AWI_getAccountConfig("ACCOUNT_NM"); // Account_NAME		
			if(sANM != objForm.txt_MemName.value) {
				$.alert("<spring:message code="user.msg.namedifferent" />");
				return false;
			}
			
			// checkPassword call
			if (AWI_checkPassword(document.getElementById('txt_MemPwd').value) == 'OK') {	
				location.href="/index";				
			} else {
				alert("<spring:message code="user.msg.loginfail" />");
				return false;
			}
			
		}		
		
		// Call loading script when loading time : S
		$(document).ready(function() {
			var loading = $('<div id="loading" class="loading"></div><img id="loading_img" alt="loading" src="/images/viewLoading.gif" />').appendTo(document.body).hide();
			$( document ).ajaxStart( function() {
				loading.show();
			} );
			$( document ).ajaxStop( function() {
				loading.hide();
			} );
		});
		// Call loading script when loading time : E
		
		function actionJoin() {
			location.href="/user/join";
		}

		var onMenu = false;
		function onMainMenu() {
			onMenu = !onMenu;
			changeMainMenu(onMenu);
		}
		function changeMainMenu(chk) {
			onMenu = chk;
			if (chk) {
				$('#menu-box').animate({ top : "50px" }, 300);
			} else {
				$('#menu-box').animate({ top : "-300px" }, 300);
			}
		}

	    // restore
	    function setRestoreFunc() {
			sReturn = AWI_setRestore();
			/* var joReturn = JSON.parse(sReturn);
			if (joReturn['result'] == 'OK') {
			} */		
		}
	    
	 	// App To Web
	    function AWI_CallFromApp(strJson) {
	    	var joRoot = JSON.parse(strJson);  
	    	var joFunc = joRoot.func;
    		if(joFunc.cmd == 'backup') {
    			// '{ "func" : { "cmd" : "backup", "result" : "OK", "walletID" : "Wallet Id" }}'
        		//alert("backup complete");
    			//location.reload();
	    	}
    		
    		if(joFunc.cmd == 'restore') {
    			// '{ "func" : { "cmd" : "restore", "result" : "OK", "walletID" : "Wallet Id" }}'
    			if (joFunc.result == 'OK') {
	    			var pWalletId = joFunc.walletID;
	        		AWI_setAccountConfig("CUR_WID",pWalletId);
	        		location.href="/svm/wallet/createWalletRestore?wid="+pWalletId;
	    			//location.href="/index?wid="+pWalletId;
        		}
	    	}

    		if(joFunc.cmd == 'fingerprint' && joFunc.result == 'OK') {
    			location.href="/index";
    		}
	    }
    </script>
    
  	</head>
  
  
<body>

	<div id="top_header" style="position:absolute;right:0px;top:0;width:100%;height:60px;margin:0;background-color:#fff;z-index:900;border-bottom:1px solid #D0D0D0;">
		<div class="row" style="margin:0;">
			<div class="col-xs-7 col-sm-7" style="height:40px;">
				<a href="/user/login"><img src="/images/nodehome.png" width="138" height="40" style="margin-top:10px;margin-left:5px;" /></a>
			</div>
			<div class="col-xs-3 col-sm-3" style="height:60px;text-align:right;">
	            <div style="margin-top:22px;margin-right:7px;font-size:10pt;color:#aaa;" id="net-name">
	            </div>
			</div>
			<div class="col-xs-2 col-sm-2" style="height:60px;text-align:right;">
	            <div style="margin-top:15px;margin-right:7px;font-size:15pt;">
	                <i class="fas fa-ellipsis-v" onclick="onMainMenu();" style="color:#127519;"></i>
	            </div>
			</div>
		</div>
	</div>
	<script>
	function Fn_openLocation() {
		$('#locationDiv').show();
	}
	function Fn_actionLocation() {
		if($('#locationUrl').val()!="") {
			AWI_openAppByHost($('#locationUrl').val());
		}
	}
	</script>
	<div id="menu-box" style="position:absolute;right:0px;top:-300px;width:100%;background-color:#424242;padding:10px;color:#000;z-index:800;">
		<li onclick="javascript:Fn_openLocation();" id="goHostBtn" style="display:none;"><i class="fas fa-location-arrow"></i> 호스트가기</li>
		<li onclick="javascript:AWI_goHubPage();" id="chgNetBtn"><i class="fas fa-cog"></i> 노드홈 채널 변경</li>
		<li onclick="javascript:AWI_showSettingView();"><i class="fas fa-cog"></i> 설정</li>
		<div style="position:absolute;right:5px;bottom:-23px;font-size:20pt;background-color:#fff;height:23px;line-height:23px;"><i style="padding:0;margin:0;border:0;height:23px;line-height:23px;color:#414041;" class="fas fa-window-close" onclick="changeMainMenu(false)"></i></div>
	</div>
	<div id="locationDiv" style="display:none;" class="pop-center-260-150">
		<div class="col-xs-12 col-sm-12" style="height:40px;line-height:40px;margin-top:30px;">
			<input type="text" name="locationUrl" id="locationUrl" value="" placeholder="http://www.sample.com" class="form-control" />	
		</div> 
		<div class="col-xs-12 col-sm-12" style="height:60px;padding-top:15px;text-align:left;color:#127519;vertical-align: middle;line-height:60px;">
			<button type="button" class="btn btn-primary col-xs-12" onclick="Fn_actionLocation();">이동</button>
		</div>
		<div style="position:absolute;right:5px;top:-1px;font-size:20pt;font-weight:bold;"><i class="fas fa-window-close" onclick="$('#locationDiv').hide();"></i></div>
	</div>
	
	<section style="height: 100vh;">
    <div style="background-attachment: fixed; background-size: cover; width: 100%; height: 100vh; position: relative;"  >
    <div class="baslik">
        <b style="font-size: 50px; text-align: center; margin-bottom: -21px; display: block;">NodeHome</b>
    </div>
    <section>
    <form name="loginform" id="loginform" method="post">
        <div class="arkalogin">
            <div class="loginbaslik">Launcher Login</div>
            <hr style="border: 1px solid #ccc;">
            <input type="text" class="giris" name="txt_MemName" id="txt_MemName" placeholder="Username" maxlength="30" tabindex="1" />
            <input type="password" class="giris" name="txt_MemPwd" id="txt_MemPwd" placeholder="Password" maxlength="30" tabindex="2" />
            <input class="butonlogin" type="button" name="" value="Login" onclick="chkForm();" />
            <input class="butonlogin" type="button" name="" id="FingerC" value="Fingerprint authentication" onclick="Fingerprint();" style="display:none;"/>
            <br/><br/>
			<div id="btnJoin" style="display:none;">
				<div class="row">
					<div class="col-xs-6"><a href="javascript:actionJoin();" class="btn btn-danger btn-block ">사용자등록</a></div>
					<div class="col-xs-6"><a href="javascript:setRestoreFunc();" class="btn btn-danger btn-block "><spring:message code="user.text.restore" /></a></div>
				</div>
			</div>
        </div>
    </form>
    </section><br>
    <span style="font-size: 23px; text-align: center; display: block; color: #888888;">Welcome To The User Panel</span>
    <span style="font-size: 24px; text-align: center; display: block; color: #888888; font-weight: bold; margin-bottom: 34px;">LOGİN</span>
    </div>
    </section>
	
</body>

</html>
