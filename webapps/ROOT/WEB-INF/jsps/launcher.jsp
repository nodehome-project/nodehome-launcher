<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="io.nodehome.svm.common.biz.CoinListVO"%>
<%@ page import="io.nodehome.svm.common.CoinUtil"%>
<%@ page import="io.nodehome.cmm.service.GlobalProperties"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">

<title></title>
<link rel="stylesheet" type="text/css" href="/js/slider/dist/css/slider-pro.css" media="screen"/>
<link rel="stylesheet" type="text/css" href="/js/slider/libs/fancybox/jquery.fancybox.css" media="screen"/>
<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>
<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.4.2/css/all.css" integrity="sha384-/rXc/GQVaYpyDdyxK+ecHPVYJSN9bmVFBvjA/9eOB+pb3F2w2N6fc5qB9Ew5yIns" crossorigin="anonymous">
    
<script type="text/javascript" src="/js/slider/libs/jquery-1.11.0.min.js"></script>
<script type="text/javascript" src="/js/slider/dist/js/jquery.sliderPro.js"></script>
<script type="text/javascript" src="/js/slider/libs/fancybox/jquery.fancybox.pack.js"></script>

<link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script> 

<link href="/css/style.css" rel="stylesheet"/>
<link href="/css/loading.css" rel="stylesheet"/>
	
<link rel="stylesheet" href="/css/jquery-confirm.min.css">
<script src="/js/jquery-confirm.min.js"></script>
<script src="/js/tapp_interface.js"></script>
  
