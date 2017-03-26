-- 一些常量的定义
EM = EM or {}

EM.ERROR_CODE = 
{
    SUCCESS                     = 0,        -- 无错误

    -- System
    SYSTEM_ERROR                = -1000,    -- 系统错误

    -- MSG
    MSG_PARAM_ERROR             = -1020,    -- 消息参数错误

    -- Login
    LOGIN_ERROR                 = -1100,    -- 账号未登陆，不能操作
    LOGIN_UDID_ERROR            = -1101,    -- 登陆识别码有误
    
    -- Account
    ACCOUNT_BIND_REQ            = -1110,    -- 账号绑定请求参数有误 
    ACCOUNT_HAS_BIND            = -1111,    -- 账号已绑定过
    ACCOUNT_TOKEN_HAS           = -1112,    -- 令牌已绑定过别的账号

    -- Name
    NAME_LEN                    = -1120,    -- 昵称长度有误(过小or过大 Common表 NameLenMin NameLenMax)

    -- ROLE
    ROLE_COIN_NOT               = -2000,    -- 角色金币不足

    -- HERO
    HERO_NOT_HAVE               = -2100,    -- 英雄不存在

    -- SHOP_CARD
    SHOP_CARD_TIME_LIMIT        = -2200,    -- 卡牌商店过期
    SHOP_CARD_NOT_HAVE          = -2201,    -- 卡牌商店卡牌不存在
    SHOP_CARD_BUY_TIMES_MAX     = -2202,    -- 卡牌商店卡牌购买次数达到上限
    SHOP_CARD_CARD_MAX          = -2203,    -- 卡牌商店卡牌已满

    -- Friend
    FRIEND_SRC_MAX              = -2300,    -- 好友人数满(源实体)
    FRIEND_DES_MAX              = -2301,    -- 好友人数满(目标实体)
    FRIEND_ADD_NAME             = -2302,    -- 好友姓名格式有误
    FRIEND_ADD_NONE             = -2303,    -- 没有此人
    FRIEND_ADD_SRC_BLACK        = -2304,    -- 添加好友拉黑(源拉黑目标)
    FRIEND_ADD_DES_BLACK        = -2305,    -- 添加好友拉黑(目标拉黑源)
    FRIEND_ADD_SELF             = -2306,    -- 不能添加自己
    FRIEND_ADD_ALREADY          = -2307,    -- 你们已经是好友了
}

-- 令牌类型
EM.TOKEN_TYPE = 
{
    NONE            = 0,                    -- NONE(设备令牌)
    WECHAT          = 1 << 0,               -- 微信
    FACEBOOK        = 1 << 1,               -- FACEBOOK
}

-- 房间类型
EM.ROOM_TYPE = 
{
    NONE            = 0,                    -- NONE
    ONE_V_ONE       = 1,                    -- 1v1
    THREE_V_THREE   = 2,                    -- 3v3
    TEST_ONE        = 3,                    -- 测试1v1
    TEST_THREE      = 4,                    -- 测试3v3
}

-- 实体类型
EM.BE_TYPE = 
{
    NONE            = 0,                    -- NONE
    PLAYER          = 1,                    -- 玩家
    SUMMON          = 2,                    -- 召唤物
    BULLET          = 3,                    -- 子弹
    TRAP            = 4,                    -- 陷阱
    BUILDING        = 5,                    -- 建筑
}

-- 英雄类型
EM.ROLE_TYPE = 
{
    NONE            = 0,                    -- NONE
    NORMAL          = 1,                    -- 普通英雄
    SHAPESHIFTING   = 2,                    -- 变身英雄
}

-- 卡牌类型
EM.CARD_TYPE = 
{
    NONE            = 0,                    -- NONE
    NORMAL          = 1,                    -- 普通
    UNIQUE          = 2,                    -- 大招牌
}

