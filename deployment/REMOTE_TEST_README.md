# Rushware 远程测试

用户已选择临时开放协议 47 的 Minecraft Java 1.8.x 测试，无法区分 1.8 与 1.8.9。

开服包 `plugins/RushwareGuard/config.yml` 设置：

```yaml
local-test: false
remote-test: true
```

`server.properties` 设置 `online-mode=true`、`white-list=true`、`server-ip=`（留空）。
远程模式只有在正版认证开启、白名单开启且玩家明确列入白名单时才允许协议 47 登录；OP 也必须列入白名单。
控制台用 `whitelist add 玩家名` 添加正版玩家，使用 `whitelist list` 查看名单。
本次开服包已添加日志中的 `username3123`，不是输入命令中的 `username3132`。

更新后重启服务器。如果使用另一台电脑上的开服包，请同步新的
`plugins/RushwareGuard.jar`、`plugins/RushwareGuard/config.yml`、`server.properties` 和白名单设置。
首次启动仍须自行接受 EULA；通过 `Start.bat` 使用 JDK 25 启动。

恢复严格验证时关闭 `remote-test` 和 `local-test`；可信客户端验证尚未实现，严格模式将拒绝登录。
