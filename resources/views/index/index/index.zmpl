<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>文章 - Zig-say</title>
    <link rel="stylesheet icon" href="/static/webnav/img/favicon.ico" />
    
    @partial index/common/head
</head>

<body>
    @partial index/common/top_nav

    <div class="container topic">
        <div class="row">
            <div class="col-lg-9">
                <ol class="breadcrumb">
                    <li>
                        <a href="/">
                            <i class="fa fa-home" aria-hidden="true"></i> 首页
                        </a>
                    </li>
                    <li class="active">文章</li>
                </ol>
                
                <div class="topic-content">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            文章列表
                        </div>
                        <div class="panel-body">
                            <div class="art-page-items">
                                @for ($.topics) |topic| {
                                <div class="media art-page-item">
                                    <div class="media-body">
                                        <h4 class="media-heading">
                                            <a href="/topic/{{ topic.id }}">
                                                {{ topic.title }}
                                            </a>
                                        </h4>
                                        
                                        <p class="text-muted">
                                            <span class="art-author">
                                                <i class="fa fa-user" aria-hidden="true"></i>  
                                                {{ topic.username }}
                                            </span>
                                            <span class="art-datetime ml-3">
                                                <i class="fa fa-clock-o" aria-hidden="true"></i>  
                                                {{ topic.add_time }}
                                            </span>
                                        </p>
                                    </div>
                                </div>
                                }
                            </div>
                            
                            @if ($.pages > 1) 
                            <div class="art-page">
                                <nav aria-label="Page navigation">
                                    <ul class="pager">
                                        @if ($.page > 1 and $.pages > 1) 
                                            <li><a href="/?page={{ $.page - 1 }}">Previous</a></li>
                                        @else
                                            <li class="disabled"><a href="#">Previous</a></li>
                                        @end

                                        @if ($.page < $.pages and $.pages > 1) 
                                            <li><a href="/?page={{ $.page + 1 }}">Next</a></li>
                                        @else
                                            <li class="disabled"><a href="#">Next</a></li>
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
    
    @partial index/common/footer

    <script type="text/javascript">
    $(function() {
        $(".top-nav-item.top-nav-home").addClass("active");
    });
    </script>

</body>
</html>
