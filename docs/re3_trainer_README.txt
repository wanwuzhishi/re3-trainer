======================================================================
 RE3 单机修改器  v1.4.0  ——  使用说明
 适用: 生化危机3 重制版 / Resident Evil 3 (2020)   [仅单机离线模式]
 平台: REFramework (Lua 脚本版, 免编译)
======================================================================

【一】文件清单
----------------------------------------------------------------------
  reframework/autorun/re3_trainer.lua     主脚本 (修改器本体)
  reframework/re3_trainer_README.txt      本说明文件

  ※ v1.0.8 起默认中文界面。中文使用 REFramework 内置中文字体:
     游戏根目录存在 reframework_pictographic.mode (0 字节空文件) 时,
     REFramework 会把默认 ImGui 字体切换为完整中文字体。
     本机已有该文件, 无需安装任何 TTF; 自定义字体仍归档在 .workbuddy/backup/。

  运行后自动产生:
  reframework/data/re3_trainer.json       设置存档 (开关状态/速度倍率)
  reframework/data/re3_trainer_dump.txt   对象转储 (按 F10 生成, 排错用)
  reframework/data/re3_trainer_itemprobe.txt
                                          道具箱/物品探针 (只读, 菜单按钮生成)

【二】安装
----------------------------------------------------------------------
  已安装完成, 无需额外操作。若需重装/迁移:
    1. 把 re3_trainer.lua 放入  <游戏目录>\reframework\autorun\
    2. 启动游戏, 见到日志 "[RE3Trainer] ... 加载完成" 即成功
       (无需字体文件; 默认中文界面依赖游戏根目录的 reframework_pictographic.mode)

