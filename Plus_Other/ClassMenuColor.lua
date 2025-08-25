if WoWTools_ChineseMixin then
    return
end

local addName
local classTabs={}
local function Save()
    return WoWToolsSave['Other_ClassMenuColor']
end



--[[hooksecurefunc(DropdownButtonMixin, 'SetupMenu', function(self)
    print('SetupMenu', self.Text, self.text, self.fontString)
end)
hooksecurefunc(DropdownTextMixin, 'OnLoad', function(self)
    hooksecurefunc(self, 'SetText', function(btn, ...)
        print('SetText', btn:GetText())
    end)
end)
hooksecurefunc(DropdownTextMixin, 'UpdateText', function(self)
    print('UpdateText', self.Text:GetText())
end)
hooksecurefunc(DropdownSelectionTextMixin, 'OverrideText', function(self)
    print('OverrideText', self.Text:GetText())
end)
hooksecurefunc(DropdownSelectionTextMixin, 'UpdateToMenuSelections', function(self)
    print('UpdateToMenuSelections', self.Text:GetText())
end)


hooksecurefunc(MenuVariants, 'CreateCheckbox', function(...)
    print('CreateCheckbox',...)
end)]]

local function Init()
local tab

tab= {--https://wago.tools/db2/ChrClasses?locale=zhCN
[1] ='战士',
[2] ='圣骑士',
[3] ='猎人',
[4] ='潜行者',
[5] ='牧师',
[6] ='死亡骑士',
[7] ='萨满祭司',
[8] ='法师',
[9] ='术士',
[10] ='武僧',
[11] ='德鲁伊',
[12] ='恶魔猎手',
[13] ='唤魔师',
[14] ='冒险者',
}

for index = 1, GetNumClasses() do
    if (index == 10) and (GetClassicExpansionLevel() <= LE_EXPANSION_CATACLYSM) then-- We have an annoying gap between warlock and druid
        index = 11
    end
    local className, classFile, classID = GetClassInfo(index)
    if className then
        local hex= select(4, GetClassColor(classFile))

        classTabs[className]= WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile)
            ..'|c'..hex
            ..(WoWTools_DataMixin.onlyChinese and tab[classID] or className)
            ..'|r'

    end
end

--[ID]= ClassID,
--https://wago.tools/db2/ChrSpecialization?locale=zhCN
tab={
[62]= 8,
[63]= 8,
[64]= 8,
[65]= 2,
[66]= 2,
[70]= 2,
[71]= 1,
[72]= 1,
[73]= 1,
[102]= 11,
[103]= 11,
[104]= 11,
[105]= 11,
[250]= 6,
[251]= 6,
[252]= 6,
[253]= 3,
[254]= 3,
[255]= 3,
[256]= 5,
[257]= 5,
[258]= 5,
[259]= 4,
[260]= 4,
[261]= 4,
[262]= 7,
[263]= 7,
[264]= 7,
[265]= 9,
[266]= 9,
[267]= 9,
[268]= 10,
[269]= 10,
[270]= 10,
[577]= 12,
[581]= 12,
[1444]= 7,
[1446]= 1,
[1447]= 11,
[1448]= 3,
[1449]= 8,
[1450]= 10,
[1451]= 2,
[1452]= 5,
[1453]= 4,
[1454]= 9,
[1455]= 6,
[1456]= 12,
[1465]= 13,
[1467]= 13,
[1468]= 13,
[1473]= 13,
[1478]= 14,
}

for specID, classID in pairs(tab) do
    local className, classFile= GetClassInfo(classID)
    local hex=className and classFile and select(4, GetClassColor(classFile))
    if hex then
        for _, sex in pairs(Enum.UnitSex) do
            local name, _, icon, role= select(2, GetSpecializationInfoByID(specID, sex))
            if name and icon then
                classTabs[name]=
                    '|T'..icon..':0|t'
                    ..'|c'..hex
                    ..name
                    ..'|r'
                    ..(role and _G['INLINE_'..role..'_ICON'] or '')
            end
        end
    end
end


    hooksecurefunc(MenuUtil, 'SetElementText', function(desc, text)
        local colorText= classTabs[text]
        if not colorText then
            return
        end
        desc:AddInitializer(function(btn)
            btn.fontString:SetText(colorText)
        end)
    end)


    tab=nil
    Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['Other_ClassMenuColor']= WoWToolsSave['Other_ClassMenuColor'] or {}

    addName= '|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '职业菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, HUD_EDIT_MODE_MICRO_MENU_LABEL))

    --添加控制面板
    WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        Value= not Save().disabled,
        GetValue=function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            Init()
            if Save().disabled then
                print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_TextMixin:GetEnabeleDisable(Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end,
        tooltip=WoWTools_DataMixin.onlyChinese and '添加 颜色 图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, COLOR..', '..EMBLEM_SYMBOL),
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    })

    if not Save().disabled then
        Init()
    end
    self:UnregisterEvent(event)
end)