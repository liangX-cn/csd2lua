--/////////////////////////////////////////////////////////////////////////////
-- LuaResHelper for csd2lua 
-- https://github.com/liangX-cn/csd2lua
--
--/////////////////////////////////////////////////////////////////////////////

local _L = {}

--/////////////////////////////////////////////////////////////////////////////

--/////////////////////////////////////////////////////////////////////////////
function _L.setValue(obj, name, tag, size, position, ancpoint, color, opacity, zOrder, ignoreSize)
	if type(obj.setCascadeColorEnabled) == "function" then obj:setCascadeColorEnabled(true) end
	if type(obj.setCascadeOpacityEnabled) == "function" then obj:setCascadeOpacityEnabled(true) end
	if type(obj.setLayoutComponentEnabled) == "function" then obj:setLayoutComponentEnabled(true) end
	if nil ~= name then obj:setName(name) end
	if nil ~= tag then obj:setTag(tag) end
	if nil ~= color then obj:setColor(color) end
	if nil ~= opacity then obj:setOpacity(opacity) end
	if nil ~= zOrder then obj:setLocalZOrder(zOrder) end
	if nil ~= position then obj:setPosition(position) end
	if nil ~= ancpoint then obj:setAnchorPoint(ancpoint) end
	if nil ~= ignoreSize and type(obj.ignoreContentAdaptWithSize) == "function" then 
		obj:ignoreContentAdaptWithSize(ignoreSize) 
	end
	if nil ~= size then 
		if type(obj.setContentSize) == "function" then
			obj:setContentSize(size)
		elseif type(obj.setSize) == "function" then	
			obj:setSize(size)
		end
	end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setBgImage(obj, imgName, imgType, scale9En, capInsets)
	if nil ~= bgType then obj:setBackGroundImage(imgName, imgType or 0) end
	if nil ~= scale9En and type(obj.setBackGroundImageScale9Enabled) == "function" then 
		obj:setBackGroundImageScale9Enabled(scale9En) 
	end
	if nil ~= capInsets and type(obj.setBackGroundImageCapInsets) == "function" 
		then obj:setBackGroundImageCapInsets(capInsets) 
	end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setBgColor(obj, bgType, bgOpacity, bgColor, startColor, endColor, colorVec)
	if nil ~= bgType then obj:setBackGroundColorType(bgType) end
	if nil ~= bgOpacity then obj:setBackGroundColorOpacity(bgOpacity) end
	if nil ~= startColor and nil ~= endColor then obj:setBackGroundColor(startColor, endColor) end
	if nil ~= bgColor then obj:setBackGroundColor(bgColor) end
	if nil ~= colorVec then obj:setBackGroundColorVector(colorVec) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setClickEvent(obj, cb, evt)
	if nil ~= cb then obj:addClickEventListener(cb("", obj, evt)) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setTouchEvent(obj, cb, evt)
	if nil ~= cb then obj:addTouchEventListener(cb("", obj, evt)) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.bind(obj)
	_L.lay = ccui.LayoutComponent:bindLayoutComponent(obj)
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setMargin(left, top, right, bottom)
	if nil ~= left then _L.lay:setLeftMargin(left) end
	if nil ~= top then _L.lay:setTopMargin(top) end
	if nil ~= right then _L.lay:setRightMargin(right) end
	if nil ~= bottom then _L.lay:setBottomMargin(bottom) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setSize(width, height, wEnabled, hEnabled)
	if nil ~= width then _L.lay:setPercentWidth(width) end
	if nil ~= height then _L.lay:setPercentHeight(height) end
	if nil ~= wEnabled then _L.lay:setPercentWidthEnabled(wEnabled) end
	if nil ~= hEnabled then _L.lay:setPercentHeightEnabled(hEnabled) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setPosition(x, y, xEnabled, yEnabled)
	if nil ~= x then _L.lay:setPositionPercentX(x) end
	if nil ~= y then _L.lay:setPositionPercentY(y) end
	if nil ~= xEnabled then _L.lay:setPositionPercentXEnabled(xEnabled) end
	if nil ~= yEnabled then _L.lay:setPositionPercentYEnabled(yEnabled) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setStretch(wEnabled, hEnabled)
	if nil ~= wEnabled then _L.lay:setStretchWidthEnable(wEnabled) end
	if nil ~= hEnabled then _L.lay:setStretchHeightEnable(hEnabled) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////
function _L.setEdge(hEdge, vEdge)
	if nil ~= hEdge then _L.lay:setHorizontalEdge(hEdge) end
	if nil ~= vEdge then _L.lay:setVerticalEdge(vEdge) end
	return _L
end

--/////////////////////////////////////////////////////////////////////////////

return _L
