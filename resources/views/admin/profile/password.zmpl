<!DOCTYPE html>
<html>
    <head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <title>更改密码</title>
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
    </head>

    <body class="pear-container">
        <div class="layui-row">
            <div class="layui-card">
                <div class="layui-card-header">更改密码</div>
                <div class="layui-card-body">
                    <form class="layui-form" action="">
                        <div class="layui-form-item">
                            <label class="layui-form-label">旧密码</label>
                            <div class="layui-input-block">
                                <input type="password"  name="oldpassword" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入旧密码" class="layui-input">
                            </div>
                        </div>
        
                        <div class="layui-form-item">
                            <label class="layui-form-label">新密码</label>
                            <div class="layui-input-block">
                                <input type="password" name="newpassword" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入新密码" class="layui-input">
                            </div>
                        </div>
        
                        <div class="layui-form-item">
                            <label class="layui-form-label">确认新密码</label>
                            <div class="layui-input-block">
                                <input type="password" name="newpassword2" 
                                    lay-verify="title" autocomplete="off" 
                                    placeholder="请输入确认新密码" class="layui-input">
                            </div>
                        </div>
        
                        <div class="layui-form-item">
                            <label class="layui-form-label">&nbsp;</label>
                            <div class="layui-input-block">
                                <button type="submit" class="pear-btn pear-btn-primary pear-btn-sm" lay-submit="" lay-filter="user-save">
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
    
            form.on('submit(user-save)', function(data) {
                $.ajax({
                    url: "/admin/profile/password",
                    data: data.field,
                    dataType:'json',
                    type:'post',
                    success:function(result) {
                        if (result.code == 0) {
                            layer.msg(result.msg, {icon:1,time:1000}, function() {
                                location.reload();
                            });
                        } else {
                            layer.msg(result.msg, {icon:2,time:1000});
                        }
                    }
                })
                return false;
            });
        })
        </script>
    </body>
   
</html>