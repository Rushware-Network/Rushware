# LuckPerms 开发集成

使用官方 Bukkit 版 LuckPerms 5.5.87，支持当前 SportPaper 1.8.8 服务端。
源码以 Git submodule 纳入 `vendor/luckperms`，固定到对应构建的提交
`5fc3d583c412854e050b1e4ba8aa5036d8daf982`，保留上游历史与 MIT 许可证。

克隆项目后运行 `git submodule update --init vendor/luckperms` 获取源码。
它是独立的上游 Gradle 工程，不合并进 PGM 构建。
官方 Bukkit 插件下载 URL、版本、源码提交和 SHA-256 均记录在 `deployment/dependencies.lock.json`。

`scripts/Install-LuckPerms.ps1` 安装到 `server-package`；`-ServerRoot runtime` 安装到开发服。
开发服初始化和开服包生成脚本也会安装它；启动脚本检查固定插件的哈希。
运行 JDK 仍为 25。首次启动生成 LuckPerms 默认配置和本地 H2 数据库，随后安装保留已有配置和数据。
这些数据库、插件二进制和运行配置不提交 Git。

当前不创建自定义组、不分配玩家、不设置头衔、不修改 PGM `groups` 配置。
LuckPerms 管理权限和组继承；目前 PGM 通过 `pgm.group.<组名>` 判定分组，
头衔由 PGM `groups` 的 prefix/suffix 显示，不会自动读取 LuckPerms 元数据。
后续讨论分组和头衔设计后再配置，或开发直接读取 LuckPerms 头衔的适配器。
当前权限节点方案不需要 Vault。原版 OP、正版认证及 Guard 白名单准入继续沿用现有配置。

官方说明：https://luckperms.net/wiki/Installation
