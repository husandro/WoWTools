
local id, e= ...
local Save={}
local addName= STAT_CATEGORY_ATTRIBUTES
local panel= CreateFrame('Frame')
local button

local Stats = {
    [1] = {name= e.onlyChinse and '力量', LE_UNIT_STAT_STRENGTH},
    [2] = {name= e.onlyChinse and '敏捷', LE_UNIT_STAT_AGILITY},
    [3] = {name= e.onlyChinse and '智力', LE_UNIT_STAT_INTELLECT},
    }

local Tabs={
    {name='STAUTS', r=e.Player.r, g=e.Player.g, b=e.Player.b, text= e.onlyChinse and  SPEC_FRAME_PRIMARY_STAT},
}

local function set_OnEvent(frame, name)
    
    if name=='STAUTS' then
        local spec = GetSpecialization()
        local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")))
        frame:RegisterUnitEvent('UNIT_STATS', 'player')
        frame.primaryStat= primaryStat
        frame:SetScript("OnEvent", function(self)
            local stat, effectiveStat, posBuff, negBuff = UnitStat('player', self.primaryStat);
            local effectiveStatDisplay = BreakUpLargeNumbers(effectiveStat);
            self.text:SetText(UnitStat('player', self.primaryStat))
        end)
    end
end
local function create_Lable()
    local last
    for _, info in pairs(Tabs) do
        if not button[info.name] then
            local frame= CreateFrame('Frame', nil, button)
            frame:SetPoint('TOPRIGHT', last or button, 'BOTTOMRIGHT')
            frame:SetSize(6, 12)
            frame.label= e.Cstr(frame, nil, nil, nil, {info.r,info.g,info.b}, nil, 'RIGHT')
            frame.label:SetPoint('TOPRIGHT', last or button, 'BOTTOMRIGHT')
            last= frame
            frame.text= e.Cstr(frame, nil, nil, nil, {1,1,1}, nil, 'LEFT')
            frame.text:SetPoint('LEFT', frame, 'RIGHT')
            set_OnEvent(frame, info.name)
            frame.label:SetText('aaa')
            frame.text:SetText('bbb')
        end
        
    end
end

--####
--初始
--####
local function Init()
    --##########
    --设置 panel
    --##########
    panel.name = (e.onlyChinse and '属性' or STAT_CATEGORY_ATTRIBUTES)..'|A:charactercreate-icon-customize-body-selected:0:0|a'--添加新控制面板
    panel.parent =id
    InterfaceOptions_AddCategory(panel)

    --e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
    button= e.Cbtn(nil, nil, nil, nil, nil, true, {18,18})
    if Save.point then
        button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        button:SetPoint('LEFT', 80, 180)
    end
    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)
    button:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then--提示移动

        elseif d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        end
    end)
    button:SetScript("OnMouseUp", function() ResetCursor() end)
    button:SetScript("OnLeave",function() ResetCursor() e.tips:Hide() end)
    button:SetScript('OnMouseWheel', function(self, d)--缩放
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
        
        self:SetScale(sacle)
        Save.scale=sacle
    end)
    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinse and '重置' or RESET, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinse and '缩放' or UI_SCALE)..': '..(Save.scale or 1), e.Icon.mid)
        e.tips:Show()
    end)


    

    if Save.scale and Save.scale~=1 then--缩放
        button:SetScale(Save.scale)
    end

    C_Timer.After(2, create_Lable)
end


panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local check= e.CPanel((e.onlyChinse and '属性' or STAT_CATEGORY_ATTRIBUTES)..'|A:charactercreate-icon-customize-body-selected:0:0|a', not Save.disabled)
            check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需求重新加载' or REQUIRES_RELOAD)
            end)
            --[[check:SetScript('OnEnter', function(self2)
                local name, description, filedataid= C_ChallengeMode.GetAffixInfo(13)
                if name and description then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(name, filedataid and '|T'..filedataid ..':0|t' or ' ')
                    e.tips:AddLine(description, nil,nil,nil,true)
                    e.tips:Show()
                end
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)]]
            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)