【三】使用方法
----------------------------------------------------------------------
  1. 进入游戏存档 (任意进度), 所有对象才会被解析到。
  2. 按 F1~F8 / F10 直接开关功能; 或按 Insert 打开 REFramework 菜单,
     在 Script Generated UI -> "RE3 单机修改器" (英文界面下为 "RE3 Trainer")
     中勾选/调参。
  3. 设置会自动保存, 下次启动保留上次的开关状态。
  4. “高级 / 排错（一般不用）”折叠区:
     - “读取道具箱内部信息（只读，不修改存档）”会读取游戏道具箱条目和
       库存方法签名, 写入 reframework/data/re3_trainer_itemprobe.txt;
       按 F10 的转储也包含它。
     - “导出排查文件（发给作者定位问题）” [F10]。
     - “重新识别游戏数据（某项显示“未识别”时使用）”。
  5. 按 F11 可打开/关闭独立窗口 (模仿 Raz0r 训练器的 separate window):
     窗口是独立的 ImGui 窗口, 可拖动/缩放/关闭; 开关状态会保存。
     ⚠ REFramework 只在它自己的菜单打开时把鼠标/键盘交给 ImGui,
     所以独立窗口在 Insert 菜单关闭时只显示、不能点击; 按 Insert 打开
     REFramework 菜单后即可正常交互。
  6. “游戏道具箱（可取出到背包）”:
     - 先按 Esc 暂停游戏, 再点“读取 / 刷新道具箱”;
     - 每个条目旁点“放入背包”, 普通物品会进入第一个可用背包槽;
       写入后会读回校验并清空道具箱条目, 失败自动回滚, 不会复制物品;
     - 取出后请手动保存;
     - 武器条目在列表里只显示, 请用游戏自己的道具箱取出。
  7. “界面语言（默认中文）”: 选 中文界面 或 English UI, 选择会保存。
  8. “刷取物品（直接放入背包，未获得的也能刷）”:
     - 先点“加载可刷取物品列表（首次使用点这里）”, 脚本会遍历
       Item.ID 并用游戏自己的 getItemName 过滤出有效物品;
     - 用搜索框按名称/编号过滤, 用“刷取数量（1~999）”选数量;
     - 点物品右侧的“放入背包”即可直接写入背包 (尚未获得的也可以)。
     - 需要先暂停游戏 (Esc); 钥匙/剧情道具可能导致卡关, 建议先备份存档。
     - 实现优先调用 Inventory.addSlotNumber; 失败则创建
       PrimitiveItem 走 Inventory.setSlot / Slot.set, 写入后读回校验。
  9. “刷取武器（每次一把，直接放入背包）”:
     - 先点“加载可刷取武器列表（首次使用点这里）”; 脚本遍历
       EquipmentDefine.WeaponType (1~381), 用 getWeaponName 过滤有效武器。
     - 用搜索框过滤, 点“放入背包”每次只刷一把。
     - 刷前会自动检查:
       * 背包/装备: Slot.get_IsWeapon + get_WeaponType, Equipment.hasWeapon;
       * 游戏道具箱: _Items / _Items2nd 中的 isWeaponAll + get_WeaponId。
       任一位置已有该武器就拒绝, 日志会说明原因。
     - 武器固定无配件、1 发; 需要先暂停游戏 (Esc)。
       如果武器在游戏道具箱里, 请用游戏自己的道具箱取出; 本修改器
       不会重复刷取。未知/敌人武器可能导致崩溃, 建议只刷玩家武器。

  热键一览:
    F1   无敌                F6   完美闪避
    F2   一击必杀            F7   游戏速度 (默认 0.5x, 界面可调)
    F3   无限弹药            F8   回满血量 (一次性)
    F4   无限物品            F9   屏幕左上角状态开关
    F5   小刀耐久检测        F10  导出排查文件 (高级)
    F11  独立窗口开关        Insert  修改器菜单

  判别热键是否生效: 按 F1 后, 画面左上角应出现绿色 "F1 无敌"
  (英文界面为 "F1 God Mode")。
  若无任何显示, 说明热键未生效 —— 请改用菜单勾选(功能完全等价),
  并把日志发我(搜索 "[RE3Trainer] 键盘接口")。

  热键接口说明 (v1.4.0): 每帧探测, 优先使用 reframework:is_key_down(vk)
  (冒号调用), 其次点号, 再退回每帧新取的 get_keyboard_state()[vk+1],
  最后才是 get_first_key_down()。菜单底部会显示当前使用的键盘接口;
  若显示 "键盘接口: 探测中..." 或热键仍无效, 请按 F10 导出转储,
  并把日志中 "[RE3Trainer] 键盘接口" 与 "无可用键盘接口" 两行发回。
  注意: get_first_key_down 只返回"当前第一个按下的键", 它作为最后兜底时,
  按着方向键/WASD 移动中按 F 键可能不响应 —— 松开方向键再按即可。

【四】功能说明与生效条件
----------------------------------------------------------------------
  无敌（不会掉血）
                写 <Invincible>/<NoDamage> 并拦截玩家受击判定; 血量维持
                在 <DefaultHitPoint> (真实上限), 不再写 9999。
                注: 剧情"寄生"状态下不做拦截, 避免阻断剧情。
                若装了 Auto-Dodge, 玩家本来就不会受伤, 这个开关看不出差别。
  一击必杀（敌人一枪就死）
                玩家造成伤害时把伤害提升至 99999, 只作用于敌人,
                绝不作用于玩家/友方。
                ⚠ 可能提前杀死剧情敌人或跳过事件, 建议只在战斗时开启。
  无限弹药（通常不用装填）
                库存武器槽的数量属性 (get_Number/set_Number) 每帧锁定;
                弹匣保持高数量, 通常不用装填; 备弹消耗取决于武器。
  无限物品（消耗品不减少）
                药草/手雷/弹药盒等消耗品数量锁定为 99;
                剧情钥匙类物品不动, 以免干扰解谜。
  小刀耐久检测（目前只检测，不修改）
                采集 _Stock/InnerData/ExtendData 的耐久候选字段并写入日志。
                耐久字段尚未确认, 本版不会修改游戏数据; 确认后再实现不磨损。
  完美闪避（随时可闪避）
                持续开启紧急闪避判定; 可能影响部分敌人行为。
  游戏速度（调快 / 调慢）
                改写引擎时间缩放 (0.1 ~ 5.0 倍), 可做慢动作或快进。
  回满血量（一次性）
                一次性把当前生命恢复到正常上限。
  游戏道具箱（可取出到背包）
                读取 ItemLockerSaveData 的 _Items / _Items2nd;
                “放入背包”把普通物品写入第一个可用背包槽, 读回校验后
                清空道具箱条目, 失败自动回滚; 需先暂停游戏 (Esc)。
                武器条目只显示, 请用游戏自己的道具箱取出。
  界面语言（默认中文）
                中文界面 / English UI 切换, 选择写入配置。
  刷取物品（直接放入背包，未获得的也能刷）
                遍历 Item.ID 生成物品列表, 支持搜索和数量; 即使玩家
                尚未获得也可以直接写入背包 (addSlotNumber 优先,
                setSlot/Slot.set 兜底, 写后读回校验)。需暂停游戏;
                钥匙/剧情物品可能导致卡关, 建议先备份存档。
  刷取武器（每次一把，直接放入背包）
                遍历 EquipmentDefine.WeaponType 生成武器列表, 每次只刷
                一把; 刷前检查背包/装备和游戏道具箱, 已有则拒绝。
                武器无配件、1 发; 需暂停游戏; 只建议刷玩家武器。

  生效前提: 主界面需显示"游戏状态：游戏中"。若显示
  "还没有进入游戏存档", 请先载入游戏存档 (菜单/载入阶段无玩家对象属正常)。

