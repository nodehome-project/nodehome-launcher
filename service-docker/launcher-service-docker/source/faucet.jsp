<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
	<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link href="https://fonts.googleapis.com/css?family=Baloo+Tammudu" rel="stylesheet">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="/css/style.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script src="/js/loader.js"></script>
    
    <link rel="stylesheet" href="/css/jquery-confirm.min.css">
	<script src="/js/jquery-confirm.min.js"></script>
	
	<script src="/js/tapp_interface.js"></script>
	
	<script>
		//Web에서 로딩되자 마자 실행하는 스크립트
		$(function() {
		});
		
		var j_curNetId;
		var j_chainID;
		var j_seedHost;

		// Function to call as soon as it is loaded from the App
		function AWI_OnLoadFromApp(dtype) {
			// Activate AWI_XXX method
			AWI_ENABLE = true;
		    AWI_DEVICE = dtype;

			 var seedInfo = AWI_getSeedHostInfo();
		     if(seedInfo['result']=='OK') {
				 j_curNetId = seedInfo['netID'];
				 j_chainID = seedInfo['chainID'];
				 j_seedHost = seedInfo['seedHost'];
		     } else {
		    	 $.alert('체인 정보를 로딩하는데 실패 했습니다.');
		     }

		     userWalletRimitFom.netType.value = j_curNetId;
		     userWalletRimitFom.chainID.value = j_chainID;
		    
		    j_curWID = AWI_getAccountConfig("CUR_WID");
		    $('#walletName2').val(j_curWID);
		}
			
		// 전송
		function FnTransferCoin() {

	        var formData = $("#userWalletRimitFom").serialize();
	        $.ajax({
	        	async:false,
	            cache : false,
	            url : "/faucet_proc.do",
	            type : 'POST',
	            data : formData,
	            success : function(data) {
	            	var res = JSON.parse(data);
	            	if(res['result']=="OK") {
		    			$.alert({
		    				    title: '안내',
		    				    content: "전송되었습니다.",
		    				    confirm: function(){
		    				    },
		    				    onClose: function(){
		    						location.reload();
		    				    },
		    			});
	            	} else if(res['result']=="NOTTODAY") {
		    			$.alert({
		    				    title: '오류',
		    				    content: "1일 1회만 전송 가능합니다.",
		    				    confirm: function(){
		    				    },
		    				    onClose: function(){
		    						location.reload();
		    				    },
		    			});
	            	} else {
		    			$.alert({
	    				    title: '오류',
	    				    content: "전송중 오류가 발생했습니다.",
	    				    confirm: function(){
	    				    },
	    				    onClose: function(){
	    						location.reload();
	    				    },
	    				});
	            	}
	            },
	            error : function(xhr, status) {
	    			$.alert({ 
    				    title: '에러',
    				    content: "전송중 오류가 발생했습니다.",
    				    confirm: function(){
    				    },
    				    onClose: function(){
    						location.reload();
    				    },
    				});
	            }
	        });	
		}
    </script>
  	</head>
  <body>
  
		<nav class="navbar navbar-default navbar-fixed-top">
		  <div class="container">
		    <div class="navbar-header">
		        <span style="display:inline-block; width:100%; margin:0 auto; padding:10px 0px 0px 0px; text-align:center; vertical-align:middle; font-size:28px; font-family: 'Baloo Tammudu', cursive;background-color:#fff;" onclick="javascript:location.href='/user/login.jsp'">Nodehome Platform</span>
		    </div>
		  </div>
		</nav>


	<div class="container">
		<Br/>
		<p style="height:50px;">&nbsp;</p>
        <span style="font-size:24px; font-weight:bold;">Faucet</span>
        <div style="width:100%; height:8px; text-align:center;"></div> 
        
		<!-- Body : S -->
		<form name="userWalletRimitFom" id="userWalletRimitFom" method="post" action="/faucet_proc.do" onsubmit="return false;">
		  <input type="hidden" name="netType" value="dev" />
		  <input type="hidden" name="chainID" value="" />
		  
		  <div style="width:100%;border:1px solid #F5ECDC;border-radius: 5px;padding:10px 10px 25px 10px;background:#FFFCF7;word-wrap: break-word;">
		  	<h4>NodeHome COIN Faucet </h4>
		  	<p>Free COIN (BON) every 1 Day</p>
		  		<br/><br/>
			  <div class="form-group">
			    <label for="name">User wallet</label>
			    <input type="text" class="form-control" name="walletName2" id="walletName2" placeholder="Wallet ID" value=""/>
			    <br/><br/>
			    <button type="button" class="btn btn-primary" onclick="FnTransferCoin()">request 2,000,000BON from faucet</button>
<button type="button" class="btn btn-primary" onclick="location.href='/index.jsp'">뒤로가기</button>
			  </div>
		  
		  </div>
		  
		</form> 
		<!-- Body : E -->
		
	</div>
	

  </body>

</html>

