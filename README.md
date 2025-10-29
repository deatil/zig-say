## zig-say 匿名社区

`zig-say` 是使用 `httpz`, `myzql` 及 `zmpl` 的 `zig` 博客系统


### 项目介绍

*  使用 `zig` 开发的简易匿名社区系统
*  核心使用 `httpz`, `myzql` 及 `zmpl` 等开发匿名社区系统
*  系统后台使用 `pear-admin` 后端模板，非前后端分离项目


### 环境要求

 - zig >= 0.15.1
 - Myzql


### 截图预览

<table>
    <tr>
        <td width="50%">
            <center>
                <img alt="登录" src="https://github.com/user-attachments/assets/46fe50bf-2311-4457-8332-6ff23f3bd374" />
            </center>
        </td>
        <td width="50%">
            <center>
                <img alt="控制台" src="https://github.com/user-attachments/assets/4f1993a9-9824-4bd4-9aab-c1c12565caac" />
            </center>
        </td>
    </tr>
    <tr>
        <td width="50%">
            <center>
                <img alt="话题管理" src="https://github.com/user-attachments/assets/80a64ec3-9cf5-46ca-8127-11f9c17c02a2" />
            </center>
        </td>
        <td width="50%">
            <center>
                <img alt="账号管理" src="https://github.com/user-attachments/assets/5a7f3caa-42ec-4287-be36-fb7ffc53f999" />
            </center>
        </td>
    </tr>
</table>

更多截图
[zig-say 截图](https://github.com/deatil/zig-say/issues/1)


### 安装及开发步骤

1. 首先克隆项目到本地

```
git clone https://github.com/deatil/zig-say.git
```

2. 然后配置数据库等信息

```
/src/utils/config.zig
```

3. 最后导入 sql 数据到数据库

```
/docs/zig_say.sql
```

4. 运行测试

```rust
zig build run
```

6. 后台登录账号及密码：`admin` / `123456`, 后台登录地址: `/admin/index`


### 特别鸣谢

感谢以下的项目,排名不分先后

 - [httpz](https://github.com/karlseguin/http.zig)

 - [myzql](https://github.com/speed2exe/myzql)
 
 - [zmpl](https://github.com/jetzig-framework/zmpl)


### 开源协议

*  `zig-say` 遵循 `Apache2` 开源协议发布，在保留本系统版权的情况下提供个人及商业免费使用。


### 版权

*  该系统所属版权归 deatil(https://github.com/deatil) 所有。
