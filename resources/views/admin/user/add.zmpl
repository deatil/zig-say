<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>添加用户</title>
    <link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
</head>
<body>
<form class="layui-form" action="">
    <div class="mainBox">
        <div class="main-container">
            <div class="main-container">
                <div class="layui-form-item">
                    <label class="layui-form-label">账号</label>
                    <div class="layui-input-block">
                        <input type="text" name="cookie" 
                            lay-verify="title" autocomplete="off" placeholder="请输入账号" class="layui-input">
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="bottom">
        <div class="button-container">
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

<script src="/static/admin/component/layui/layui.js"></script>
<script src="/static/admin/component/pear/pear.js"></script>
<script>
layui.use(['form','jquery'],function(){
    let form = layui.form;
    let $ = layui.jquery;

    form.on('submit(user-save)', function(data){

        $.ajax({
            url: "/admin/user/add",
            data: data.field,
            dataType:'json',
            type:'post',
            success:function(result) {
                if (result.code == 0) {
                    layer.msg(result.msg, {icon:1,time:1000}, function() {
                        parent.layer.close(parent.layer.getFrameIndex(window.name));//关闭当前页
                        parent.layui.table.reload("user-table");
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
<script>
</script>
</body>
</html>