-- 卡牌稀有度
EM.CARD_RARITY = 
{
    NONE            = 0,                    -- NONE
    GREEN           = 1,                    -- 绿(普通)
    BLUE            = 2,                    -- 蓝(稀有)
    PURPLE          = 3,                    -- 紫(史诗)
    ORANGE          = 4,                    -- 橙(传奇)
}

-- 召唤兽类型
EM.SUMMON_TYPE = 
{
    NONE            = 0,                    -- NONE
    SHIELD          = 1,                    -- 盾(阻挡所有子弹)
}

-- 子弹类型
EM.BULLET_TYPE = 
{
    NONE            = 0,                    -- NONE
    TRACK           = 1,                    -- 追踪
    NO_TRACK        = 2,                    -- 不追踪
    TARGET_SPEED    = 3,                    -- 到达目标位置固定速度
    TARGET_TIME     = 4,                    -- 到达目标位置固定时间
}

-- 子弹属性
EM.BULLET_PROPERTY = 
{
    NONE            = 0,                    -- NONE
    REBOUND         = 1,                    -- 回弹(ArrayParam:没中的时候附加BUFF组ID 参数1:子弹击中回弹类型(BULLET_HIT_REBOUND_TYPE) 参数2:回弹时源实体否进入特殊状态 参数3:回弹时是否可以碰撞 参数4:回弹时是否清除击中列表)
}

-- 子弹击中回弹类型
EM.BULLET_HIT_REBOUND_TYPE = 
{
    NONE            = 0,                    -- NONE(直接销毁)
    REBOUND         = 1,                    -- 直接回弹
    DELAY           = 2,                    -- 延迟销毁(延迟时间为源实体按照子弹速度过来的时间)
}

-- 实体状态类型(简单状态 存活or死亡)
EM.BE_STATE = 
{
    NONE            = 0,                    -- NONE(没有生命的, 子弹类, 陷阱类)
    ALIVE           = 1,                    -- 存活
    DEAD            = 2,                    -- 死亡(尸体)
    AIR             = 3,                    -- 死亡(空气 不存在)
    BOOM            = 4,                    -- 爆炸(子弹类, 陷阱类)
    BORN            = 5,                    -- 出生状态(一般是召唤兽用)
    ACTIVATE        = 6,                    -- 激活(子弹, 陷阱, 建筑类)
}

-- 阵营类型
EM.BE_CAMP = 
{
    NONE            = 0,                    -- NONE(中立)
    RED             = 1,                    -- 红方
    BLUE            = 2,                    -- 蓝方
}

-- 设备类型
EM.MC_TYPE = 
{
    NONE            = 0,                    -- NONE
    SERVER          = 1,                    -- 服务器
    CLIENT          = 2,                    -- 客户端
}

-- 移动vector类型
EM.VEC_TYPE = 
{
    NONE            = 0,                    -- NONE
    MOVE            = 1,                    -- 移动
    TURN            = 2,                    -- 转动
}

-- 动作类型
EM.ACT_TYPE = 
{
    NONE            = 0,                    -- NONE
    NORMAL_ATTACK   = 1,                    -- s2c普通攻击
    USE_CARD        = 2,                    -- c2s s2c使用卡牌(c2s参数1表示手牌区索引(从1开始) 参数2表示卡牌类型(大招牌，普通票) 参数3模板ID; s2c用参数1表示模板ID)
    INSTANT         = 3,                    -- s2c瞬发状态(参数1表示瞬发卡牌手牌区索引(从1开始) 参数2表示卡牌类型(大招牌，普通票) 参数3模板ID)
    HP_CHANGE       = 4,                    -- s2c血量变化(参数1表示对应的值, 参数2血量变化类型(HP_CHANGE_TYPE), 参数3表示对应的模板ID, 参数4表示间接收到影响的实体ID)
    HP_CHANGE_EX    = 5,                    -- s2c血量变化扩展 飘字状态(参数1:HP_CHANGE_EX_TYPE)
    SWITCH_TARGET   = 6,                    -- c2s切换目标(targetEntityID)
    USE_CARD_EX     = 7,                    -- s2s瞬发吟唱后摇()
}

