<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>添加话题 - {{context.webname}}</title>
    <link rel="stylesheet icon" href="/static/topic/img/favicon.ico" />

    @partial index/common/head
</head>

<body>
    @partial index/common/top_nav($.loginid)
    
    <div class="container topic">
        <div class="row">
            <div class="col-lg-9">
                <ol class="breadcrumb">
                    <li><a href="/">首页</a></li>
                    <li class="active">添加话题</li>
                </ol>
                
                <div class="topic-content">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            添加话题
                        </div>
                        <div class="panel-body">
                            <form action="" method="post" id="data-form">
                                <div class="form-group">
                                    <label for="link-title">标题</label>
                                    <div>
                                        <input type="text" name="title" value="" class="form-control" id="topic-title" placeholder="">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="topic-content">内容</label>
                                    <div>
                                        <textarea class="form-control" id="topic-content" name="content" rows="5"></textarea>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <button type="button" class="btn btn-primary px-5 py-2 js-save-btn">提交</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-3">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        快捷操作
                    </div>
                    <div class="panel-body text-center">
                        <a href="/topic/create"
                            class="btn btn-primary"
                            style="width: 185px; padding: 13px 0; border-radius:3px"
                        >
                            创建话题
                        </a>
                    </div>
                </div>

            </div>
            
        </div>
    </div>

    @partial index/common/footer
    
    <script type="text/javascript" src="/static/topic/js/jquery.min.js"></script>
    <script type="text/javascript" src="/static/topic/js/layer/layer.js"></script>
    <script type="text/javascript">
    $(function() {
        // 保存
        $(".js-save-btn").click(function(e) {
            e.stopPropagation;
            e.preventDefault;

            var data = $("#data-form").serialize();

            var url = '/topic/create';
            $.post(url, data, function(data) {
                if (data.code == 0) {
                    layer.msg(data.msg);
                    
                    setTimeout(function() {
                        location.href = "/";
                    }, 1500);
                } else {
                    layer.msg(data.msg);
                }
            }).fail(function (xhr, status, info) {
                layer.msg("请求失败");
            });
        });
    });
    </script>

</body>
</html>
