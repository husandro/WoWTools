function DressUpFrameTransmogSetMixin:RefreshItems()
	self.ScrollBox:ForEachFrame(function(element, elementData)
		element:Refresh()
	end)
end