-- 血量变化类型扩展
EM.HP_CHANGE_EX_TYPE = 
{
    NONE            = 0,                    -- NONE
    GAD             = 1,                    -- 无敌
    SHIELD          = 2,                    -- 护盾
}

-- 动作释放相关
EM.ACT_FROM_TYPE = 
{
    NONE            = 0,                    -- NONE
    SELF            = 1,                    -- 自己对别人释放
    OTHER           = 2,                    -- 别人对自己释放
    SELF_TO_SELF    = 3,                    -- 自己对自己释放
}

-- 血量变化类型
EM.HP_CHANGE_TYPE = 
{
    NONE            = 0,                    -- NONE
    ATTACK          = 1,                    -- 普攻
    SKILL           = 2,                    -- 技能
    BUFF            = 3,                    -- BUFF
}

-- 技能类型
EM.SKILL_TYPE = 
{
    NONE            = 0,                    -- NONE
    HP_EFFECT       = 1,                    -- 生命影响类(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值)
    BULLET          = 2,                    -- 弹幕类(参数1:弹幕模板ID 参数2:个数 参数3:角度)
    SUMMON          = 3,                    -- 召唤类(参数1:召唤兽模板ID 参数2:个数 参数3:角度)
    TRAP            = 4,                    -- 陷阱类(参数1:陷阱模板ID 参数2:个数 参数3:角度)
    CONTROL         = 5,                    -- 控制类(参数1:被控制BuffGroup模板ID)
}

-- 技能消耗类型
EM.SKILL_COST_TYPE = 
{ 
    NONE            = 0,                    -- NONE
    HP              = 1,                    -- 生命值
}

-- 实体施法状态
EM.BE_USE_CARD_STATE = 
{
    NONE            = 0,                    -- 无状态，普攻状态
    INSTANT         = 1,                    -- 瞬发(参数1:前摇时间 参数2:后摇时间)
    SING            = 2,                    -- 吟唱(参数1:吟唱时间 参数2:后摇时间)
    LAST            = 3,                    -- 持续(参数1:持续时间 参数2:时间间隔)
}

-- 移动打断状态
EM.BE_MOVE_BREAK_TYPE = 
{
    NONE            = 0,                    -- 不可移动
    BREAK           = 1,                    -- 打断
    NOT_BREAK       = 2,                    -- 不打断
}

-- 目标类型
EM.TARGET_TYPE = 
{
    NONE            = 0,                    -- NONE
    SELF            = 1,                    -- 自己
    ENEMY           = 2,                    -- 目标敌人
    SELF_SUMMON     = 3,                    -- 自己和召唤物
    LAST_BY_ATTACK  = 4,                    -- 上一次攻击自己的
    BY_CREATE       = 5,                    -- 创建自己的人
    CAMP_NOT_CREATE = 6,                    -- 同一阵营玩家 不包括创建者
}

-- 范围类型
EM.RANGE_TYPE = 
{
    NONE            = 0,                    -- NONE
    ROUND           = 1,                    -- 圆(参数1:半径)
    SECTOR          = 2,                    -- 扇形(参数1:半径,参数2:角度(0-360))
    RECT            = 3,                    -- 矩形(参数1:伸出距离,参数2:横向范围)
    POLYGON         = 4,                    -- 多边形(参数1:模板ID)

    -- 以下类型前端用做额外范围显示
    ROUND_FE        = 101,                  -- 圆(参数1: 半径, 参数2: 0自己,1敌人)
    SECTOR_FE       = 102,                  -- 扇形(参数1: 半径, 参数2: 角度(0-360))
    RECT_FE         = 103,                  -- 矩形(参数1: 伸出距离, 参数2: 横向范围)
    ARROW           = 105,                  -- 箭头(参数1: 伸出距离, 参数2: 横向范围)
    TARGET          = 106,                  -- 目标(参数1: 留空,参数2: 0自己,1敌人)
    SUMMON          = 107,                  -- 召唤物(参数1: 个数，参数2: 角度间隔 30)
}

