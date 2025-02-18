<script>
var menus = [
	{
		"id": 0,
		"title": "控制台",
		"icon": "layui-icon layui-icon-console",
		"type": 1,
		"openType": "_iframe",
		"href": "/admin/console"
	},
	{
		"id": "arts",
		"title": "文章管理",
		"icon": "layui-icon layui-icon-app",
		"type": 0,
		"href": "",
		"children": [
			{
				"id": "art",
				"title": "文章列表",
				"icon": "layui-icon layui-icon-face-smile",
				"type": 1,
				"openType": "_iframe",
				"href": "/admin/topic/index"
			},
			{
				"id": "comment",
				"title": "评论管理",
				"icon": "layui-icon layui-icon-file",
				"type": 1,
				"openType": "_iframe",
				"href": "/admin/comment/index"
			}
		]
	},
	{
		"id": "system",
		"title": "系统管理",
		"icon": "layui-icon layui-icon-set-fill",
		"type": 0,
		"href": "",
		"children": [
			{
				"id": "user",
				"title": "用户管理",
				"icon": "layui-icon layui-icon-user",
				"type": 1,
				"openType": "_iframe",
				"href": "/admin/user/index"
			}
		]
	},
	{
		"id": "setting",
		"title": "网站设置",
		"icon": "layui-icon layui-icon-auz",
		"type": 1,
		"openType": "_iframe",
		"href": "/admin/setting"
	}
];
</script>