【五】与已安装模组的冲突说明
----------------------------------------------------------------------
  1. 检测到 reframework/autorun/Auto-Dodge.lua 已安装。
     该脚本同时挂钩了 checkHitDamage (受击判定) 与 doSurvivorUpdate,
     并且是"始终生效、无法关闭"的:
       - 它的闪避功能与本修改器的 F6 完美闪避重复;
       - 它会让玩家免疫受击, 因此本修改器的 F1 无敌开关可能看不出差别。
     若希望完全由本修改器接管开关控制, 建议把 Auto-Dodge.lua 移出
     autorun 目录 (改名加 .bak 亦可)。

  2. plugins/re3r_ultimate_trainer.dll (Raz0r 的 RE3R Ultimate Trainer,
     C++ 插件版) 与本修改器功能高度重叠。两者可以共存, 但同时开启
     同类功能会互相覆盖数值。建议只用其中一套。

【六】排错
----------------------------------------------------------------------
  0. 启动闪退 / 卡死无响应 (必读)
     v1.0.8 默认中文界面使用 REFramework 内置中文字体, 不加载
     reframework/fonts/ 下的自定义 TTF; 启动路径不触碰自定义字体扫描。
     若仍出现, 请按顺序做排除法 (每步只改一项):
     a) 先看日志: <游戏目录>\re2_framework_log.txt
        * 通篇没有 "[RE3Trainer]" => 脚本尚未加载。此时卡点在 REFramework
          初始化阶段 (日志末尾一般是 "Locking loader lock..." 后连续
          "Suspending <线程号>"), 与修改器逻辑无关, 优先做 d) / e)。
        * 有 "[RE3Trainer]" => 脚本已加载, 请把该日志发我。
     b) 把 re3_trainer.lua 改名为 re3_trainer.lua.off 后启动:
        恢复正常 => 问题在修改器, 发我日志;
        仍异常   => 与修改器无关, 做 d)。
     c) 自定义中文字体保持停用 (归档在 .workbuddy/backup/),
        默认中文界面不依赖它, 无需再处理。
     d) 把 reframework/plugins/reframework-d2d.dll 改名为 .off 后启动 ——
        它是画面绘制层的第三方插件, 可排除渲染层冲突。
     e) 日志出现 "[Streamline] Failed to get sl.dlss_g.dll" 或
        "Failed to get type info: unknown exception" 时, 多与显卡/DLSS/
        驱动层有关: 尝试关闭游戏内 DLSS/光追、更新显卡驱动, 或换用
        同版本的 RE3 稳定版 REFramework。
  1. 某项功能无效 / 显示"未解析":
     v1.0.3 起, 进入游戏后会自动把武器、PlayerCondition、HitPointController、
     库存槽的**全部真实字段名**写入日志 (每个类型一次, 前缀
     "[RE3Trainer] 字段清单")。请把这段日志发我, 即可精确定位字段。
     也可按 F10 导出 reframework/data/re3_trainer_dump.txt,
     内容为各对象的字段与方法完整列表。
  2. 中文界面
     v1.0.8 起默认中文界面。中文使用 REFramework 内置中文字体:
     游戏根目录存在 reframework_pictographic.mode (0 字节空文件) 时,
     REFramework 会把默认 ImGui 字体切换为完整中文字体。
     本机已有该文件; 若中文显示为方块/问号, 请确认该文件位于 re3.exe
     同级目录 (不是 reframework 子目录)。
     切换语言: 在菜单/独立窗口的“界面语言（默认中文）”里选
     中文界面 或 English UI (选择会保存); 也可把脚本中
     ENABLE_CJK_UI 改为 false 强制英文。
     自定义字体仍需把 re3_trainer_sc.ttf 放回 reframework/fonts/ 并把
     USE_CUSTOM_FONT 改为 true —— 该路径曾与启动异常相关, 默认不推荐。
  3. 查看日志:
     <游戏目录>\re2_framework_log.txt  (搜索 "[RE3Trainer]")
  4. 修改脚本文字后需重新生成字体子集 (仅使用自定义字体时需要):
     运行  python .workbuddy\tools\gen_trainer_font.py
     该脚本会重新提取脚本文案、子集化字体并回填字形范围表。
     仓库/本机无需联网: 字体来源为本机 C:\Windows\Fonts\NotoSansSC-VF.ttf
     (Noto Sans SC, SIL OFL 1.1 开源许可)。