-- 范围控制类型
EM.MOVE_RANGE_TYPE = 
{
    NONE            = 0,                    -- NONE
    MAX             = 1,                    -- 最大距离(参数1:最大距离)
}

-- 影响类型
EM.EFFECT_TYPE = 
{
    NONE            = 0,                    -- NONE
    MORE            = 1,                    -- 增加
    LESS            = 2,                    -- 减少
}

-- 数据类型
EM.DATA_TYPE =
{
    NONE            = 0,                    -- NONE
    CONST           = 1,                    -- 固定值
    PERCENT         = 2,                    -- 百分比(需要一个参数:基数)
}

-- 数据百分比基数类型
EM.DATA_PER_BASE_TYPE =
{
    NONE            = 0,                    -- NONE
    DEFAULT         = 1,                    -- 默认(传进来的参数)
    ATTACK          = 2,                    -- 当前攻击值
    BY_ATTACK       = 3,                    -- 当前被攻击值
    LOSE_HP         = 4,                    -- 当前失血量
    SUMMON_LOSE_HP  = 5,                    -- 召唤兽流逝生命
    MAX_HP          = 6,                    -- 总血量

    PER_LOST_HP     = 101,                  -- 百分比 流失生命
}

-- BUFF类型
EM.BUFF_TYPE = 
{
    NONE            = 0,                    -- NONE
    ATTACK          = 1,                    -- 攻击影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    HP              = 2,                    -- 生命影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE) 参数5:是否是流逝类不受别的BUFF影响(1是 固定通知前端) 参数6:是否不显示(1不显示 不受别的BUFF影响))
    MOVE_SPEED      = 3,                    -- 移速影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    ATTACK_SPEED    = 4,                    -- 攻速影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    HP_CHANGE_SRC   = 5,                    -- 源实体对目标实体最终变化影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    HP_CHANGE_DES   = 6,                    -- 目标实体自己生命最终变化影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    GOD             = 7,                    -- 无敌
    NO_ATTACK       = 8,                    -- 不能攻击
    NO_SKILL        = 9,                    -- 不能施法
    NO_MOVE         = 10,                   -- 不能移动(参数1:是否可转向 1表示可转向)
    MOVE            = 11,                   -- 移动类(ArrayParam:碰撞后附加BUFF组模板ID 参数1:速度 参数2:最远距离 参数3:移动方向(EM.MOVE_TYPE) 参数4:填1表示不以移动方向为朝向 参数5:目标类型(TARGET_TYPE) 参数6:击中几个实体停下来(0表示无线))
    ADD_BUFF        = 12,                   -- 附加BUFF(ArrayParam:BUFF组模板ID 参数1:影响类型(EFFECT_TYPE) 参数2:距离 参数3:在一定的状态下附加(BUFF_STATE) 参数4:持续时间)
    CLEAR_BUFF      = 13,                   -- 清除BUFF(ArrayParam:BUFF组模板ID 参数1:是否清除身上已有的BUFF(-1清除所有，0不清除，其他参照BUFF_SIGN_TYPE))
    BULLET          = 14,                   -- 发射子弹(参数1:子弹模板ID 参数2:个数 参数3:相差角度 参数4:有这个值 则随机角度(参数3, 参数4))
    SUMMON          = 15,                   -- 召唤(参数1:召唤兽模板ID 参数2:个数 参数3:相差角度)
    IMMUNE          = 16,                   -- 免疫类(ArrayParam:免疫的BUFF种类 参数1:影响类型(EFFECT_TYPE)) 
    TRAP            = 17,                   -- 设置陷阱(参数1:陷阱模板ID 参数2:个数 参数3:相差角度)
    SHIELD          = 18,                   -- 护盾(ArrayParam:BUFF组模板ID 参数1:护盾值 参数2:盾被打掉时候获取or干掉BUFF EM.EFFECT_TYPE)
    SIZE            = 19,                   -- 体积影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    REBIRTH         = 20,                   -- 重生(参数1:复活点类型(REBIRTH_POINT_TYPE) 参数2:复活血量万分比)
    POWER_SPEED     = 21,                   -- 手牌充能影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    CLEAR_BY_TARGET = 22,                   -- 清除被选中状态
    MOVE_REVERSE    = 23,                   -- 移动翻转
    MOVE_CONTROL    = 24,                   -- 移动控制
    MOVE_BY_CONTROL = 25,                   -- 移动被控制
    COPY_SKILL      = 26,                   -- 复制源实体技能(参数1:Copy的Key)
    SHAPESHIFTING   = 27,                   -- 变身(参数1:TempID 0表示变回去)
    CLEAR_STATE     = 28,                   -- 清楚BUFF状态(ArrayParam:清掉状态后对应上的BUFF 参数1:状态 参数2:是否几级上几个对应BUFF 1表示是)
    CARD_ADD_POWER  = 29,                   -- 下一张卡牌增加能量(参数1:能量值)
    GHOST           = 30,                   -- 隐身
    MOVE_RANGE      = 31,                   -- 移动范围(参数1:范围类型(MOVE_RANGE_TYPE) 参数2:值)
    MOVE_DISTANCE   = 32,                   -- 移动距离(ArrayParam:BUFF组模板ID 参数1:移动距离达到多少后附加BUFF)
    ATTACK_RANGE    = 33,                   -- 攻击范围影响(参数1:影响类型(EFFECT_TYPE) 参数2:数据类型(DATA_TYPE) 参数3:对应值 参数4:百分比基数类型(DATA_PER_BASE_TYPE))
    ATTACK_BULLET   = 34,                   -- 攻击弹幕变换(参数1:模板ID)
}

