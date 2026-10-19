--[[=====================================================================
  RE3 单机修改器 (RE3 Single-Player Trainer)  v1.4.0
  ---------------------------------------------------------------------
  适用游戏 : 生化危机3 重制版 / Resident Evil 3 (2020)  —— 仅单机离线模式
  运行平台 : REFramework (Lua 脚本版, 免编译)
  安装位置 : reframework/autorun/re3_trainer.lua   (放入即随游戏自动加载)
  使用说明 : reframework/re3_trainer_README.txt    (含冲突说明与排错步骤)
  打开界面 : Insert -> Script Generated UI -> "RE3 单机修改器"
             或按 F11 打开独立窗口 (不依赖 REFramework 菜单)

  热键     : F1 无敌   F2 一击必杀   F3 无限弹药   F4 无限物品
             F5 小刀耐久检测   F6 完美闪避   F7 游戏变速   F8 回满血量
             F9 状态 HUD   F10 导出对象转储(排错用)   F11 独立窗口

  说明     : 1) 所有开关默认关闭, 需手动开启; 设置会自动保存。
             2) 开启某项后若界面显示"未解析", 按 F10 导出转储文件以便排查。
             3) 请勿在联机/排行榜等场景使用, 仅供单机娱乐。

  v1.0.1 修复 (针对启动闪退):
    * 修复字形范围表被写成"表套表"的问题 —— 该结构会被 REFramework
      当作 ImWchar* 直接解引用(野指针), 构建字体图集时越界读取,
      表现为启动后闪退(c0000005, 崩在 REFramework 的 ImGui 代码)。
    * 中文字体改为受 ENABLE_CJK_UI 开关控制, 可一键回退英文界面。
    * 移除 d2d 画面 HUD, 减少启动阶段的渲染依赖(状态改在菜单内查看)。
    * 钩子安装与游戏对象访问延迟到"真正进入游戏后"执行。

  v1.0.2 修复 (针对启动卡死):
    * 中文字体默认停用 (ENABLE_CJK_UI=false), 并移除 reframework/fonts/
      下的自定义字体 —— 该字体位于 REFramework 的自动扫描路径, 会参与
      ImGui 字体图集初始化, 是启动阶段最主要的可疑环节。
      界面改为纯英文(功能完全一致), 启动路径不再触碰字体系统。
    * 说明: 卡死日志显示脚本尚未加载(无 [RE3Trainer] 记录), 崩点位于
      REFramework 初始化时"挂起全部线程"之后; 若停用字体后仍卡死,
      请按 README 排错第 0 条做排除法测试。

  v1.0.3 修复 (针对功能无效 / 热键无反馈):
    * HP 取值路径错误: get_HitPointController 属于 PlayerCondition 组件,
      之前直接在 GameObject 上调用, 导致永远拿不到 HP 控制器
      (无敌锁血、血量回满均失效)。已改为先取组件再调用。
    * 数量写入改为"属性 setter 优先" (set_Number/set_Count),
      比猜字段名可靠; 字段名匹配作为兜底。
    * 恢复画面 HUD (d2d, 英文) 作为热键切换的即时反馈; F9 开关。
    * 新增字段诊断: 进入游戏后把武器/HP/库存槽的真实字段名写入日志,
      便于核对匹配是否正确 (DEBUG_FIELDS, 稳定后可关)。
    * 修复上一版插入时的重复语句。

  v1.0.4 修复 (热键彻底不可用 / 字段名错误):
    * 热键: 启动阶段一次点号调用抛异常, 当时误判为 is_key_down 完全不可用;
      改为缓存 get_keyboard_state 快照 (该实现有缺陷, v1.0.5 已修正)。
    * 无敌: 直接写 HitPointController 的 <Invincible>/<NoDamage> 字段
      (日志字段清单确认存在), 不再依赖 hook。
    * 数量: 库存槽真实字段为 _Stock(内层库存对象) 与 _Infinity(无限标记);
      数量实际通过 get_Number/set_Number 读写 (v1.0.5 修正描述)。
    * 菜单勾选与变速开关会写日志, 可确认功能是否真的被开启。

  v1.0.5 修复 (代码审查后):
    * 热键: 不再缓存 get_keyboard_state 的一次性快照。每帧优先用
      reframework:is_key_down(vk) (冒号调用), 失败再试点号, 再退回
      每帧新取的 get_keyboard_state()[vk+1] (sol 容器是 1 基索引),
      最后才用 get_first_key_down()。接口探测失败会自动重试。
    * 字段发现: RETypeDefinition 的父类查询改用 get_parent_type()。
      原来的 get_parent() 在该类型上不存在, 异常被 pcall 吞掉,
      导致所有继承字段从未被扫描。
    * 血量: 无敌/回满改用 <DefaultHitPoint> 作为上限, 不再写 9999;
      关闭无敌后不会残留超上限血量。
    * 无限弹药: 只在真正写入后报告状态; 增加库存槽读回值。
    * 小刀耐久: 增加 _Stock/InnerData/ExtendData 探测与日志。
      耐久字段尚未确认, 本版只采集数据, 不盲目写未知对象。
    * 性能: 每帧复用 inventory; 物品可移除性缓存移出每帧函数。
    * HUD: d2d 字体加载失败会写日志, 并回退 Consolas/Arial。
    * 配置: speed 加载后限制在 0.1 ~ 5.0。

  v1.0.6 新增 (CabbyCodes 风格道具箱/物品探针, 只读):
    * 新增 ItemLockerManager / GameSaveData / _Items 探测, 读取道具箱
      条目 (物品 ID、数量、名称) 并写入 re3_trainer_itemprobe.txt。
    * 导出 Inventory / Slot / ItemManager / ItemLockerManager 的
      方法签名 (setSlot/putSlot/set_ItemID/set_Number 等重载),
      为实现“从道具箱取出/发放物品”做准备。
    * F10 转储包含探针结果; 菜单新增“道具箱探针 (只读)”按钮。
    * 本版不写任何道具数据, 避免在 API 未确认时损坏存档。

  v1.0.7 新增独立窗口 UI (模仿 Raz0r 训练器):
    * F11 或菜单“独立窗口”开关。使用 imgui.begin_window/end_window
      在 on_frame 中绘制独立 ImGui 窗口, 不依赖 REFramework 菜单。
    * 窗口可拖动/缩放/关闭; 关闭状态和开关会写入配置。
    * 窗口内复用同一套控件 (draw_ui_body), 菜单内入口保留。

  v1.0.8 默认中文界面:
    * 界面文字默认改为中文 (ENABLE_CJK_UI = true)。
    * 中文不再依赖自定义 TTF: 游戏根目录存在 reframework_pictographic.mode
      (0 字节空文件) 时, REFramework 会把内置 ImGui 字体切换成完整中文字体
      (GetGlyphRangesChineseFull), 不会触碰 reframework/fonts/ 扫描路径。
    * 自定义字体改为 USE_CUSTOM_FONT 可选开关, 默认关闭。
    * HUD 中文标签优先使用 Microsoft YaHei / SimHei。
    * 如需英文界面: 把 ENABLE_CJK_UI 改为 false。

  v1.0.9 道具箱探针 v2:
    * 逐层解开 GameSaveData.SaveData, 找到真正的 ItemLockerSaveData;
      读取 get_Items() / get_Items_2nd() 两个物品列表。
    * 导出 InventoryManager.ItemData / StockItem / PrimitiveItem /
      ItemExData 与 inventory.Vital 的字段和全部方法签名。
    * ItemLockerManager 签名增加 AddStrage / RemoveStrage /
      AddWeaponToStrage / RemoveWeaponToStrage 等存储函数。
    * 仍为只读; 用于确认“从道具箱取出/发放物品”的最终写入路径。

  v1.1.0 道具箱取出 + 界面语言切换:
    * 菜单新增“道具箱 (游戏内物品)”列表: 读取 ItemLockerSaveData 的
      _Items / _Items2nd, 显示名称和数量。
    * “取出”把普通物品写入第一个可用背包槽:
      Inventory.setSlot(...) 优先, Slot.set(...) 兜底; 写入后读回校验,
      再清空道具箱条目。任一步失败自动回滚, 避免物品复制。
    * 取出需在游戏暂停 (Esc) 时进行; 武器暂时只显示、不支持取出。
    * 新增界面语言选择: 中文 / English, 默认中文, 写入配置。
    * 独立窗口在 REFramework 菜单关闭时仅显示、不可点击 (REFramework
      只在菜单打开时把输入交给 ImGui); 按 Insert 打开菜单后即可交互。

  v1.2.0 刷取物品:
    * 新增“刷取物品 (未获得的物品)”列表: 遍历 Item.ID (1..400),
      用 ItemManager.getItemName 过滤无效项, 支持按名称/ID 搜索。
    * 优先 Inventory.addSlotNumber(id, count) 入包 (会处理已有堆叠);
      失败则创建 InventoryManager.PrimitiveItem + ItemExData,
      走 Inventory.setSlot 或 Slot.set 兜底; 写入后读回校验。
    * 数量 1~999; 不可堆叠物品自动按 1 处理。
    * 需在游戏暂停 (Esc) 时操作; 关键/剧情物品可能影响流程。

  v1.3.0 武器刷取:
    * 新增“刷取武器 (单个)”列表: 遍历 EquipmentDefine.WeaponType
      (1..381), 用 ItemManager.getWeaponName(wt, 0) 过滤无效项。
    * 刷取前检查背包/装备 (Slot.get_IsWeapon + get_WeaponType,
      Equipment.hasWeapon) 和武器箱 (道具箱 _Items/_Items2nd 中的
      isWeaponAll + get_WeaponId); 已存在则拒绝刷取。
    * 武器版 Inventory.setSlot(slot, wt, parts, bulletID, count, ExData)
      优先, Slot.set 兜底; 读回 get_WeaponType 校验。
    * 武器固定无配件、1 发; 需暂停游戏。

  v1.4.0 界面文案重写:
    * 所有菜单/HUD/提示文字改为“名称 + 效果 + 前提/风险”的通俗写法。
    * 统一动作为“放入背包”; 道具箱两组列表显示为 1 / 2。
    * 新增“高级 / 排错”折叠区: 导出转储、道具箱探针、重新识别、
      字段识别结果、钩子状态、热键识别方式。
    * HUD 显示“已开启功能”; 没有功能时明确显示“当前没有开启功能”。
    * 热键识别方式/钩子状态改为“正常/兼容模式/失败”等通俗描述。
    * 中英文文案同步。
=====================================================================]]


-- 仅对 RE3 生效 (同目录可能有其它 RE 引擎游戏的脚本)
if reframework.get_game_name() ~= "re3" then
    log.info("[RE3Trainer] 当前游戏非 RE3, 脚本不加载")
    return
end

local MOD_NAME    = "RE3 Trainer"            -- 界面标题 (英文: 中文字体可选)
local MOD_NAME_CN = "RE3 单机修改器"           -- 日志显示用
local MOD_VER     = "1.4.0"
local CFG_FILE    = "re3_trainer.json"         -- 设置存档 (写入 reframework/data/)
local DUMP_FILE   = "re3_trainer_dump.txt"     -- 对象转储输出
local ITEM_PROBE_FILE = "re3_trainer_itemprobe.txt" -- 道具箱/物品探针 (只读)

-- 界面语言: true=中文, false=英文 (v1.0.8 起默认中文)。
-- 中文默认使用 REFramework 内置中文字体: 游戏根目录存在
-- reframework_pictographic.mode (0 字节空文件) 时, REFramework 会把默认
-- ImGui 字体切换为完整中文字体 (GetGlyphRangesChineseFull)。本机已存在
-- 该文件, 因此不需要把 re3_trainer_sc.ttf 放回 reframework/fonts/。
local ENABLE_CJK_UI = true
-- 可选: 使用自定义中文字体。把 re3_trainer_sc.ttf 放回
-- reframework/fonts/ 后改为 true。注意该目录属于 REFramework 自动扫描路径,
-- 该字体曾与启动异常相关, 默认关闭; 内置中文字体已覆盖全部界面文字。
local USE_CUSTOM_FONT = false
-- 字段诊断: 进入游戏后把武器/HP/库存槽的真实字段名写入日志(每个类型一次)。
-- 用于核对字段匹配是否正确; 稳定后可改为 false。
local DEBUG_FIELDS = true
local FONT_FILE     = "re3_trainer_sc.ttf"     -- 位于 reframework/fonts/
local FONT_SIZE     = 16

-- Windows 虚拟键码 (可自行修改为自己习惯的按键)
local VK = { F1 = 112, F2 = 113, F3 = 114, F4 = 115, F5 = 116,
             F6 = 117, F7 = 118, F8 = 119, F9 = 120, F10 = 121, F11 = 122 }

-- 运行状态 (可变项 = 功能开关)
local state = {
    god_mode      = false,   -- F1 无敌
    ohk           = false,   -- F2 一击必杀
    ammo          = false,   -- F3 无限弹药
    items         = false,   -- F4 无限物品
    knife         = false,   -- F5 小刀耐久检测 (目前只检测)
    dodge         = false,   -- F6 完美闪避
    speed_enabled = false,   -- F7 游戏变速
    speed         = 0.5,     --    速度倍率 (0.1 ~ 5.0)
    hud           = true,    -- F9 画面状态 HUD
    standalone_ui = false,   -- F11 独立窗口 (不依赖 REFramework 菜单)
    ui_language   = "zh",    -- "zh" 中文 / "en" 英文 (默认中文)
    item_filter   = "",      -- 刷取物品的搜索文本 (不保存)
    give_count    = 1,       -- 刷取数量 (不保存)
    weapon_filter = "",      -- 刷取武器的搜索文本 (不保存)
}

-- 运行状态 (只读, 供界面显示)
local status = {
    in_game = false, paused = false, player = false,
    hp = nil, weapon = nil,
    hp_note = "", ammo_note = "", item_note = "", knife_note = "",
    hook_god = false, hook_ohk = false, hook_dodge = false, hook_speed = false,
    item_box = { known = false, error = "", entries = {} },
    item_catalog = {}, item_catalog_ready = false,
    weapon_catalog = {}, weapon_catalog_ready = false,
}

