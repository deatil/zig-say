<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>添加Topic</title>
    <link rel="stylesheet icon" href="/static/topic/img/favicon.ico" />
    <link rel="stylesheet" type="text/css" href="/static/topic/js/bootstrap/bootstrap.css">
    <link href="/static/topic/css/top.css" rel="stylesheet" type="text/css">
</head>

<body>
    @partial index/common/top_nav
    
    <div class="container zone">
        <div class="row">
            <div class="col-lg-9">
                <ol class="breadcrumb">
                    <li><a href="/">首页</a></li>
                    <li class="active">添加Topic</li>
                </ol>
                
                <div class="zone-content">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            添加Topic
                        </div>
                        <div class="panel-body">
                            <form action="" method="post" id="data-form" class="form-horizontal">
                                <div class="form-group">
                                    <label for="link-title" class="col-sm-2 control-label">Title</label>
                                    <div class="col-sm-10">
                                        <input type="text" name="title" value="" class="form-control" id="topic-title" placeholder="">
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="topic-image" class="col-sm-2 control-label">content</label>
                                    <div class="col-sm-10">
                                        <textarea class="form-control" name="content" rows="3"></textarea>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <button type="button" class="btn btn-primary js-save-btn">提交</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-3">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        Create Topic
                    </div>
                    <div class="panel-body">
                        <ul class="nav nav-pills nav-stacked">
                            <li role="presentation" class="link-all">
                                <a href="/topic/create">Create</a>
                            </li>
                        </ul>
                    </div>
                </div>

            </div>
            
        </div>
    </div>
    
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
