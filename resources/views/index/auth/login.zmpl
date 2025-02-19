<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title>账号登录 - {{context.webname}}</title>
    <link rel="shortcut icon" href="/static/topic/img/favicon.ico">
    <link rel="stylesheet" type="text/css" href="/static/topic/js/bootstrap/bootstrap.css">
    <style>
    .main {
        max-width: 400px;
        min-width: 280px;
        margin: 60px auto 20px;
        overflow: hidden;
        border-radius: 3px 3px 0 0;
        background-clip: padding-box;
    }
    @media only screen and (max-width: 767px) {
        .main {
            margin-top: 20px;
            max-width: 95% !important;
        }
    }
    .login-msg {
        padding: 16px 0;
        font-size: 16px;
    }
    .login-btn {
        margin-bottom: 20px;
    }
    </style>
</head>

<body>
    <div class="main clearfix">
        <form action="" method="post">
            <div class="panel panel-default">
                <div class="panel-heading text-center">
                   <a href="/" title="Zig-say">
                    <img src="/static/topic/img/logo.png" alt="Zig-say" style="width: 50px;">
                   </a>
                </div>
                <div class="panel-body">
                   <h5 class="text-center login-msg">
                        账号登录
                    </h5>

                    <div class="text-center login-btn">
                        <a href="javascript:void(0);"
                            class="btn btn-primary js-login-btn"
                            lay-submit lay-filter="login"
                            style="width: 185px; padding: 13px 0; border-radius:3px"
                        >
                            账号登录
                        </a>
                    </div>
                </div>
            </div>

        </form>
    </div>
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
                var url = "/auth/login";

                /// 动画
                button.load({
                    elem: '.login',
                    time: 1500,
                    done: function() {
                        $.post(url, {}, function(data) {
                            if (data.code == 0) {
                                popup.success("登录成功", function() {
                                    location.href = "/";
                                });
                            } else {
                                layer.msg(data.msg, { 
                                    offset: '15px',
                                    icon: 5 
                                });
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
