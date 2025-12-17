local classTabs={}
--https://wago.tools/db2/ChrClasses?locale=zhCN
WoWTools_DataMixin.ClassName_CN= {
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









local function Init()
local _tab

for classID = 1, GetNumClasses() do
    if (classID == 10) and (GetClassicExpansionLevel() <= LE_EXPANSION_CATACLYSM) then-- We have an annoying gap between warlock and druid
        classID = 11
    end
    local className, classFile = GetClassInfo(classID)
    if className and className~='' then
        local hex= select(4, GetClassColor(classFile))

        classTabs[className]= WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile)
            ..'|c'..hex
            ..(WoWTools_DataMixin.onlyChinese and WoWTools_DataMixin.ClassName_CN[classID] or className)
            ..'|r'
    end
end

--[ID]= ClassID,
--https://wago.tools/db2/ChrSpecialization?locale=zhCN
_tab={
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

for specID, classID in pairs(_tab) do
    local className, classFile= GetClassInfo(classID)
    local hex=className and classFile and select(4, GetClassColor(classFile))
    if hex then
        for _, sex in pairs(Enum.UnitSex) do
            local name, _, icon, role= select(2, GetSpecializationInfoByID(specID, sex))
            if name and name~='' and icon then
                local colorText=
                    '|T'..icon..':0|t'
                    ..(role and _G['INLINE_'..role..'_ICON'] or '')
                    ..'|c'..hex
                    ..WoWTools_TextMixin:CN(name)
                    ..'|r'
                classTabs[name..(specID==251 and '251' or '')]= colorText--251 DEATHKNIGHT 冰霜
            end
        end
    end
end




--Blizzard_Menu/MenuUtil.lua
    WoWTools_DataMixin:Hook(MenuUtil, 'SetElementText', function(desc, text)
        if text then
            local colorText
            if type(desc.data)=='table' and (desc.data.specID==251 or desc.data.specID==64) then
                colorText= classTabs[text..desc.data.specID]
            else
                colorText= classTabs[text]
            end
            if colorText then
                desc:AddInitializer(function(btn)
                    btn.fontString:SetText(colorText)
                end)
            end
        end
    end)



    _tab=nil
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then

        if WoWTools_OtherMixin:AddOption(
            'ClassMenuColor',
            '|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '职业菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, HUD_EDIT_MODE_MICRO_MENU_LABEL)),
            WoWTools_DataMixin.onlyChinese and '添加 颜色 图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, COLOR..', '..EMBLEM_SYMBOL)
        ) then
            Init()
        end

        Init=function()end
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)