----------------------------------------------------------------------
-- 中文字体 (可选): reframework/fonts/re3_trainer_sc.ttf
-- 注意: load_font 的第三个参数必须是"一维"数值数组并以 0 结尾。
--       (v1.0.0 误写成嵌套表, 会变成野指针并导致游戏闪退, 已修复)
----------------------------------------------------------------------
local FONT_RANGES = { 0x20, 0x7E, 0xA0, 0xFF, 0x2013, 0x2026, 0x2039, 0x203A, 0x3000, 0x303F, 0x4E00, 0x4E00, 0x4E0A, 0x4E0E, 0x4E2A, 0x4E2D, 0x4E3A, 0x4E3B, 0x4E45, 0x4E45, 0x4E50, 0x4E50, 0x4E5F, 0x4E60, 0x4E8E, 0x4E8E, 0x4EBA, 0x4EBA, 0x4EC5, 0x4EC5, 0x4EE5, 0x4EE5, 0x4EF6, 0x4EFB, 0x4F18, 0x4F1A, 0x4F24, 0x4F24, 0x4F4D, 0x4F5C, 0x4F7F, 0x4F7F, 0x4F8B, 0x4F8B, 0x4F9B, 0x4F9D, 0x4FBF, 0x4FBF, 0x4FDD, 0x4FDD, 0x4FEE, 0x4FEE, 0x500D, 0x500D, 0x503C, 0x503C, 0x505C, 0x505C, 0x50A8, 0x50A8, 0x5148, 0x514D, 0x515C, 0x515C, 0x5165, 0x5168, 0x5173, 0x5177, 0x5185, 0x518C, 0x5199, 0x5199, 0x51B5, 0x51BB, 0x51CF, 0x51CF, 0x51FA, 0x5200, 0x5219, 0x5219, 0x5224, 0x5224, 0x5230, 0x5236, 0x524D, 0x524D, 0x5267, 0x5267, 0x529F, 0x52A8, 0x52FF, 0x52FF, 0x5316, 0x5319, 0x5339, 0x5339, 0x5347, 0x5347, 0x5355, 0x5355, 0x5371, 0x5373, 0x5386, 0x5386, 0x53CB, 0x53D8, 0x53EA, 0x53F0, 0x540C, 0x540E, 0x5426, 0x542F, 0x547D, 0x547D, 0x54C1, 0x54C1, 0x54CD, 0x54CD, 0x5668, 0x5668, 0x56DE, 0x56DE, 0x5728, 0x5728, 0x573A, 0x573A, 0x578B, 0x578B, 0x586B, 0x586B, 0x5907, 0x5907, 0x5927, 0x5927, 0x5931, 0x5931, 0x59CB, 0x59CB, 0x5A31, 0x5A31, 0x5B50, 0x5B58, 0x5B83, 0x5B8C, 0x5B9A, 0x5B9E, 0x5BB3, 0x5BB6, 0x5BC4, 0x5BC4, 0x5BF9, 0x5BFC, 0x5C06, 0x5C06, 0x5C0F, 0x5C11, 0x5C1D, 0x5C1D, 0x5C31, 0x5C31, 0x5DE5, 0x5DE5, 0x5DF1, 0x5DF2, 0x5E26, 0x5E27, 0x5E38, 0x5E38, 0x5E72, 0x5E73, 0x5E93, 0x5E95, 0x5EA6, 0x5EA6, 0x5EFA, 0x5F02, 0x5F0F, 0x5F15, 0x5F39, 0x5F3A, 0x5F53, 0x5F55, 0x5F71, 0x5F71, 0x5F84, 0x5F84, 0x5FAA, 0x5FAA, 0x5FC5, 0x5FC5, 0x5FFD, 0x6001, 0x6025, 0x6027, 0x60C5, 0x60C5, 0x60EF, 0x60F0, 0x610F, 0x610F, 0x620F, 0x6210, 0x622A, 0x622A, 0x6240, 0x6240, 0x624B, 0x6253, 0x6267, 0x6267, 0x6270, 0x6270, 0x627E, 0x627E, 0x628A, 0x628A, 0x62A4, 0x62A5, 0x62DF, 0x62E6, 0x6301, 0x6309, 0x6362, 0x6362, 0x6389, 0x6389, 0x6392, 0x6392, 0x63A5, 0x63A5, 0x63D0, 0x63D2, 0x64CD, 0x64CE, 0x6536, 0x653E, 0x6548, 0x654C, 0x6570, 0x6570, 0x6587, 0x6587, 0x65AD, 0x65B0, 0x65B9, 0x65B9, 0x65E0, 0x65E0, 0x65F6, 0x65F6, 0x660E, 0x660E, 0x662F, 0x662F, 0x663E, 0x663E, 0x666F, 0x666F, 0x6682, 0x6682, 0x6700, 0x6700, 0x6709, 0x6709, 0x672A, 0x672C, 0x673A, 0x6740, 0x6781, 0x6781, 0x6790, 0x6790, 0x679C, 0x679C, 0x67AA, 0x67AA, 0x67D0, 0x67D0, 0x67E5, 0x67E5, 0x6863, 0x6863, 0x68B0, 0x68B0, 0x68C0, 0x68C0, 0x699C, 0x699C, 0x69FD, 0x69FD, 0x6A21, 0x6A21, 0x6B21, 0x6B21, 0x6B65, 0x6B66, 0x6BB5, 0x6BB5, 0x6BCF, 0x6BCF, 0x6CBF, 0x6CBF, 0x6CD5, 0x6CD5, 0x6CE8, 0x6CE8, 0x6D4B, 0x6D4B, 0x6D88, 0x6D88, 0x6E05, 0x6E05, 0x6E38, 0x6E38, 0x6EE1, 0x6EE1, 0x70ED, 0x70ED, 0x7236, 0x7236, 0x7248, 0x7248, 0x7269, 0x7269, 0x72B6, 0x72B6, 0x7387, 0x7387, 0x73A9, 0x73B0, 0x751F, 0x751F, 0x7528, 0x7528, 0x753B, 0x753B, 0x754C, 0x754C, 0x7565, 0x7565, 0x7684, 0x7684, 0x76D2, 0x76D2, 0x76EE, 0x76F8, 0x77AC, 0x77AC, 0x7801, 0x7801, 0x786E, 0x786E, 0x793A, 0x793A, 0x79BB, 0x79BB, 0x79F0, 0x79F0, 0x7A7A, 0x7A7A, 0x7B49, 0x7B49, 0x7C7B, 0x7C7B, 0x7D27, 0x7D27, 0x7EBF, 0x7EBF, 0x7EC8, 0x7ED3, 0x7EDD, 0x7EDD, 0x7EEA, 0x7EED, 0x7F13, 0x7F16, 0x7F29, 0x7F29, 0x7F6E, 0x7F6E, 0x7F8E, 0x7F8E, 0x8010, 0x8017, 0x8054, 0x8054, 0x80FD, 0x80FD, 0x811A, 0x811A, 0x81EA, 0x81EA, 0x82E5, 0x82E5, 0x82F1, 0x82F1, 0x8349, 0x8349, 0x836F, 0x836F, 0x83DC, 0x83DC, 0x865A, 0x865A, 0x8840, 0x8840, 0x884C, 0x884C, 0x88C5, 0x88C5, 0x89C4, 0x89C6, 0x89E3, 0x89E6, 0x8BA4, 0x8BA4, 0x8BAE, 0x8BAE, 0x8BBE, 0x8BC1, 0x8BD1, 0x8BD5, 0x8BE5, 0x8BE5, 0x8BF4, 0x8BFB, 0x8C1C, 0x8C1C, 0x8C61, 0x8C61, 0x8D25, 0x8D25, 0x8DDF, 0x8DDF, 0x8DEF, 0x8DF3, 0x8F6C, 0x8F6C, 0x8F7D, 0x8F7D, 0x8F91, 0x8F93, 0x8FB9, 0x8FB9, 0x8FC7, 0x8FC7, 0x8FD0, 0x8FD4, 0x9000, 0x9009, 0x901A, 0x901F, 0x903B, 0x903B, 0x904D, 0x904D, 0x907F, 0x907F, 0x90E8, 0x90E8, 0x90FD, 0x90FD, 0x914D, 0x914D, 0x91CD, 0x91CF, 0x94A5, 0x94A9, 0x9500, 0x9501, 0x9519, 0x9519, 0x952E, 0x952E, 0x95EA, 0x95F4, 0x9600, 0x9600, 0x963B, 0x963B, 0x9644, 0x9644, 0x9650, 0x9650, 0x968F, 0x968F, 0x96C6, 0x96C6, 0x96F7, 0x96F7, 0x9700, 0x9700, 0x975E, 0x9762, 0x9879, 0x9879, 0x9996, 0x9996, 0x9ED8, 0x9ED8, 0xFF01, 0xFF5E, 0xFFE0, 0xFFE5, 0 }

local font_handle = nil
local use_cjk = ENABLE_CJK_UI
if use_cjk and USE_CUSTOM_FONT then
    local ok, h = pcall(imgui.load_font, FONT_FILE, FONT_SIZE, FONT_RANGES)
    if ok and h ~= nil then
        font_handle = h
        log.info("[RE3Trainer] 已加载自定义中文字体: " .. FONT_FILE)
    else
        log.warn("[RE3Trainer] 自定义中文字体加载失败, 使用 REFramework 内置中文字体")
    end
end

-- 界面文字: 按运行时语言选择, 可在菜单里切换
local function L(zh, en)
    if state.ui_language == "zh" and use_cjk then return zh end
    return en
end

----------------------------------------------------------------------
-- 通用安全工具 (所有对游戏对象的访问都经过保护, 避免脚本报错影响游戏)
----------------------------------------------------------------------
-- 依次尝试若干个方法名, 返回首个非 nil 的结果 (支持透传参数)
local unpack_ = table.unpack or unpack
local function call_m(obj, names, ...)
    if obj == nil then return nil end
    local args = { ... }
    local nargs = select("#", ...)
    for i = 1, #names do
        local ok, r = pcall(function()
            return obj:call(names[i], unpack_(args, 1, nargs))
        end)
        if ok and r ~= nil then return r end
    end
    return nil
end

local function get_field(obj, name)
    if obj == nil then return nil end
    local ok, v = pcall(function() return obj:get_field(name) end)
    if ok then return v end
    return nil
end

local function set_field(obj, name, value)
    if obj == nil then return false end
    local ok = pcall(function() obj:set_field(name, value) end)
    return ok
end

local function type_name(obj)
    if obj == nil then return nil end
    local ok, n = pcall(function() return obj:get_type_definition():get_full_name() end)
    if ok then return n end
    return nil
end

----------------------------------------------------------------------
-- 游戏对象解析 (RE3 = offline.* 命名空间)
----------------------------------------------------------------------
local KNOWN_TYPEOFS = {}
local function get_component(go, type_name_str)
    if go == nil then return nil end
    local t = KNOWN_TYPEOFS[type_name_str]
    if t == nil then
        local ok, r = pcall(sdk.typeof, type_name_str)
        t = (ok and r) or false
        KNOWN_TYPEOFS[type_name_str] = t
    end
    if t == false or t == nil then return nil end
    local ok, comp = pcall(function() return go:call("getComponent(System.Type)", t) end)
    if ok then return comp end
    return nil
end

local function get_flow_manager()
    return sdk.get_managed_singleton(sdk.game_namespace("gamemastering.MainFlowManager"))
end

local function get_item_manager()
    return sdk.get_managed_singleton(sdk.game_namespace("gamemastering.ItemManager"))
end

local function get_player()
    local pm = sdk.get_managed_singleton(sdk.game_namespace("PlayerManager"))
    if pm then
        local p = call_m(pm, { "get_CurrentPlayer" })
        if p then return p end
    end
    local sm = sdk.get_managed_singleton(sdk.game_namespace("SurvivorManager"))
    if sm then
        local p = call_m(sm, { "get_Player" })
        if p then return p end
    end
    return nil
end

local function get_equipment(player)
    if not player then return nil end
    return get_component(player, sdk.game_namespace("survivor.Equipment"))
end

local function get_weapon(player)
    local eq = get_equipment(player)
    if not eq then return nil end
    -- 当前装备的武器 (小刀/枪械/手雷)
    return get_field(eq, "<EquipWeapon>k__BackingField")
end

local function get_inventory(player)
    if not player then return nil end
    return get_component(player, sdk.game_namespace("survivor.Inventory"))
end

local function get_player_condition(player)
    if not player then return nil end
    return get_component(player, sdk.game_namespace("survivor.player.PlayerCondition"))
end

-- get_HitPointController 定义在 PlayerCondition(组件) 上, 不在 GameObject 上。
-- v1.0.2 直接在 GameObject 上调用, 因此永远拿不到 HP 控制器。
local function get_hitpoint_controller(player)
    if not player then return nil end
    local pc = get_player_condition(player)
    if pc then
        local hpc = call_m(pc, { "get_HitPointController", "get_HitPointController()" })
        if hpc then return hpc end
    end
    return call_m(player, { "get_HitPointController", "get_HitPointController()" })
end

----------------------------------------------------------------------
-- 字段发现与冻结
----------------------------------------------------------------------
local PAT_AMMO = { "ammo", "bullet", "magazine", "cartridge", "clip", "round" }
local PAT_HP   = { "hitpoint", "health", "hp" }
local PAT_DURA = { "durab", "wear", "sharpen", "endur", "blade", "vital" }
local PAT_NUM  = { "number", "count" }

-- 物品可移除性缓存 (按 ItemID; 不要放在每帧函数里重建)
local removable_cache = {}

