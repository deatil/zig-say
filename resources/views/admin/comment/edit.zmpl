<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>更改信息</title>
		<link rel="stylesheet" href="/static/admin/component/pear/css/pear.css" />
    </head>
    <body>
    <form class="layui-form" action="">
        <div class="mainBox">
            <div class="main-container">
                <div class="main-container">
                    <div class="layui-form-item">
                        <label class="layui-form-label">topic_id</label>
                        <div class="layui-input-block">
                            <input type="text" disabled="disabled" value="{{ $.data.topic_id }}" 
                                autocomplete="off" placeholder="" class="layui-input">
                        </div>
                    </div>
    
                    <div class="layui-form-item">
                        <label class="layui-form-label">content</label>
                        <div class="layui-input-block">
                            <textarea name="content" placeholder="" class="layui-textarea">{{ $.data.content }}</textarea>
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <label class="layui-form-label">状态</label>
                        <div class="layui-input-block">
                            @if ($.data.status == 1)
                                <input type="radio" name="status" value="1" title="启用" checked>
                                <input type="radio" name="status" value="0" title="禁用">
                            @else
                                <input type="radio" name="status" value="1" title="启用">
                                <input type="radio" name="status" value="0" title="禁用" checked>
                            @end
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="bottom">
            <div class="button-container">
                <button type="submit" class="pear-btn pear-btn-primary pear-btn-sm" lay-submit="" lay-filter="comment-save">
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

        form.on('submit(comment-save)', function(data) {
            $.ajax({
                url: "/admin/comment/edit?id={{ $.data.id }}",
                data: data.field,
                dataType: 'json',
                type: 'post',
                success: function(result) {
                    if (result.code == 0) {
                        layer.msg(result.msg, {icon:1,time:1000}, function() {
                            parent.layer.close(parent.layer.getFrameIndex(window.name));//关闭当前页
                            parent.layui.table.reload("comment-table");
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
