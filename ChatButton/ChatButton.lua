local id, e = ...
local Save={scale=0.8}
local addName='ChatButton'
local panel=e.Cbtn(UIParent, nil, nil, nil, 'WoWToolsChatButtonFrame', true, {30,30})
WoWToolsChatButtonFrame.last=panel

--####
--初始
--####
local function Init()
    panel:SetSize(10,30)
    if Save.scale and Save.scale~=1 then--缩放
        panel:SetScale(Save.scale)
    end
    if Save.Point then
        panel:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
    else
        panel:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
    end
    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)

    panel:SetScript("OnDragStart", function(self,d )
        if not IsModifierKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
        print(id, addName, (e.onlyChinse and '重置位置' or RESET_POSITION), 'Alt+'..e.Icon.right)
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then--提示移动
            print(id, addName, (e.onlyChinse and '移动' or NPE_MOVE)..e.Icon.right, (e.onlyChinse and '缩放' or UI_SCALE)..'Alt+'..e.Icon.mid,Save.scale)

        elseif d=='RightButton' and not IsModifierKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and IsAltKeyDown() then--还原
            if UnitAffectingCombat('player') then
                print(id ,addName, (e.onlyChinse and '移动' or NPE_MOVE), '|cnRED_FONT_COLOR:'..(e.onlyChinse and '战斗中' or COMBAT))
                return
            end
            Save.Point=nil
            panel:ClearAllPoints()
            panel:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end
    end)
    panel:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    panel:SetScript("OnLeave",function(self)
        ResetCursor()
        self:SetButtonState('NORMAL')
    end)
    panel:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            if UnitAffectingCombat('player') then
                print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '战斗中' or COMBAT))
            else
                local sacle=Save.scale or 1
                if d==1 then
                    sacle=sacle+0.1
                elseif d==-1 then
                    sacle=sacle-0.1
                end
                if sacle>3 then
                    sacle=3
                elseif sacle<0.6 then
                    sacle=0.6
                end
                print(id, addName, (e.onlyChinse and '缩放' or UI_SCALE), sacle)
                self:SetScale(sacle)
                Save.scale=sacle
            end
        end
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            if WoWToolsSave and not WoWToolsSave[addName] then
                panel:SetButtonState('PUSHED')
            end

            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            panel.sel=e.CPanel(addName, not Save.disabled, true)
            panel.sel:SetScript('OnMouseDown', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                panel.disabled=Save.disabled
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)
            if not Save.disabled then
                Init()
            else
                self:SetShown(false)
                panel.disabled=true
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)