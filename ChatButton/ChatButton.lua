local id, e = ...
local Save={}
local addName='ChatButton'
local panel=e.Cbtn(SELECTED_CHAT_FRAME, nil, nil, nil, 'WoWToolsChatButtonFrame', true, {30,30})
--e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)


--####
--初始
--####
local function Init()
    panel:SetSize(10,30)
    if Save.Point then
        panel:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
    end
    panel:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 25)

    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)

    panel:SetScript("OnDragStart", function(self,d )
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)
    panel:SetScript("OnMouseDown", function(self,d)
      if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    panel:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)

    panel:SetScript('OnEnter', function (self)

    end)
    panel:SetScript("OnLeave",function(self)
        e.tips:Hide()
        ResetCursor()
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
            end)
            if not Save.disabled then
                Init()
            else
                panel.disabled=true
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)