-- 收集对象(含其父类)中名称匹配任一关键字的实例字段名
local function discover_fields(obj, patterns)
    local names = {}
    if obj == nil then return names end
    local ok, td = pcall(function() return obj:get_type_definition() end)
    if not ok or not td then return names end

    local seen, depth = {}, 0
    while td and depth < 8 do
        local ok_f, fields = pcall(function() return td:get_fields() end)
        if ok_f and fields then
            for _, f in ipairs(fields) do
                local ok_n, name = pcall(function() return f:get_name() end)
                if ok_n and name and not seen[name] then
                    seen[name] = true
                    local ok_s, is_static = pcall(function() return f:is_static() end)
                    if not (ok_s and is_static) then
                        local lower = string.lower(name)
                        for _, p in ipairs(patterns) do
                            if string.find(lower, p, 1, true) then
                                names[#names + 1] = name
                                break
                            end
                        end
                    end
                end
            end
        end
        local ok_p, parent = pcall(function() return td:get_parent_type() end)
        td = (ok_p and parent) or nil
        depth = depth + 1
    end
    return names
end

-- 诊断: 把某类型的全部字段名写入日志(每个类型只写一次), 用于定位真实字段名
local dumped_types = {}
local function dump_all_field_names(obj, label)
    local tn = type_name(obj)
    if tn == nil or dumped_types[tn] then return end
    dumped_types[tn] = true
    local ok, td = pcall(function() return obj:get_type_definition() end)
    if not ok or not td then return end
    local parts, seen, depth = {}, {}, 0
    while td and depth < 6 and #parts < 500 do
        local tdn = "?"
        pcall(function() tdn = td:get_full_name() end)
        parts[#parts + 1] = "[" .. tostring(tdn) .. "]"
        local okf, fields = pcall(function() return td:get_fields() end)
        if okf and fields then
            for _, f in ipairs(fields) do
                local fname
                pcall(function() fname = f:get_name() end)
                if fname and not seen[fname] then
                    seen[fname] = true
                    parts[#parts + 1] = fname
                    if #parts >= 500 then break end
                end
            end
        end
        local okp, parent = pcall(function() return td:get_parent_type() end)
        td = (okp and parent) or nil
        depth = depth + 1
    end
    log.info(string.format("[RE3Trainer] 字段清单(%s) %s: %s",
        tostring(label), tostring(tn), table.concat(parts, ", ")))
end

-- 耐久探测: 只记录候选字段和当前值, 不写未知对象。
-- 小刀耐久很可能在 Slot 的内层数据 (_Stock / InnerData / ExtendData) 上,
-- 先用日志确认字段名和取值范围, 再决定写入方式。
local probed_dura = {}
local function probe_durability(obj, label)
    if obj == nil then return end
    local tn = type_name(obj)
    if tn == nil or probed_dura[tn] then return end
    probed_dura[tn] = true
    local fields = discover_fields(obj, PAT_DURA)
    if #fields == 0 then
        log.info(string.format("[RE3Trainer] 耐久探测(%s) %s: 无匹配字段", label, tn))
        return
    end
    local parts = {}
    for _, fname in ipairs(fields) do
        local v = get_field(obj, fname)
        parts[#parts + 1] = string.format("%s=%s(%s)", fname, tostring(v), type(v))
    end
    log.info(string.format("[RE3Trainer] 耐久探测(%s) %s: %s",
        label, tn, table.concat(parts, ", ")))
end

-- 解析缓存: 换武器/换类型时自动重新解析
local cache_ammo = { tname = nil, fields = {} }
local cache_hp   = { tname = nil, fields = {} }
local cache_slot = { tname = nil, fields = {} }

local function resolve(cache, obj, patterns)
    local tn = type_name(obj)
    if tn == nil then return cache.fields end
    if cache.tname ~= tn then
        cache.fields = discover_fields(obj, patterns)
        cache.tname = tn
        log.info(string.format("[RE3Trainer] 解析 %s -> %s", tn,
            (#cache.fields > 0) and table.concat(cache.fields, ", ") or "(无匹配字段)"))
    end
    return cache.fields
end

-- 把匹配字段中数值低于 target 的提升到 target (等价于"锁定")
-- 返回: 是否找到数值字段, 最后一个字段名, 该字段当前值, 实际写入次数
local function freeze_fields(obj, cache, patterns, target)
    if obj == nil then return false, nil, nil, 0 end
    local fields = resolve(cache, obj, patterns)
    if #fields == 0 then return false, nil, nil, 0 end
    local last_name, last_val, wrote = nil, nil, 0
    for _, fname in ipairs(fields) do
        local v = get_field(obj, fname)
        if type(v) == "number" then
            last_name, last_val = fname, v
            if v >= 0 and v < target then
                if set_field(obj, fname, target) then
                    wrote = wrote + 1
                end
            end
        end
    end
    return (last_name ~= nil), last_name, last_val, wrote
end

-- 数量类(备弹/物品数)写入: 先试属性 setter, 再退回直接写字段。
-- RE3 的库存槽公开了 get_Number 等属性, 用 setter 比猜字段名可靠。
-- 库存槽的真实字段(来自日志字段清单):
--   _Stock    = 内层库存对象 (userdata/对象, 不是数量)
--   _Infinity = 无限使用标记
-- 数量实际通过 get_Number / set_Number 属性读写。
local NUM_FIELDS   = { "_Stock", "<Number>k__BackingField", "_Number", "<Count>k__BackingField" }
local NUM_GETTERS  = { "get_Number", "get_Count", "get_ItemCount" }
local NUM_SETTERS  = { "set_Number", "set_Count", "set_ItemCount" }

local function freeze_number(obj, cache, target, infinity)
    if obj == nil then return false, nil, nil, false end

    -- 1) 直接写已知字段
    for _, fname in ipairs(NUM_FIELDS) do
        local v = get_field(obj, fname)
        if type(v) == "number" then
            local wrote = false
            if v >= 0 and v < target then
                wrote = set_field(obj, fname, target)
                local back = get_field(obj, fname)
                if type(back) == "number" then v = back end
            end
            if infinity then
                set_field(obj, "_Infinity", true)
            end
            return true, fname, v, wrote
        end
    end

    -- 2) 属性 setter
    for i = 1, #NUM_GETTERS do
        local v = call_m(obj, { NUM_GETTERS[i] })
        if type(v) == "number" then
            local wrote = false
            if v >= 0 and v < target then
                call_m(obj, { NUM_SETTERS[i] }, target)
                wrote = true
            end
            if infinity then
                set_field(obj, "_Infinity", true)
            end
            local back = call_m(obj, { NUM_GETTERS[i] })
            return true, NUM_GETTERS[i], (type(back) == "number") and back or v, wrote
        end
    end

    -- 3) 兜底
    return freeze_fields(obj, cache, PAT_NUM, target)
end

----------------------------------------------------------------------
-- 游戏内钩子 (惰性安装, 失败会在下一帧自动重试)
----------------------------------------------------------------------
local function install_hooks()
    -- 全部就绪时直接返回 (常规路径开销可忽略)
    if status.hook_god and status.hook_ohk and status.hook_dodge and status.hook_speed then
        return
    end

    -- 1) 无敌: 拦截玩家受击判定 (返回 false = 不受伤)
    if not status.hook_god then
        local td = sdk.find_type_definition(sdk.game_namespace("survivor.SurvivorCondition"))
        local m = td and td:get_method("checkHitDamage")
        if m then
            local player_cond = sdk.game_namespace("survivor.player.PlayerCondition")
            sdk.hook(m,
                function(args)
                    local is_player = false
                    local ok, cond = pcall(sdk.to_managed_object, args[2])
                    if ok and cond then
                        local ok2, same = pcall(function()
                            return cond:get_type_definition():get_full_name() == player_cond
                        end)
                        if ok2 and same then
                            -- 剧情"寄生"状态下不拦截, 避免阻断剧情
                            is_player = not get_field(cond, "_IsParasite")
                        end
                    end
                    thread.get_hook_storage().is_player = is_player
                end,
                function(retval)
                    if state.god_mode and thread.get_hook_storage().is_player then
                        return sdk.to_ptr(false)
                    end
                    return retval
                end)
            status.hook_god = true
            log.info("[RE3Trainer] 钩子已安装: checkHitDamage (无敌)")
        end
    end

    -- 2) 一击必杀: 命中敌人时把伤害提到极大 (只对敌人, 绝不作用于玩家)
    if not status.hook_ohk then
        local td = sdk.find_type_definition(sdk.game_namespace("Collision.HitManager"))
            or sdk.find_type_definition("offline.Collision.HitManager")
        local m = td and td:get_method("calcDamage")
        if m then
            sdk.hook(m,
                function(args)
                    if not state.ohk then return end
                    local ok_d, dmg = pcall(sdk.to_managed_object, args[3])
                    if not ok_d or not dmg then return end
                    local ok_v, victim = pcall(sdk.to_managed_object, args[4])
                    if not ok_v or not victim then return end
                    local tn = type_name(victim)
                    if tn == nil then return end
                    tn = string.lower(tn)
                    local is_friendly = string.find(tn, "survivor", 1, true)
                        or string.find(tn, "player", 1, true)
                    if is_friendly then return end -- 安全阀: 玩家/友方不加强
                    local is_enemy = string.find(tn, "enemy", 1, true) ~= nil
                    if not is_enemy then
                        -- 兜底: 带敌人 KindID 的对象视为敌人
                        local k = call_m(victim, { "get_KindID", "get_KindID()" })
                        is_enemy = (k ~= nil)
                    end
                    if is_enemy then
                        set_field(dmg, "<Damage>k__BackingField", 99999)
                    end
                end,
                function(retval) return retval end)
            status.hook_ohk = true
            log.info("[RE3Trainer] 钩子已安装: calcDamage (一击必杀)")
        end
    end

    -- 3) 完美闪避: 持续开启紧急闪避相关开关
    if not status.hook_dodge then
        local td = sdk.find_type_definition(sdk.game_namespace("survivor.player.PlayerCondition"))
        local m = td and td:get_method("doSurvivorUpdate")
        if m then
            sdk.hook(m,
                function(args)
                    if not state.dodge then return end
                    local ok, cond = pcall(sdk.to_managed_object, args[2])
                    if not ok or not cond then return end
                    pcall(function()
                        if cond:get_field("<SurvivorType>k__BackingField") ~= 2 then return end
                        local hpc = cond:call("get_HitPointController")
                        if hpc then
                            hpc:set_field("<SecondEnableEmergencyDodge>k__BackingField", true)
                            hpc:set_field("<ThirdEnableEmergencyDodge>k__BackingField", true)
                        end
                        local orderer = cond:call("get_ActionOrderer")
                        if orderer then
                            orderer:set_field("EnableHoldStartDodge", true)
                            orderer:set_field("EnableHoldStartDodgeTimer", 1000)
                            orderer:set_field("IntervalEnableHoldStartDodgeTimer", 1000)
                            orderer:set_field("EnableStartStartDodgeTimer", 1000)
                        end
                        if cond:get_field("<DodgeTargetObject>k__BackingField") then
                            cond:set_field("<InZoneDodgeArea>k__BackingField", true)
                            if orderer then
                                if cond:call("get_IsHold") then
                                    orderer:set_field("<Petient>k__BackingField", 1024)
                                    orderer:set_field("<Precede>k__BackingField", 1024)
                                    cond:set_field("<DodgeTargetObject>k__BackingField", nil)
                                else
                                    orderer:set_field("<Petient>k__BackingField", 16)
                                    orderer:set_field("<Precede>k__BackingField", 0)
                                end
                            end
                        end
                    end)
                end)
            status.hook_dodge = true
            log.info("[RE3Trainer] 钩子已安装: doSurvivorUpdate (完美闪避)")
        end
    end

    -- 4) 游戏变速: 改写引擎时间缩放
    if not status.hook_speed then
        local td = sdk.find_type_definition("via.Scene")
        local m = td and td:get_method("get_TimeScale")
        if m then
            sdk.hook(m,
                function(args) end,
                function(retval)
                    if state.speed_enabled then
                        return sdk.float_to_ptr(state.speed)
                    end
                    return retval
                end)
            status.hook_speed = true
            log.info("[RE3Trainer] 钩子已安装: get_TimeScale (游戏变速)")
        end
    end
end

----------------------------------------------------------------------
-- 库存槽遍历
----------------------------------------------------------------------
local function for_each_slot(fn, player, inv)
    player = player or get_player()
    inv = inv or get_inventory(player)
    if not inv then return end
    local n = call_m(inv, { "get_CurrentSlotSize", "get_CurrentSlotSize()" })
    if type(n) ~= "number" or n <= 0 then return end
    for i = 0, n - 1 do
        local slot = call_m(inv, { "getSlot" }, i)
        if slot then
            local dead = call_m(slot, { "get_IsDeadSlot" })
            if not dead then fn(slot, i) end
        end
    end
end

----------------------------------------------------------------------
-- 血量回满 (一次性)
----------------------------------------------------------------------
local function heal_to_full()
    local player = get_player()
    local hpc = get_hitpoint_controller(player)
    if hpc == nil then
        log.warn("[RE3Trainer] 未找到 HitPointController, 无法回血")
        return
    end

    -- 真实上限在 <DefaultHitPoint>; 不要写 9999, 否则血条比例会超过 1.0,
    -- 关闭无敌后还会残留超上限血量。
    local max_hp = get_field(hpc, "<DefaultHitPoint>k__BackingField")
    if type(max_hp) ~= "number" or max_hp <= 0 then
        log.warn("[RE3Trainer] 未找到 DefaultHitPoint, 无法确定血量上限")
        return
    end

    if set_field(hpc, "<CurrentHitPoint>k__BackingField", max_hp) then
        log.info(string.format("[RE3Trainer] 血量回满: CurrentHitPoint = %s (DefaultHitPoint)",
            tostring(max_hp)))
    else
        log.warn("[RE3Trainer] 血量回满失败: 无法写入 CurrentHitPoint")
    end
end

----------------------------------------------------------------------
-- 每帧游戏逻辑 (挂在 UpdateBehavior 上, 与游戏主循环同步)
----------------------------------------------------------------------
local frame_tick = 0
local debug_done = false
local debug_weapon_type = nil

