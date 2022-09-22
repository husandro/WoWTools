local id, e = ...
local addName=WARDROBE..ITEMS
local Save = {}
local wowSave={}
local panel=CreateFrame("Frame")
local Frame

local slots = {
    "|A:transmog-nav-slot-head:0:0|a",
    "|A:transmog-nav-slot-shoulder:0:0|a",
    "|A:transmog-nav-slot-back:0:0|a",
    "|A:transmog-nav-slot-chest:0:0|a",
    "|A:transmog-nav-slot-shirt:0:0|a",
    "|A:transmog-nav-slot-tabard:0:0|a",
    "|A:transmog-nav-slot-wrist:0:0|a",
    "|A:transmog-nav-slot-hands:0:0|a",
    "|A:transmog-nav-slot-waist:0:0|a",
    "|A:transmog-nav-slot-legs:0:0|a",
    "|A:transmog-nav-slot-feet:0:0|a",
    "|T135139:0|t",--魔杖
    '|T132392:0|t',--13单手斧
    '|A:transmog-nav-slot-mainhand:0:0|a',--14单手剑
    '|T133476:0|t',--15单手锤
    '|T132324:0|t',--16匕首
    '|T132965:0|t',--17拳套
    '|A:transmog-nav-slot-secondaryhand:0:0|a',--18副手
    '|T652302:0|t',--19副手物品    
    '|T132400:0|t',--20双手斧
    '|T135327:0|t',--21双手剑
    '|T133044:0|t',--22双手锤
    '|T135145:0|t',--23法杖
    '|T135129:0|t',--24长柄武器
    '|T135490:0|t',--25弓
    '|T135610:0|t',--26枪械
    '|T135530:0|t',--27弩
    nil,
    '|A:ElementalStorm-Lesser-Earth:0:0|a',--29'军团再临"神器
}

local function Set()
    local List={}--保存数据
    for i=1, 29 do
        local all=C_TransmogCollection.GetCategoryTotal(i)
        local name= C_TransmogCollection.GetCategoryInfo(i)
        if name and all>0 then
            table.insert(List, {
                Name=name,
                Icon=slots[i] or e.Icon.icon,
                Collected=C_TransmogCollection.GetCategoryCollectedCount(i),
                All=all,
            })
        end
    end
    local visualsList=C_TransmogCollection.GetIllusions() or {}
    local totale = #visualsList;
    if totale>0 then
        local collected = 0;
        for i, illusion in ipairs(visualsList) do
            if ( illusion.isCollected ) then
                collected = collected + 1;
            end
        end
        table.insert(List, {
            Name=WEAPON_ENCHANTMENT,
            Icon='|A:transmog-nav-slot-enchant:0:0|a',
            Collected=collected,
            All=totale,
        })
    end
    wowSave[e.Player.class]=List

    if not Frame then
        return
    elseif Save.disableditems then--禁用
        for class, type in pairs (wowSave) do
            local str=Frame[addName..class]
            if str then
                str:SetText('')
                str.tip=nil
            end
        end
        local str=Frame[addName..'All']--总数字符
        if str then
            str:SetText('')
        end
        return
    end

    --设置内容
    local last, initStr
    local totaleCollected, totaleAll, totaleClass = 0, 0, 0--总数
    for class, type in pairs (wowSave) do
        local tip={}--提示用
        local collected, all = 0, 0
        for _, info in pairs(type) do
            collected = collected + info.Collected
            all = all + info.All
            table.insert(tip,{
                name=info.Icon..(info.Collected==info.All and '|cnGREEN_FONT_COLOR:'..info.Name..'|r' or info.Name),
                num= info.Collected==info.All and '|cnGREEN_FONT_COLOR:'..info.Collected..'/'.. info.All..'|r' or info.Collected..'/'.. info.All                
            })
        end
        local str=Frame[addName..class]
        if not str then
            str=e.Cstr(Frame)
            if not last then
                initStr=str--总数字符用
                str:SetPoint('BOTTOMRIGHT', 5, 80)
            else
                str:SetPoint('BOTTOMRIGHT', last, 'TOPRIGHT', 0, 2)
            end
            str:SetJustifyH('RIGHT')
            str:EnableMouse(true)
            str:SetScript('OnEnter', function(self2)--鼠标提示
                if self2.tip then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    local n=1
                    for _, info in pairs(self2.tip) do
                        if info.name then
                            if select(2, math.modf(n/2))==0 then
                                e.tips:AddDoubleLine(info.name, info.num, 1,0.5,0, 1, 0.5,0)                            
                            else
                                e.tips:AddDoubleLine(info.name, info.num)
                            end
                        else
                            e.tips:AddLine(' ')
                        end
                        n=n+1
                    end
                    e.tips:Show()
                end
            end)
            str:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        totaleCollected=totaleCollected+collected
        totaleAll=totaleAll+ all
        totaleClass=totaleClass+1

        local per=(' %i%%'):format(collected/all*100)
        collected, all = e.MK(collected,3), e.MK(all,3)

        local col='|c'..select(4,GetClassColor(class))
        str:SetText(col..collected..' '..per..'|A:classicon-'..class..':0:0|a|r')
        table.insert(tip,1,{})
        table.insert(tip,1,{
            name='|A:classicon-'..class..':0:0|a '..col..per..'|r',
            num=col..collected..'/'..all..'|r',
        })
        str.tip=tip

        Frame[addName..class]=str
        last=str
    end

    local str= Frame[addName..'All']--总数字符
    if not str and initStr then
        str=e.Cstr(Frame)
        str:SetPoint('TOPRIGHT', initStr, 'BOTTOMRIGHT', 0, -10)
        str:SetJustifyH('RIGHT')
        Frame[addName..'All']=str
    end
    if str and totaleAll>0 then
        str:SetText(totaleClass..CLASS..'  '..('%i%%'):format(totaleCollected/totaleAll*100)..'  '..e.MK(totaleCollected, 3)..'/'..e.MK(totaleAll,3)..e.Icon.wow2)
    end
end

local function Init()
    Frame=WardrobeCollectionFrame.ItemsCollectionFrame
    Frame.sel=e.Cbtn(Frame, nil, not Save.disableditems)
    Frame.sel:SetPoint('BOTTOMRIGHT',-19, 30)
    Frame.sel:SetSize(18,18)
    Frame.sel:SetAlpha(0.5)
    Frame.sel:SetScript('OnClick',function (self2)
        if Save.disableditems then
            Save.disableditems=nil
        else
            Save.disableditems=true
        end
        print(id, addName,e.GetEnabeleDisable(not Save.disableditems))
        self2:SetNormalAtlas(Save.disableditems and e.Icon.disabled or e.Icon.icon)
        Set()
    end)
    Frame.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disableditems), e.Icon.left)
        e.tips:Show()
    end)
    Frame.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)

    panel:RegisterEvent("TRANSMOGRIFY_ITEM_UPDATE");
    Set()
end

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
        wowSave=WoWToolsSave and WoWToolsSave['WoW-CollectionWardrobeItems'] or wowSave

    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save
        WoWToolsSave['WoW-CollectionWardrobeItems']=wowSave

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        Init()

    elseif event=='TRANSMOGRIFY_ITEM_UPDATE' then
        C_Timer.After(2, Set)
    end
end)
