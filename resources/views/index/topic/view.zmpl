<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{{ $.topic.title }} - {{context.webname}}</title>
    <link rel="stylesheet icon" href="/static/webnav/img/favicon.ico" />
    
    @partial index/common/head

    <style>
    .topic-page-item {
        border-bottom: 1px solid #edeeef;
    }
    .topic-content-data {
        padding: 15px;
    }
    .topic-comment-content {
        padding: 5px 0 15px 0;;
    }
    </style>
</head>

<body>
    @partial index/common/top_nav($.loginid)
    
    <div class="container topic">
        <div class="row">
            <div class="col-lg-9">
                <ol class="breadcrumb">
                    <li>
                        <a href="/">
                            <i class="fa fa-home" aria-hidden="true"></i> 首页
                        </a>
                    </li>
                    <li class="active">话题详情</li>
                </ol>
                
                <div class="topic-content">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4>
                                {{ $.topic.title }}
                            </h4>
                            <div class="topic-meta text-muted">
                                <span class="topic-datetime">
                                    <i class="fa fa-clock-o" aria-hidden="true"></i>  
                                    {{ $.topic_time }}
                                </span>
                            
                                <span class="topic-author ml-3">
                                    <i class="fa fa-user" aria-hidden="true"></i>  
                                    {{ $.topic.username }}
                                </span>
                            </div>
                        </div>
                        <div class="panel-body topic-content-data">
                            {{ $.topic.content }}
                        </div>
                    </div>

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            评论列表({{ $.comment_count }})
                        </div>
                        <div class="panel-body">
                            <div class="topic-page-items">
                                @for ($.comments) |comment| {
                                <div class="media topic-page-item">
                                    <div class="media-body">
                                        <p class="text-muted">
                                            <span class="topic-author">
                                                <i class="fa fa-user" aria-hidden="true"></i>  
                                                {{ comment.username }}
                                            </span>
                                            <span class="topic-datetime ml-3">
                                                <i class="fa fa-clock-o" aria-hidden="true"></i>  
                                                {{ comment.add_time }}
                                            </span>
                                        </p>

                                        <div class="media-content topic-comment-content">
                                            {{ comment.content }}
                                        </div>
                                    </div>
                                </div>
                                }

                                @if ($.comment_count == 0)
                                    <div class="text-center">
                                        无数据
                                    </div>
                                @end
                            </div>
                        </div>
                    </div>

                    @if ($.comment_pages > 1)
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <div class="topic-page">
                                    <nav aria-label="Page navigation">
                                        <ul class="pager" style="margin:0;text-align:left;">
                                            @if ($.comment_page > 1 and $.comment_pages > 1)
                                                <li><a href="/topic/{{ $.topic.id }}?page={{ $.comment_page1 }}">上一页</a></li>
                                            @end

                                            @if (!($.comment_page > 1 and $.comment_pages > 1))
                                                <li class="disabled"><a href="#">上一页</a></li>
                                            @end

                                            @if ($.comment_page < $.comment_pages and $.comment_pages > 1)
                                                <li><a href="/topic/{{ $.topic.id }}?page={{ $.comment_page2 }}">下一页</a></li>
                                            @end

                                            @if (!($.comment_page < $.comment_pages and $.comment_pages > 1))
                                                <li class="disabled"><a href="#">下一页</a></li>
                                            @end
                                        </ul>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    @end

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            添加评论
                        </div>
                        <div class="panel-body">
                            <form action="" method="post" id="data-form" class="form-horizontal">
                                <div class="form-group">
                                    <label for="topic-comment-add" class="col-sm-2 text-right">评论内容</label>
                                    <div class="col-sm-10">
                                        <textarea class="form-control" id="topic-comment-add" name="content" rows="3"></textarea>
                                    </div>
                                </div>

                                <input type="hidden" name="topic_id" value="{{ $.topic.id }}" />

                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <button type="button" class="btn btn-primary px-5 py-2 js-save-btn">提交</button>
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
        $(".top-nav-item.top-nav-home").addClass("active");

        // 保存
        $(".js-save-btn").click(function(e) {
            e.stopPropagation;
            e.preventDefault;

            var data = $("#data-form").serialize();

            var url = '/topic/comment/add';
            $.post(url, data, function(data) {
                if (data.code == 0) {
                    layer.msg(data.msg);
                    
                    setTimeout(function() {
                        location.reload();
                    }, 1000);
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
