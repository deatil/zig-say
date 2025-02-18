<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>系统提示</title>
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
		<link rel="stylesheet" href="/static/admin/admin/css/other/error.css" />
	</head>
	<body>
		<div class="content">
			<img src="/static/admin/admin/images/500.svg" alt="500">
			<div class="content-r">
				<h1>404</h1>
				<p>{{ $.message }}</p>
                @if ($.url) |url|
					<a href="{{url}}" class="pear-btn pear-btn-primary">马上跳转</a>
				@else
					<a href="javascript:location.reload();" class="pear-btn pear-btn-primary">刷新重试</a>
				@end
			</div>
		</div>
	</body>
</html>
