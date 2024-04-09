local e = select(2, ...)
local addName= 'Tools'
local panel= CreateFrame("Frame")
local Save={

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

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[id..'_Tools'] or Save

            --添加控制面板
            e.AddPanel_Sub_Category({name='|A:bag-border-empty:0:0|aTools', frame=panel})
            
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[id..'_Tools']=Save
        end
    end
end)