-- BUFF状态
EM.BUFF_STATE =
{
    NONE            = 0,                    -- NONE
    STUN            = 1,                    -- 眩晕
    SLEEP           = 2,                    -- 琴女 睡
    POISON_SPEED    = 3,                    -- 毒减速
    POISON_HP       = 4,                    -- 毒扣血
    MUD_SPEED       = 5,                    -- 屠夫 焦油泥沼 减速
    POISON_DAMAGE   = 6,                    -- 盗贼 毒素爆发 伤害
    POISON_HEAL     = 7,                    -- 盗贼 毒素爆发 回血
}

-- BUFF正负项
EM.BUFF_SIGN_TYPE = 
{
    NONE            = 0,                    -- NONE
    PLUS            = 1,                    -- 正向BUFF
    MINUS           = 2,                    -- 负向BUFF
}


-- BUFF触发类型
EM.BUFF_TRIGGER_TYPE = 
{
    NONE            = 0,                    -- NONE(直接作用)
    TIME            = 1,                    -- 按时间作用(参数1:时间间隔(必须能被buff持续时间整除))
    ATTACK          = 2,                    -- 攻击时作用(参数1:BUFF_TRIGGER_ATTACK_TYPE)
    BY_ATTACK       = 3,                    -- 被攻击时作用(参数1:BUFF_TRIGGER_ATTACK_TYPE)
    TRAP_BOOM       = 4,                    -- 陷阱爆炸时作用
    SRC_DAMAGE      = 5,                    -- 源实体伤害结算时作用
    DES_BY_DAMAGE   = 6,                    -- 目标实体伤害结算时作用
    CREATER_CARD    = 7,                    -- 创建者卡牌释放成功时作用
    POS_CHANGE      = 8,                    -- 位置变化时作用
    LOSE_HP         = 9,                    -- 掉血时作用
    DES_BY_D_ATTACK = 10,                   -- 目标实体被普攻伤害时作用(参数1:BUFF_TRIGGER_ATTACK_TYPE)
    DES_BY_D_SKILL  = 11,                   -- 目标实体被技能伤害时作用(参数1:Card模板ID 对应才作用)
    DES_BY_D_BUFF   = 12,                   -- 目标实体被BUFF伤害时作用(参数1:BuffGroup模板ID 对应才作用)
    BULLET_HIT      = 13,                   -- 子弹击中时作用
}

