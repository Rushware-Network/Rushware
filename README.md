Rushware
===

基于 [OvercastCommunity/PGM](https://github.com/OvercastCommunity/PGM) 的 Minecraft Java 1.8.9 PGM 服务器开发项目。

- 玩法：使用 PGM 的地图、队伍、比赛目标与轮换系统。
- 战斗：原生 SportPaper 1.8 内核，保留 1.8 系列战斗机制。
- 开发：JDK 25、Gradle Wrapper，保留完整上游源码与历史。
- 准入：目标是严格验证 1.8.9，验证组件未完成前默认拒绝所有登录。

**协议号 47 不能区分 1.8 与 1.8.9。当前完成准入接口和拒绝逻辑，配套客户端/启动器验证留待后续开发。**

```powershell
.\scripts\Build.ps1
.\scripts\Setup-DevServer.ps1
# 阅读 EULA 后自行修改 runtime/eula.txt，再启动：
.\scripts\Start-DevServer.ps1
```

构建产物在 `build/libs/`，开发服在 `runtime/`（默认仅监听本机）。
详见 [开发与部署说明](docs/RUSHWARE.md)。

本地玩法验证可使用独立的 `server-package/` 文件夹，双击其中的 `Start.bat`。
打包命令为 `.\scripts\Package-LocalTestServer.ps1`，说明模板见 [本地开服验证](deployment/LOCAL_TEST_README.md)。
该包开启仅限回环地址的测试模式，可以用原版 1.8.9 测试 PGM，但无法区分其他 1.8.x 小版本。

目录：`core/`、`util/`、`platform/`、`server/` 为上游 PGM；`rushware-guard/` 为准入插件；
`deployment/` 保存配置模板和依赖基线；`scripts/` 保存 Windows 开发脚本。

保留上游 AGPL-3.0 许可证与 LICENSE_LINKING。下文为上游介绍，原文另存于 `docs/UPSTREAM_README.md`。

Upstream PGM
------------

The original PvP Game Manager for Minecraft.

Overview
--------

Back in 2011, a Minecraft map creator named dewtroid released a PvP map called [Airship Battle.](https://www.youtube.com/watch?v=3dLo8ytygWs) At the time, there were no comprehensive Bukkit plugins to manage PvP matches, so everything was done manually. Then, two young developers named [Apple](https://github.com/tonybruess) and [Anxuiz](https://github.com/anxuiz) came along and created the first version of "PGM" (also known as **P**vP **G**ame **M**anager) to automate the process of playing PvP matches. Later, they would establish the popular Minecraft server network, `Overcast Network` (also know as `oc.tc`). After the network went through a cycle of hyper-growth, stabilization, and eventual closure in 2016, its [plugins](https://github.com/OvercastNetwork/ProjectAres) were open sourced for the community to enjoy.

This project is an earlier fork of those plugins with three major changes:

1. Using [Minecraft 1.8](https://github.com/Electroid/SportPaper), the biggest ask by the community.
2. No backend, website, or API to make server hosting more cost effective.
3. No dependency injection to make contributing more accessible.

Documents
---------

1. [`LICENSE`](LICENSE) - any forks or modifications to this project must be kept public.
2. [`CODE_OF_CONDUCT`](docs/CODE_OF_CONDUCT.md) - guidelines that contributors and server owners must agree to.
3. [`RUNNING`](docs/RUNNING.md) - how to host and run a PGM server.
4. [`CONTRIBUTING`](docs/CONTRIBUTING.md) - how to build, compile, and submit changes to the project.


Governance
----------

The lead maintainer of this project is [Electroid](https://github.com/Electroid), a former administrator and software developer at [`oc.tc`](https://oc.tc/). As the project grows, we'll scale the governance model to meet those needs.
