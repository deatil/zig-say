<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>控制台</title>
		<meta name="renderer" content="webkit">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
		<link rel="stylesheet" href="/static/admin/admin/css/other/console2.css" />
	</head>
	<body class="pear-container">
		<div class="layui-row layui-col-space10">
			<div class="layui-col-md8">
				<div class="layui-row layui-col-space10">
					<div class="layui-col-md6">
						<div class="layui-card">
							<div class="layui-card-header">
								快捷菜单
							</div>
							<div class="layui-card-body">
								<div class="layui-row layui-col-space10">
									<div class="layui-col-md3 layui-col-sm3 layui-col-xs3">
										<div class="pear-card" data-id="art" data-title="文章列表" data-url="/admin/topic/index">
											<i class="layui-icon layui-icon-app"></i>
										</div>
										<span class="pear-card-title">文章</span>
									</div>
									<div class="layui-col-md3 layui-col-sm3 layui-col-xs3">
										<div class="pear-card" data-id="comment" data-title="评论管理" data-url="/admin/comment/index">
											<i class="layui-icon layui-icon-star"></i>
										</div>
										<span class="pear-card-title">评论</span>
									</div>
									<div class="layui-col-md3 layui-col-sm3 layui-col-xs3">
										<div class="pear-card" data-id="user" data-title="用户管理" data-url="/admin/user/index">
											<i class="layui-icon layui-icon-user"></i>
										</div>
										<span class="pear-card-title">用户</span>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="layui-col-md6">
						<div class="layui-card">
							<div class="layui-card-header">
								数据统计
							</div>
							<div class="layui-card-body">
								<div class="layui-row layui-col-space10">
									<div class="layui-col-md6 layui-col-sm6 layui-col-xs6">
										<div class="pear-card2">
											<div class="title">文章数量</div>
											<div class="count pear-text">{{ $.topic_count }}</div>
										</div>
									</div>
									<div class="layui-col-md6 layui-col-sm6 layui-col-xs6">
										<div class="pear-card2">
											<div class="title">评论数量</div>
											<div class="count pear-text">{{ $.comment_count }}</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div class="layui-col-md12">
						<div class="layui-card">
							<div class="layui-card-body">
								<div class="layui-tab custom-tab layui-tab-brief" lay-filter="docDemoTabBrief">
									<div id="echarts-records" style="background-color:#ffffff;min-height:400px;"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="layui-col-md4">
				<div class="layui-card">
					<div class="layui-card-header">最新文章</div>
					<div class="layui-card-body">
						<ul class="pear-card-status">
							@for ($.new_topics) |new_topic| {
								<li>
									<p>{{new_topic.title}}</p>
									<span>{{new_topic.add_time}}</span>
									<a href="javascript:;" class="pear-btn pear-btn-primary pear-btn-xs pear-reply">编辑</a>
								</li>
							}
						</ul>
					</div>
				</div>
			</div>
		</div>
		<!--</div>-->
		<script src="/static/admin/component/layui/layui.js"></script>
		<script src="/static/admin/component/pear/pear.js"></script>
		<script>
			layui.use(['layer', 'echarts', 'carousel', 'element', 'table'], function() {
				var $ = layui.jquery,
					layer = layui.layer,
					element = layui.element,
					echarts = layui.echarts,
					table = layui.table,
					carousel = layui.carousel;

				let cols = [
					[{
							type: 'checkbox'
						},
						{
							title: '角色名',
							field: 'roleName',
							align: 'center',
							width: 100
						},
						{
							title: 'Key值',
							field: 'roleCode',
							align: 'center'
						},
						{
							title: '描述',
							field: 'details',
							align: 'center'
						},
						{
							title: '是否可用',
							field: 'enable',
							align: 'center',
							templet: '#role-enable'
						}
					]
				]

				var echartsRecords = echarts.init(document.getElementById('echarts-records'), 'walden');

				$("body").on("click", "[data-url]", function() {
					parent.layui.tab.addTabOnlyByElem("content", {
						id: $(this).attr("data-id"),
						title: $(this).attr("data-title"),
						url: $(this).attr("data-url"),
						close: true
					})
				})


				let bgColor = "#fff";
				let color = [
					"#0090FF",
					"#36CE9E",
					"#FFC005",
					"#FF515A",
					"#8B5CFF",
					"#00CA69"
				];
				let echartData = [{
						name: "1",
						value1: 100,
						value2: 233
					},
					{
						name: "2",
						value1: 138,
						value2: 233
					},
					{
						name: "3",
						value1: 350,
						value2: 200
					},
					{
						name: "4",
						value1: 173,
						value2: 180
					},
					{
						name: "5",
						value1: 180,
						value2: 199
					},
					{
						name: "6",
						value1: 150,
						value2: 233
					},
					{
						name: "7",
						value1: 180,
						value2: 210
					},
					{
						name: "8",
						value1: 230,
						value2: 180
					}
				];

				let xAxisData = echartData.map(v => v.name);
				//  ["1", "2", "3", "4", "5", "6", "7", "8"]
				let yAxisData1 = echartData.map(v => v.value1);
				// [100, 138, 350, 173, 180, 150, 180, 230]
				let yAxisData2 = echartData.map(v => v.value2);
				// [233, 233, 200, 180, 199, 233, 210, 180]
				const hexToRgba = (hex, opacity) => {
					let rgbaColor = "";
					let reg = /^#[\da-f]{6}$/i;
					if (reg.test(hex)) {
						rgbaColor =
							`rgba(${parseInt("0x" + hex.slice(1, 3))},${parseInt(
					      "0x" + hex.slice(3, 5)
					    )},${parseInt("0x" + hex.slice(5, 7))},${opacity})`;
					}
					return rgbaColor;
				}

				option = {
					backgroundColor: bgColor,
					color: color,
					legend: {
						right: 10,
						top: 10
					},
					tooltip: {
						trigger: "axis",
						formatter: function(params) {
							let html = '';
							params.forEach(v => {
								console.log(v)
								html +=
									`<div style="color: #666;font-size: 14px;line-height: 24px">
					                <span style="display:inline-block;margin-right:5px;border-radius:10px;width:10px;height:10px;background-color:${color[v.componentIndex]};"></span>
					                ${v.seriesName}.${v.name}
					                <span style="color:${color[v.componentIndex]};font-weight:700;font-size: 18px">${v.value}</span>
					                万元`;
							})



							return html
						},
						extraCssText: 'background: #fff; border-radius: 0;box-shadow: 0 0 3px rgba(0, 0, 0, 0.2);color: #333;',
						axisPointer: {
							type: 'shadow',
							shadowStyle: {
								color: '#ffffff',
								shadowColor: 'rgba(225,225,225,1)',
								shadowBlur: 5
							}
						}
					},
					grid: {
						top: 100,
						containLabel: true
					},
					xAxis: [{
						type: "category",
						boundaryGap: false,
						axisLabel: {
							formatter: '{value}月',
							textStyle: {
								color: "#333"
							}
						},
						axisLine: {
							lineStyle: {
								color: "#D9D9D9"
							}
						},
						data: xAxisData
					}],
					yAxis: [{
						type: "value",
						name: '单位：万千瓦时',
						axisLabel: {
							textStyle: {
								color: "#666"
							}
						},
						nameTextStyle: {
							color: "#666",
							fontSize: 12,
							lineHeight: 40
						},
						splitLine: {
							lineStyle: {
								type: "dashed",
								color: "#E9E9E9"
							}
						},
						axisLine: {
							show: false
						},
						axisTick: {
							show: false
						}
					}],
					series: [{
						name: "2018",
						type: "line",
						smooth: true,
						// showSymbol: false,/
						symbolSize: 8,
						zlevel: 3,
						lineStyle: {
							normal: {
								color: color[0],
								shadowBlur: 3,
								shadowColor: hexToRgba(color[0], 0.5),
								shadowOffsetY: 8
							}
						},
						areaStyle: {
							normal: {
								color: new echarts.graphic.LinearGradient(
									0,
									0,
									0,
									1,
									[{
											offset: 0,
											color: hexToRgba(color[0], 0.3)
										},
										{
											offset: 1,
											color: hexToRgba(color[0], 0.1)
										}
									],
									false
								),
								shadowColor: hexToRgba(color[0], 0.1),
								shadowBlur: 10
							}
						},
						data: yAxisData1
					}, {
						name: "2019",
						type: "line",
						smooth: true,
						// showSymbol: false,
						symbolSize: 8,
						zlevel: 3,
						lineStyle: {
							normal: {
								color: color[1],
								shadowBlur: 3,
								shadowColor: hexToRgba(color[1], 0.5),
								shadowOffsetY: 8
							}
						},
						areaStyle: {
							normal: {
								color: new echarts.graphic.LinearGradient(
									0,
									0,
									0,
									1,
									[{
											offset: 0,
											color: hexToRgba(color[1], 0.3)
										},
										{
											offset: 1,
											color: hexToRgba(color[1], 0.1)
										}
									],
									false
								),
								shadowColor: hexToRgba(color[1], 0.1),
								shadowBlur: 10
							}
						},
						data: yAxisData2
					}]
				};

				echartsRecords.setOption(option);

				window.onresize = function() {
					echartsRecords.resize();
				}

			});
		</script>
	</body>
</html>
