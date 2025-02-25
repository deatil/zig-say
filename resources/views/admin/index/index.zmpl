<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
		<title>{{context.webname}} 后台管理</title>
		<link rel="stylesheet" href="/static/admin/admin/css/other/icon.css">
		<!-- 依 赖 样 式 -->
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
		<!-- 加 载 样 式-->
		<link rel="stylesheet" href="/static/admin/admin/css/load.css" />
		<!-- 布 局 样 式 -->
		<link rel="stylesheet" href="/static/admin/admin/css/admin.css" />
	</head>
	<!-- 结 构 代 码 -->
	<body class="layui-layout-body pear-admin">
		<!-- 布 局 框 架 -->
		<div class="layui-layout layui-layout-admin">
			<div class="layui-header">
				<!-- 顶 部 左 侧 功 能 -->
				<ul class="layui-nav layui-layout-left">
					<li class="collaspe layui-nav-item"><a href="#" class="layui-icon layui-icon-shrink-right"></a></li>
					<li class="refresh layui-nav-item"><a href="#" class="layui-icon layui-icon-refresh-1" loading = 600></a></li>
				</ul>
				<!-- 多 系 统 菜 单 -->
				<div id="control" class="layui-layout-control"></div>
				<!-- 顶 部 右 侧 菜 单 -->
				<ul class="layui-nav layui-layout-right">
					<li class="layui-nav-item layui-hide-xs">
						<a href="#" class="fullScreen layui-icon layui-icon-screen-full"></a>
					</li>
					<li class="layui-nav-item layui-hide-xs">
						<a href="/" class="layui-icon layui-icon-website" target="_blank"></a>
					</li>
					<li class="layui-nav-item user">
						<!-- 头 像 -->
						<a href="javascript:;">
							<img src="/static/admin/admin/images/avatar.jpg" class="layui-nav-img">
						</a>
						<!-- 功 能 菜 单 -->
						<dl class="layui-nav-child">
							<dd>
								<a href="javascript:void(0);" 
									user-menu-url="/admin/profile/password" 
									user-menu-id="profile_password" 
									user-menu-title="更改密码">更改密码</a>
							</dd>
							<dd>
								<a href="javascript:void(0);" class="logout">注销登录</a>
							</dd>
						</dl>
					</li>
					<!-- 主 题 配 置 -->
					<li class="layui-nav-item setting"><a href="#" class="layui-icon layui-icon-more-vertical"></a></li>
				</ul>
			</div>
			<!-- 侧 边 区 域 -->
			<div class="layui-side layui-bg-black">
				<!-- 菜 单 顶 部 -->
				<div class="layui-logo">
					<!-- 图 标 -->
					<img class="logo"></img>
					<!-- 标 题 -->
					<span class="title"></span>
				</div>
				<!-- 菜 单 内 容 -->
				<div class="layui-side-scroll">
					<div id="sideMenu"></div>
				</div>
			</div>
			<!-- 视 图 页 面 -->
			<div class="layui-body">
				<!-- 内 容 页 面 -->
				<div id="content"></div>
			</div>
			<!-- 遮 盖 层 -->
			<div class="pear-cover"></div>
			<!-- 加 载 动 画-->
			<div class="loader-main">
				<div class="loader"></div>
			</div>
		</div>
		<!-- 移 动 端 便 捷 操 作 -->
		<div class="pear-collasped-pe collaspe">
			<a href="#" class="layui-icon layui-icon-shrink-right"></a>
		</div>
		<!-- 依 赖 脚 本 -->
		<script src="/static/admin/component/layui/layui.js"></script>
		<script src="/static/admin/component/pear/pear.js"></script>

		<!-- 框 架 初 始 化 -->

        @partial admin/index/menus

		<script>
			layui.use(['admin','jquery','convert','popup'], function() {
				var admin = layui.admin;
				var $ = layui.jquery;
				var convert = layui.convert;
				var popup = layui.popup;
		
				admin.setAvatar("/static/admin/admin/images/avatar.jpg", "{{ $.admin_login }}");
				
				admin.render({
					"logo": {
						"title": "{{context.webname}}",
						"image": "/static/admin/admin/images/logo.png"
					},
					"menu": {
						"data": menus,
						"collaspe": true,
						"accordion": true,
						"method": "GET",
						"control": false,
						"async": false,
						"select": "0"
					},
					"tab": {
						"muiltTab": true,
						"keepState": true,
						"tabMax": 30,
						"index": {
							"id": "0",
							"href": "/admin/console",
							"title": "首页"
						}
					},
					"theme": {
						"defaultColor": "2",
						"defaultMenu": "dark-theme",
						"allowCustom": true
					},
					"colors": [{
						"id": "1",
						"color": "#2d8cf0"
						},{
						"id": "2",
						"color": "#5FB878"
						},{
						"id": "3",
						"color": "#1E9FFF"
						}, {
						"id": "4",
						"color": "#FFB800"
						}, {
						"id": "5",
						"color": "darkgray"
						}
					],
					"links": [{
						"icon": "layui-icon layui-icon-auz",
						"title": "开源地址",
						"href": "https://www.github.com/deatil/zig-say"
						}
					],
					"other": {
						"keepLoad": 1200,
						"autoHead": false
					},
					"header": {
						"message": false
					}
				});
				
				// 登出逻辑 
				admin.logout(function(){
					popup.success("注销成功", function() {
						location.href = "/admin/auth/logout";
					});

					// 注销逻辑 返回 true / false
					return true;
				});
			})
		</script>
	</body>
</html>
