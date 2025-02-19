@args loginid: ZmplValue
<div class="container top-nav">
    <div class="row">
        <div class="col-lg-12">
            <nav class="navbar navbar-default">
              <div class="container-fluid">
                <div class="navbar-header">
                  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                  </button>
                  <a class="navbar-brand" href="/">
                    <img alt="{{context.webname}}" width="20" height="20" src="/static/topic/img/logo.png">
                  </a>
                  
                </div>

                <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                  <p class="navbar-text">{{context.webname}}</p>

                  <ul class="nav navbar-nav navbar-right">
                      @zig {
                        const login_id = loginid.toString() catch "";
                        if (login_id.len > 0) {
                          <li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">{{ login_id }} <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                              <li><a href="/auth/logout">退出登录</a></li>
                            </ul>
                          </li>
                        } else {
                          <li>
                              <a href="/auth/login">
                                  <i class="fa fa-user" aria-hidden="true"></i> 登录
                              </a>
                          </li>
                        }
                      }

                  </ul>
                </div>
              </div>
            </nav>

        </div>
    </div>
</div>
