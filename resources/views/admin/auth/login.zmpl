<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>系统登陆</title>
		<!-- 样 式 文 件 -->
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
		<link rel="stylesheet" href="/static/admin/admin/css/other/login.css" />
	</head>

  <!-- 代 码 结 构 -->
	<body background="/static/admin/admin/images/background.svg" style="background-size: cover;">
		<form class="layui-form" action="javascript:void(0);">
			<div class="layui-form-item">
				<img class="logo" src="/static/admin/admin/images/logo.png" />
				<div class="title">Zig Say</div>
				<div class="desc">
					欢迎使用
				</div>
			</div>
			<div class="layui-form-item">
				<input placeholder="账 户" type="text" lay-verify="required" hover class="layui-input login-name"  />
			</div>
			<div class="layui-form-item">
				<input placeholder="密 码" type="password" lay-verify="required" hover class="layui-input login-password"  />
			</div>

			<div class="layui-form-item">
				<button type="button" class="pear-btn pear-btn-success login" lay-submit lay-filter="login">
					登 入
				</button>
			</div>
		</form>

		<!-- 资 源 引 入 -->
		<script src="/static/admin/component/layui/layui.js"></script>
		<script src="/static/admin/component/pear/pear.js"></script>
		<script>
			layui.use(['form', 'button', 'popup', 'jquery'], function() {
				var form = layui.form;
				var button = layui.button;
				var popup = layui.popup;
				var $ = layui.jquery;
				
                // 登 录 提 交
				form.on('submit(login)', function(data) {
					var name = $(data.form).find('.login-name').val();            
					var password = $(data.form).find('.login-password').val();            

					var url = "/admin/auth/login";

					/// 动画
					button.load({
						elem: '.login',
						time: 1500,
						done: function() {
							$.post(url, {
								'username': name,
								'password': password,
							}, function(data) {
								if (data.code == 0) {
									popup.success("登录成功", function() {
										location.href = "/admin/index";
									});
								} else {
									layer.msg(data.msg, { 
										offset: '15px',
										icon: 5 
									});

									// 刷新验证码
									$(".js-captcha-btn").click();
								}
							}, "json");
						}
					});

					return false;
				});
			})
		</script>
	</body>
</html>
