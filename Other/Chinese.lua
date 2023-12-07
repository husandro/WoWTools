local id, e= ...
if LOCALE_zhCN or LOCALE_zhTW then
    return
end


local addName= BUG_CATEGORY15
local Save={
    disabled= e.Player.husandro
}




local function set(self, text)
    if not self then
        return
    end
    self:SetText(text)
end



local function Init()
    --角色
    set(CharacterFrameTab1, '角色')
    set(CharacterFrameTab2, '声望')
    set(CharacterFrameTab3, '货币')
    set(CharacterStatsPane.ItemLevelCategory.Title, '物品等级')
    set(CharacterStatsPane.AttributesCategory.Title, '属性')
    set(CharacterStatsPane.EnhancementsCategory.Title, '强化属性')
    
    set(PaperDollFrameEquipSetText, '装备')
    set(PaperDollFrameSaveSetText , '保存')

    set(GearManagerPopupFrame.BorderBox.EditBoxHeaderText, '输入方案名称（最多16个字符）：')
    set(GearManagerPopupFrame.BorderBox.IconSelectionText, '选择一个图标：')
    set(GearManagerPopupFrame.BorderBox.OkayButton, '确认')
    set(GearManagerPopupFrame.BorderBox.CancelButton, '取消')
    GearManagerPopupFrame:HookScript('OnShow', function(self)
        set(self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader, '当前已选择')
        set(self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription, '点击在列表中浏览')
    end)

end








--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not e.onlyChinese then
                Init=function() end
                return
            end

            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
              Init()
            end

            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)