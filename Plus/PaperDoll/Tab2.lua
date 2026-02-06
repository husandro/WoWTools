--头衔数量
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end
local Button, Title






local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local all= GetNumTitles()
    root:CreateTitle('|cnGREEN_FONT_COLOR:'..(#GetKnownTitles()-1)..'|r/'..all..' ')

    local sub

    for i=1, all do
        local name = GetTitleName(i)
        if name then
            local cn= WoWTools_TextMixin:CN(name, {titleID=i})
            if cn then
                cn= cn:gsub('%%s', '')
                cn= cn=='' and name or cn
                cn= cn~=name and cn or nil
            end
            sub=root:CreateButton(

                (IsTitleKnown(i) and '|cffffffff' or '|cff606060')
                ..(cn or name),

            function(data)
                WoWTools_TooltipMixin:Show_URL(true, 'title', data.rightText, nil)
                return MenuResponse.Open

            end, {rightText=i, name=name, cn=cn})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(WoWTools_DataMixin.Icon.left..'wowhead.com')
                tooltip:AddLine('index '..description.data.rightText)
                tooltip:AddLine(description.data.name..' ')
                if description.data.cn then
                    tooltip:AddLine(description.data.cn)
                end
            end)
            WoWTools_MenuMixin:SetRightText(sub)

        end
    end

    WoWTools_MenuMixin:SetScrollMode(root)
end





local function Init_Button()
--未收集
    Button= CreateFrame('DropdownButton', 'WoWToolsTitleMenuButton', PaperDollFrame.TitleManagerPane, 'WoWToolsButtonTemplate')
    Button:SetSize(23,23)
    Button:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    Button.tooltip= WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED
    Button.Text= Button:CreateFontString(nil, 'ARTWORK', 'GameFontDisableSmall')
    Button.Text:SetPoint('CENTER')
    Button:SetFrameLevel(PaperDollFrame.TitleManagerPane.ScrollBox:GetFrameLevel()+1)
    Button:SetPoint('TOPRIGHT', -16, 2)
    Button:SetupMenu(Init_Menu)
    Button:Hide()

    function Button:settings()
        self.Text:SetText(GetNumTitles()- #GetKnownTitles() -1)
        local w, h= self.Text:GetSize()
        self:SetSize(w+4, h+4)
    end

    Button:SetScript('OnShow', function(self)
        self:settings()
    end)
    Button:SetScript('OnHide', function(self)
        self.Text:SetText("")
    end)




--已收集数量
    Title= WoWTools_LabelMixin:Create(PaperDollSidebarTab2, {
        justifyH='CENTER',
        mouse=true,
        name='WoWToolsTitleNumLabel'
    })
    Title:SetPoint('BOTTOM')

    function Title:settings()
        self:SetText(#GetKnownTitles()-1)
    end
    Title:SetScript('OnShow', function(self)
        self:settings()
    end)
    Title:SetScript('OnHide', function(self)
        self:SetText("")
    end)

    Title:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    Title:SetScript('OnEnter', function(self)
        self:settings()
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '头衔' or PAPERDOLL_SIDEBAR_TITLES)
            .. ' |cffffffff'..#GetKnownTitles()..'|r '
            ..(WoWTools_DataMixin.onlyChinese and '已收集' or  COLLECTED)
        )
        --[[GameTooltip:AddDoubleLine(
            '|cnWARNING_FONT_COLOR:'..(GetNumTitles()-known-1),
            '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)
        )]]
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    Title:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', _G['PaperDollSidebarTab2'], 2)--PaperDollFrame.lua
    end)

end














--[[function WoWTools_PaperDollMixin:Init_Tab2()--头衔数量
    Init_Button()
end

function WoWTools_PaperDollMixin:Settings_Tab2()--头衔数量
    local show= PAPERDOLL_SIDEBARS[2].IsActive() and not Save().hide
    Title:SetShown(show)
    Button:SetShown(show)
end]]