【七】卸载
----------------------------------------------------------------------
  删除 reframework/autorun/re3_trainer.lua 即可。
  中文字体备份在 .workbuddy/backup/re3_trainer_sc.ttf (不在扫描路径), 可一并删除。
  已保存的设置/转储文件可一并删除 (reframework/data/ 下同名文件)。

【八】安全提示
----------------------------------------------------------------------
  * 仅供单机离线娱乐, 请勿用于联机/排行榜等场景。
  * 修改存档类工具均建议先备份存档:
    Steam 云存档目录  ...\Steam\userdata\<你的ID>\952060\remote\
  * 脚本中所有对游戏对象的调用都包了错误保护, 单项失败会在日志中记录
    而不会直接导致游戏崩溃; 但"一击必杀"等功能仍可能触发游戏本身的
    逻辑异常, 出现异常时按 F2 关闭即可。

【九】版本记录
----------------------------------------------------------------------
  v1.4.0  界面文案重写
    * 所有菜单/HUD/提示文字改为“名称 + 效果 + 前提/风险”的通俗写法。
    * 统一动作为“放入背包”; 道具箱两组列表显示为 1 / 2。
    * 新增“高级 / 排错”折叠区: 导出排查文件、读取道具箱内部信息、
      重新识别游戏数据、字段识别结果、钩子状态、热键识别方式。
    * HUD 显示“已开启功能”; 没有功能时显示“当前没有开启功能”。
    * 热键/钩子状态改为“正常 / 兼容模式 / 失败”等通俗描述。
    * 中英文文案同步。
  v1.3.0  武器刷取
    * 新增“刷取武器 (单个)”列表: 遍历 EquipmentDefine.WeaponType
      (1~381), 用 ItemManager.getWeaponName(wt, 0) 过滤有效武器。
    * 刷取前检查背包/装备 (get_IsWeapon + get_WeaponType,
      Equipment.hasWeapon) 和武器箱 (_Items/_Items2nd 中
      isWeaponAll + get_WeaponId); 任一位置已有该武器则拒绝。
    * 武器版 Inventory.setSlot(slot, wt, parts, bulletID, count, ExData)
      优先, Slot.set 兜底; 读回 get_WeaponType 校验。
    * 固定无配件、1 发; 需暂停游戏。
  v1.2.0  刷取物品
    * 新增“刷取物品 (任意物品)”列表: 遍历 Item.ID (1..400),
      用 ItemManager.getItemName 过滤无效项, 支持名称/ID 搜索。
    * 数量 1~999; 优先 Inventory.addSlotNumber 入包 (处理已有堆叠),
      失败则创建 InventoryManager.PrimitiveItem + ItemExData,
      走 Inventory.setSlot / Slot.set 兜底, 写入后读回校验。
    * 需暂停游戏 (Esc); 关键/剧情物品可能影响流程。
  v1.1.0  道具箱取出 + 界面语言切换
    * 道具箱列表: 读取 ItemLockerSaveData 的 _Items / _Items2nd,
      显示名称和数量; “取出”把普通物品写入第一个可用背包槽:
      Inventory.setSlot(...) 优先, Slot.set(...) 兜底; 写入后读回校验,
      再清空道具箱条目; 任一步失败自动回滚, 避免物品复制。
    * 取出需在游戏暂停 (Esc) 时进行; 武器暂时只显示、不支持取出。
    * 新增界面语言选择: 中文 / English, 默认中文, 写入配置。
    * 独立窗口在 REFramework 菜单关闭时仅显示、不可点击
      (REFramework 只在菜单打开时把输入交给 ImGui); 按 Insert 后交互。
  v1.0.9  道具箱探针 v2
    * 探针现在会逐层解开 GameSaveData.SaveData, 找到真正的
      ItemLockerSaveData, 并读取 get_Items() / get_Items_2nd()
      两个物品列表 (不再只找 _Items 字段)。
    * 导出 InventoryManager.ItemData / StockItem / PrimitiveItem /
      ItemExData 与 inventory.Vital 的字段和全部方法签名。
    * ItemLockerManager 增加 AddStrage / RemoveStrage /
      AddWeaponToStrage / RemoveWeaponToStrage 等存储函数签名。
    * 仍为只读, 不修改道具数据。
  v1.0.8  默认中文界面
    * ENABLE_CJK_UI 默认 true; 中文使用 REFramework 内置中文字体
      (依赖游戏根目录的 reframework_pictographic.mode), 不再加载
      reframework/fonts/ 下的自定义 TTF。
    * 自定义字体改为 USE_CUSTOM_FONT 可选开关, 默认关闭。
    * HUD 中文标签优先使用 Microsoft YaHei / SimHei。
    * 如需英文界面: 把 ENABLE_CJK_UI 改为 false。
  v1.0.7  新增独立窗口 UI
    * 模仿 Raz0r 训练器的 “Use Separate Window”: 在 on_frame 中用
      imgui.begin_window/end_window 绘制独立 ImGui 窗口, 不依赖
      REFramework 菜单; F11 开关, 可拖动/缩放/关闭, 开关状态自动保存。
    * 窗口内容与菜单内 UI 完全一致 (复用 draw_ui_body)。
    * 菜单内新增“独立窗口 [F11]”勾选框。
  v1.0.6  新增道具箱/物品探针 (只读)
    * 模仿 CabbyCodes 的“道具箱取出物品”功能, 先做只读数据采集:
      读取 ItemLockerManager / GameSaveData / _Items, 输出道具箱条目的
      物品 ID、数量、名称; 同时导出 Inventory / Slot / ItemManager /
      ItemLockerManager 的方法签名 (setSlot/putSlot/set_ItemID/
      set_Number 等重载)。
    * 入口: 菜单“道具箱探针 (只读)” 或 F10 对象转储;
      结果写入 reframework/data/re3_trainer_itemprobe.txt。
    * 本版不写任何道具数据。等探针结果确认字段/签名后, 再实现
      “取出/发放物品”; 这样不会在 API 未确认时损坏存档。
  v1.0.5  代码审查修复
    * 热键: v1.0.4 缓存 get_keyboard_state 一次快照的做法是错的 ——
      REFramework 返回 std::array<uint8_t,256>, sol2 按值包装且为 1 基索引,
      快照不会更新, 索引还错一位。v1.0.5 改为每帧探测:
      reframework:is_key_down(vk) (冒号优先) -> 点号 -> 每帧新取
      get_keyboard_state()[vk+1] -> get_first_key_down()。
      接口失效会自动重试, 菜单底部显示当前接口。
    * 字段发现: RETypeDefinition 的父类查询改为 get_parent_type()。
      原来的 get_parent() 不存在, 异常被 pcall 吞掉, 继承字段从未被扫描。
    * 血量: 无敌/回满使用 <DefaultHitPoint> 作为上限, 不再写 9999。
    * 无限弹药: 只在真正写入后报告状态; 增加库存槽读回值。
    * 小刀耐久: 增加 _Stock/InnerData/ExtendData 探测日志;
      耐久字段未确认前不盲目写未知对象。
    * 性能: 每帧复用 inventory; 物品可移除性缓存移出每帧函数。
    * HUD: d2d 字体加载失败会写日志, 并回退 Consolas/Arial。
    * 配置: speed 加载后限制在 0.1 ~ 5.0。
  v1.0.4  热键重写 + 使用真实字段名
    * 热键: 日志证实 reframework.is_key_down 在启动阶段有一次调用抛异常,
      当时误判为接口完全不可用, 改为缓存 get_keyboard_state 快照
      (该实现本身有缺陷, 已在 v1.0.5 修正)。
    * 无敌: 改用 HitPointController 的真实字段 <Invincible> / <NoDamage>
      (由字段清单确认), 不再依赖 hook。
    * 数量: 库存槽真实字段为 _Stock(内层库存对象) / _Infinity(无限标记);
      实际数量通过 get_Number/set_Number 读写 (v1.0.5 修正描述)。
    * 菜单勾选与变速开关会记录日志, 可确认功能是否真的被开启。
  v1.0.3  修复功能无效 / 热键无反馈
    * HP 取值路径错误: get_HitPointController 属于 PlayerCondition 组件,
      上一版直接在 GameObject 上调用, 永远拿不到 HP 控制器,
      导致"无敌锁血"与"血量回满"失效。已改为先取组件再调用。
    * 数量写入改为"属性 setter 优先"(set_Number / set_Count),
      字段名匹配作为兜底 —— RE3 的库存槽对外暴露的是属性而非字段。
    * 恢复画面 HUD(英文) 作为热键切换的即时反馈, F9 开关。
    * 新增字段清单诊断日志, 便于核对匹配是否正确。
  v1.0.2  修复启动卡死
    * 现象: 启动后卡在 REFramework 初始化, 日志末尾为
      "Locking loader lock..." + 连续 "Suspending <线程号>", 无响应;
      且日志中没有任何 "[RE3Trainer]" 记录(脚本尚未加载)。
    * 处置: 自定义中文字体默认停用并移出 reframework/fonts/
      (该目录属 REFramework 自动扫描路径, 字体会参与 ImGui 字体图集
      初始化); 界面改为纯英文, 启动链路不再触碰字体系统。
    * 若停用后仍异常, 说明与修改器无关, 按【六】排错第 0 条做排除法
      (重点关注 REFramework 初始化、d2d 插件与 DLSS/驱动层)。
  v1.0.1  修复启动闪退
    * 根因: 字形范围表被写成嵌套表 ({ {...} })。REFramework 把该表
      转为 ImWchar* 时, 内层 table 被当作指针直接解引用(野指针),
      ImGui 构建字体图集时越界读取 -> c0000005 访问冲突 -> 游戏闪退。
      特征是: load_font 返回成功, 崩溃却发生在 REFramework 的 ImGui 代码,
      且具有间歇性(取决于堆内存内容)。
    * 修复: 范围表改为一维数值数组并以 0 结尾 (已用 Lua 实际执行校验);
      新增 ENABLE_CJK_UI 开关, 可一键回退英文界面。
    * 同时: 移除 d2d 画面 HUD, 减少启动阶段的渲染依赖;
      钩子安装与游戏对象访问延迟到"真正进入游戏后"执行,
      避免引擎初始化期间访问尚未就绪的对象。
  v1.0.0  首个版本: 无敌 / 一击必杀 / 无限弹药 / 无限物品 /
          无限小刀耐久 / 完美闪避 / 游戏变速 / 血量回满 / 对象转储。
======================================================================
