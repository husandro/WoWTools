local function Save()
    return  WoWToolsSave['Minimap_Plus']
end
local Button










local function Init_Menu(self, root)
    if not Button then
        return
    end

    local sub

    --显示背景
    WoWTools_MenuMixin:ShowBackground(root,
    function()
        return not Save().Icons.hideBackground
    end, function()
        local hide= Save().Icons.hideBackground
        Save().Icons.hideBackground= not hide and true or nil
        self:settings()
    end)

    root:CreateDivider()
--重置位置
    WoWTools_MenuMixin:RestPoint(self, root, Save().Icons.point, function()
        Save().Icons.point=nil
        self:set_point()
        return MenuResponse.Open
    end)

--打开，选项
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MinimapMixin.addName})

    WoWTools_MinimapMixin:Init_Plus_Menu(self, sub)
end


















local function Init()
    if Save().Icons.disabled then
        return
    end

    Button= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsMinimapCollectionIcons',
        size={15, 23},
        addTexture=true,
    })
    Button.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
    Button.texture:SetAlpha(0.3)

    Button.frame= CreateFrame('Frame', nil, Button)
    Button.frame:SetPoint('RIGHT', Button, 'LEFT')

--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(Button.frame, {isAllPoint= true})

    Button:SetMovable(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:HookScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save().Icons.point= {self:GetPoint(1)}
        Save().Icons.point[2]=nil
    end)

    Button:SetScript("OnMouseUp", ResetCursor)--停止移动
    Button:HookScript("OnMouseDown", function(self, d)--设置, 光标
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
             MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)



    Button:SetScript("OnLeave", function(self)
        self.texture:SetAlpha(0.3)
        ResetCursor()
    end)
    Button:SetScript('OnEnter', function(self)
        self.texture:SetAlpha(1)
        self:set_tooltip()
    end)

    function Button:set_event()
        self:UnregisterAllEvents()
--战斗
        if Save().Icons.hideInCombat then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
--移动
        if Save().Icons.hideInMove then
            self:RegisterEvent("PLAYER_STARTED_MOVING")
            self:RegisterEvent("PLAYER_STOPPED_MOVING")
        end
    end

    function Button:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_MinimapMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end

    function Button:settings()
        self.Background:SetShown(not Save().Icons.hideBackground)
    end

    function Button:set_point()
        self:ClearAllPoints()
        local p= Save().Icons.point
        if p then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('RIGHT', WoWTools_MinimapMixin.MiniButton, 'LEFT')
        end
    end
    function Button:rest()

    end

    Button:set_point()
    Button:settings()
    Init=function()
        if Save().Icons.disabled then
            Button:rest()
        else
            Button:settings()
        end
    end
end








function WoWTools_MinimapMixin:Init_Collection_Icon()
    Init()
end

function WoWTools_MinimapMixin:Collection_Icon_Menu(_, root)
    Init_Menu(Button, root)
end
