local id, e = ...
local addName= 'spanelSettings'
local Save={
    onlyChinese= e.Player.husandro,
    useClassColor= e.Player.husandro,--使用,职业, 颜色
    useCustomColor= nil,--使用, 自定义, 颜色
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}
local panel = CreateFrame("Frame")--Panel

panel.name = id--'|cffff00ffWoW|r|cff00ff00Tools|r'
InterfaceOptions_AddCategory(panel)

local reloadButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--重新加载UI
reloadButton:SetPoint('TOPLEFT')
reloadButton:SetSize(120, 28)
reloadButton:SetScript('OnMouseUp', e.Reload)

--##############
--Instance Panel
--##############
local instancePane= CreateFrame('Frame')
instancePane.name = '|A:poi-rift1:0:0|a'..INSTANCE
instancePane.parent =id;
InterfaceOptions_AddCategory(instancePane)

--##############
--创建, 添加控制面板
--##############
local gamePlus=e.Cstr(panel)
gamePlus:SetPoint('TOPLEFT', panel,'TOP', 0, -14)
gamePlus:SetText('Game Plus')

local lastWoW, lastGame, lastInstance
lastWoW, lastGame= reloadButton, gamePlus

e.CPanel= function(name, value, GamePlus, Instance)
    local check=CreateFrame("CheckButton", nil, Instance and instancePane or panel, "InterfaceOptionsCheckButtonTemplate")
    check.text:SetText(name)
    check:SetChecked(value)

    if Instance then--副本, 大类
        if not lastInstance then
            check:SetPoint('TOPLEFT')
            lastInstance= check
        else
            check:SetPoint('TOPLEFT', lastInstance, 'BOTTOMLEFT')
        end

    elseif GamePlus then--GamePlus, 大类
        check:SetPoint('TOPLEFT', lastGame, 'BOTTOMLEFT')
        lastGame=check

    else--WoWPlus, 大类
        check:SetPoint('TOPLEFT', lastWoW, 'BOTTOMLEFT')
        lastWoW=check
    end
    return check
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1==id then
            WoWToolsSave= WoWToolsSave or {}
            WoWDate= WoWDate or {}
            --BunniesDB= BunniesDB or {}

            Save= WoWToolsSave[addName] or Save
            Save.useCustomColorTab= Save.useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}

            e.onlyChinese= Save.onlyChinese

            

            if e.onlyChinese then
                e.L['LAYER']='位面'
                e.L['EMOJI']={'天使','生气','大笑','鼓掌','酷','哭','可爱','鄙视','美梦','尴尬','邪恶','兴奋','晕','打架','流感','呆','皱眉','致敬','鬼脸','龇牙','开心','心','恐惧','生病','无辜','功夫','花痴','邮件','化妆','沉思','可怜','好','漂亮','吐','握手','喊','闭嘴','害羞','睡觉','微笑','吃惊','失败','流汗','流泪','悲剧','想','偷笑','猥琐','胜利','雷锋','委屈','马里奥'}
            end

            local useClassColor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用,职业,颜色
            local useCustomColor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用,自定义,颜色

            local function set_Use_Color()
                if Save.useClassColor then
                    useClassColor:SetChecked(true)
                    useCustomColor:SetChecked(false)
                    Save.useCustomColor=nil
                    local r,g,b= e.Player.r, e.Player.g, e.Player.b
                    local hex= e.RGB_to_HEX(r,g,b,1)
                    e.Player.useColor= {r=r, g=g, b=b, a=1, hex=hex}

                elseif Save.useCustomColor then
                    useClassColor:SetChecked(false)
                    useCustomColor:SetChecked(true)
                    Save.useClassColor=nil
                    e.Player.useColor= Save.useCustomColorTab
                else
                    e.Player.useColor=nil
                end
            end
            set_Use_Color()

            useClassColor.text:SetText(e.Player.col..(e.onlyChinese and '职业颜色' or COLORS))
            useClassColor:SetPoint('BOTTOMLEFT')
            useClassColor:SetScript('OnClick', function()
                Save.useClassColor= not Save.useClassColor and true or nil
                if Save.useCustomColor then
                    Save.useCustomColor=nil
                end
                set_Use_Color()
                print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            useCustomColor.text:SetText('|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '自定义 ' or CUSTOM))
            useCustomColor:SetPoint('LEFT', useClassColor.text, 'RIGHT',2,0)
            useCustomColor:SetScript('OnClick', function()
                Save.useCustomColor= not Save.useCustomColor and true or nil
                if Save.useClassColor then
                    Save.useClassColor=nil
                end
                set_Use_Color()
                print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            useCustomColor.text:SetTextColor(Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a)
            useCustomColor.text:EnableMouse(true)
            useCustomColor.text:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
                local hex=self2.hex:gsub('|c','')
                e.tips:AddDoubleLine(format('r%.2f g%.2f b%.2f a%.2f', self2.r, self2.g, self2.b, self2.a), hex)
                e.tips:Show()
            end)
            useCustomColor.text:SetScript('OnLeave', function() e.tips:Hide() end)

            useCustomColor.text.r, useCustomColor.text.g, useCustomColor.text.b, useCustomColor.text.a, useCustomColor.text.hex= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a, Save.useCustomColorTab.hex
            useCustomColor.text:SetScript('OnMouseDown', function(self2)
                local valueR, valueG, valueB, valueA, class, custom= self2.r, self2.g, self2.b, self2.a, Save.useClassColor, Save.useCustomColor
                e.ShowColorPicker(self2.r, self2.g, self2.b,self2.a, function(restore)
                    local setA, setR, setG, setB, class2, custom2
                    if not restore then
                        setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                        class2, custom2= nil, true
                    else
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                        class2, custom2= class, custom
                    end
                    e.RGB_to_HEX(setR, setG, setB, setA, self2)--RGB转HEX
                    Save.useCustomColorTab= {r=setR, g=setG, b=setB, a=setA, hex=self2.hex}
                    Save.useClassColor, Save.useCustomColor= class2, custom2
                    set_Use_Color()
                end)
            end)

            local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--仅中文
            check:SetChecked(Save.onlyChinese)
            check.text:SetText('Chinese')
            check:SetPoint('LEFT', useCustomColor.text, 'RIGHT', 10,0)
            check:SetScript('OnMouseUp',function()
                e.onlyChinese= not e.onlyChinese and true or nil
                Save.onlyChinese = e.onlyChinese
                print(id, addName, e.GetEnabeleDisable(e.onlyChinese), '|cffff00ff', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            check:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(LANGUAGE..'('..SHOW..')', LFG_LIST_LANGUAGE_ZHCN)
                e.tips:AddDoubleLine('显示语言', '简体中文')
                e.tips:Show()
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)

            local restButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--全部重
            restButton:SetPoint('TOPRIGHT',3,10)
            restButton:SetSize(120, 28)
            restButton:SetScript('OnMouseUp', function()
                StaticPopupDialogs[id..'restAllSetup']={
                    text =id..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..'|r '..(e.onlyChinese and '保存' or SAVE)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..' /reload',
                    button1 = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
                    button2 = e.onlyChinese and '取消' or CANCEL,
                    whileDead=true,timeout=30,hideOnEscape = 1,
                    OnAccept=function()
                        e.ClearAllSave=true
                        e.Reload()
                    end,
                }
                StaticPopup_Show(id..'restAllSetup')
            end)
            restButton:SetText('|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|r')

            local textTips= e.Cstr(panel, {justifyH='CENTER'})--nil, nil, nil, nil, nil, 'CENTER')
            textTips:SetPoint('TOP',-70,10)
            textTips:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '启用' or ENABLE)..'|r/|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE))

            reloadButton:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)

            MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
            MainMenuMicroButton:SetScript('OnMouseWheel', function()
                InterfaceOptionsFrame_OpenToCategory(id)
            end)

            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if e.ClearAllSave then
            WoWToolsSave=nil
            WoWDate=nil
        else
            WoWToolsSave[addName]=Save
        end
    end
end)