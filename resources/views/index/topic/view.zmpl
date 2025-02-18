<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <title>{{ $.topic.title }}</title>
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
                    <li class="active">文章详情</li>
                </ol>
                
                <div class="topic-content">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4>
                                {{ $.topic.title }}
                            </h4>
                            <div class="art-meta text-muted">
                                <span class="art-author">
                                    <i class="fa fa-user" aria-hidden="true"></i>  
                                    {{ $.topic.username }}
                                </span>
                                <span class="art-datetime ml-3">
                                    <i class="fa fa-clock-o" aria-hidden="true"></i>  
                                    {{ $.topic_time }}
                                </span>
                            </div>
                        </div>
                        <div class="panel-body">
                            {{ $.topic.content }}
                        </div>
                    </div>

                    <div class="panel panel-default">
                        <div class="panel-heading">
                            文章列表
                        </div>
                        <div class="panel-body">
                            <div class="art-page-items">
                                @for ($.comments) |comment| {
                                <div class="media art-page-item">
                                    <div class="media-body">
                                        <div class="media-heading">
                                            {{ comment.content }}
                                        </div>
                                        
                                        <p class="text-muted">
                                            <span class="art-author">
                                                <i class="fa fa-user" aria-hidden="true"></i>  
                                                {{ comment.username }}
                                            </span>
                                            <span class="art-datetime ml-3">
                                                <i class="fa fa-clock-o" aria-hidden="true"></i>  
                                                {{ comment.add_time }}
                                            </span>
                                        </p>
                                    </div>
                                </div>
                                }
                            </div>
                            
                            <div class="art-page">
                                <nav aria-label="Page navigation">
                                    <ul class="pager">
                                        @if ($.comment_page > 1 and $.comment_pages > 1) 
                                            <li><a href="/?page={{ $.comment_page - 1 }}">Previous</a></li>
                                        @else
                                            <li class="disabled"><a href="#">Previous</a></li>
                                        @end

                                        @if ($.comment_page < $.comment_pages and $.comment_pages > 1) 
                                            <li><a href="/?page={{ $.comment_page + 1 }}">Next</a></li>
                                        @else
                                            <li class="disabled"><a href="#">Next</a></li>
                                        @end
                                    </ul>
                                </nav>
                            </div>
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
