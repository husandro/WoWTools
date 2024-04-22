local id, e = ...
--local addName= 'Tools'
local panel= CreateFrame("Frame")
local Save={
    --disabled=true,
}



e.toolsFrame=CreateFrame('Frame')--TOOLS 框架
e.toolsFrame:SetSize(1,1)
e.toolsFrame:SetShown(false)
e.toolsFrame.last=e.toolsFrame
e.toolsFrame.line=1
e.toolsFrame.index=0




function e.ToolsSetButtonPoint(self, line, unoLine)--设置位置
    self:SetSize(30, 30)
    if (not unoLine and e.toolsFrame.index>0 and select(2, math.modf(e.toolsFrame.index / 10))==0) or line then
        local x= - (e.toolsFrame.line * 30)
        self:SetPoint('BOTTOMRIGHT', e.toolsFrame , 'TOPRIGHT', x, 0)
        e.toolsFrame.line=e.toolsFrame.line + 1
        if line then
            e.toolsFrame.index=0
        end
    else
        self:SetPoint('BOTTOMRIGHT', e.toolsFrame.last , 'TOPRIGHT')
    end
    e.toolsFrame.last=self
    e.toolsFrame.index=e.toolsFrame.index+1
end














--[[local function Init_Options()
    local Category, Layout= e.AddPanel_Sub_Category({name='|A:bag-border-empty:0:0|aTools'})
    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= e.cn(addName),
        value= not Save.disabled,
        category= Category,
        func= function()
            Save.disabled= not Save.disabled and true or nil
            print(e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            Init_Options()--初始, 选项
        end
    })

end]]





local function Init()
    e.toolsFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
    e.toolsFrame:RegisterEvent('PLAYER_STARTED_MOVING')
    e.toolsFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_REGEN_DISABLED' then
            if self:IsShown() then
                self:SetShown(false)--设置, TOOLS 框架,隐藏
            end
        elseif event=='PLAYER_STARTED_MOVING' then
            if not UnitAffectingCombat('player') and self:IsShown() then
                self:SetShown(false)--设置, TOOLS 框架,隐藏
            end
        end
    end)
end






panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[id..'_Tools'] or Save
            e.toolsFrame.disabled= Save.disabled
            e.toolsFrame.addName= '|A:bag-border:0:0|aTools'

            e.AddPanel_Check({
                name= e.toolsFrame.addName,
                --tooltip= e.cn(addName),
                value= not Save.disabled,
                category= Category,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                    Init_Options()--初始, 选项
                end
            })

            if Save.disabled then
                self:UnregisterAllEvents()
            else
                Init()
                self:UnregisterEvent('ADDON_LOADED')
            end

        --elseif arg1=='Blizzard_Settings' then
          --  Init_Options()--初始, 选项           
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[id..'_Tools']=Save
        end
    end
end)