local id, e = ...
local Save={scale=0.8}
local addName='ChatButton'
local panel=e.Cbtn(UIParent, nil, nil, nil, 'WoWToolsChatButtonFrame', true, {30,30})
--e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)


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
        panel:SetPoint('BOTTOMRIGHT', SELECTED_CHAT_FRAME, 'TOPLEFT',0,10)
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
        print(id, addName, RESET_POSITION, 'Alt+'..e.Icon.right)
    end)
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then--提示移动
            print(id, addName, NPE_MOVE..e.Icon.right, UI_SCALE..'Alt+'..e.Icon.mid)

        elseif d=='RightButton' and not IsModifierKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and IsAltKeyDown() then--还原
            panel:ClearAllPoints()
            panel:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 25)
        end
    end)
    panel:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    panel:SetScript("OnLeave",function()
        ResetCursor()
    end)
    panel:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
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
            print(id, addName, UI_SCALE, sacle)
            self:SetScale(sacle)
            Save.scale=sacle
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