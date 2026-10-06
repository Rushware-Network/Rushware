# Rushware 本地开服验证包

这个文件夹可以单独复制使用，不依赖开发项目的源码或 Gradle。电脑需安装 JDK 25，设置 `JAVA_HOME` 或 `RUSHWARE_JAVA_HOME`。

1. 阅读 https://aka.ms/MinecraftEULA ，同意后自行将 `eula.txt` 的 `eula=false` 改为 `eula=true`。
2. 双击 `Start.bat`，等控制台出现 `Done`，并确认 PGM 和 RushwareGuard 都成功启用。
3. 使用 **Minecraft Java 1.8.9 正版账号**连接 `127.0.0.1:25565`（服务器与客户端在同一电脑）。
4. 控制台输入 `op 你的游戏名`（不加斜杠）。游戏内用 `/join` 加入、`/start` 开始比赛、`/cycle` 切换地图。
5. 控制台输入 `stop` 正常停服。

## RushwareGuard 的作用

它负责登录准入，检查原生 SportPaper、PGM 是否启用、正版认证是否开启，拒绝跨版本转换插件。
严格模式要求协议 47 和可信 1.8.9 验证结果；配套验证组件还没实现，因此严格模式目前拒绝所有玩家。

**这个包专供本地玩法验证**：`plugins/RushwareGuard/config.yml` 中 `local-test: true`。
仅当监听地址为回环地址且玩家来自本机时，允许协议 47 客户端进入。
这意味着其他 1.8.x 小版本也可能进入，不能称为严格 1.8.9 验证。
主开发项目的默认配置仍为严格模式；不要将本测试配置用于公网部署。
改成 `local-test: false` 并重启即可恢复严格模式，此时 1.8.9 也会被拒绝，直到实现可信验证组件。

自带 PGMDev 的 5 张经典示例地图。地图作者保留权利，详见 `maps/README.md`。
PGM 与 RushwareGuard 的许可证见 `licenses/`；源码版本记录在 `BUILD.txt`。
源码项目来源：https://github.com/OvercastCommunity/PGM （本地 Rushware 修改源码在开发项目中）。
