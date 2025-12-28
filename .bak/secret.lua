--[[
https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes

issecretvalue(value) 如果提供的值是秘密的，则返回 true。
canaccesssecrets() 如果直接调用函数无法访问秘密值，即因为执行已被污染，则返回 false。
canaccessvalue(value) 如果给定的值不是秘密值，或者调用函数被允许访问秘密值，则返回 true。

issecrettable ( table ) 如果表已被标记为秘密，则返回 true。
canaccesstable ( table ) 如果给定的表不是秘密的，或者调用函数被允许访问秘密信息，则返回 true。

自动生成的 API 文档已扩展，详细说明了 API 如何处理密钥。

无条件返回秘密值的函数被标记为SecretReturns = true。
也存在有条件地返回秘密值的函数。
UnitName（unit）在战斗中查询非玩家或宠物单位时返回秘密值（SecretNonPlayerUnitOrMinionWhileInCombat = true）。
UnitClass（单元）将其第一个返回值标记为有条件地秘密（ConditionalSecret = true）。
函数是否接受秘密值作为参数，由该SecretArguments字段记录。
如果设置为"AllowedWhenUntainted"函数，则仅在执行未被污染的情况下才接受秘密值。
如果设置为"AllowedWhenTainted"函数，则始终可以接受秘密值。
如果设置为"NotAllowed"某个函数，则该函数永远不会接受秘密值，即使是来自未受污染的调用者。


FrameScriptObject:HasAnySecretAspect
FrameScriptObject:HasSecretAspect
FrameScriptObject:HasSecretValues
FrameScriptObject:IsPreventingSecretValues
FrameScriptObject:SetPreventSecretValues
ScriptRegion:IsAnchoringSecret
]]