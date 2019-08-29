<%@page import="io.nodehome.cmm.service.GlobalProperties"%>
<%@ page language="java" contentType="text/html; charset=utf-8"  pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="io.nodehome.cmm.service.GlobalProperties"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html; charset=utf-8");
%>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8" />
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title></title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0, shrink-to-fit=no' name='viewport' />
    
    <!--     Fonts and icons     -->
	<script src="/ss/js/core/jquery.min.js"></script>
    <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700,200" rel="stylesheet" />
    <link href="https://use.fontawesome.com/releases/v5.0.6/css/all.css" rel="stylesheet">
    <!-- CSS Files -->
    <link href="/ss/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ss/css/now-ui-dashboard.css?v=1.0.1" rel="stylesheet" />
    <!-- CSS Just for demo purpose, don't include it in your project -->
    <link href="/ss/demo/demo.css" rel="stylesheet" />
    
    <script src="/js/tapp_interface.js"></script>
	<link href="/css/loading.css" rel="stylesheet" />

	<script>
	$.ajaxSetup({ async:false }); // AJAX calls in order

	var serviceList = null;
	var myServices = "${serviceIDs }";
	function searchSubmit() {
		frm.action="/svm/common/serviceSelection";
		frm.target="_self";
		frm.submit();
	}

	var j_terminalVersion;
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


		 
		$('#loading').css('display','block');

		setTimeout(function () {
			var sQuery = {"requestUrl" : j_seedHost+"/getServiceList?searchText=${param.searchText}&searchType=${param.searchType}&searchOrder=${param.searchOrder}"};
			var data = WSI_callCorsJsonAPI(sQuery);

	    	if(data['result']=="LIST" && data['list']!="") {
	    			serviceList = data['list'];
	    			var sHTML='';
	    			var elmtTBody = $('#id_servicelist_table_body');
	    			for(var i=0; i < serviceList.length ; i ++) {
	    				
	    				if(serviceList[i]['serviceID']!='nhlauncher' && serviceList[i]['serviceID']!='ebstock-wallet') {

		    				sHTML += '	<div class="font-icon-list col-6 col-xs-4 col-sm-4 col-md-3 col-lg-2" style="padding-left:3px;padding-right:3px;">';
		    				sHTML += '    	<div class="font-icon-detail"><input type="checkbox" id="cur'+i+'" name="svr" value="' + serviceList[i]['serviceID'] + '" onclick="chkRadio('+i+')">';
			    		    sHTML += '        	<img src="'+serviceList[i]['host']+'/images/icon.png" width="100%" height="100%" onError="javascript:noImageHeaderError(this)" />';
			    		    sHTML += '        	<p>';
		    				sHTML += 				'' + serviceList[i]['serviceName'] + '<input type="hidden" name="svrnm" value="' + serviceList[i]['serviceName'] + '" /><input type="hidden" name="svrHost" value="' + serviceList[i]['host'] + '" />';
			    		    sHTML += '        	</p>';
			    		    sHTML += '    	</div>';
			    		    sHTML += '	</div>';
	    				}
	    				
	    			}
	    			elmtTBody.html(sHTML);
	    	}
	    	if(serviceList!=null && serviceList.length>0 && myServices!="") {
	    		if(serviceList.length==1) {
	    			if(myServices.indexOf((frm.svr.value))>-1) {
	    				frm.svr.checked = true;
	    			}
	    		} else {
		    		for(var i=0; i<frm.svr.length; i++) {
		    			if(myServices.indexOf(frm.svr[i].value)>-1) {
		    				frm.svr[i].checked = true;
		    			}
		    		}	
	    		}
	    	}
		},10);
		$('#loading').css('display','none');
	}
	
	// Script to run as soon as loaded from the web
	$(function() {

	});
	
  	function noImageHeaderError( obj ){
	    if( obj !=null){
	      obj.src = "/images/noimage.png"; // 변경하고자하는 이미지를 넣는다.
	    }
	}
  	
	function selectionSubmit() {
		var saveStr = null;
		var tempStr = "";
		
		var chk = false;
		if(frm.svr.length) {
			for(var i=0; i<frm.svr.length; i++) {
				if(frm.svr[i].checked) chk = true;
			}	
		} else {
			if(frm.svr.checked) chk = true;
		}
		if(!chk) {
			alert('<spring:message code="common.choice.service" />');
			return;
		}

		$('#loading').css('display','block');

		setTimeout(function () {
			if(frm.svr.length) {
				for(var i=0; i<frm.svr.length; i++) {
					if(frm.svr[i].checked) { 
						tempStr += "{\"serviceID\":\""+frm.svr[i].value+"\",\"serviceName\":\""+frm.svrnm[i].value+"\",\"imgPath\":\""+frm.svrHost[i].value+"/images/icon.png\"},";
					}
				}
			} else {
				if(frm.svr.checked) { 
					tempStr += "{\"serviceID\":\""+frm.svr.value+"\",\"serviceName\":\""+frm.svrnm.value+"\",\"imgPath\":\""+frm.svrHost.value+"/images/icon.png\"},";
				}
			}
			if(tempStr.length>0) tempStr = tempStr.substring(0,tempStr.length-1);
			saveStr = tempStr;

			// Save to service terminal
			joReturn = AWI_setServiceList(saveStr,'');
			location.href="/index.jsp";
		},10);
	}

	function goMain() {
		location.href="/index";
	}
	</script>
