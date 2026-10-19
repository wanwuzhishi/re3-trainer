# RE3 单机修改器 (RE3 Trainer)

REFramework Lua 版单机修改器，适用于《生化危机3 重制版 / Resident Evil 3 (2020)》Steam 版。
免编译，把一个 Lua 文件放进 `reframework/autorun/` 即可使用。

> ⚠ 仅供单机离线娱乐。请勿用于联机、排行榜、速通认证等场景。

> 项目介绍与使用说明：[万物之时博客 · RE3 单机修改器](https://blog.126330.xyz/posts/9cbc7098/)  
> 博客主页：<https://blog.126330.xyz>

## 功能一览

| 功能 | 说明 |
|---|---|
| 无敌 | 受到攻击不掉血，生命维持在正常上限 |
| 一击必杀 | 敌人受伤直接放大到 99999（可随时开关） |
| 无限弹药 | 弹匣保持高数量，通常无需装填 |
| 无限物品 | 药草/手雷/弹药盒等消耗品保持 99，剧情道具不受影响 |
| 小刀耐久检测 | 目前只收集数据，不修改游戏 |
| 完美闪避 | 随时具备紧急闪避判定 |
| 游戏速度 | 0.10x ~ 5.00x，慢动作/快进 |
| 回满血量 | 一次性恢复到当前上限 |
| 游戏道具箱 | 读取游戏道具箱，把普通物品取到背包（带校验与回滚） |
| 刷取物品 | 任意物品直接放入背包，未获得的也可以 |
| 刷取武器 | 玩家武器每次一把放入背包；刷前自动查重（背包/装备/道具箱） |
| 中/英界面 | 默认中文，可在界面切换 |

## 安装

1. 安装 [REFramework](https://github.com/praydog/REFramework-nightly/releases)（RE3 版，非 RT 选 RE3_TDB67）。
   已装过可跳过——游戏目录有 `dinput8.dll` 和 `reframework/` 即可。
2. 把 [`reframework/autorun/re3_trainer.lua`](reframework/autorun/re3_trainer.lua)
   放进游戏目录的 `reframework\autorun\`。
3. （可选，中文界面）在游戏根目录（`re3.exe` 旁）放一个 0 字节空文件
   `reframework_pictographic.mode`。REFramework 检测到它会加载内置中文字体。
4. 启动游戏，日志出现 `[RE3Trainer] RE3 单机修改器 ... 加载完成` 即成功。

## 快速上手

1. 游戏里按 **Insert** → `Script Generated UI` → **RE3 单机修改器**。
2. 载入存档（顶部状态从“还没有进入游戏存档”变为“游戏中”）。
3. 勾选功能或按 F1~F8 热键；屏幕左上角（F9）显示已开启功能。
4. **改道具类数据（道具箱/刷取）前先按 Esc 暂停游戏，改完手动存档。**

热键：

```
F1 无敌   F2 一击必杀   F3 无限弹药   F4 无限物品
F5 小刀检测   F6 完美闪避   F7 游戏速度   F8 回满血量
F9 状态显示   F10 导出排查文件   F11 独立窗口   Insert 菜单
```

## 文档

- [详细使用指南（新手推荐）](docs/re3_trainer_guide.md) —— 安装、上手、每个功能的操作步骤与 FAQ
- [技术说明 / 版本记录](docs/re3_trainer_README.txt) —— 冲突说明、排错、开发记录
- [中文字体（可选）](docs/re3_trainer_sc.ttf) —— 自定义中文字体，默认不需要；
  界面默认使用 REFramework 内置中文字体

## 数据文件（自动生成，可删除）

| 文件 | 内容 |
|---|---|
| `reframework/data/re3_trainer.json` | 开关状态、速度倍率、界面语言 |
| `reframework/data/re3_trainer_dump.txt` | F10 对象转储（排错） |
| `reframework/data/re3_trainer_itemprobe.txt` | 道具箱内部信息探针（只读） |

## 已知限制

- 独立窗口（F11）在 REFramework 菜单关闭时只能显示、不能点击
  （REFramework 只在菜单打开时把输入交给 ImGui）。
- 小刀耐久功能目前只检测不修改（字段未确认，避免误写）。
- 道具箱中的武器条目只显示；请用游戏内道具箱取出。
- 与 Raz0r Ultimate Trainer 功能重叠，建议只启用一套；
  Auto-Dodge.lua 会让“无敌”开关看不出差别。

## 免责声明

本项目仅用于单机游戏体验优化，与 Capcom、Steam、REFramework 均无关联。
使用本修改器产生的一切游戏内后果（存档统计变化、剧情触发异常等）由使用者自行承担。
使用前请备份存档：`...\Steam\userdata\<SteamID>\952060\remote\`。

## 许可

MIT License
