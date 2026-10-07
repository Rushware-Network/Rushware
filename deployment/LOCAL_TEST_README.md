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
若已导入 PublicMaps，另有 KOTF 21、FFA 51、KOTH 63、TDM 62 份地图配置（共 197 份，另含变体）。
当前轮换与投票池为 196 张，排除了最初示例地图的名称（PublicMaps 的同名 Harb 也排除）。
Airship Battle、Harb、Race for Victory、The Fenland、Warlock 不再参与轮换或投票。
这些地图位于 `maps/PublicMaps/`；请保留各地图的 LICENSE.txt / NOTICE.txt。
比赛结束 5 秒后提供最多 5 张投票候选地图；点击投票书选择，或使用 `/votenext 地图名`。
`/votebook` 可以重新打开投票书。YAML 设置切图倒计时 20 秒：剩余 15 秒开启投票书，剩余 5 秒结算、揭示并预载下一张地图。原版 PGM 的预载可能在加载完成后提前转场，单靠 YAML 无法保证严格到 0 秒才切图；PGM 代码保持原样。
当前部署图池包含 196 张 PublicMaps、24 张 CommunityMaps touchdown 和 155 张兼容 1.8 的 arcade 地图，共 375 张。arcade 的 MMB: Anthill、Random Items 和 Survive or Die: Oracle 要求 1.21，未加入投票；Santa's Express Delivery 需要 `experiments.payload: true`。
管理员可用 `/pools` 检查 `publicmaps` 投票池，或用 `/pool` 查看池中的地图。
PGM 与 RushwareGuard 的许可证见 `licenses/`；源码版本记录在 `BUILD.txt`。
源码项目来源：https://github.com/OvercastCommunity/PGM （本地 Rushware 修改源码在开发项目中）。
