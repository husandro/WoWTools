--头衔数量
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local Button






local function Init_Menu(_, root)
    local all= GetNumTitles()
    root:CreateTitle(
       ((#GetKnownTitles()-1)..'/'..GetNumTitles()..' ')
       ..(e.onlyChinese and '未收集' or NOT_COLLECTED)
    )

    local sub
    local num=0
    for i=1, all, 1 do
        if not IsTitleKnown(i) then
            num= num+1
            local name, playerTitle = GetTitleName(i)
            if name and playerTitle then
                local cnName
                if WoWTools_Chinese_Mixin then
                    cnName= e.cn(name, {titleID=i})
                end

                sub=root:CreateButton(
                    num..') '
                    ..(cnName and cnName:find('%%s') and format(name, '') or name),

                function(data)
                    WoWTools_TooltipMixin:Show_URL(true, 'title', data.index, nil)
                    return MenuResponse.Open

                end, {index=i, name=name, cnName=cnName})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(e.Icon.left..'wowhead.com')
                    tooltip:AddLine('index '..description.data.index)
                    tooltip:AddLine(description.data.name..' ')
                    local cn= description.data.cnName
                    if cn and cn:find('%%s') then
                        local player= UnitName('player')
                        tooltip:AddLine(format(cn, player))
                    end
                end)

            end
        end
    end

    WoWTools_MenuMixin:SetScrollMode(root)
end





local function Init_Button()
--未收集
    Button= WoWTools_ButtonMixin:Menu(PaperDollFrame.TitleManagerPane, {icon='hide'})
    Button.Text= WoWTools_LabelMixin:Create(Button)
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

    Button:SetScript('OnShow', Button.settings)
    Button:SetScript('OnHide', function(self)
        self.Text:SetText("")
    end)




--已收集数量
    Title= WoWTools_LabelMixin:Create(PaperDollSidebarTab2, {justifyH='CENTER', mouse=true})
    Title:SetPoint('BOTTOM')

    function Title:settings()
        self:SetText(#GetKnownTitles()-1)
    end
    Title:SetScript('OnShow', Title.settings)
    Title:SetScript('OnHide', function(self)
        self:SetText("")
    end)

    Title:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    Title:SetScript('OnEnter', function(self)
        self:settings()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(e.onlyChinese and '头衔' or PAPERDOLL_SIDEBAR_TITLES)--, WoWTools_PaperDollMixin.addName)
        local known= #GetKnownTitles()-1
        GameTooltip:AddDoubleLine(
            '|cnGREEN_FONT_COLOR:'..known,
            '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or  COLLECTED)
        )

        GameTooltip:AddDoubleLine(
            '|cnRED_FONT_COLOR:'..(GetNumTitles()-known),
            '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)
        )
        GameTooltip:Show()
        self:SetAlpha(0)
    end)

    Title:SetScript('OnMouseDown', function()
        e.call(PaperDollFrame_SetSidebar, _G['PaperDollSidebarTab2'], 2)--PaperDollFrame.lua
    end)

end














function WoWTools_PaperDollMixin:Init_Tab2()--头衔数量
    Init_Button()
end

function WoWTools_PaperDollMixin:Settings_Tab2()--头衔数量
    local show= PAPERDOLL_SIDEBARS[2].IsActive() and not Save().hide
    Title:SetShown(show)
    Button:SetShown(show)
end


