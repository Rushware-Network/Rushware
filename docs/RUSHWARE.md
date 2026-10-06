# Rushware 开发与部署

## 范围与版本

玩法直接使用 PGM 的队伍、地图轮换和胜利目标模块（如 CTW、DTM、DTC、TDM）。
采用原生 SportPaper 1.8.8 内核，保留 1.8 系列战斗规则，不使用新版服务端模拟旧版战斗。
Minecraft Java 1.8.9 客户端可以连接这一内核；“内核 1.8.8”并不表示要求玩家使用 1.8.8。
当前 PGM 源码需要 JDK 25 和 Gradle 9.8.0。依赖基线见 `deployment/dependencies.lock.json`。

## 严格 1.8.9 准入：当前仍处于开发阶段

Java 1.8 至 1.8.9 共用协议号 47。握手不能区分这些小版本。
MC|Brand、Forge 声明、客户端自行上报的版本均不能作为可信验证。
因此 RushwareGuard 同时要求协议 47 和可信验证结果 `1.8.9`。
**当前没有验证提供者，所有玩家（包括原版 1.8.9）都会被拒绝登录。**
这属于初始化阶段的封闭准入骨架，不代表已经实现可用的客户端验证系统。

后续组件通过 Bukkit ServicesManager 注册 `ClientVersionVerifier`。
实现应在登录前完成验证，登录事件中只消费结果；证明需绑定正版认证 UUID、连接和短时单次会话，
拒绝重放、缺失、超时、其他版本及验证异常。接口不能进行阻塞网络请求。
配套启动器需要明确威胁模型：签名凭证可证明发行方授权的会话，但无法天然证明恶意用户没有修改客户端。
不能把伪造一个版本字符串当作严格识别。该客户端/验证服务是后续开发工作。

### 独立本地验证包

根据用户的本地开服验证需求，新增 `.\scripts\Package-LocalTestServer.ps1`，
在 `server-package/` 创建完整开服目录：内核、两个插件、5 张示例地图、配置、许可证和启动文件。
不依赖源码或 Gradle；电脑需要 JDK 25。这个文件夹及运行数据不进入 Git。
打包脚本拒绝覆盖已存在的包，避免覆盖玩家数据；重新打包前先自行将旧目录改名保留。

该包明确启用 `local-test: true`；主项目的 Guard 默认仍为 `false`。
只有服务端监听 `127.0.0.1` / `::1` 且连接来自回环地址时，测试模式才接受协议 47。
公网监听、其他地址、其他协议不会通过测试模式，仍需严格验证。
使用 1.8.9 正版账号连接 `127.0.0.1:25565` 进行玩法验证；其他 1.8.x 也可能被接受。
详细步骤见 `server-package/README.md`。EULA 仍由用户自行阅读和接受。

### PublicMaps 与结束后投票

当前包导入了 OvercastCommunity/PublicMaps 的 KOTF 21、FFA 51、KOTH 63、TDM 62 份地图配置，
共 197 份。源码版本为 `0d9ed9ccf57343e683a05c0b9a0c8a476460705f`，地图复制在 `server-package/maps/PublicMaps/`，
共享 includes 在 `server-package/plugins/PGM/includes/`；保留各地图的许可证和通知文件。
原有 5 张示例地图保留，但自动轮换的 `publicmaps` 池仅选用这四类地图。

`map.pools` 指向 `map-pools.yml`，池类型为 `voted`，比赛结束 5 秒后提供最多 5 个候选项。
切图倒计时 35 秒，预载提前 5 秒决定下一张地图。投票采用 PGM 内置的最高票选择机制。
玩家点击投票书，或用 `/votenext 地图名`；`/votebook` 重新打开书。

配置模板见 `deployment/publicmaps-map-pools.yml`。
复现时将锁文件对应的 PublicMaps 版本以稀疏检出下载到 `.local/PublicMaps`，
检出 `includes kotf ffa koth tdm` 后运行 `scripts/Import-PublicMaps.ps1`。
该脚本拒绝覆盖已有地图，修改配置前创建备份，并记录 `PUBLICMAPS.json`。
打包脚本在 `.local/PublicMaps/kotf` 存在时自动导入这些地图。