<script type="text/javascript">

	var j_curWID;
	var j_curANM;
  	var slider;
	var isLoding = false;

	var pageCnt = 0;
	var maxPageNo = 0;
	var rtnServiceList;
	var imageFolder = "";
	var serviceIds = "";	// 보유한 서비스ID 목록
    
	$(function() {
		//$('#body_container').click(function(){
		//});
	});
	
	var localHost;
	var j_curNetId;
	var j_isAbleTestNet;
	var j_isAbleDebugNet;
	
	// Function to call as soon as it is loaded from the App
	function AWI_OnLoadFromApp(dtype) {
		// Activate AWI_XXX method
		AWI_ENABLE = true;
	    AWI_DEVICE = dtype;
	    
	 	// 서비스 앱 초기화 
		AWI_setTerminatePath('/launcher');
		AWI_closeServiceApp();	
		 
		if(!isLoding) {	// slidePro때문에 AWI_OnLoadFromApp()가 두번이상 호출되는 문제
		    j_curWID = AWI_getAccountConfig("CUR_WID");
			j_curANM = AWI_getAccountConfig("ACCOUNT_NM");
			 
			 j_isAbleTestNet = AWI_isAbleTestNet();
			 j_isAbleDebugNet = AWI_isAbleDebugNet();

			 if(j_isAbleTestNet=="OK" || j_isAbleDebugNet=="OK") {
				 $('#netIdBtn').show();
			 }
			 if(j_isAbleTestNet=="OK") {
	             var option = $("<option value='TestNet'>TestNet</option>");
	             $('#netId').append(option); 
			 } 
			 if(j_isAbleDebugNet=="OK") {
	             var option = $("<option value='DebugNet'>DebugNet</option>");
	             $('#netId').append(option); 
			 }

			 j_curNetId = (AWI_getNetID())['value'];
			 $('#netId').val(j_curNetId);
			 if(j_curNetId!="MainNet") $('#goHostBtn').show();
			 
			if(j_curWID=="") {
				 location.href="/svm/wallet/myWalletList";
			} else {
				 //var myBalance = getBalance(j_curWID);
			}
			
			var chk = AWI_isCheckedPassword();
			if(chk!="OK") location.href="/user/login";

			localHost = AWI_getLocalHttpHost();
			rtnServiceList = AWI_getServiceList();
			loadServices();
			
			Fn_initDisplay();
			drawPageIcon();
		}
	}
	
	// 페이지 슬라이드 출력후에 실행 초기화
	function Fn_initDisplay() {
		$( '#body_container' ).sliderPro({
			autoHeight: true,
			fade: true,
			updateHash: true,
			loop: false,
			autoplay: false,
			buttons: false,
			heightMinus: (60+40+20),
			forceSize:'fullWindow',
			keyboard:false,
			autoScaleLayers: false,
		});
		
		$('.sp-slide .row').css("min-height",$( window ).height()-(60+40+20));

		$( '#body_container .sp-lightbox' ).on( 'click', function( event ) {
			event.preventDefault();
			if ( $( '#body_container' ).hasClass( 'sp-swiping' ) === false ) {
				$.fancybox.open( this );
			}
		});
		
		slider = $( '#body_container' ).data( 'sliderPro' );
		$( '#body_container' ).on( 'gotoSlide', function( event ) {
			drawPageIcon();
			$('#pageNo').val(slider.getSelectedSlide()+1);
		});

		if(maxPageNo>2) {slider.settings.loop = true;}
		
		isLoding = true;
	}
	
	function drawPageIcon() {
		//$('#page-no').html(slider.getSelectedSlide()+1);	// 페이지 번호
		// draw page icon
		$('#page-no').html("");
		for(var ii=0; ii<pageCnt; ii++) {
			if(slider.getSelectedSlide() == ii)
				$('#page-no').append("<span style='color:#fff;padding-left:10px;padding-right:10px;'>"+(ii+1)+"</span>");
			else
				$('#page-no').append("<span style='color:#B5CB8E;padding-left:10px;padding-right:10px;'>"+(ii+1)+"</span>");
		}
	}
	
	function loadServices() {
		var serviceList = [[]];
		if(rtnServiceList['result']=="OK") {
			var objServices = rtnServiceList['list'];
			
			//alert(JSON.stringify(rtnServiceList));
			
			imageFolder = rtnServiceList['imageFolder'];
			for(var i=0; i<objServices.length; i++) {
				var obj = objServices[i];
				var pageNum = obj['pageNum']; if(pageNum<1) pageNum=1;
				if(pageNum > maxPageNo) maxPageNo = pageNum;

		        var tempObj = serviceList[(pageNum-1)];
		        if(serviceList.length < pageNum) {	// serviceList 배열 초기화 체크
		        	for(var a=serviceList.length; a<pageNum; a++) {
		    	        var tempObj2 = serviceList[a];
		    	        if(tempObj2===undefined) {
		        			serviceList.push([]);
		    	        }
		        	}
		        }
		        var tempObj = serviceList[(pageNum-1)];
		        tempObj.push("{\"serviceId\":\""+obj["serviceId"]+"\",\"serviceName\":\""+obj["serviceName"]+"\",\"defaultCheck\":\"false\"}");
		        serviceList[(pageNum-1)] = tempObj;	
			} 
		}
		displayServices(serviceList);
	}
	
	function FnOpenServiceApp(pServiceId) {
		$('#loading').show();
		AWI_openServiceApp(pServiceId);
	}

	function displayServices(serviceList) {
		$('.sp-slides').html("");
		var sHtml = "";

		pageCnt = 0;
		serviceIds = "";
		for(var i=0; i<serviceList.length; i++) {
			sHtml += '<div class="sp-slide">';
			sHtml += '	<div class="row" style="margin:0;">';
			if(serviceList[i].length>0) {
				for(var i2=0; i2<serviceList[i].length; i2++) {
					var tempObj = JSON.parse(serviceList[i][i2]);
					sHtml += '		<div class="col-xs-6 col-sm-6" style="text-align:center;padding:5px;" id="sp-col-'+i+'-'+i2+'">';
					sHtml += '			<img src="'+localHost+'/'+imageFolder+'/'+tempObj['serviceId']+'/icon.png" width=80 height=80 style="border-radius:25px;"  onclick="javascript:FnOpenServiceApp(\''+tempObj['serviceId']+'\');" /><br/>';
					sHtml += '			<div style="height:50px;">';
					if(tempObj['defaultCheck']=="true") { 
						sHtml += '			<input type="checkbox" class="serviceChkBox" name="serviceValue" value="'+(i+1)+'|'+(i2+1)+'|'+tempObj['serviceId']+'|'+tempObj['serviceName']+'" checked style="display:none;" />';
					} else {
						sHtml += '			<input type="checkbox" class="serviceChkBox" name="serviceValue" value="'+(i+1)+'|'+(i2+1)+'|'+tempObj['serviceId']+'|'+tempObj['serviceName']+'" style="display:none;" />';	
					}
					sHtml += '			'+tempObj['serviceName']+'</div>';
					sHtml += '		</div>';
					serviceIds += tempObj['serviceId']+",";
				}
			}
			sHtml += '	</div>';
			sHtml += '</div>';
			pageCnt++;
		}
		if(serviceIds.length > 0) serviceIds = serviceIds.substring(0,serviceIds.length-1);
		$('.sp-slides').append(sHtml);
		//$('#tot-page-no').html(pageCnt);
	}
	
	
	
	
    function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                $('#foo').attr('src', e.target.result);
            }
            reader.readAsDataURL(input.files[0]);
        }
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
			$('#netIdDiv').hide();
			$('#menu-box').animate({ top : "-420px" }, 300);
		}
	}
	
	function changemngMenuPop(chk) {
		if (chk) {
			$('#mngMenuPop').show(300);
		} else {
			$('#mngMenuPop').hide(300);
		}
	}

	var defaultBottomGap = 40;
	var openBottomGap = 250;
	
	function loadManagerBox() {
		onMenu = false;
		changeMainMenu(false);

		changemngMenuPop(true);
		changeBottomGapSize(openBottomGap);
	}
	
	// 하단 여백 조정
	function changeBottomGapSize(height) {
		$('#bottomGap').css("height",height+"px");
	}
	
	function closePop(pid) {
		$('#'+pid).hide(300);
		changeBottomGapSize(defaultBottomGap);
		$('.serviceChkBox').hide();
	}

	function iconSelMove() {
		$('#btn-list1').hide();
		$('#btn-list2').show();
		$('.serviceChkBox').show();
	}
	
	function iconSelDel() {
		$('#btn-list1').hide();
		$('#btn-list3').show();
		$('.serviceChkBox').show();
	}
	
	// 선택 아이콘 삭제
	function iconSelDelProc() {
		var serviceList = [[]];
		var nowSelectedPageNo = slider.getSelectedSlide()+1;
		$('input:checkbox[name="serviceValue"]').each(function() {
			var val = (this.value).split("|");
			var pageNum = parseInt(val[0]);
			var pageSeq = parseInt(val[1]);
			var sId = val[2];
			var sNm = val[3];

	        if(serviceList.length < pageNum) {	// serviceList 배열 초기화 체크
	        	for(var a=serviceList.length; a<pageNum; a++) {
	    	        var tempObj2 = serviceList[a];
	    	        if(tempObj2===undefined) {
	        			serviceList.push([]);
	    	        }
	        	}
	        }
			if(this.checked && nowSelectedPageNo == pageNum) {
				;
			} else {
		        var tempObj = serviceList[(pageNum-1)];
		        tempObj.push("{\"serviceId\":\""+sId+"\",\"serviceName\":\""+sNm+"\",\"defaultCheck\":\"false\"}");
		        serviceList[(pageNum-1)] = tempObj;
			}
		});
		displayServices(serviceList);
		Fn_initDisplay();
		$('.serviceChkBox').show();
	}
	
	// 터미널에 적용
	function iconSelApply() {
		var tempStr="";
		var index=0;
		$('input:checkbox[name="serviceValue"]').each(function() {
			var val = (this.value).split("|");
			var pageNum = parseInt(val[0]);
			var pageSeq = parseInt(val[1]);
			var sId = val[2];
			var sNm = val[3];

			tempStr += "{\"pageNum\":"+pageNum+",\"seqNum\":"+pageSeq+",\"serviceId\":\""+sId+"\",\"serviceName\":\""+sNm+"\",\"active\":";
			if(index==0) tempStr += "\"Y\"";
			else tempStr += "\"N\"";
			tempStr += "},";
			index++;
		});
		if(tempStr.length>0) tempStr = tempStr.substring(0,tempStr.length-1);
		// Save to service terminal 
		joReturn = AWI_setServiceList(tempStr,'launcher');

		if(joReturn['result']=="OK") {
			$('.serviceChkBox').hide();
			$('#btn-list2').hide();
			$('#btn-list3').hide();
			$('#btn-list1').show();
		} else {
			$.alert("저장에 실패했습니다.");
		}
		
		drawPageIcon();	// 페이지 아이콘 다시 그리기
	}
	
	function cancelSelApply() {
		$('.serviceChkBox').hide();
		$('#btn-list2').hide();
		$('#btn-list3').hide();
		$('#btn-list1').show();
	}
	
	function changeOrder(ord) {
		var itemList = [];
		var nowSelectedPageNo = slider.getSelectedSlide()+1;
		var curPageServiceCnt = 0;
		$('input:checkbox[name="serviceValue"]').each(function() {
			itemList.push(this.value+"|"+this.checked);
			var val = (this.value).split("|");
			var pageNum = parseInt(val[0]);
			if(pageNum == nowSelectedPageNo) {
				curPageServiceCnt++;
			}
		});

		if(ord=="L") {
			var pageIndex = 0;
			for(var i=0; i<itemList.length; i++) {
				var tmp = itemList[i];
				var val = (tmp).split("|");
				var pageNum = parseInt(val[0]);
				if(nowSelectedPageNo == pageNum) {
					if(pageIndex>0 && val[4]=="true") {
						itemList.splice(i, 1);
						itemList.splice(i-1, 0, tmp);
					}
					pageIndex++;
				}
			};
		} else {
			var pageIndex = (curPageServiceCnt-1);
			for(var i=(itemList.length-1); i>=0; i--) {
				var tmp = itemList[i];
				var val = (tmp).split("|");
				var pageNum = parseInt(val[0]);
				if(nowSelectedPageNo == pageNum) {
					if(pageIndex<(curPageServiceCnt-1) && val[4]=="true") {
						itemList.splice(i, 1);
						itemList.splice(i+1, 0, tmp);
					}
					pageIndex--;
				}
			};
		}
		
		var serviceList = [[]];
		for(var i=0; i<itemList.length; i++) {
			var val = (itemList[i]).split("|");
			var pageNum = parseInt(val[0]);
			var pageSeq = parseInt(val[1]);
			var sId = val[2];
			var sNm = val[3];
			
	        if(serviceList.length < pageNum) {	// serviceList 배열 초기화 체크
	        	for(var a=serviceList.length; a<pageNum; a++) {
	    	        var tempObj2 = serviceList[a];
	    	        if(tempObj2===undefined) {
	        			serviceList.push([]);
	    	        }
	        	}
	        }
	        var tempObj = serviceList[(pageNum-1)];
	        tempObj.push("{\"serviceId\":\""+sId+"\",\"serviceName\":\""+sNm+"\",\"defaultCheck\":\""+val[4]+"\"}");
	        serviceList[(pageNum-1)] = tempObj;
		}
		displayServices(serviceList);
		Fn_initDisplay();
		$('.serviceChkBox').show();
	}

	function changePage() {
		var isChkItem = false;
		var itemList = [];
		var upPageNo = $('#pageNo').val();
		if(upPageNo=="") {return;}
		
		$('input:checkbox[name="serviceValue"]').each(function() {
			if(this.checked) {
				var val = (this.value).split("|");
				itemList.push(upPageNo+"|999|"+val[2]+"|"+val[3]+"|false");
			} else {
				itemList.push(this.value+"|"+this.checked);
			}
		});

		var serviceList = [[]];
		for(var i=0; i<itemList.length; i++) {
			var val = (itemList[i]).split("|");
			var pageNum = parseInt(val[0]);
			var pageSeq = parseInt(val[1]);
			var sId = val[2];
			var sNm = val[3];

	        if(serviceList.length < pageNum) {	// serviceList 배열 초기화 체크
	        	for(var a=serviceList.length; a<pageNum; a++) {
	    	        var tempObj2 = serviceList[a];
	    	        if(tempObj2===undefined) {
	        			serviceList.push([]);
	    	        }
	        	}
	        }
	        var tempObj = serviceList[(pageNum-1)];
	        tempObj.push("{\"serviceId\":\""+sId+"\",\"serviceName\":\""+sNm+"\",\"defaultCheck\":\"false\"}");
	        serviceList[(pageNum-1)] = tempObj;	
		}
		displayServices(serviceList);
		
		if(pageCnt < (slider.getSelectedSlide()+1)) slider.gotoSlide(pageCnt-1);
		Fn_initDisplay();
		$('.serviceChkBox').show();
	}
	
	function Fn_goServiceList() {
		location.href="/svm/common/serviceSelection?serviceIds="+serviceIds;
	}

	function Fn_addNewServiceForm() {
		location.href="/svm/service/addServiceForm";	
	}
	function Fn_faucet() {
		location.href="/faucet.jsp";	
	}
	function Fn_actionWalletPage() {
		location.href="/index";	
	}
	