-- BUFF替换类型
EM.BUFF_REPLACE_TYPE = 
{
    NONE            = 0,                    -- NONE(可以共存)
    ONLY            = 1,                    -- 唯一的 不可多个
    REPLACE         = 2,                    -- 新的替换旧的
    LEVEL_UP        = 3,                    -- 升级
}

-- 地图类型
EM.MAP_TYPE = 
{
    NONE            = 0,                    -- NONE
    ALL_DEAD        = 1,                    -- 敌方全灭
    RES             = 2,                    -- 资源夺取(参数1:资源获胜总量)
    PUSH_CAR        = 3,                    -- 推车(参数1:获胜分数)
}

-- 建筑类型
EM.BUILDING_TYPE = 
{
    NONE            = 0,                    -- NONE
    RES             = 1,                    -- 资源(参数1:每帧占取 参数2:占取满值 参数3:每帧产出)
    CAR             = 2,                    -- 车(参数1:红得分点X 参数2:红得分点Y 参数3:蓝得分点X 参数4:蓝得分点Y 参数5:到达得分点分数)
}

-- 箱子类型
EM.BOX_TYPE = 
{
    NONE            = 0,                    -- NONE
    COIN            = 1,                    -- 金币购买箱子
    MONEY           = 2,                    -- 用现金购买箱子
}

-- 箱子掉落类型
EM.BOX_DROP_TYPE = 
{
    NONE            = 0,                    -- NONE
    ROLE            = 1,                    -- 专属角色牌
    COMMON          = 2,                    -- 通用牌
    COIN            = 3,                    -- 金币牌
}

-- 奖励类型
EM.REWARD_TYPE = 
{
    NONE            = 0,                    -- NONE
    EXP             = 1,                    -- 经验
    COIN            = 2,                    -- 金币
    CARD            = 3,                    -- 卡牌
}

-- 奖励类型
EM.REWARD_NUM_TYPE = 
{
    NONE            = 0,                    -- NONE
    ALL             = 1,                    -- 总值
    ADD             = 2,                    -- 本次增加值
}

-- 任务类型
EM.TASK_TYPE = 
{
    NONE            = 0,                    -- NONE
    REWARD          = 1,                    -- 奖励任务(每日上线获得)
    GROUP           = 2,                    -- 成长任务
    ACTIVITY        = 3,                    -- 活动任务
}

-- 好友操作类型
EM.MSG_FRIEND_OP_TYPE = 
{
    NONE            = 0,                    -- NONE
    GET             = 1,                    -- 获取信息
    AGREE           = 2,                    -- 同意好友申请
    REFUSE          = 3,                    -- 拒绝好友申请
    REMOVE          = 4,                    -- 删除好友
}

-- 一些常量
EM.COMMON = 
{
    CONVERSION_NUM  = 10000,                -- 配置表常用换算系数 万分比
    SEND_TIMES      = 10,                   -- 1秒通讯次数
    COEFFICIRNT     = 1000,                 -- 万分比换算系数 转换为帧数
    MAP_RATIO       = 200000,               -- 地图前后端比值
    ONE_DAY_SECOND  = 86400,                -- 一天秒数
    DELAY_FRAME     = 4,                    -- 延迟帧数
    MAX_VALUE       = 999999999             -- 表示无穷大值
}

-- Key值
EM.KEY = 
{
    CONF_DATA       = "ConfData",           -- 数据表在sharedata中的Key值
}

-- 数据表名称(单条)
EM.DATA = 
{
    COMMON          = "Common",             -- 配置表
}