验证：独立 SportPaper 实例成功加载 269 张地图（含变体与 5 张示例地图），
`publicmaps` 池解析出 197 张，实际结束比赛后生成 5 项投票，正常切换到下一张地图。

Guard 还检查正版认证、SportPaper 内核、PGM 是否启用，并拒绝安装 ViaVersion、ViaBackwards、ViaRewind、ProtocolSupport。
启动脚本仅允许 PGM 和 RushwareGuard 两个插件；接入验证插件时需审查并扩展该名单。
PGM 声明依赖 Guard。部署时必须使用启动脚本并检查插件加载日志；Guard 加载失败时禁止开放服务器。

## Windows 开发流程

```powershell
# JAVA_HOME 已指向 JDK 25 时，无需额外设置。
# 可选：$env:RUSHWARE_JAVA_HOME = '你的 JDK 25 安装目录'
.\scripts\Build.ps1
.\scripts\Setup-DevServer.ps1
```

产物：`build/libs/PGM.jar`、`build/libs/RushwareGuard.jar`。
Setup 下载带 SHA-256 校验的固定 SportPaper，检出固定版本 PGMDev/Maps，安装插件和配置。
地图保留各自许可证与作者信息。`runtime/` 只存本地数据，不进入 Git。
示例地图不适用 PGM 的 AGPL 许可证，作者保留权利，详见 `runtime/maps/README.md`；不要据此假设可任意再发行。
脚本保留已有配置，后续修改模板不会自动覆盖它们；更新插件前先停止服务器。
阅读 Minecraft EULA 后自行将 `runtime/eula.txt` 改为 `eula=true`，再运行：

```powershell
.\scripts\Start-DevServer.ps1
```

默认监听 `127.0.0.1:25565`，正版认证开启，RCON 关闭。初始化不会开放公网或自动启动服务器。
PGM 配置在 `runtime/plugins/PGM/config.yml`，地图库在 `runtime/maps/`。
完成验证组件后可用 `/join`、`/start`、`/cycle` 调试比赛（管理命令需要相应权限）。

## Git 工作流

`main` 是本项目开发分支；`upstream/occ` 是来源，`rushware/upstream-base` 标记初始化基线。
保留完整历史，无 `origin`，避免误推到上游。创建自己的远程仓库后再添加 `origin`。
功能开发使用 `feature/<name>`，修复用 `fix/<name>`。合并前运行构建，保持工作区干净。
拉取上游更新：`git fetch upstream`，在独立分支审查并合并 `upstream/occ`。
不要移动基线标签；更新锁文件与构建记录应作为明确提交。
格式检查直接使用该标签对应的固定提交 SHA，不依赖远程仓库是否发布了标签。
保留 AGPL-3.0 和 LICENSE_LINKING，发布或运营修改版时按许可证提供对应源码。

## 初始化验证（2026-10-06）

- JDK 25 / Gradle 9.8.0 完整构建通过，204 项测试通过（其中 2 项为准入策略测试）。
- Windows wrapper 和 PowerShell 脚本语法验证通过；本地开发服依赖、示例地图和插件已准备。
- SportPaper SHA-256 与地图提交校验通过；启动脚本在 EULA 未接受时正确拒绝启动。
- 尚未执行真实服务端启动、玩家接入和战斗验收；EULA 未接受，可信客户端验证仍待开发。
- 锁文件固定的是源码与运行依赖基线；上游仍有 SNAPSHOT/动态构建依赖，不代表完整依赖树已锁定。

## 核验来源

- [指定 PGM 上游](https://github.com/OvercastCommunity/PGM)
- [PGM 官方服务端配置指南](https://pgm.dev/docs/guides/preparing/local-server-setup)
- [协议版本数据](https://github.com/PrismarineJS/minecraft-data/blob/master/data/pc/common/protocolVersions.json)
