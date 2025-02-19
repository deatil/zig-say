<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>用户管理</title>
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
	</head>
	<body class="pear-container">
		<div class="layui-card">
			<div class="layui-card-body">
				<form class="layui-form" action="">
					<div class="layui-form-item">
						<div class="layui-form-item layui-inline">
							<label class="layui-form-label">关键字</label>
							<div class="layui-input-inline">
								<input type="text" name="keywords" placeholder="" class="layui-input">
							</div>
						</div>

						<div class="layui-form-item layui-inline">
							<label class="layui-form-label">状态</label>
							<div class="layui-input-inline">
								<select name="status" lay-verify="">
									<option value="-1">全部</option>
									<option value="1">启用</option>
									<option value="0">禁用</option>
								</select>
							</div>
						</div>

						<div class="layui-form-item layui-inline">
							<button class="pear-btn pear-btn-md pear-btn-primary" lay-submit lay-filter="comment-query">
								<i class="layui-icon layui-icon-search"></i>
								查询
							</button>
							<button type="reset" class="pear-btn pear-btn-md">
								<i class="layui-icon layui-icon-refresh"></i>
								重置
							</button>
						</div>
					</div>
				</form>
			</div>
		</div>
		
		<div class="layui-card">
			<div class="layui-card-body">
				<table id="comment-table" lay-filter="comment-table"></table>
			</div>
		</div>

		@html HTML
		<script type="text/html" id="comment-bar">
			<button class="pear-btn pear-btn-primary pear-btn-sm" lay-event="edit"><i class="layui-icon layui-icon-edit"></i></button>
		    <button class="pear-btn pear-btn-danger pear-btn-sm" lay-event="remove"><i class="layui-icon layui-icon-delete"></i></button>
		</script>
		HTML

		<script src="/static/admin/component/layui/layui.js"></script>
		<script src="/static/admin/component/pear/pear.js"></script>
		<script>
			layui.use(['table', 'form', 'jquery','laytpl','common'], function() {
				let table = layui.table;
				let form = layui.form;
				let $ = layui.jquery;
				let common = layui.common;

				let cols = [
					[
						{
							title: '#',
							field: 'id',
							align: 'left',
							width: 60,
						},
						{
							title: '评论',
							field: 'content',
							align: 'left',
						},
						{
							title: '用户',
							field: 'username',
							align: 'left',
						},
						{
							title: '添加时间',
							field: 'createTime',
							align: 'left',
							templet: function(d) {
								if (d.add_time > 0) { 
									return layui.util.toDateString(d.add_time * 1000, 'yyyy-MM-dd HH:mm:ss');
								} else { 
									return "--";
								} 
							},
							width: 180,
						},
						{
							title: '启用',
							field: 'enable',
							align: 'center',
							templet: function(d) {
								if (d.status == 1) { 
									return '<input type="checkbox" name="enable" value="' + d.id + '" lay-skin="switch" lay-text="启用|禁用" lay-filter="comment-enable" checked>';
								} else { 
									return '<input type="checkbox" name="enable" value="' + d.id + '" lay-skin="switch" lay-text="启用|禁用" lay-filter="comment-enable">';
								} 
							},
							width: 150
						},
						{
							title: '操作',
							toolbar: '#comment-bar',
							align: 'left',
							width: 150
						}
					]
				]

				table.render({
					elem: '#comment-table',
					url: "/admin/comment/list",
					page: true,
					cols: cols,
					skin: 'line',
					parseData: function(res) {
						return {
							"code": res.code,
							"count": res.data.count,
							"data": res.data.list,
						};
					},
					defaultToolbar: [{
						title: '刷新',
						layEvent: 'refresh',
						icon: 'layui-icon-refresh',
					}, 'filter', 'print', 'exports']
				});

				table.on('tool(comment-table)', function(obj) {
					if (obj.event === 'remove') {
						window.remove(obj);
					} else if (obj.event === 'edit') {
						window.edit(obj);
					}
				});

				table.on('toolbar(comment-table)', function(obj) {
					if (obj.event === 'refresh') {
						window.refresh();
					}
				});

				form.on('submit(comment-query)', function(data) {
					table.reload('comment-table', {
						where: data.field
					})
					return false;
				});

				window.edit = function(obj) {
					layer.open({
						type: 2,
						title: '修改',
						shade: 0.1,
						area: ['500px', '400px'],
						content: "/admin/comment/edit?id=" + obj.data['id'],
					});
				}

				window.remove = function(obj) {
					layer.confirm('确定要删除该评论', {
						icon: 3,
						title: '提示'
					}, function(index) {
						layer.close(index);
						let loading = layer.load();

						$.ajax({
							url: "/admin/comment/del?id=" + obj.data['id'],
							data: {},
							type: 'post',
							dataType: 'json',
							success: function(result) {
								layer.close(loading);

								if (result.code == 0) {
									layer.msg(result.msg, {
										icon: 1,
										time: 1000
									}, function() {
										obj.del();
									});
								} else {
									layer.msg(result.msg, {
										icon: 2,
										time: 1000
									});
								}
							}
						})
					});
				}

				window.refresh = function(param) {
					table.reload('comment-table');
				}
			})
		</script>
	</body>
</html>