</head>

<body class="">
	<div id="loading" class="loading" style="display:none;"><div class="loading-icon">
	  <div class="loading-bar"></div>
	  <div class="loading-bar"></div>
	  <div class="loading-bar"></div>
	  <div class="loading-bar"></div>
	</div></div>
	
	<form name="frm" id="frm" method="post" onsubmit="return false;" class="form-horizontal">
	<input type="hidden" name="serviceIDs" value="${serviceIDs }" />
    <div class="wrapper ">
        <!-- <div class="sidebar" data-color="orange">
            <div class="logo">
                <a href="http://www.creative-tim.com" class="simple-text logo-mini">
                    CT
                </a>
                <a href="http://www.creative-tim.com" class="simple-text logo-normal">
                    Creative Tim
                </a>
            </div>
            <div class="sidebar-wrapper">
                <ul class="nav">
                    <li>
                        <a href="../examples/dashboard.html">
                            <i class="now-ui-icons design_app"></i>
                            <p>Dashboard</p>
                        </a>
                    </li>
                    <li class="active">
                        <a href="../examples/icons.html">
                            <i class="now-ui-icons education_atom"></i>
                            <p>Icons</p>
                        </a>
                    </li>
                    <li>
                        <a href="../examples/map.html">
                            <i class="now-ui-icons location_map-big"></i>
                            <p>Maps</p>
                        </a>
                    </li>
                    <li>
                        <a href="../examples/notifications.html">
                            <i class="now-ui-icons ui-1_bell-53"></i>
                            <p>Notifications</p>
                        </a>
                    </li>
                    <li>
                        <a href="../examples/user.html">
                            <i class="now-ui-icons users_single-02"></i>
                            <p>User Profile</p>
                        </a>
                    </li>
                    <li>
                        <a href="../examples/tables.html">
                            <i class="now-ui-icons design_bullet-list-67"></i>
                            <p>Table List</p>
                        </a>
                    </li>
                    <li>
                        <a href="../examples/typography.html">
                            <i class="now-ui-icons text_caps-small"></i>
                            <p>Typography</p>
                        </a>
                    </li>
                    <li class="active-pro">
                        <a href="../examples/upgrade.html">
                            <i class="now-ui-icons arrows-1_cloud-download-93"></i>
                            <p>Upgrade to PRO</p>
                        </a>
                    </li>
                </ul>
            </div>
        </div> -->
        <div class="">
            <!-- Navbar -->
            <nav class="navbar navbar-expand-lg navbar-transparent  navbar-absolute bg-primary fixed-top">
                <div class="container-fluid">
                    <div class="navbar-wrapper">
                        <!-- <div class="navbar-toggle">
                            <button type="button" class="navbar-toggler">
                                <span class="navbar-toggler-bar bar1"></span>
                                <span class="navbar-toggler-bar bar2"></span>
                                <span class="navbar-toggler-bar bar3"></span>
                            </button>
                        </div> -->
                        <a class="navbar-brand" href="javascript:location.reload();">Select Platform Services</a>
                    </div>
                    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navigation" aria-controls="navigation-index" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-bar navbar-kebab"></span>
                        <span class="navbar-toggler-bar navbar-kebab"></span>
                        <span class="navbar-toggler-bar navbar-kebab"></span>
                    </button>
                    <div class="collapse navbar-collapse justify-content-end" id="navigation">
                        <ul class="navbar-nav">
                            <li class="nav-item">
                                <a class="nav-link" href="javascript:goMain();">
                                    <i class="now-ui-icons users_single-02"></i>
                                    <p>
                                        <span class="d-lg-none d-md-block">메인페이지 이동</span>
                                    </p>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            <!-- End Navbar -->
            <div class="panel-header panel-header-sm">
            </div>
            <div class="content">
                <div class="row">
                    <div class="col-md-12">
                        <div class="card">
                            <div class="card-body all-icons">
                                <div class="row">

									
									<div class="row" style="padding:0 10px 0 10px;">
										<div class="col-xs-6 col-6" style="margin-bottom:5px;">
											<select name="searchType" id="searchType" class="form-control input-lg">
												<option value="1" <c:if test="${param.searchType=='1'}">selected="selected"</c:if>><spring:message code="title.service.name" /></option>
												<option value="2" <c:if test="${empty param.searchType || param.searchType=='' || param.searchType=='2'}">selected="selected"</c:if>><spring:message code="table.regdate" /></option>
											</select>
										</div>
										<div class="col-xs-6 col-6" style="margin-bottom:5px;">
											<select name="searchOrder" id="searchOrder" class="form-control input-lg">
												<option value="0" <c:if test="${empty param.searchOrder || param.searchOrder=='' || param.searchOrder=='0'}">selected="selected"</c:if>><spring:message code="title.sort.asc" /></option>
												<option value="1" <c:if test="${param.searchOrder=='1'}">selected="selected"</c:if>><spring:message code="title.sort.desc" /></option>
											</select>
										</div>
										<div class="col-xs-12" style="margin:0;padding:0 30px 0 30px;">
										    <div class="form-group">
												<div class="input-group">
											      <div class="input-group-addon"><spring:message code="title.search" /></div>
											      <input type="text" class="form-control input-lg" value="${param.searchText}" id="searchText" name="searchText"  />
											    </div>
											</div> 
										</div>
									</div>
									<div class="container row" style="margin:0;">
										<div class="col-xs-6 col-6">
											<button type="button" class="btn btn-primary btn-block" onclick="javascript:searchSubmit();"><spring:message code="button.search" /></button> 
										</div>
										<div class="col-xs-6 col-6">
											<button type="button" class="btn btn-primary btn-block" onclick="javascript:selectionSubmit();"><spring:message code="button.create" /></button> 
										</div>
									</div>
									<div style="padding-bottom:20px;"></div>
									
                                </div>
                            </div>
                        </div>
                        
                        <div class="card">
                            <div class="card-body all-icons">
                                <div class="row"  id='id_servicelist_table_body' style="margin:0;">	    	
                                </div>
                            </div>
                        </div>
                        
						<div class="container row" style="margin:0;">
							<div class="col-xs-12 col-12">
								<button type="button" class="btn btn-primary btn-block" onclick="javascript:selectionSubmit();"><spring:message code="button.create" /></button> 
							</div>
						</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
<!--   Core JS Files   -->
<script src="/ss/js/core/popper.min.js"></script>
<script src="/ss/js/core/bootstrap.min.js"></script>
<script src="/ss/js/plugins/perfect-scrollbar.jquery.min.js"></script>
<!--  Google Maps Plugin    -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY_HERE"></script>
<!-- Chart JS -->
<script src="/ss/js/plugins/chartjs.min.js"></script>
<!--  Notifications Plugin    -->
<script src="/ss/js/plugins/bootstrap-notify.js"></script>
<!-- Control Center for Now Ui Dashboard: parallax effects, scripts for the example pages etc -->
<script src="/ss/js/now-ui-dashboard.js?v=1.0.1"></script>
<!-- Now Ui Dashboard DEMO methods, don't include it in your project! -->
<script src="/ss/demo/demo.js"></script>
</body>

