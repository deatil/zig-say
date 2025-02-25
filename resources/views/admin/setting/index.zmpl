<!DOCTYPE html>
<html>
    <head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <title>网站设置</title>
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
        <link rel="stylesheet" href="/static/admin/admin/css/other/person.css" />
    </head>

    <body class="pear-container">
        <div class="layui-row">
            <div class="layui-card">
                <div class="layui-card-header">网站设置</div>
                <div class="layui-card-body">
                    <form class="layui-form" action="">

                        <div class="layui-form-item">
                            <label class="layui-form-label">网站名称</label>
                            <div class="layui-input-block">
                                <input type="text" name="website_name" 
                                    value="{{ $.data.website_name }}" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入网站名称" class="layui-input">
                            </div>
                        </div>
                        <div class="layui-form-item">
                            <label class="layui-form-label">网站关键字</label>
                            <div class="layui-input-block">
                                <input type="text"  name="website_keywords" 
                                    value="{{ $.data.website_keywords }}" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入网站关键字" class="layui-input">
                            </div>
                        </div>
        
                        <div class="layui-form-item">
                            <label class="layui-form-label">网站描述</label>
                            <div class="layui-input-block">
                                <textarea name="website_description" placeholder="请输入网站描述" class="layui-textarea">{{ $.data.website_description }}</textarea>
                            </div>
                        </div>
        
                        <div class="layui-form-item">
                            <label class="layui-form-label">版权信息</label>
                            <div class="layui-input-block">
                                <input type="text" name="website_copyright" 
                                    value="{{ $.data.website_copyright }}" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入版权信息" class="layui-input">
                            </div>
                        </div>

                        <div class="layui-form-item">
                            <label class="layui-form-label">网站备案</label>
                            <div class="layui-input-block">
                                <input type="text" name="website_beian" 
                                    value="{{ $.data.website_beian }}" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入网站备案" class="layui-input">
                            </div>
                        </div>

                        <div class="layui-form-item">
                            <label class="layui-form-label">网站状态</label>
                            <div class="layui-input-block">
                                @if ($.data.website_status == "1") 
                                    <input type="radio" name="website_status" value="1" title="正常" checked>
                                    <input type="radio" name="website_status" value="0" title="关闭维护">
                                @else
                                    <input type="radio" name="website_status" value="1" title="正常">
                                    <input type="radio" name="website_status" value="0" title="关闭维护" checked>
                                @end
                            </div>
                        </div>

                        <div class="layui-form-item">
                            <label class="layui-form-label">&nbsp;</label>
                            <div class="layui-input-block">
                                <button type="submit" class="pear-btn pear-btn-primary pear-btn-sm" lay-submit="" lay-filter="setting-save">
                                    <i class="layui-icon layui-icon-ok"></i>
                                    提交
                                </button>
                                <button type="reset" class="pear-btn pear-btn-sm">
                                    <i class="layui-icon layui-icon-refresh"></i>
                                    重置
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

		<script src="/static/admin/component/layui/layui.js"></script>
		<script src="/static/admin/component/pear/pear.js"></script>
        <script>
        layui.use(['form','jquery'],function(){
            let form = layui.form;
            let $ = layui.jquery;

            form.on('submit(setting-save)', function(data) {
                $.ajax({
                    url: "/admin/setting",
                    data: data.field,
                    dataType: 'json',
                    type: 'post',
                    success: function(result) {
                        if (result.code == 0) {
                            layer.msg(result.msg, {icon:1,time:1000}, function() {
                                location.reload();
                            });
                        } else {
                            layer.msg(result.msg, {icon:2,time:1000});
                        }
                    }
                });

                return false;
            });
        })
        </script>
    </body>
</html>
