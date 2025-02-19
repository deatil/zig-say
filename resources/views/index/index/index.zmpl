<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{{context.webname}}</title>
    <link rel="stylesheet icon" href="/static/webnav/img/favicon.ico" />
    
    @partial index/common/head

    <style>
    .topic-page-item {
        border-bottom: 1px solid #edeeef;
    }
    </style>
</head>

<body>
    @partial index/common/top_nav($.loginid)

    <div class="container topic">
        <div class="row">
            <div class="col-lg-9">
                <div class="topic-content">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            最新话题
                        </div>
                        <div class="panel-body">
                            <div class="topic-page-items">
                                @for ($.topics) |topic| {
                                <div class="media topic-page-item">
                                    <div class="media-body">
                                        <h4 class="media-heading">
                                            <a href="/topic/{{ topic.id }}">
                                                {{ topic.title }}
                                            </a>
                                        </h4>
                                        
                                        <p class="text-muted">
                                            <span class="topic-datetime">
                                                <i class="fa fa-clock-o" aria-hidden="true"></i>  
                                                {{ topic.add_time }}
                                            </span>

                                            <span class="topic-author ml-3">
                                                <i class="fa fa-user" aria-hidden="true"></i>  
                                                {{ topic.username }}
                                            </span>
                                        </p>
                                    </div>
                                </div>
                                }
                            </div>
                            
                            @if ($.pages > 1) 
                            <div class="topic-page">
                                <nav aria-label="Page navigation">
                                    <ul class="pager">
                                        @if ($.page > 1 and $.pages > 1) 
                                            <li><a href="/?page={{ $.comment_page1 }}">上一页</a></li>
                                        @end

                                        @if (!($.page > 1 and $.pages > 1))
                                            <li class="disabled"><a href="#">上一页</a></li>
                                        @end

                                        @if ($.page < $.pages and $.pages > 1) 
                                            <li><a href="/?page={{ $.comment_page2 }}">下一页</a></li>
                                        @end
                                        
                                        @if (!($.page < $.pages and $.pages > 1))
                                            <li class="disabled"><a href="#">下一页</a></li>
                                        @end
                                    </ul>
                                </nav>
                            </div>
                            @end
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

    <script type="text/javascript">
    $(function() {
        $(".top-nav-item.top-nav-home").addClass("active");
    });
    </script>

</body>
</html>
