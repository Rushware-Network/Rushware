# Rushware 权限规则

| 组 | 投票倍率 | 满队加入 | 自由选队 |
| --- | ---: | --- | --- |
| admin | 10 | 是 | 仅观察者管理时 |
| sponsor | 5 | 是 | 否 |
| supporter | 3 | 是 | 否 |
| default | 1 | 沿用普通玩家规则 | 沿用普通玩家规则 |

四组使用小写内部 ID。Admin 为 Aqua 加粗 `❑`（`&b&l`），Sponsor 为紫色加粗 `✳⁺⁺`（`&5&l`），Supporter 为粉色加粗 `✳`（`&d&l`）。
头衔结尾重置格式并留空格，保留玩家名字原有的队伍颜色。
每个特殊组只继承 default，避免赞助组之间的头衔叠加；投票取最高有效倍率，不相加。
PGM 上限配置为 10；票数仍遵循 PGM 原生规则，离线玩家的票按 1 计。
满队加入沿用 PGM 的人数上限、队伍平衡及现有 priority-kick 规则；不等于绕过最大硬上限。

Admin 可以警告、禁言/解除禁言、踢人、封禁/解封、冻结/解除冻结、查看背包和使用管理频道。
开始/结束比赛、切图、修改下一图和投票候选、调整队伍人数、调队、隐身和拆除 TNT 仅在观察者状态开放。
参赛时仍遵守 PGM 对导航和背包查看的限制；没有创造、刷物品、WorldEdit 编辑、脚本执行权限。
Admin 不能停服、重启/取消服务器重启、修改白名单、授予 OP、管理 LuckPerms、重载或修改玩法参数。
通过显式权限清单实现，不授予 `pgm.*`、`pgm.mod`、`pgm.premium` 或原版 OP。
不要把 `pgm.dev`、`pgm.mod` 或 `pgm.premium` 显式设为 false：LuckPerms 会把拒绝传递给这些父权限下的普通功能，包括 `pgm.join`、`pgm.leave` 和 `pgm.inventory`。不授予父权限即可；限制管理能力使用具体功能节点。
原版 OP 是独立的服务器所有者权限；要让已有 OP 玩家遵守 Admin 规则，需由所有者先取消其 OP。

`pgm.stop` 只管理比赛结束和比赛倒计时；服务器重启与取消重启单独要求 `pgm.restart`。
原有 PGM moderator/developer/OP 的重启功能保持可用。

基础处罚模块为 `RushwareModeration`，通过 PGM 的 PunishmentIntegration 对接禁言。
`warn/mute/unmute/freeze/unfreeze` 操作在线玩家；禁言与冻结持续到手动解除，记录保存在该插件运行配置中。
冻结期间禁止移动、交互、破坏、放置、攻击、发射投射物，并防止受到伤害。
`kick/ban/pardon` 使用服务器原生命令。所有自定义处罚命令还会在执行时检查权限。

## 安装与分配

`scripts/Prepare-PermissionGroups.ps1` 更新 PGM 分组和投票配置，备份已有配置，并准备导入文件。
服务器加载新 PGM 后，由控制台执行：

```text
lp export before-rushware-groups
lp import rushware-groups --replace
```

导入只替换文件中的四个权限组，不修改玩家或其他组；头衔独立由 PGM 配置显示。保存导出文件以便恢复。
为玩家分配组的控制台命令：

```text
lp user 玩家名 parent set admin
lp user 玩家名 parent set sponsor
lp user 玩家名 parent set supporter
lp user 玩家名 parent set default
```

`parent set` 会替换该玩家现有继承组；需要同时保留已有组时改用 `parent add`。
本次不自动给任何玩家分配 Admin 或赞助组。白名单和正版认证保持现有配置。
