local id, e = ...

e.Panel = CreateFrame("Frame")--Panel
e.Panel.name = id
InterfaceOptions_AddCategory(e.Panel)

local str=e.Cstr(e.Panel)
str:SetPoint('TOPLEFT')
str:SetText('/reload')