</script>

</head>

<body leftmargin=0 topmargin=0>
	<div id="loading" class="loading" style="display:none;"><div class="loading-icon">
	  <div class="loading-bar"></div>
	  <div class="loading-bar"></div>
	  <div class="loading-bar"></div>
	  <div class="loading-bar"></div>
	</div></div>

	<script>
	function Fn_openNetOption() {
		$('#netIdDiv').show();
	}
	function Fn_redirectNetID() {
		AWI_setNetID($('#netId').val());
	}
	function Fn_openLocation() {
		changeMainMenu(false);
		$('#locationDiv').show();
	}
	function Fn_actionLocation() {
		if($('#locationUrl').val()!="") {
			AWI_openAppByHost($('#locationUrl').val());
		}
	}
	function calcPageNo(g) {
		var pn = parseInt($('#pageNo').val());
		if(g=='+') {
			$('#pageNo').val(pn+1);
		} else if(g=='-' && pn>0){
			$('#pageNo').val(pn-1);
		}
	}
	
	</script>
	
	<div id="menu-box" style="position:absolute;right:0px;top:-420px;width:100%;background-color:#424242;padding:10px;color:#000;z-index:800;">
		<li onclick="javascript:loadManagerBox();"><i class="fas fa-user-cog"></i> 바탕화면 관리</li>
		<li onclick="javascript:Fn_faucet();"><i class="fas fa-coins"></i> 무료 충전</li>
		<li onclick="javascript:Fn_goServiceList();"><i class="fas fa-search-plus"></i> 서비스 검색</li>
		<li onclick="javascript:Fn_openNetOption();"><i class="fas fa-network-wired"></i> 접속 네트워크</li>
		<div id="netIdDiv" style="display:none;"> 
			<select name="netId" id="netId" class="form-control" onchange="Fn_redirectNetID()">
			</select>	
		</div>
		<li onclick="javascript:AWI_showSettingView();"><i class="fas fa-cog"></i> 설정</li>
		<li onclick="javascript:Fn_addNewServiceForm();"><i class="fas fa-cog"></i> 새서비스추가</li>
		<li onclick="javascript:Fn_actionWalletPage();"><i class="fas fa-cog"></i> 지갑 서비스</li>
		<li id="goHostBtn" style="display:none;" onclick="javascript:Fn_openLocation();"><i class="fas fa-location-arrow"></i> 호스트 가기</li>
		<li onclick="javascript:AWI_logout();"><i class="fas fa-sign-out-alt"></i> 로그아웃</li> 
		<li onclick="javascript:changeMainMenu(false);"><i class="fas fa-times" style="padding-left:9px;"></i> 메뉴 닫기</li> 
	</div> 
	<div id="locationDiv" style="display:none;border:1px solid #ccc;" class="pop-center-260-150">
		<div class="col-xs-12 col-sm-12" style="height:40px;line-height:40px;margin-top:30px;">
			<input type="text" name="locationUrl" id="locationUrl" value="" placeholder="http://www.sample.com" class="form-control" />	
		</div> 
		<div class="col-xs-12 col-sm-12" style="height:60px;padding-top:15px;text-align:left;color:#127519;vertical-align: middle;line-height:60px;">
			<button type="button" class="btn btn-primary col-xs-12" onclick="Fn_actionLocation();">이동</button>
		</div>
		<div style="position:absolute;right:5px;top:-1px;font-size:20pt;font-weight:bold;"><i class="fas fa-window-close" onclick="$('#locationDiv').hide();" style="border-radius:0;"></i></div>
	</div>
	
	<div style="width:100%;height:50px;"></div><!-- 상단 header여백 -->
	
	<div id="top_header" style="position:absolute;right:0px;top:0;width:100%;height:60px;margin:0;background-color:#fff;z-index:900;border-bottom:1px solid #D0D0D0;">
		<div class="row" style="margin:0;">
			<div class="col-xs-7 col-sm-7" style="height:40px;">
				<a href="/launcher"><img src="/images/nodehome.png" width="138" height="40" style="margin-top:10px;margin-left:5px;" /></a>
			</div>
			<div class="col-xs-5 col-sm-5" style="height:60px;text-align:right;">
	            <div style="margin-top:15px;margin-right:7px;font-size:14pt;">
	                <i class="fas fa-ellipsis-v" onclick="onMainMenu();" style="color:#414041;"></i>
	            </div>
			</div>
		</div>
	</div>
	 
	<div id="body_container" style="padding-top:20px;background-image: linear-gradient(-40deg, #F6F8EC, #FFF);"><!-- background: url(/images/bg3.png); -->
		<div class="sp-slides">
		</div>
    </div>

	<!-- DAPP 관리 메뉴 -->
	<div style="display:none;position:fixed;bottom:40px;left:0;border-top:1px solid #cccccc;height:160px;width:100%;vertical-align:middle;background-color:#fff;z-index:700;" id="mngMenuPop">
		<div style="width:100%;height:160px;vertical-align:middle;padding:50px 10px 10px 10px;" id="btn-list1">
			<button type="button" class="btn launcher-btn col-xs-12" onclick="iconSelMove();">아이콘 선택 이동</button>
			<button type="button" class="btn launcher-btn col-xs-12" onclick="iconSelDel();">아이콘 선택 삭제</button>
		</div>
		<div style="display:none;width:100%;height:160px;vertical-align:middle;padding:20px 10px 10px 10px;" id="btn-list2">
			<div class="col-xs-7">
				<table>
					<tr>
						<td>
							<button type="button" class="btn launcher-btn3" onclick="calcPageNo('-');" style="margin-left:4px;"><i class="fas fa-minus-circle"></i></button>
						</td>
						<td>
							<input type="number" id="pageNo" class="form-control" value="1" style="margin-right:4px;width:100%;"/>
						</td>
						<td>
							<button type="button" class="btn launcher-btn3" onclick="calcPageNo('+');" style="margin-left:4px;"><i class="fas fa-plus-circle"></i></button>
						</td>
					</tr>
				</table>
			</div>
			<div class="col-xs-4">
				<button type="button" class="btn launcher-btn3" onclick="changePage();" style="margin-left:4px;">페이지로 이동</button>
			</div>
			<div class="col-xs-6">
				<button type="button" class="btn launcher-btn col-xs-12" onclick="changeOrder('L');">순서 앞으로</button>
			</div>
			<div class="col-xs-6">
				<button type="button" class="btn launcher-btn col-xs-12" onclick="changeOrder('R');">순서 뒤로</button>
			</div>
			<div class="col-xs-6">
				<button type="button" class="btn launcher-btn2 col-xs-12" onclick="iconSelApply();">적용</button>
			</div>
			<div class="col-xs-6">
				<button type="button" class="btn launcher-btn2 col-xs-12" onclick="cancelSelApply();">취소</button>
			</div>
		</div>
		<div style="display:none;width:100%;height:160px;vertical-align:middle;padding:50px 10px 10px 10px;" id="btn-list3">
			<div class="col-xs-12">
				<button type="button" class="btn launcher-btn col-xs-12" onclick="iconSelDelProc();">삭제</button>
			</div>
			<div class="col-xs-6">
				<button type="button" class="btn launcher-btn2 col-xs-12" onclick="iconSelApply();">적용</button>
			</div>
			<div class="col-xs-6">
				<button type="button" class="btn launcher-btn2 col-xs-12" onclick="cancelSelApply();">취소</button>
			</div>
		</div>
		<div style="position:absolute;right:5px;top:-30px;font-size:20pt;font-weight:bold;"><i class="fas fa-window-close" onclick="closePop('mngMenuPop');"></i></div>
	</div>
	
	<div id="bottomGap" style="width:100%;height:40px;"></div><!-- 하단 여백 -->
	<div id="bottom" style="position: fixed;left:0px;bottom:0;width:100%;height:40px;margin:0;z-index:900;">
		<div class="row" style="margin:0;background-color:#1B5E20;"><!-- background-image: linear-gradient(-40deg, #6F8732, #6F8732, #6F8732, #30440C); -->
			<div style="height:40px;line-height:40px;vertical-align: middle;text-align:center;color:#000;font-size:13pt;" id="page-no">
				<!-- <span id="page-no" style="font-weight:bold;">1</span> / <span id="tot-page-no" style="color:blue;"></span> -->
			</div>
		</div>
	</div>
	
</body>
</html>