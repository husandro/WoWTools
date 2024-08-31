local id, e = ...
local addName= CHARACTER
Save={
    --EquipmentH=true, --装备管理, true横, false坚
    equipment= e.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1,--装备管理, 缩放
    --hide=true,--隐藏CreateTexture

    --notStatusPlus=true,--禁用，属性 PLUS
    StatusPlus_OnEnter_show_menu=true,--移过图标时，显示菜单

    --notStatusPlusFunc=true, --属性 PLUS Func
    itemLevelBit= 1,--物品等级，位数
}

WoWTools_PaperDoll_Mixin={}

function WoWTools_PaperDoll_Mixin:GetSave()
    return Save
end
function WoWTools_PaperDoll_Mixin:SetSave(save)
    Save=save
end






local panel= CreateFrame("Frame", nil, PaperDollFrame)
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            Save= WoWToolsSave[addName] or Save
            Save.itemLevelBit= Save.itemLevelBit or 1

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName),
                --tooltip= Initializer:GetName(),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            })

            --[[添加控制面板
            local sel=e.AddPanel_Check((e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)]]


            if not Save.disabled then
                Init()
                self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
                self:RegisterEvent('SOCKET_INFO_UPDATE')--宝石，更新

                --[[ProfessionsFrame_LoadUI()
                OpenProfessionUIToSkillLine(202)
                C_TradeSkillUI.CloseTradeSkill()]]

            else
                self:UnregisterEvent('ADDON_LOADED')
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_InspectUI' then--目标, 装备
            self:Init_Target_InspectUI()
            InspectFrame:HookScript('OnShow', Set_Target_Status)
            --hooksecurefunc('InspectFrame_UnitChanged', Set_Target_Status)
            hooksecurefunc('InspectPaperDollItemSlotButton_Update', set_InspectPaperDollItemSlotButton_Update)--目标, 装备
            hooksecurefunc('InspectPaperDollFrame_SetLevel', set_InspectPaperDollFrame_SetLevel)--目标,天赋 装等
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        GetDurationTotale()--装备,总耐久度

    elseif event=='SOCKET_INFO_UPDATE' then--宝石，更新
        if PaperDollItemsFrame:IsShown() then
            e.call(PaperDollFrame_UpdateStats)
        end
    end
end)
