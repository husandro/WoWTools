local e= select(2, ...)
local function Save()
    return WoWTools_AttributesMixin.Save
end

















local function Init_Menu(self, root)
    local sub
    root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'..(e.onlyChinese and '重置数值' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, STATUS_TEXT_VALUE)),
    function()
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
        print(e.Icon.icon2..WoWTools_AttributesMixin.addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '重置数值' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, STATUS_TEXT_VALUE))
        return MenuResponse.Open
    end)

    root:CreateDivider()
    root:CreateCheckbox(
        e.Icon.mid..(e.onlyChinese and '显示' or SHOW),
    function()
        return self.frame:IsShown()
    end, function()
        Save().hide= not Save().hide and true or nil
        self:set_Show_Hide()--显示， 隐藏
    end)

    sub=root:CreateButton(
        '|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '发送信息' or SEND_MESSAGE),
    function()
        self:send_Att_Chat()--发送信息
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(self:get_sendTextTips())
        tooltip:AddLine(self:get_Att_Text_Chat())
    end)

--专精
    WoWTools_MenuMixin:Set_Specialization(root)


    root:CreateDivider()
--目标移动速度
    local targetMove= WoWTools_AttributesMixin.TargetMoveButton
    if targetMove then
        sub= root:CreateButton(
            '|A:common-icon-rotateright:0:0|a'..(e.onlyChinese and '目标移动' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TARGET, NPE_MOVE)),
        function()
            return MenuResponse.Open
        end)
        WoWTools_AttributesMixin:Target_Speed_Menu(self, sub)
    end

--选项
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name= WoWTools_AttributesMixin.addName,
        category=WoWTools_AttributesMixin.Category,
    })


--显示背景
    WoWTools_MenuMixin:ShowBackground(sub,
    function()
        return Save().showBG
    end, function()
        Save().showBG= not Save().showBG and true or nil
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end)


    sub:CreateDivider()
--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:set_Point()--设置, 位置
        return MenuResponse.Open
    end)
end

















function WoWTools_AttributesMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end