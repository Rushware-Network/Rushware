# WorldEdit 开发集成

WorldEdit 源码通过 `vendor/worldedit` Git submodule 固定到官方 6.1.9 发布包中的提交 `caf0ad9417d719ded2ef122dadeaebc00a03003d`。保留完整上游历史与 GPL 许可证。
克隆 Rushware 后运行 `git submodule update --init vendor/worldedit` 获取源码。

PGM 的 Teleport compass 是物品 345，依赖 WorldEdit 导航工具的事件处理：
`worldedit-core/src/main/java/com/sk89q/worldedit/extension/platform/PlatformManager.java`。
左键使用 `worldedit.navigation.jumpto.tool`，右键使用 `worldedit.navigation.thru.tool`。
PGM 原有权限配置向观察者授予导航权限，向参赛者撤销这两个权限；无需授予普通玩家 WorldEdit 编辑权限。
WorldEdit 配置模板使用指南针导航，并把编辑魔杖设为兔子脚（414），与 PGM 保持一致。

运行 `scripts/Install-WorldEdit.ps1` 安装固定 SHA-256 的官方插件到开服包。
`Setup-DevServer.ps1` 和 `Package-LocalTestServer.ps1` 也会安装它。
启动脚本检查插件哈希；WorldEdit 不修改登录协议，不影响 RushwareGuard 准入。

服务器和 Rushware 构建继续使用 JDK 25。submodule 保留了上游旧 Gradle 构建文件，
它不是 Rushware 的 Gradle 子项目；当前安装流程使用已发布插件，不把旧构建描述成 JDK 25 可直接构建。
修改源码后需另行迁移上游旧构建并验证产物；固定发布包的启动校验不会直接接受自编译插件。

版本依据：https://pgm.dev/docs/guides/preparing/local-server-setup

# Touchdown 地图

`scripts/Import-TouchdownMaps.ps1` 固定 CommunityMaps 提交，导入 24 张 touchdown 地图及许可证到
`maps/CommunityMaps/touchdown`。现有 PublicMaps includes 提供其共享规则。
地图追加到现有 `publicmaps` voted 池，总计 220 张基础地图；比赛结束的选图书会从该池产生候选。
`/votebook` 显示当轮最多 5 张候选，并非一次展示全部 220 张。
地图保留原始开发阶段标签，沿用现有 `enforce-dev-phase: false`。
导入脚本保留旧地图排除规则、投票设置和运行配置，并在 `.backups` 保存修改前的配置。
