
local function Save()
    return WoWToolsSave['Plus_Attributes'] or {}
end

















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    
    local sub
    root:CreateButton(
        '|A:characterundelete-RestoreButton:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置数值' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, STATUS_TEXT_VALUE)),
    function()
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
        print(
            WoWTools_AttributesMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnGREEN_FONT_COLOR:',
            WoWTools_DataMixin.onlyChinese and '重置数值' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RESET, STATUS_TEXT_VALUE)
        )
        return MenuResponse.Open
    end)

    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW),
    function()
        return self.frame:IsShown()
    end, function()
        Save().hide= not Save().hide and true or nil
        self:set_Show_Hide()--显示， 隐藏
    end)

    sub=root:CreateButton(
        '|A:communities-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '发送信息' or SEND_MESSAGE),
    function()
        self:send_Att_Chat()--发送信息
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(self:get_sendTextTips())
        tooltip:AddLine(self:get_Att_Text_Chat())
    end)

    root:CreateDivider()
--专精
    WoWTools_MenuMixin:Set_Specialization(root)


    root:CreateDivider()
--目标移动速度
    if _G['WoWToolsAttributesTargetMoveButton'] then
        sub= root:CreateButton(
            '|A:common-icon-rotateright:0:0|a'..(WoWTools_DataMixin.onlyChinese and '目标移动' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TARGET, NPE_MOVE)),
        function()
            return MenuResponse.Open
        end)
        WoWTools_AttributesMixin:Target_Speed_Menu(self, sub)
    end

--选项
    sub=WoWTools_AttributesMixin:Open_Options(root)


--背景, 透明度
    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().bgAlpha or 0.5
    end, function(value)--SetValue
        Save().bgAlpha=value
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end, function()--RestFunc
        Save().bgAlpha= 0.5
        WoWTools_AttributesMixin:Frame_Init(true)--初始， 或设置
    end)--onlyRoot

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
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
    MenuUtil.CreateContextMenu(frame, function(...) Init_Menu(...) end)
end