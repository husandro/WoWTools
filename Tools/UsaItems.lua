local id, e = ...
local addName=USE..ITEMS
local panel=CreateFrame("Frame")
local Save= {
        item={
            49040,--[基维斯]
            144341,--[可充电的里弗斯电池]
            40768,--[移动邮箱]
            156833,--[凯蒂的印哨]
            168667,--[布林顿7000]
            128353,--[海军上将的罗盘]
            167075,--[超级安全传送器：麦卡贡]
            168222,--[加密的黑市电台]
            184504,184501, 184503, 184502, 184500, 64457,--[侍神者的袖珍传送门：奥利波斯]
        },
        spell={

        },
        equip={

        }
}

--####
--初始
--####
local function Init()
   

end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            Init()--初始
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--主图标冷却
    end
end)