local function update_game()
    -- 启动后前 60 帧(约 1 秒)不动作: 等引擎完成初始化,
    -- 避免在对象/单例尚未就绪时访问它们。
    frame_tick = frame_tick + 1
    if frame_tick < 60 then return end

    local fm = get_flow_manager()
    status.in_game = (call_m(fm, { "get_IsInGame" }) == true)
    status.paused  = (call_m(fm, { "get_IsInPause" }) == true)

    -- 仅真正进入游戏(存档载入完成)后才安装钩子、遍历对象
    if not status.in_game then
        status.player = false
        status.hp, status.weapon = nil, nil
        return
    end

    install_hooks()

    local player = get_player()
    status.player = (player ~= nil)
    if not player then
        status.hp, status.weapon = nil, nil
        return
    end

    local inventory = get_inventory(player)
    local weapon = get_weapon(player)
    status.weapon = type_name(weapon)

    -- 字段诊断: 玩家/HP/库存类型各一次; 武器类型变化时重新 dump
    if DEBUG_FIELDS then
        local wt = type_name(weapon)
        if wt and debug_weapon_type ~= wt then
            debug_weapon_type = wt
            pcall(function() dump_all_field_names(weapon, "当前武器") end)
        end
        if not debug_done then
            debug_done = true
            pcall(function()
                local pc = get_player_condition(player)
                if pc then dump_all_field_names(pc, "PlayerCondition") end
                local hpc0 = get_hitpoint_controller(player)
                if hpc0 then dump_all_field_names(hpc0, "HitPointController") end
                for_each_slot(function(slot)
                    dump_all_field_names(slot, "库存槽")
                    dump_all_field_names(get_field(slot, "_Stock"), "库存槽._Stock")
                    dump_all_field_names(call_m(slot, { "get_InnerData" }), "库存槽.InnerData")
                    dump_all_field_names(call_m(slot, { "get_ExtendData" }), "库存槽.ExtendData")
                end, player, inventory)
            end)
        end
    end

    -- 生命
    local hpc = get_hitpoint_controller(player)
    if hpc then
        resolve(cache_hp, hpc, PAT_HP)
        local parts = {}
        for _, fname in ipairs(cache_hp.fields) do
            local v = get_field(hpc, fname)
            if type(v) == "number" then
                status.hp = v
                parts[#parts + 1] = string.format("%s=%s", fname, tostring(v))
            end
        end
        status.hp_note = table.concat(parts, "  ")
        -- 无敌: 优先使用游戏自带的无敌字段 (比 hook 更直接可靠)
        if state.god_mode then
            set_field(hpc, "<Invincible>k__BackingField", true)
            set_field(hpc, "<SecondInvincible>k__BackingField", true)
            set_field(hpc, "<NoDamage>k__BackingField", true)
            -- 只把血量维持在真实上限, 不再写 9999
            local max_hp = get_field(hpc, "<DefaultHitPoint>k__BackingField")
            if type(max_hp) == "number" and max_hp > 0 then
                local cur = get_field(hpc, "<CurrentHitPoint>k__BackingField")
                if type(cur) == "number" and cur ~= max_hp then
                    set_field(hpc, "<CurrentHitPoint>k__BackingField", max_hp)
                end
            end
        end
    end

    -- 装备武器 / 弹药
    if state.ammo then
        local note = nil
        local ok, fname, v, wrote = freeze_fields(weapon, cache_ammo, PAT_AMMO, 9999)
        if ok and wrote > 0 then
            note = string.format("weapon %s = %s", tostring(fname), tostring(v))
        end
        -- 库存中的武器槽 (弹药/备弹)
        for_each_slot(function(slot)
            if call_m(slot, { "get_IsWeapon" }) and not call_m(slot, { "get_AlwaysReloadable" }) then
                local sok, sfn, sv, swrote = freeze_number(slot, cache_slot, 9999, true)
                if sok and swrote then
                    note = string.format("slot %s = %s", tostring(sfn), tostring(sv))
                end
            end
        end, player, inventory)
        status.ammo_note = note or ""
    end

    -- 消耗品 (药草/弹药盒/手雷等)
    if state.items then
        local im = get_item_manager()
        for_each_slot(function(slot)
            if call_m(slot, { "get_IsItem" }) then
                local iid = call_m(slot, { "get_ItemID" })
                local removable = true
                if im and iid ~= nil then
                    local key = tostring(iid)
                    if removable_cache[key] == nil then
                        local r = call_m(im, { "getItemRemovable" }, iid)
                        removable_cache[key] = (r == nil) and true or r
                    end
                    removable = removable_cache[key]
                end
                -- 跳过剧情钥匙类物品, 避免干扰解谜
                if removable then
                    freeze_number(slot, cache_slot, 99, true)
                end
            end
        end, player, inventory)
    end

    -- 小刀耐久: 耐久字段尚未确认, 先探测并记录候选, 不盲目写未知对象。
    -- 只有装备 Melee 类武器时才探测, 避免把其他武器的 RemainingVital 当成小刀。
    if state.knife then
        local is_melee = status.weapon ~= nil
            and string.find(string.lower(tostring(status.weapon)), "melee", 1, true) ~= nil
        if is_melee then
            local vital_note = nil
            probe_durability(weapon, "当前武器")
            for_each_slot(function(slot)
                if call_m(slot, { "get_IsWeapon" }) then
                    probe_durability(slot, "Slot")
                    probe_durability(get_field(slot, "_Stock"), "Slot._Stock")
                    probe_durability(call_m(slot, { "get_InnerData" }), "Slot.InnerData")
                    probe_durability(call_m(slot, { "get_ExtendData" }), "Slot.ExtendData")
                    local vital = call_m(slot, { "get_RemainingVital" })
                    if type(vital) == "number" then
                        vital_note = string.format("RemainingVital=%s ratio=%s",
                            tostring(vital), tostring(call_m(slot, { "get_RemainingVitalRatio" })))
                    end
                end
            end, player, inventory)
            status.knife_note = vital_note or ""
        else
            status.knife_note = ""
        end
    end
end

----------------------------------------------------------------------
-- 转储 (排错用): 导出关键对象的类型/字段/方法到文本
----------------------------------------------------------------------
local function dump_type_info(obj, label, out)
    out[#out + 1] = string.rep("=", 60)
    out[#out + 1] = "## " .. label
    if obj == nil then
        out[#out + 1] = "  (对象为空)"
        return
    end
    out[#out + 1] = "类型: " .. tostring(type_name(obj))
    local ok, td = pcall(function() return obj:get_type_definition() end)
    if not ok or not td then return end
    local td_root = td

    local depth = 0
    while td and depth < 8 do
        local tn = "?"
        pcall(function() tn = td:get_full_name() end)
        out[#out + 1] = "-- 字段 [" .. tostring(tn) .. "]"
        local ok_f, fields = pcall(function() return td:get_fields() end)
        if ok_f and fields then
            for _, f in ipairs(fields) do
                local fname
                pcall(function() fname = f:get_name() end)
                if fname then
                    local v = get_field(obj, fname)
                    out[#out + 1] = string.format("   %s = %s (%s)", fname, tostring(v), type(v))
                end
            end
        end
        local ok_p, parent = pcall(function() return td:get_parent_type() end)
        td = (ok_p and parent) or nil
        depth = depth + 1
    end

    local ok_m, methods = pcall(function() return td_root:get_methods() end)
    if ok_m and methods then
        local names, cap = {}, 0
        for _, m in ipairs(methods) do
            local mname
            pcall(function() mname = m:get_name() end)
            if mname then
                names[#names + 1] = mname
                cap = cap + 1
                if cap >= 250 then break end
            end
        end
        out[#out + 1] = "-- 方法: " .. table.concat(names, ", ")
    end
end

----------------------------------------------------------------------
-- 道具箱/物品探针 (只读)
-- 目标: 为“从道具箱取出物品 / 发放物品”采集真实字段与方法签名。
-- 本版只读, 不写任何道具数据; 先确认 API, 再实现写入。
----------------------------------------------------------------------
local ITEM_ID_FIELDS = {
    "_ItemID", "<ItemID>k__BackingField", "ItemID",
    "_ItemId", "<ItemId>k__BackingField", "ItemId",
}
local ITEM_COUNT_FIELDS = {
    "_Number", "<Number>k__BackingField", "Number",
    "_Count", "<Count>k__BackingField", "Count",
}
local ITEM_LIST_FIELDS = {
    "_Items", "<Items>k__BackingField", "Items",
    "_Items2nd", "_Items_2nd", "<Items_2nd>k__BackingField", "Items_2nd",
}
local ITEM_LIST_GETTERS = {
    "get_Items", "getItems", "get_Items_2nd", "getItems_2nd",
}

local function find_type_any(names)
    for _, n in ipairs(names) do
        local ok, td = pcall(sdk.find_type_definition, n)
        if ok and td ~= nil then return td, n end
    end
    return nil
end

local function first_number(obj, fields, getters)
    for _, f in ipairs(fields) do
        local v = get_field(obj, f)
        if type(v) == "number" then return v end
    end
    if getters then
        for _, g in ipairs(getters) do
            local v = call_m(obj, { g })
            if type(v) == "number" then return v end
        end
    end
    return nil
end

local function first_object(obj, fields, getters)
    for _, f in ipairs(fields) do
        local v = get_field(obj, f)
        if v ~= nil then return v, "field:" .. f end
    end
    if getters then
        for _, g in ipairs(getters) do
            local v = call_m(obj, { g })
            if v ~= nil then return v, "call:" .. g end
        end
    end
    return nil
end

local function list_count(list)
    local n = call_m(list, { "get_Count", "get_Length", "get_count", "get_size" })
    if type(n) == "number" then return n end
    n = get_field(list, "_size")
    if type(n) == "number" then return n end
    n = get_field(list, "size")
    if type(n) == "number" then return n end
    return nil
end

local function list_item(list, i)
    return call_m(list, { "get_Item", "get_item" }, i)
end

local function type_full_name(t)
    if t == nil then return "?" end
    local ok, n = pcall(function() return t:get_full_name() end)
    if ok and n then return n end
    local ok2, n2 = pcall(function() return t:call("get_FullName") end)
    if ok2 and n2 then return tostring(n2) end
    local ok3, n3 = pcall(function() return t:call("get_Name") end)
    if ok3 and n3 then return tostring(n3) end
    return tostring(t)
end

local function dump_method_signatures(td, label, filter, out)
    out[#out + 1] = "-- 方法签名 [" .. label .. "]"
    if td == nil then
        out[#out + 1] = "   (类型未找到)"
        return
    end
    local ok, methods = pcall(function() return td:get_methods() end)
    if not ok or not methods then
        out[#out + 1] = "   (无法枚举方法)"
        return
    end
    local seen = {}
    for _, m in ipairs(methods) do
        local name
        pcall(function() name = m:get_name() end)
        if name and filter(name) then
            local params = {}
            local okp, pts = pcall(function() return m:get_param_types() end)
            if okp and pts then
                for _, pt in ipairs(pts) do
                    params[#params + 1] = type_full_name(pt)
                end
            end
            local ret = "?"
            local okr, r = pcall(function() return m:get_return_type() end)
            if okr then ret = type_full_name(r) end
            local sig = string.format("%s(%s) -> %s", name,
                table.concat(params, ", "), ret)
            if not seen[sig] then
                seen[sig] = true
                out[#out + 1] = "   " .. sig
            end
        end
    end
end

local function get_item_locker_manager()
    local names = { "gamemastering.ItemLockerManager", "ItemLockerManager" }
    for _, n in ipairs(names) do
        local full = sdk.game_namespace(n)
        local ok, mgr = pcall(sdk.get_managed_singleton, full)
        if ok and mgr ~= nil then return mgr, full end
        ok, mgr = pcall(sdk.get_managed_singleton, n)
        if ok and mgr ~= nil then return mgr, n end
    end
    return nil, nil
end

local function get_item_box_save_data(mgr)
    if mgr == nil then return nil, nil end
    return first_object(mgr,
        { "<GameSaveData>k__BackingField", "_GameSaveData", "GameSaveData", "gameSaveData",
          "<SaveData>k__BackingField", "_SaveData", "SaveData" },
        { "get_GameSaveData", "get_gameSaveData", "get_SaveData", "getSaveData" })
end

local function get_item_box_list(save_data)
    if save_data == nil then return nil, nil end
    return first_object(save_data, ITEM_LIST_FIELDS, ITEM_LIST_GETTERS)
end

-- 类型定义转储: 不需要实例, 直接列出字段/方法签名
local function dump_type_definition(td, label, out)
    out[#out + 1] = string.rep("-", 50)
    out[#out + 1] = "-- 类型定义 [" .. label .. "]"
    if td == nil then
        out[#out + 1] = "   (类型未找到)"
        return
    end
    out[#out + 1] = "   " .. type_full_name(td)
    local okf, fields = pcall(function() return td:get_fields() end)
    if okf and fields then
        for _, f in ipairs(fields) do
            local name, ftype
            pcall(function() name = f:get_name() end)
            local okt, t = pcall(function() return f:get_type() end)
            if okt then ftype = type_full_name(t) end
            out[#out + 1] = string.format("   字段 %s : %s",
                tostring(name), tostring(ftype))
        end
    end
    dump_method_signatures(td, label .. " 方法", function() return true end, out)
end

-- GameSaveData.SaveData 才是 ItemLockerSaveData; 逐层解开直到找到 get_Items()/_Items
local function unwrap_item_box_save_data(sd, out)
    local cur = sd
    for level = 1, 4 do
        if cur == nil then return nil end
        local list = first_object(cur, ITEM_LIST_FIELDS, ITEM_LIST_GETTERS)
        if list ~= nil and list_count(list) ~= nil then
            return cur
        end
        local inner, how = first_object(cur,
            { "SaveData", "_SaveData", "<SaveData>k__BackingField" },
            { "get_SaveData", "getSaveData" })
        if inner == nil or inner == cur then return cur end
        if out ~= nil then
            out[#out + 1] = string.format(
                "  SaveData 层级 %d: 来源=%s 类型=%s",
                level, tostring(how), tostring(type_name(inner)))
            dump_type_info(inner, "ItemLocker SaveData 层级 " .. level, out)
        end
        cur = inner
    end
    return cur
end

local function item_name_of(im, id)
    if im == nil or type(id) ~= "number" then return nil end
    local name = call_m(im, { "getItemName", "getItemNameMsgID" }, id)
    if type(name) == "string" and name ~= "" then return name end
    return nil
end

local function probe_item_box(out)
    out[#out + 1] = string.rep("=", 60)
    out[#out + 1] = "## 道具箱/物品探针 (只读)"

    local im = get_item_manager()
    local mgr, mgr_name = get_item_locker_manager()
    if mgr == nil then
        out[#out + 1] = "ItemLockerManager: 未找到单例"
    else
        out[#out + 1] = "ItemLockerManager: " .. tostring(mgr_name)
        dump_type_info(mgr, "ItemLockerManager", out)
    end

    local sd, sd_how = get_item_box_save_data(mgr)
    if sd == nil then
        out[#out + 1] = "GameSaveData: 未找到"
    else
        out[#out + 1] = "GameSaveData 来源: " .. tostring(sd_how)
        dump_type_info(sd, "ItemLockerManager.GameSaveData", out)
        -- GameSaveData 只暴露 SaveData; 真正的 ItemLockerSaveData 在下一层
        sd = unwrap_item_box_save_data(sd, out)
    end

    local list, list_how = get_item_box_list(sd)
    if list == nil then
        out[#out + 1] = "_Items: 未找到"
    else
        local n = list_count(list)
        out[#out + 1] = string.format("_Items 来源=%s 类型=%s count=%s",
            tostring(list_how), tostring(type_name(list)), tostring(n))
        if type(n) == "number" then
            local shown = math.min(n, 40)
            for i = 0, shown - 1 do
                local e = list_item(list, i)
                if e ~= nil then
                    local id = first_number(e, ITEM_ID_FIELDS,
                        { "get_ItemID", "get_ItemId", "getItemID", "getItemId" })
                    local count = first_number(e, ITEM_COUNT_FIELDS,
                        { "get_Number", "get_Count", "getNumber", "getCount" })
                    local nm = item_name_of(im, id)
                    out[#out + 1] = string.format("  #%d id=%s count=%s name=%s type=%s",
                        i, tostring(id), tostring(count), tostring(nm), tostring(type_name(e)))
                    if i == 0 then
                        dump_type_info(e, "道具箱条目 #0", out)
                    end
                else
                    out[#out + 1] = string.format("  #%d (nil)", i)
                end
            end
            if n > shown then
                out[#out + 1] = string.format("  ... 其余 %d 条省略", n - shown)
            end
        end
    end

    -- 第二列表 (ItemLockerSaveData.get_Items_2nd)
    local list2 = first_object(sd,
        { "_Items_2nd", "<Items_2nd>k__BackingField", "Items_2nd" },
        { "get_Items_2nd", "getItems_2nd" })
    if list2 ~= nil then
        local n2 = list_count(list2)
        out[#out + 1] = string.format("_Items_2nd 类型=%s count=%s",
            tostring(type_name(list2)), tostring(n2))
        if type(n2) == "number" then
            for i = 0, math.min(n2, 10) - 1 do
                local e = list_item(list2, i)
                if e ~= nil then
                    local id = first_number(e, ITEM_ID_FIELDS,
                        { "get_ItemID", "get_ItemId", "getItemID", "getItemId" })
                    local count = first_number(e, ITEM_COUNT_FIELDS,
                        { "get_Number", "get_Count", "getNumber", "getCount" })
                    out[#out + 1] = string.format("  #%d id=%s count=%s name=%s",
                        i, tostring(id), tostring(count), tostring(item_name_of(im, id)))
                end
            end
        end
    end

    local inv_td = find_type_any({ sdk.game_namespace("survivor.Inventory"), "offline.survivor.Inventory" })
    local slot_td = find_type_any({ sdk.game_namespace("inventory.Slot"), "offline.inventory.Slot" })
    local im_td = find_type_any({ sdk.game_namespace("gamemastering.ItemManager"), "offline.gamemastering.ItemManager" })
    local mgr_td = find_type_any({ sdk.game_namespace("gamemastering.ItemLockerManager"), "offline.gamemastering.ItemLockerManager" })
    local gsd_td = find_type_any({
        "offline.gamemastering.ItemLockerManager.GameSaveData",
        "offline.gamemastering.ItemLockerManager+GameSaveData",
    })
    local locker_td = find_type_any({
        "offline.gimmick.action.GimmickItemLockerControl.ItemLockerSaveData",
        "offline.gimmick.action.GimmickItemLockerControl+ItemLockerSaveData",
        "offline.gamemastering.ItemLockerSaveData",
    })

    local inv_filter = {
        setSlot = true, putSlot = true, getSlot = true, addSlotNumber = true,
        equipSlot = true, removeSlot = true, exchangeSlot = true,
        getNumber = true, getItemID = true, getWeaponType = true,
        isBlankSlot = true, isFatSlot = true, isDeadSlot = true,
        getSlotType = true, get_CurrentSlotSize = true, get_MainSlot = true,
        get_MainSlotSurplusBulletID = true, set_MainSlotSurplusBulletNumber = true,
    }
    dump_method_signatures(inv_td, "Inventory", function(n) return inv_filter[n] == true end, out)

    local slot_filter = {
        set = true, put = true, fill = true, add = true,
        set_ItemID = true, set_Number = true, set_WeaponType = true, set_WeaponParts = true,
        get_ItemID = true, get_Number = true, get_WeaponType = true, get_WeaponParts = true,
        get_InnerData = true, get_ExtendData = true, get_RemainingVital = true,
        get_IsItem = true, get_IsWeapon = true, get_IsBlank = true, get_HasStock = true,
    }
    dump_method_signatures(slot_td, "Slot", function(n) return slot_filter[n] == true end, out)

    local im_filter = {
        getItemName = true, getWeaponName = true, getItemNameMsgID = true,
        instantiateItem = true, instantiateWeapon = true,
        getItemType = true, getItemRemovable = true, getItemMultipleUseMax = true,
    }
    dump_method_signatures(im_td, "ItemManager", function(n) return im_filter[n] == true end, out)

    local mgr_filter = function(n)
        return string.find(n, "Item", 1, true) ~= nil
            or string.find(n, "Save", 1, true) ~= nil
            or string.find(n, "Stock", 1, true) ~= nil
            or string.find(n, "Slot", 1, true) ~= nil
            or string.find(n, "Strage", 1, true) ~= nil
            or string.find(n, "Storage", 1, true) ~= nil
            or string.find(n, "Weapon", 1, true) ~= nil
    end
    dump_method_signatures(mgr_td, "ItemLockerManager", mgr_filter, out)
    dump_method_signatures(gsd_td, "ItemLockerManager.GameSaveData", function() return true end, out)
    dump_method_signatures(locker_td, "GimmickItemLockerControl.ItemLockerSaveData", function() return true end, out)

    -- 写入/读取物品所需的数据类型
    dump_type_definition(find_type_any({ "offline.gamemastering.InventoryManager.ItemData" }),
        "InventoryManager.ItemData", out)
    dump_type_definition(find_type_any({ "offline.gamemastering.InventoryManager.StockItem" }),
        "InventoryManager.StockItem", out)
    dump_type_definition(find_type_any({ "offline.gamemastering.InventoryManager.PrimitiveItem" }),
        "InventoryManager.PrimitiveItem", out)
    dump_type_definition(find_type_any({ "offline.gamemastering.InventoryManager.ItemExData" }),
        "InventoryManager.ItemExData", out)
    dump_type_definition(find_type_any({ "offline.inventory.Vital" }),
        "inventory.Vital", out)
end

local function write_item_probe()
    local out = {}
    probe_item_box(out)
    local ok = pcall(fs.write, ITEM_PROBE_FILE, table.concat(out, "\n"))
    if ok then
        log.info("[RE3Trainer] 道具箱探针已写入: " .. ITEM_PROBE_FILE)
    else
        log.error("[RE3Trainer] 道具箱探针写入失败: " .. ITEM_PROBE_FILE)
    end
end

----------------------------------------------------------------------
-- 道具箱读取 + 取出普通物品
-- 已由实机探针确认:
--   ItemLockerManager.gameSaveData.SaveData
--     -> ItemLockerSaveData._Items / _Items2nd (List<ItemData>, 400 格)
--   ItemData: get_ItemId / get_Count / getName / isBlank / isWeaponAll /
--             DefaultItem(PrimitiveItem) / ExData(ItemExData) / setBlank()
--   Inventory.setSlot(index, itemID, count, PrimitiveItem, ItemExData) -> bool
--   Slot.set(itemID, count, PrimitiveItem, ItemExData) -> bool
----------------------------------------------------------------------
local function item_box_entry_blank(e)
    if e == nil then return true end
    if call_m(e, { "isBlank" }) == true then return true end
    local id = call_m(e, { "get_ItemId" })
    local wt = call_m(e, { "get_WeaponId" })
    local count = call_m(e, { "get_Count" })
    local has_item = type(id) == "number" and id > 0
    local has_weapon = type(wt) == "number" and wt > 0
    if has_weapon then return false end -- 武器即使 0 发也不算空
    if has_item then
        return not (type(count) == "number" and count > 0)
    end
    return true
end

local function refresh_item_box()
    local snap = { known = false, error = "", entries = {} }
    local mgr = get_item_locker_manager()
    if mgr == nil then
        snap.error = "未找到 ItemLockerManager"
        status.item_box = snap
        return false, snap.error
    end
    local gsd = get_item_box_save_data(mgr)
    if gsd == nil then
        snap.error = "未找到 GameSaveData"
        status.item_box = snap
        return false, snap.error
    end
    local sd = unwrap_item_box_save_data(gsd, nil)
    if sd == nil then
        snap.error = "未找到 ItemLockerSaveData"
        status.item_box = snap
        return false, snap.error
    end

    local im = get_item_manager()
    local lists = {
        { label = "_Items", list = first_object(sd, ITEM_LIST_FIELDS, ITEM_LIST_GETTERS) },
        { label = "_Items2nd", list = first_object(sd,
            { "_Items2nd", "_Items_2nd", "<Items_2nd>k__BackingField", "Items_2nd" },
            { "get_Items_2nd", "getItems_2nd" }) },
    }

    for li, item in ipairs(lists) do
        local list = item.list
        if list ~= nil then
            local n = list_count(list)
            if type(n) == "number" then
                for i = 0, n - 1 do
                    local e = list_item(list, i)
                    if e ~= nil and not item_box_entry_blank(e) then
                        local id = call_m(e, { "get_ItemId" })
                        local count = call_m(e, { "get_Count" })
                        local weapon = call_m(e, { "isWeaponAll" }) == true
                        local wt_raw = weapon and call_m(e, { "get_WeaponId" }) or nil
                        local weapon_type = (type(wt_raw) == "number")
                            and wt_raw or tonumber(wt_raw)
                        local valid_item = type(id) == "number" and id > 0
                        local valid_weapon = weapon
                            and type(weapon_type) == "number" and weapon_type > 0
                        if valid_weapon or (valid_item and type(count) == "number" and count > 0) then
                            local name = call_m(e, { "getName" })
                            if type(name) ~= "string" or name == "" then
                                if valid_weapon then
                                    name = call_m(im, { "getWeaponName" }, weapon_type, 0)
                                else
                                    name = item_name_of(im, id)
                                end
                                if type(name) ~= "string" or name == "" then
                                    name = "ID " .. tostring(valid_weapon and weapon_type or id)
                                end
                            end
                            snap.entries[#snap.entries + 1] = {
                                obj = e, id = id, count = count, name = name,
                                weapon = weapon, weapon_type = weapon_type, list = li,
                            }
                        end
                    end
                end
            end
        end
    end

    snap.known = true
    status.item_box = snap
    log.info(string.format("[RE3Trainer] 道具箱刷新: %d 件", #snap.entries))
    return true
end

local function find_free_inventory_slot(inv)
    if inv == nil then return nil end
    local n = call_m(inv, { "get_CurrentSlotSize" })
    if type(n) ~= "number" then return nil end
    for i = 0, n - 1 do
        local slot = call_m(inv, { "getSlot" }, i)
        local blank = call_m(inv, { "isBlankSlot" }, i)
        if blank == nil and slot ~= nil then
            blank = call_m(slot, { "get_IsBlank" })
        end
        local dead = call_m(inv, { "isDeadSlot" }, i)
        if dead == nil and slot ~= nil then
            dead = call_m(slot, { "get_IsDeadSlot" })
        end
        local force_blank = slot and call_m(slot, { "get_IsForceBlank" })
        if blank == true and dead ~= true and force_blank ~= true then
            return i
        end
    end
    return nil
end

local function take_box_item(info)
    if info == nil or info.obj == nil then return false end
    if info.weapon then
        log.warn("[RE3Trainer] 武器取出暂未实现: " .. tostring(info.name))
        return false
    end
    local fm = get_flow_manager()
    if call_m(fm, { "get_IsInGame" }) ~= true
        or call_m(fm, { "get_IsInPause" }) ~= true then
        log.warn("[RE3Trainer] 请先在游戏中暂停 (Esc), 再取出物品")
        return false
    end

    -- 重新读取并确认条目没有变化 (避免在错误的条目上操作)
    local id = call_m(info.obj, { "get_ItemId" })
    local count = call_m(info.obj, { "get_Count" })
    if id ~= info.id or count ~= info.count
        or call_m(info.obj, { "isBlank" }) == true then
        log.warn("[RE3Trainer] 道具箱条目已变化, 请刷新后重试")
        refresh_item_box()
        return false
    end

    local player = get_player()
    local inv = get_inventory(player)
    if inv == nil then
        log.warn("[RE3Trainer] 未找到 Inventory, 无法取出物品")
        return false
    end

    local slot_index = find_free_inventory_slot(inv)
    if slot_index == nil then
        log.warn("[RE3Trainer] 背包没有可用空格子, 无法取出 " .. tostring(info.name))
        return false
    end

    local primitive = get_field(info.obj, "DefaultItem")
    local exdata = get_field(info.obj, "ExData")

    -- 优先 Inventory.setSlot; 失败再试 Slot.set
    local ok = call_m(inv, { "setSlot" }, slot_index, id, count, primitive, exdata)
    local slot = call_m(inv, { "getSlot" }, slot_index)
    if ok ~= true and slot ~= nil then
        ok = call_m(slot, { "set" }, id, count, primitive, exdata)
    end
    if ok ~= true and slot ~= nil then
        ok = call_m(slot, { "set" }, id, count, nil, nil)
    end
    -- 有的重载返回 false/void 但实际写入成功; 以槽位读回为准
    if ok ~= true then
        local slot2 = call_m(inv, { "getSlot" }, slot_index)
        local sid = slot2 and call_m(slot2, { "get_ItemID" })
        local snum = slot2 and call_m(slot2, { "get_Number" })
        if sid == id and type(snum) == "number" and snum >= count then
            ok = true
        end
    end
    if ok ~= true then
        log.error(string.format("[RE3Trainer] 写入背包失败: %s (id=%d count=%d slot=%d)",
            tostring(info.name), id, count, slot_index))
        return false
    end

    -- 读回校验
    slot = call_m(inv, { "getSlot" }, slot_index)
    local got_id = slot and call_m(slot, { "get_ItemID" })
    local got_num = slot and call_m(slot, { "get_Number" })
    if got_id ~= id or (type(got_num) == "number" and got_num < count) then
        call_m(inv, { "removeSlot" }, slot_index)
        log.error(string.format("[RE3Trainer] 背包读回校验失败 (got id=%s count=%s), 已回滚",
            tostring(got_id), tostring(got_num)))
        return false
    end

    -- 清空道具箱条目; 失败则回滚背包, 绝不留下两份
    call_m(info.obj, { "setBlank" })
    if call_m(info.obj, { "isBlank" }) ~= true then
        call_m(inv, { "removeSlot" }, slot_index)
        log.error("[RE3Trainer] 道具箱条目清空失败, 已回滚背包")
        return false
    end

    log.info(string.format("[RE3Trainer] 已取出: %s x%d -> 背包槽 %d",
        tostring(info.name), count, slot_index))
    refresh_item_box()
    return true
end

-- 物品目录: 遍历 Item.ID (1..400), 用游戏自己的 getItemName 过滤无效项。
-- 不写任何数据; 只在用户点“加载物品列表”时执行一次。
local function build_item_catalog()
    local im = get_item_manager()
    if im == nil then
        log.warn("[RE3Trainer] 未找到 ItemManager, 无法加载物品列表")
        return false
    end
    local list = {}
    for id = 1, 400 do
        local name = call_m(im, { "getItemName" }, id)
        if type(name) == "string" and name ~= ""
            and not string.find(name, "Invalid Item", 1, true)
            and not string.match(name, "^sm%d") then
            list[#list + 1] = { id = id, name = name }
        end
    end
    status.item_catalog = list
    status.item_catalog_ready = true
    log.info(string.format("[RE3Trainer] 物品列表已加载: %d 项", #list))
    return true
end

local function inventory_count(inv, id)
    local n1 = call_m(inv, { "getNumber" }, id)
    local slot = call_m(inv, { "getSlot" }, id)
    local n2 = slot and call_m(slot, { "get_Number" })
    local a = (type(n1) == "number") and n1 or 0
    local b = (type(n2) == "number") and n2 or 0
    if a > 0 or b > 0 then return math.max(a, b) end
    return 0
end

-- 创建一个 PrimitiveItem(id, count), 供 setSlot/Slot.set 使用
local function new_primitive_item(id, count)
    local ok, prim = pcall(sdk.create_instance,
        "offline.gamemastering.InventoryManager.PrimitiveItem", true)
    if not ok or prim == nil then
        ok, prim = pcall(sdk.create_instance,
            "offline.gamemastering.InventoryManager.PrimitiveItem")
    end
    if not ok or prim == nil then return nil end
    local ok2 = pcall(function() prim:call("setItem", id, count) end)
    if not ok2 then
        set_field(prim, "ItemId", id)
        set_field(prim, "Count", count)
    end
    return prim
end

-- 刷取物品: 玩家尚未获得也可以直接写入背包。
-- 优先 Inventory.addSlotNumber (游戏自己的入包函数), 失败再创建
-- PrimitiveItem 走 setSlot/Slot.set; 写入后读回校验。
local function give_item(id, name, count)
    if type(id) ~= "number" or id <= 0 then
        log.warn("[RE3Trainer] 无效物品 ID")
        return false
    end
    if type(count) ~= "number" or count < 1 then count = 1 end
    count = math.floor(count)

    local fm = get_flow_manager()
    if call_m(fm, { "get_IsInGame" }) ~= true
        or call_m(fm, { "get_IsInPause" }) ~= true then
        log.warn("[RE3Trainer] 请先在游戏中暂停 (Esc), 再刷取物品")
        return false
    end

    local player = get_player()
    local inv = get_inventory(player)
    if inv == nil then
        log.warn("[RE3Trainer] 未找到 Inventory, 无法刷取物品")
        return false
    end

    local im = get_item_manager()
    local maxn = call_m(im, { "getItemMultipleUseMax" }, id)
    if type(maxn) == "number" and maxn == 0 then
        count = 1 -- 不可堆叠物品
    end

    local before = inventory_count(inv, id)

    -- 1) 已有同类物品: 先让游戏自己的入包函数叠加
    if before > 0 then
        local left = call_m(inv, { "addSlotNumber" }, id, count)
        local after = inventory_count(inv, id)
        if after > before then
            log.info(string.format("[RE3Trainer] 已刷取: %s x%d (addSlotNumber, 剩余 %s)",
                tostring(name or id), after - before, tostring(left)))
            refresh_item_box()
            return true
        end
    end

    -- 2) 新物品/叠加失败: 找空槽, 创建 PrimitiveItem, 用 setSlot/Slot.set
    local slot_index = find_free_inventory_slot(inv)
    if slot_index ~= nil then
        local prim = new_primitive_item(id, count)
        local ex = nil
        pcall(function()
            local ok, e = pcall(sdk.create_instance,
                "offline.gamemastering.InventoryManager.ItemExData", true)
            if ok and e ~= nil then ex = e end
        end)

        local ok = call_m(inv, { "setSlot" }, slot_index, id, count, prim, ex)
        local slot = call_m(inv, { "getSlot" }, slot_index)
        if ok ~= true and slot ~= nil then
            ok = call_m(slot, { "set" }, id, count, prim, ex)
        end
        if ok ~= true and slot ~= nil then
            ok = call_m(slot, { "set" }, id, count, nil, nil)
        end

        local sid = slot and call_m(slot, { "get_ItemID" })
        local snum = slot and call_m(slot, { "get_Number" })
        if ok == true or (sid == id and type(snum) == "number" and snum >= count) then
            log.info(string.format("[RE3Trainer] 已刷取: %s x%d -> 背包槽 %d",
                tostring(name or id), count, slot_index))
            refresh_item_box()
            return true
        end
    end

    -- 3) 最后再试一次 addSlotNumber (有些物品只能通过它入包)
    local left = call_m(inv, { "addSlotNumber" }, id, count)
    local after = inventory_count(inv, id)
    if after > before then
        log.info(string.format("[RE3Trainer] 已刷取: %s x%d (addSlotNumber, 剩余 %s)",
            tostring(name or id), after - before, tostring(left)))
        refresh_item_box()
        return true
    end

    log.error(string.format("[RE3Trainer] 刷取失败: %s (id=%d count=%d)",
        tostring(name or id), id, count))
    return false
end

-- 武器: 只刷单个; 刷前检查背包/装备和武器箱, 已有则不刷。
local function inventory_has_weapon(player, inv, wt)
    local found = false
    for_each_slot(function(slot)
        if call_m(slot, { "get_IsWeapon" })
            and call_m(slot, { "get_WeaponType" }) == wt then
            found = true
        end
    end, player, inv)
    if found then return true end
    local eq = get_equipment(player)
    if eq ~= nil and call_m(eq, { "hasWeapon" }, wt) == true then
        return true
    end
    return false
end

-- true=箱内已有, false=没有, nil=读不到武器箱
local function box_has_weapon(wt)
    local ok = refresh_item_box()
    if not ok then return nil end
    for _, e in ipairs(status.item_box.entries) do
        if e.weapon and e.weapon_type == wt then
            return true
        end
    end
    return false
end

local function build_weapon_catalog()
    local im = get_item_manager()
    if im == nil then
        log.warn("[RE3Trainer] 未找到 ItemManager, 无法加载武器列表")
        return false
    end
    local list = {}
    for wt = 1, 381 do
        local name = call_m(im, { "getWeaponName" }, wt, 0)
        if type(name) == "string" and name ~= ""
            and not string.find(name, "Invalid", 1, true)
            and not string.match(name, "^WP%d") then
            list[#list + 1] = { id = wt, name = name }
        end
    end
    status.weapon_catalog = list
    status.weapon_catalog_ready = true
    log.info(string.format("[RE3Trainer] 武器列表已加载: %d 项", #list))
    return true
end

local function give_weapon(wt, name)
    if type(wt) ~= "number" or wt <= 0 then
        log.warn("[RE3Trainer] 无效武器类型")
        return false
    end
    local fm = get_flow_manager()
    if call_m(fm, { "get_IsInGame" }) ~= true
        or call_m(fm, { "get_IsInPause" }) ~= true then
        log.warn("[RE3Trainer] 请先在游戏中暂停 (Esc), 再刷取武器")
        return false
    end

    local player = get_player()
    local inv = get_inventory(player)
    if inv == nil then
        log.warn("[RE3Trainer] 未找到 Inventory, 无法刷取武器")
        return false
    end

    if inventory_has_weapon(player, inv, wt) then
        log.warn("[RE3Trainer] 背包/装备中已有该武器, 不刷取: " .. tostring(name))
        return false
    end
    local in_box = box_has_weapon(wt)
    if in_box == nil then
        log.warn("[RE3Trainer] 无法读取武器箱, 为避免重复不刷取: " .. tostring(name))
        return false
    elseif in_box then
        log.warn("[RE3Trainer] 武器箱中已有该武器, 不刷取: " .. tostring(name))
        return false
    end

    local slot_index = find_free_inventory_slot(inv)
    if slot_index == nil then
        log.warn("[RE3Trainer] 背包没有可用空格子, 无法刷取武器")
        return false
    end

    local ex = nil
    pcall(function()
        local ok, e = pcall(sdk.create_instance,
            "offline.gamemastering.InventoryManager.ItemExData", true)
        if ok and e ~= nil then ex = e end
    end)

    -- 武器版签名:
    -- Inventory.setSlot(slot, WeaponType, WeaponParts, bulletItemID, count, ItemExData)
    -- Slot.set(WeaponType, WeaponParts, bulletItemID, count, ItemExData)
    local ok = call_m(inv, { "setSlot" }, slot_index, wt, 0, 0, 1, ex)
    local slot = call_m(inv, { "getSlot" }, slot_index)
    if ok ~= true and slot ~= nil then
        ok = call_m(slot, { "set" }, wt, 0, 0, 1, ex)
    end
    if ok ~= true and slot ~= nil then
        ok = call_m(slot, { "set" }, wt, 0, 0, 1, nil)
    end

    local found_after = inventory_has_weapon(player, inv, wt)
    if ok == true or found_after then
        log.info(string.format("[RE3Trainer] 已刷取武器: %s (WT %d) -> 背包槽 %d",
            tostring(name or wt), wt, slot_index))
        refresh_item_box()
        return true
    end

    log.error(string.format("[RE3Trainer] 武器刷取失败: %s (WT %d)",
        tostring(name or wt), wt))
    return false
end

local function write_dump()
    local out = {}
    out[#out + 1] = string.format("RE3 修改器对象转储  游戏=%s  TDB=%s",
        tostring(reframework.get_game_name()), tostring(sdk.get_tdb_version()))

    local player = get_player()
    dump_type_info(sdk.get_managed_singleton(sdk.game_namespace("PlayerManager")), "PlayerManager 单例", out)
    dump_type_info(player, "当前玩家对象", out)
    dump_type_info(get_hitpoint_controller(player), "HitPointController", out)
    dump_type_info(get_equipment(player), "Equipment", out)
    dump_type_info(get_weapon(player), "当前装备武器", out)
    dump_type_info(get_inventory(player), "Inventory", out)
    dump_type_info(get_item_manager(), "ItemManager 单例", out)
    dump_type_info(get_flow_manager(), "MainFlowManager 单例", out)

    -- 前 4 个库存槽, 便于确认物品/弹药字段
    local idx = 0
    for_each_slot(function(slot, i)
        if idx < 4 then
            dump_type_info(slot, "库存槽 #" .. tostring(i), out)
            out[#out + 1] = string.format(
                "  运行时: Number=%s Max=%s Vital=%s VitalRatio=%s Ratio=%s IsWeapon=%s AlwaysReloadable=%s",
                tostring(call_m(slot, { "get_Number" })),
                tostring(call_m(slot, { "get_MaxNumber" })),
                tostring(call_m(slot, { "get_RemainingVital" })),
                tostring(call_m(slot, { "get_RemainingVitalRatio" })),
                tostring(call_m(slot, { "get_RemainingRatio" })),
                tostring(call_m(slot, { "get_IsWeapon" })),
                tostring(call_m(slot, { "get_AlwaysReloadable" })))
            -- 耐久/弹药的真正数据很可能在内层对象上
            dump_type_info(get_field(slot, "_Stock"), "库存槽 #" .. tostring(i) .. " _Stock", out)
            dump_type_info(call_m(slot, { "get_InnerData" }), "库存槽 #" .. tostring(i) .. " InnerData", out)
            dump_type_info(call_m(slot, { "get_ExtendData" }), "库存槽 #" .. tostring(i) .. " ExtendData", out)
            idx = idx + 1
        end
    end)

    -- 道具箱/物品 API 探针 (只读, 不修改任何道具数据)
    pcall(function() probe_item_box(out) end)

    out[#out + 1] = string.rep("=", 60)
    local ok = pcall(fs.write, DUMP_FILE, table.concat(out, "\n"))
    if ok then
        log.info("[RE3Trainer] 对象转储已写入: " .. DUMP_FILE .. " (位于 reframework/data/)")
    else
        log.error("[RE3Trainer] 对象转储写入失败: " .. DUMP_FILE)
    end
end

----------------------------------------------------------------------
-- 设置存取
----------------------------------------------------------------------
local function save_cfg()
    pcall(json.dump_file, CFG_FILE, {
        god_mode = state.god_mode, ohk = state.ohk, ammo = state.ammo,
        items = state.items, knife = state.knife, dodge = state.dodge,
        speed_enabled = state.speed_enabled, speed = state.speed,
        standalone_ui = state.standalone_ui, ui_language = state.ui_language,
    })
end

local function load_cfg()
    local ok, cfg = pcall(json.load_file, CFG_FILE)
    if ok and type(cfg) == "table" then
        for k, v in pairs(cfg) do
            if state[k] ~= nil and type(state[k]) == type(v) then
                state[k] = v
            end
        end
    end
end

load_cfg()
-- 防止手改 JSON 写入 0/负数/超大倍率导致时间缩放异常
state.speed = math.max(0.1, math.min(5.0, tonumber(state.speed) or 0.5))
if state.ui_language ~= "zh" and state.ui_language ~= "en" then
    state.ui_language = "zh"
end
if not use_cjk then
    state.ui_language = "en" -- 没有中文字体时强制英文, 避免方块
end
re.on_config_save(save_cfg)

----------------------------------------------------------------------
-- 画面状态 HUD (d2d 插件): 热键切换后的即时反馈
-- 只用英文与拉丁字体, 不涉及 ImGui 字体图集
----------------------------------------------------------------------
local hud_font, d2d_registered = nil, false

local function hud_try_font(name)
    local ok, f = pcall(d2d.Font.new, name, 15)
    if ok and f ~= nil then return f end
    return nil
end

local function hud_init()
    -- d2d 的 Font.new 接受字体家族名。中文标签优先用 Windows 自带中文字体,
    -- 失败后再回退到原有拉丁字体, 保证热键至少能看到反馈。
    local candidates
    if use_cjk then
        candidates = { "Microsoft YaHei", "Microsoft YaHei UI",
                       "SimHei", "SimSun",
                       "NotoSansMono-SemiBold.ttf", "Consolas", "Arial" }
    else
        candidates = { "NotoSansMono-SemiBold.ttf", "Consolas", "Arial" }
    end
    for _, name in ipairs(candidates) do
        hud_font = hud_try_font(name)
        if hud_font ~= nil then
            log.info("[RE3Trainer] d2d HUD 字体: " .. name)
            break
        end
    end
    if not hud_font then
        log.warn("[RE3Trainer] d2d 字体加载失败, HUD 不可用")
    end
end

local function hud_draw()
    if not state.hud or not hud_font then return end
    local active = {}
    if state.god_mode      then active[#active + 1] = L("F1 无敌", "F1 God Mode") end
    if state.ohk           then active[#active + 1] = L("F2 一击必杀", "F2 One-Hit Kill") end
    if state.ammo          then active[#active + 1] = L("F3 无限弹药", "F3 Infinite Ammo") end
    if state.items         then active[#active + 1] = L("F4 无限物品", "F4 Infinite Items") end
    if state.knife         then active[#active + 1] = L("F5 小刀检测（未修改）", "F5 Knife Check (no changes)") end
    if state.dodge         then active[#active + 1] = L("F6 完美闪避", "F6 Perfect Dodge") end
    if state.speed_enabled then
        active[#active + 1] = L(string.format("F7 游戏速度 x%.2f", state.speed),
                                string.format("F7 Game Speed x%.2f", state.speed))
    end

    local x, y = 24, 24
    local function line(text, color)
        d2d.text(hud_font, text, x + 1, y + 1, 0xCC000000)
        d2d.text(hud_font, text, x, y, color)
        y = y + 20
    end
    line(L("RE3 修改器 · 已开启功能", "RE3 Trainer · Active"), 0xFFFFFFFF)
    if #active == 0 then
        line(L("当前没有开启功能", "No features enabled"), 0xFF909090)
    else
        for _, s in ipairs(active) do line(s, 0xFF00FF00) end
    end
end

----------------------------------------------------------------------
-- 热键 (边沿检测: 仅在按下的瞬间触发一次)
----------------------------------------------------------------------
-- 键盘接口:
--   1) reframework:is_key_down(vk) —— 冒号调用优先 (is_key_down 是
--      lambda 绑定, 冒号会正确传入 self; 点号作为兼容回退)。
--   2) get_keyboard_state() —— REFramework 返回 std::array<uint8_t,256>,
--      sol2 按值包装成 Lua 容器, 索引是 1 基: VK 码 vk 对应 [vk + 1]。
--      必须每帧重新取, 不能缓存一次快照。
--   3) get_first_key_down() —— 只返回当前第一个按下的键, 按住移动键
--      时热键可能不响应, 仅作最后兜底。
local KEY_API = nil             -- "colon" | "dot" | "state" | "first"
local key_api_logged = false
local key_api_warned = false

local function log_key_api()
    if key_api_logged then return end
    key_api_logged = true
    key_api_warned = false
    log.info("[RE3Trainer] 键盘接口: " .. tostring(KEY_API))
end

local function reset_key_api(reason)
    if KEY_API ~= nil then
        log.warn("[RE3Trainer] 键盘接口 " .. tostring(KEY_API)
            .. " 失效, 重新探测: " .. tostring(reason))
    end
    KEY_API = nil
    key_api_logged = false
end

-- 返回 ok, state; 不能用 nil 区分"调用失败"和"没有按键"
local function get_keyboard_state()
    local ok, st = pcall(function() return reframework:get_keyboard_state() end)
    if ok and st ~= nil then return true, st end
    ok, st = pcall(reframework.get_keyboard_state)
    if ok and st ~= nil then return true, st end
    return false, nil
end

-- 返回 ok, key (key 可能为 nil = 当前没有按键)
local function get_first_key_down()
    local ok, k = pcall(function() return reframework:get_first_key_down() end)
    if ok then return true, k end
    ok, k = pcall(reframework.get_first_key_down)
    if ok then return true, k end
    return false, nil
end

local function detect_key_api(vk)
    -- 1) 冒号形式 (lambda 绑定需要 self)
    local ok, v = pcall(function() return reframework:is_key_down(vk) end)
    if ok and type(v) == "boolean" then KEY_API = "colon"; return end

    -- 2) 点号形式 (某些 sol 版本会自动绑定 self)
    local ok2, v2 = pcall(reframework.is_key_down, vk)
    if ok2 and type(v2) == "boolean" then KEY_API = "dot"; return end

    -- 3) 每帧新取状态数组; 1 基索引
    local okst, st = get_keyboard_state()
    if okst and st ~= nil then
        local ok4, sv = pcall(function() return st[vk + 1] end)
        if ok4 and sv ~= nil then KEY_API = "state"; return end
    end

    -- 4) 最后兜底
    local okf = get_first_key_down()
    if okf then KEY_API = "first"; return end
end

-- 返回指定虚拟键码当前是否按下
local function raw_key_down(vk, retried)
    if KEY_API == nil then
        detect_key_api(vk)
        if KEY_API == nil then
            if not retried and not key_api_warned then
                key_api_warned = true
                log.warn("[RE3Trainer] 无可用键盘接口 —— 热键不可用, 请用菜单勾选")
            end
            return false, nil
        end
        log_key_api()
    end

    if KEY_API == "colon" then
        local ok, v = pcall(function() return reframework:is_key_down(vk) end)
        if ok and type(v) == "boolean" then return v, vk end
        reset_key_api("colon 调用失败")
    elseif KEY_API == "dot" then
        local ok, v = pcall(reframework.is_key_down, vk)
        if ok and type(v) == "boolean" then return v, vk end
        reset_key_api("dot 调用失败")
    elseif KEY_API == "state" then
        local okst, st = get_keyboard_state()
        if okst and st ~= nil then
            local ok, v = pcall(function() return st[vk + 1] end)
            if ok then
                -- 真实状态是 256 元素定长数组, 未按下返回 0;
                -- nil 也按"未按下"处理, 避免稀疏表触发误降级。
                return (v == true or v == 1), vk
            end
        end
        reset_key_api("get_keyboard_state 读取失败")
    elseif KEY_API == "first" then
        local okf, k = get_first_key_down()
        if okf then
            if type(k) == "userdata" then k = tonumber(k) end
            if k == nil then return false, nil end -- 当前没有按键
            if type(k) == "number" then
                return (k ~= 0 and k == vk), vk
            end
        end
        reset_key_api("get_first_key_down 调用失败")
    end

    if retried then return false, nil end
    return raw_key_down(vk, true)
end

local prev_key = {}
local function key_pressed(vk)
    local down = raw_key_down(vk)
    local was = prev_key[vk]
    prev_key[vk] = down
    return down and not was
end

local function toggle(name, label)
    state[name] = not state[name]
    log.info(string.format("[RE3Trainer] %s %s", label, state[name] and "开" or "关"))
    save_cfg()
end

----------------------------------------------------------------------
-- 主循环
----------------------------------------------------------------------
local err_count = 0
local function safe(fn, tag)
    local ok, err = pcall(fn)
    if not ok then
        err_count = err_count + 1
        if err_count <= 10 then
            log.error(string.format("[RE3Trainer] %s 出错: %s", tag, tostring(err)))
        end
    end
end

-- 独立窗口的绘制函数在 UI 段定义; 这里先做前向声明供 on_frame 调用
local draw_standalone_window = nil

-- 热键检测 (每帧; 边沿触发, 按下瞬间执行一次)
re.on_frame(function()
    -- 键盘接口在 raw_key_down() 内按需探测, 失败会自动重试

    -- d2d 插件可能晚于脚本加载, 惰性注册一次
    if not d2d_registered and d2d ~= nil then
        pcall(function()
            d2d.register(hud_init, hud_draw)
            d2d_registered = true
        end)
    end

    if key_pressed(VK.F1)  then toggle("god_mode", "无敌模式") end
    if key_pressed(VK.F2)  then toggle("ohk", "一击必杀") end
    if key_pressed(VK.F3)  then toggle("ammo", "无限弹药") end
    if key_pressed(VK.F4)  then toggle("items", "无限物品") end
    if key_pressed(VK.F5)  then toggle("knife", "小刀耐久检测") end
    if key_pressed(VK.F6)  then toggle("dodge", "完美闪避") end
    if key_pressed(VK.F7)  then toggle("speed_enabled", "游戏变速") end
    if key_pressed(VK.F8)  then safe(heal_to_full, "血量回满") end
    if key_pressed(VK.F9)  then toggle("hud", "状态HUD") end
    if key_pressed(VK.F10) then safe(write_dump, "导出转储") end
    if key_pressed(VK.F11) then toggle("standalone_ui", "独立窗口") end

    -- 独立窗口 (模仿 Raz0r 训练器的 separate window)
    if draw_standalone_window ~= nil then
        safe(draw_standalone_window, "独立窗口")
    end
end)

-- 游戏逻辑 (跟随引擎 UpdateBehavior 执行)
re.on_pre_application_entry("UpdateBehavior", function()
    safe(update_game, "游戏逻辑")
end)

----------------------------------------------------------------------
-- 设置界面 (REFramework 菜单 -> Script Generated UI)
----------------------------------------------------------------------
local function draw_feature(name, label, hotkey, hint)
    local changed, v = imgui.checkbox(
        label .. "  [" .. hotkey .. "]##feat_" .. name, state[name])
    if changed then
        state[name] = v
        log.info(string.format("[RE3Trainer] 菜单切换 %s -> %s", name, tostring(v)))
        save_cfg()
    end
    if hint then
        imgui.text_colored("    " .. hint, 0xFF909090)
    end
end

local function draw_ui_body()
    -- REFramework 只在它自己的菜单打开时把鼠标/键盘输入交给 ImGui。
    -- 独立窗口在菜单关闭时仍会绘制, 但按钮不可点击; 这里给出明确提示。
    if state.standalone_ui then
        local menu_open = false
        pcall(function() menu_open = reframework.is_drawing_ui() end)
        if not menu_open then
            imgui.text_colored(L(
                "现在只是显示，不能点击。按 Insert 打开 REFramework 菜单后即可操作。",
                "Display only right now; press Insert to open the REFramework menu and interact."),
                0xFFFF9040)
        end
    end

    -- ---- 运行状态 ----
    if not status.player then
        imgui.text_colored(L(
            "还没有进入游戏存档。请先载入一个存档，再使用修改器。",
            "No save loaded yet. Load a save first, then use the trainer."), 0xFFFF9040)
    else
        local st = status.in_game
            and (status.paused and L("游戏中（已暂停）", "In game (paused)")
                or L("游戏中（运行中）", "In game (running)"))
            or L("主菜单 / 载入中", "Main menu / Loading")
        imgui.text(string.format("%s：%s    %s：%s",
            L("游戏状态", "Game state"), st,
            L("当前武器", "Current weapon"), tostring(status.weapon)))
        if status.hp ~= nil then
            imgui.text(string.format("%s：%s", L("当前生命", "Current HP"), tostring(status.hp)))
        end
    end

    -- ---- 功能开关 ----
    imgui.spacing()
    imgui.text(L("功能开关（按 F 键或勾选）", "Features (press F-key or tick)"))
    draw_feature("god_mode", L("无敌（不会掉血）", "God Mode (no damage)"), "F1",
        L("[常驻] 玩家受到攻击也不掉血，生命保持在正常上限。若安装了 Auto-Dodge，这个开关看不出差别。",
          "[Always] No damage taken; HP stays at the normal maximum. If Auto-Dodge is installed, this switch makes no visible difference."))
    draw_feature("ohk", L("一击必杀（敌人一枪就死）", "One-Hit Kill (enemies die instantly)"), "F2",
        L("[战斗] 敌人受到伤害时直接放大到 99999；可能提前杀死剧情敌人，建议只在战斗时开启。",
          "[Combat] Enemy damage is raised to 99999; may kill story enemies early. Enable only during combat."))
    draw_feature("ammo", L("无限弹药（通常不用装填）", "Infinite Ammo (no reload needed)"), "F3",
        L("[常驻] 弹匣数量保持很高，通常不需要装填；备弹是否消耗取决于武器。",
          "[Always] Magazine count stays high; reload is usually unnecessary. Reserve ammo use depends on the weapon."))
    draw_feature("items", L("无限物品（消耗品不减少）", "Infinite Items (consumables don't decrease)"), "F4",
        L("[常驻] 药草、手雷、弹药盒等消耗品数量保持 99；钥匙和剧情道具不受影响。",
          "[Always] Herbs, grenades, ammo boxes and other consumables stay at 99; keys and story items are untouched."))
    draw_feature("knife", L("小刀耐久（目前只检测，不修改）", "Knife Durability (detect only, no changes)"), "F5",
        L("[仅检测] 目前只收集小刀耐久数据，开启后不会改变游戏数据；确认字段后才会实现不磨损。",
          "[Detect only] Collects knife durability data; does not change anything yet."))
    draw_feature("dodge", L("完美闪避（随时可闪避）", "Perfect Dodge (always available)"), "F6",
        L("[常驻] 让角色随时具备紧急闪避判定；可能影响部分敌人行为。",
          "[Always] Emergency dodge is always available; may affect some enemy behavior."))

    -- ---- 游戏速度 ----
    imgui.spacing()
    local ch7, v7 = imgui.checkbox(
        L("游戏速度（调快 / 调慢）", "Game Speed (faster / slower)") .. "  [F7]##game_speed",
        state.speed_enabled)
    if ch7 then
        state.speed_enabled = v7
        log.info(string.format("[RE3Trainer] 菜单切换 游戏速度 -> %s (x%.2f)",
            tostring(v7), state.speed))
        save_cfg()
    end
    if state.speed_enabled then
        imgui.text_colored(L("[随时] 0.10 = 很慢，1.00 = 正常，5.00 = 很快；只影响游戏时间。",
            "[Any time] 0.10 = very slow, 1.00 = normal, 5.00 = very fast; affects game time only."), 0xFF909090)
        local cs, vs = imgui.slider_float(
            L("速度倍率（1.00 = 正常）", "Speed (1.00 = normal)") .. "##speed",
            state.speed, 0.1, 5.0, "%.2f x")
        if cs then state.speed = vs; save_cfg() end
        imgui.same_line()
        if imgui.small_button(L("0.25x（慢动作）", "0.25x (slow motion)")) then
            state.speed = 0.25; save_cfg()
        end
        imgui.same_line()
        if imgui.small_button(L("0.5x（慢一点）", "0.5x (slower)")) then
            state.speed = 0.5; save_cfg()
        end
        imgui.same_line()
        if imgui.small_button(L("2x（快进）", "2x (faster)")) then
            state.speed = 2.0; save_cfg()
        end
    end

    -- ---- 快捷操作 ----
    imgui.spacing()
    imgui.text(L("快捷操作", "Quick Actions"))
    if imgui.button(L("回满血量（一次性）", "Heal to Full (one-time)") .. "  [F8]##heal") then
        safe(heal_to_full, "回满血量")
    end
    imgui.text_colored(L("把当前生命恢复到正常上限。",
        "Restores current HP to the normal maximum."), 0xFF909090)

    -- ---- 道具箱 ----
    imgui.spacing()
    imgui.text(L("游戏道具箱（可取出到背包）", "Item Box (take into inventory)"))
    imgui.text_colored(L("游戏里有两组道具箱数据，分别显示为 1 / 2。",
        "The game has two item-box lists, shown as 1 / 2."), 0xFF909090)
    if imgui.button(L("读取 / 刷新道具箱", "Read / Refresh Item Box") .. "##refresh_box") then
        safe(refresh_item_box, "刷新道具箱")
    end
    imgui.same_line()
    if status.item_box.known then
        imgui.text(string.format(L("道具箱里有 %d 件物品", "%d items in the item box"),
            #status.item_box.entries))
    elseif status.item_box.error ~= "" then
        imgui.text_colored(status.item_box.error, 0xFFFF9040)
    else
        imgui.text_colored(L("还没有读取。点“读取 / 刷新道具箱”查看。",
            "Not read yet. Click “Read / Refresh Item Box”."), 0xFF909090)
    end
    if status.item_box.known and #status.item_box.entries > 0 then
        imgui.text_colored(L("先按 Esc 暂停游戏，再点“放入背包”；取出后请手动保存。",
            "Press Esc to pause first, then click “Put in inventory”; save afterwards."), 0xFF909090)
        for i, e in ipairs(status.item_box.entries) do
            imgui.text(string.format(L("道具箱 %d：%s x%d", "Box %d: %s x%d"),
                e.list, e.name, e.count))
            imgui.same_line()
            if e.weapon then
                imgui.begin_disabled(true)
                imgui.small_button(L("放入背包", "Put in inventory") .. "##take" .. i)
                imgui.end_disabled()
                imgui.same_line()
                imgui.text_colored(L("武器请到游戏里的道具箱取出（这里只显示）",
                    "Use the in-game item box for weapons (display only here)"), 0xFF909090)
            else
                if imgui.small_button(L("放入背包", "Put in inventory") .. "##take" .. i) then
                    safe(function() take_box_item(e) end, "取出物品")
                end
            end
        end
    end

    -- ---- 刷取物品 ----
    imgui.spacing()
    imgui.text(L("刷取物品（直接放入背包，未获得的也能刷）",
        "Give Items (directly to inventory, even if not owned)"))
    imgui.text_colored(L("注意：钥匙、剧情道具可能导致卡关或剧情异常；建议先备份存档。",
        "Warning: keys/story items may break progression; back up your save first."), 0xFF909090)
    local cf, vf = imgui.input_text(
        L("搜索物品名称或编号", "Search item name or number") .. "##item_filter",
        state.item_filter or "", 0)
    if cf then state.item_filter = vf end
    imgui.same_line()
    local cc, vc = imgui.slider_int(
        L("刷取数量（1~999）", "Amount (1-999)") .. "##give_count",
        state.give_count, 1, 999, "%d")
    if cc then state.give_count = vc end

    if not status.item_catalog_ready then
        if imgui.button(L("加载可刷取物品列表（首次使用点这里）",
            "Load item list (click here first)") .. "##load_catalog") then
            safe(build_item_catalog, "加载物品列表")
        end
    else
        imgui.text(string.format(L("可刷取物品：%d 项", "Available items: %d"),
            #status.item_catalog))
        imgui.same_line()
        if imgui.button(L("重新加载列表", "Reload list") .. "##reload_catalog") then
            safe(build_item_catalog, "刷新物品列表")
        end

        local filter = string.lower(state.item_filter or "")
        local shown = 0
        local use_child = Vector2f ~= nil
        if use_child then
            imgui.begin_child_window(Vector2f.new(0, 240), true, 0)
        end
        for _, item in ipairs(status.item_catalog) do
            local hay = string.lower(item.name .. " " .. tostring(item.id))
            if filter == "" or string.find(hay, filter, 1, true) then
                imgui.text(string.format(L("%s（编号 %d）", "%s (No. %d)"),
                    item.name, item.id))
                imgui.same_line()
                if imgui.small_button(L("放入背包", "Put in inventory") .. "##give" .. item.id) then
                    safe(function() give_item(item.id, item.name, state.give_count) end,
                        "刷取物品")
                end
                shown = shown + 1
                if shown >= 300 then break end
            end
        end
        if use_child then imgui.end_child_window() end
        if shown == 0 then
            imgui.text_colored(L("没有找到匹配的物品，换个关键词试试。",
                "No matching items. Try another keyword."), 0xFF909090)
        end
    end

    -- ---- 刷取武器 ----
    imgui.spacing()
    imgui.text(L("刷取武器（每次一把，直接放入背包）",
        "Give Weapon (one at a time, direct to inventory)"))
    imgui.text_colored(L("刷前会自动检查背包、装备和游戏道具箱；已有该武器就不会再刷。武器无配件、1 发弹药。只建议刷玩家武器；敌人/未知武器可能导致崩溃。",
        "Checks inventory, equipment and the item box first; refuses if already owned. No parts, 1 round. Only player weapons are recommended; enemy/unknown weapons may crash the game."), 0xFF909090)
    local wf, wv = imgui.input_text(
        L("搜索武器名称或编号", "Search weapon name or number") .. "##weapon_filter",
        state.weapon_filter or "", 0)
    if wf then state.weapon_filter = wv end
    if not status.weapon_catalog_ready then
        if imgui.button(L("加载可刷取武器列表（首次使用点这里）",
            "Load weapon list (click here first)") .. "##load_weapons") then
            safe(build_weapon_catalog, "加载武器列表")
        end
    else
        imgui.text(string.format(L("可刷取武器：%d 项", "Available weapons: %d"),
            #status.weapon_catalog))
        imgui.same_line()
        if imgui.button(L("重新加载列表", "Reload list") .. "##reload_weapons") then
            safe(build_weapon_catalog, "刷新武器列表")
        end
        local filter = string.lower(state.weapon_filter or "")
        local shown = 0
        local use_child = Vector2f ~= nil
        if use_child then
            imgui.begin_child_window(Vector2f.new(0, 200), true, 0)
        end
        for _, w in ipairs(status.weapon_catalog) do
            local hay = string.lower(w.name .. " " .. tostring(w.id))
            if filter == "" or string.find(hay, filter, 1, true) then
                imgui.text(string.format(L("%s（武器编号 %d）", "%s (Weapon No. %d)"),
                    w.name, w.id))
                imgui.same_line()
                if imgui.small_button(L("放入背包", "Put in inventory") .. "##givew" .. w.id) then
                    safe(function() give_weapon(w.id, w.name) end, "刷取武器")
                end
                shown = shown + 1
                if shown >= 300 then break end
            end
        end
        if use_child then imgui.end_child_window() end
        if shown == 0 then
            imgui.text_colored(L("没有找到匹配的武器，换个关键词试试。",
                "No matching weapons. Try another keyword."), 0xFF909090)
        end
    end

    -- ---- 显示与语言 ----
    imgui.spacing()
    imgui.text(L("显示与语言", "Display & Language"))
    local ch, vh = imgui.checkbox(
        L("在屏幕左上角显示已开启功能（F9）",
          "Show active features at the top-left (F9)") .. "##hud",
        state.hud)
    if ch then state.hud = vh; save_cfg() end

    local chw, vw = imgui.checkbox(
        L("使用独立窗口（F11）", "Use a separate window (F11)") .. "##standalone",
        state.standalone_ui)
    if chw then state.standalone_ui = vw; save_cfg() end
    if state.standalone_ui then
        imgui.text_colored(L("独立窗口已开启。按 F11 关闭；要点击按钮，请先按 Insert 打开 REFramework 菜单。",
            "Separate window is open. F11 closes it; press Insert to open the REFramework menu before clicking buttons."), 0xFF909090)
    end

    imgui.spacing()
    imgui.text(L("界面语言（默认中文）", "UI Language (Chinese by default)"))
    local lang_changed = false
    if use_cjk then
        local lzh, vzh = imgui.checkbox(
            L("中文界面", "Chinese UI") .. "##lang_zh", state.ui_language == "zh")
        if lzh then
            state.ui_language = vzh and "zh" or "en"
            lang_changed = true
        end
        imgui.same_line()
    end
    local len, ven = imgui.checkbox("English UI##lang_en", state.ui_language == "en")
    if len then
        state.ui_language = ven and "en" or "zh"
        lang_changed = true
    end
    if lang_changed then
        save_cfg()
        log.info("[RE3Trainer] 界面语言 -> " .. state.ui_language)
    end
    if not use_cjk then
        imgui.text_colored(L("中文字体不可用。请确认游戏根目录有 reframework_pictographic.mode 文件。",
            "Chinese font unavailable. Make sure reframework_pictographic.mode exists in the game folder."), 0xFFFF9040)
    end

    -- ---- 高级 / 排错 ----
    imgui.spacing()
    if imgui.collapsing_header(
        L("高级 / 排错（一般不用）", "Advanced / Troubleshooting (usually not needed)")
        .. "##advanced") then

        if imgui.button(L("导出排查文件（发给作者定位问题）",
            "Export diagnostic file (send to the author)") .. "  [F10]##dump") then
            safe(write_dump, "导出转储")
        end
        if imgui.button(L("读取道具箱内部信息（只读，不修改存档）",
            "Read item-box internals (read-only)") .. "##probe") then
            safe(write_item_probe, "道具箱探针")
        end
        if imgui.button(L("重新识别游戏数据（某项显示“未识别”时使用）",
            "Re-detect game data (use when something shows “not detected”)") .. "##reresolve") then
            cache_ammo = { tname = nil, fields = {} }
            cache_hp = { tname = nil, fields = {} }
            cache_slot = { tname = nil, fields = {} }
            probed_dura = {}
            log.info("[RE3Trainer] 字段缓存已清空, 将重新解析")
        end

        imgui.spacing()
        if status.hp_note ~= "" then
            imgui.text_colored(L("生命识别结果：", "HP detection: ") .. status.hp_note, 0xFF909090)
        end
        if status.ammo_note ~= "" then
            imgui.text_colored(L("弹药识别结果：", "Ammo detection: ") .. status.ammo_note, 0xFF909090)
        else
            imgui.text_colored(L("弹药识别结果：未识别到弹药数据",
                "Ammo detection: no ammo data found"), 0xFF909090)
        end
        if status.knife_note ~= "" then
            imgui.text_colored(L("小刀识别结果：", "Knife detection: ") .. status.knife_note, 0xFF909090)
        else
            imgui.text_colored(L("小刀识别结果：未识别到小刀耐久数据",
                "Knife detection: no durability data found"), 0xFF909090)
        end

        local api_text
        if KEY_API == "colon" or KEY_API == "dot" then
            api_text = L("正常", "Normal")
        elseif KEY_API == "state" then
            api_text = L("兼容模式", "Compatibility mode")
        elseif KEY_API == "first" then
            api_text = L("兼容模式（按住移动键时可能不响应，松开再按）",
                "Compatibility mode (release movement keys before pressing hotkeys)")
        elseif KEY_API == "none" then
            api_text = L("不可用（请用菜单操作）", "Unavailable (use the menu)")
        else
            api_text = L("正在识别…", "Detecting...")
        end
        imgui.text_colored(L("热键识别方式：", "Hotkey mode: ") .. api_text, 0xFF909090)

        local function ok_text(v)
            return v and L("正常", "OK") or L("失败", "Failed")
        end
        imgui.text_colored(L("功能挂接状态：无敌=%s，一击=%s，闪避=%s，变速=%s",
            "Feature hooks: god=%s, one-hit=%s, dodge=%s, speed=%s"):format(
            ok_text(status.hook_god), ok_text(status.hook_ohk),
            ok_text(status.hook_dodge), ok_text(status.hook_speed)), 0xFF909090)
    end

    -- ---- 操作提示 ----
    imgui.spacing()
    imgui.text_colored(L("操作提示：按 Insert 打开修改器菜单；按 F11 显示独立窗口；设置会自动保存。",
        "Tips: Insert opens the trainer menu; F11 shows the separate window; settings auto-save."), 0xFF909090)
end

-- 菜单内与独立窗口共用同一套内容; 保证字体栈始终平衡
local function draw_ui_content()
    local pushed = false
    if font_handle then
        pcall(imgui.push_font, font_handle)
        pushed = true
    end
    pcall(draw_ui_body)
    if pushed then pcall(imgui.pop_font) end
end

-- REFramework 菜单内的入口
local function draw_ui()
    local title = L(MOD_NAME_CN, MOD_NAME) .. " v" .. MOD_VER .. "###re3_trainer_menu"
    if not imgui.collapsing_header(title) then return end
    draw_ui_content()
end

-- 独立窗口: 在 on_frame 中绘制, 不依赖 REFramework 菜单。
-- begin_window 只能从 on_frame 调用; 只要 Begin 被执行过就必须 End。
local ui_frame_tick = 0
draw_standalone_window = function()
    if not state.standalone_ui then return end
    ui_frame_tick = ui_frame_tick + 1
    if ui_frame_tick < 10 then return end -- 等 ImGui 初始化完成

    if Vector2f ~= nil then
        pcall(imgui.set_next_window_size, Vector2f.new(480, 700), 4)
        -- 默认放在 REFramework 菜单右侧, 避免两个窗口重叠
        pcall(imgui.set_next_window_pos, Vector2f.new(380, 60), 4)
    end

    local title = L(MOD_NAME_CN, MOD_NAME) .. " v" .. MOD_VER
        .. "###re3_trainer_standalone"
    local ok, still_open = pcall(imgui.begin_window, title, true, 0)
    if not ok then return end
    if still_open then
        draw_ui_content()
    end
    pcall(imgui.end_window)
    if not still_open then
        state.standalone_ui = false
        save_cfg()
        log.info("[RE3Trainer] 独立窗口已关闭")
    end
end

re.on_draw_ui(function()
    safe(draw_ui, "界面")
end)

log.info(string.format("[RE3Trainer] %s v%s 加载完成 (界面=%s%s, 钩子将在进入游戏后安装)",
    MOD_NAME_CN, MOD_VER, (state.ui_language == "zh" and use_cjk) and "中文" or "英文",
    (state.ui_language == "zh" and use_cjk and not USE_CUSTOM_FONT)
        and " · REFramework 内置中文字体" or ""))