-- 数据表名称(数组类)
EM.DATA_ARRAY = 
{
    CARD            = "Card",               -- 卡牌配置表
    ROLE            = "Role",               -- 人物配置表
    SUMMON          = "Summon",             -- 召唤兽配置表
    MAP             = "Map",                -- 地图配置表
    BUFF_GROUP      = "BuffGroup",          -- BUFF组配置表
    BULLET          = "Bullet",             -- 弹幕配置表
    TRAP            = "Trap",               -- 陷阱配置表
    BUILDING        = "Building",           -- 建筑配置表
    PLAYER_LEVEL    = "PlayerLevel",        -- 玩家等级表
    BOX             = "Box",                -- 宝箱配置表
    BOX_CARD        = "BoxCard",            -- 宝箱卡牌表
    POLYGON         = "Polygon",            -- 多边形配置表
}

----- 后端用 -----
-- 战场事件(后端用)
EM.BA_EVENT_TYPE = 
{
    NONE            = 0,                    -- NONE
    ENTITY_DEAD     = 1,                    -- 实体死亡
}

-- 战场状态(后端用)
EM.BA_STATE = 
{
    NONE            = 0,                    -- NONE
    READY           = 1,                    -- 准备阶段
    START           = 2,                    -- 开始
    END             = 3,                    -- 结束
}

-- 实体状态机状态
EM.BE_FSM_STATE = 
{
    NONE            = "None",               -- 无状态，普攻状态
    INSTANT         = "Instant",            -- 瞬发
    SING            = "Sing",               -- 吟唱
    LAST            = "Last",               -- 持续
    BULLET_RE       = "BulletRe",           -- 子弹回弹          
}

-- 移动类型
EM.MOVE_TYPE = 
{
    NONE            = 0,                    -- NONE
    LINE_TARGET     = 1,                    -- 直线(以目标方向 到目标停止)
    LINE_MOVE       = 2,                    -- 直线(以上次移动方向)
    TRACK_TARGET    = 3,                    -- 追踪目标
    SRC_TO_MY       = 4,                    -- 源实体到我的方向
    TARGET_TO_MY    = 5,                    -- 目标到我的方向
    MY_TO_SRC       = 6,                    -- 我到源实体的方向
    MY_SRC_MID      = 7,                    -- 我到源实体中间位置
    SRC_POS         = 8,                    -- 源实体位置
    SRC_ORI         = 9,                    -- 源实体朝向
}

-- SG命令类型
EM.SG_CMD_TYPE = 
{
    UPDATE          = "update",             -- 更新数据
    COMMIT          = "commit",             -- 提交数据并重启
    REBOOT          = "reboot",             -- 重启
}

-- 实体阵营类型
EM.ENTITY_CAMP_TYPE = 
{
    NONE            = 0,                    -- 所有阵营
    SAME            = 1,                    -- 与自己相同
    DIFF            = 2,                    -- 与自己不同
}

-- 寻找目标方式
EM.FIND_TARGET_TYPE = 
{
    NONE            = 0,                    -- 不找寻目标
    NEAREST_ENEMY   = 1,                    -- 最近敌方
    RANDOM_R_ENEMY  = 2,                    -- 随机攻击范围内敌方
    SUMMONER        = 3,                    -- 召唤者
    SUMMONER_TARGET = 4,                    -- 召唤者的目标
}

-- BUFF触发攻击类型
EM.BUFF_TRIGGER_ATTACK_TYPE = 
{
    NONE            = 0,                    -- NONE全部
    NEAR            = 1,                    -- 近战
    FAR             = 2,                    -- 远程
}

-- 地图参数类型
EM.MAP_PARAM_TYPE = 
{
    SIZE            = "Map_Size",           -- 相机尺寸
    DATA_NAME       = "Point",              -- 数据表名称
    POINT_TYPE      = "Point_Type",         -- 点的类型
}

-- 地图点类型
EM.MAP_POINT_TYPE = 
{
    STOP            = -1,                   -- 阻挡
    NONE            = 0,                    -- NONE
    RED_CAMP        = 1,                    -- 红色阵营出生位置
    BLUE_CAMP       = 2,                    -- 蓝色阵营出生位置
}

-- 重生点类型
EM.REBIRTH_POINT_TYPE = 
{
    NONE            = 0,                    -- NONE(原地)
    BORN            = 1,                    -- 出生点
}

