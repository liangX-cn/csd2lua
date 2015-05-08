-- you can move these to a LuaHelper.lua and do it like
--[=[
local _SCRIPT_HELPER = 
[[
	local _L = require("LuaHelper.lua")
]]
--]=]

local _SCRIPT_HELPER = 
[[
-------------------------------------------------------------------------------	
local _L = {}

function _L.setValue(obj, name, tag, size, position, ancpoint, color, opacity, zOrder)
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
	if nil ~= size then 
		if type(obj.setContentSize) == "function" then
			obj:setContentSize(size)
		elseif type(obj.setSize) == "function" then	
			obj:setSize(size)
		end	
	end
	return _L
end

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

function _L.setBgColor(obj, bgType, bgOpacity, bgColor, startColor, endColor)
	if nil ~= bgType then obj:setBackGroundColorType(bgType) end
	if nil ~= bgOpacity then obj:setBackGroundColorOpacity(bgOpacity) end
	if nil ~= startColor and nil ~= endColor then obj:setBackGroundColor(startColor, endColor) end
	if nil ~= bgColor then obj:setBackGroundColor(bgColor) end
	return _L
end

function _L.setClickEvent(obj, cb, evt)
	if nil ~= cb then obj:addClickEventListener(cb("", obj, evt)) end
	return _L
end

function _L.setTouchEvent(obj, cb, evt)
	if nil ~= cb then obj:addTouchEventListener(cb("", obj, evt)) end
	return _L
end

function _L.bind(obj)
	_L.lay = ccui.LayoutComponent:bindLayoutComponent(obj)
	return _L
end

function _L.setMargin(left, top, right, bottom)
	if nil ~= left then _L.lay:setLeftMargin(left) end
	if nil ~= top then _L.lay:setTopMargin(top) end
	if nil ~= right then _L.lay:setRightMargin(right) end
	if nil ~= bottom then _L.lay:setBottomMargin(bottom) end
	return _L
end

function _L.setSize(width, height, wEnabled, hEnabled)
	if nil ~= width then _L.lay:setPercentWidth(width) end
	if nil ~= height then _L.lay:setPercentHeight(height) end
	if nil ~= wEnabled then _L.lay:setPercentWidthEnabled(wEnabled) end
	if nil ~= hEnabled then _L.lay:setPercentHeightEnabled(hEnabled) end
	return _L
end

function _L.setPosition(x, y, xEnabled, yEnabled)
	if nil ~= x then _L.lay:setPositionPercentX(x) end
	if nil ~= y then _L.lay:setPositionPercentY(y) end
	if nil ~= xEnabled then _L.lay:setPositionPercentXEnabled(xEnabled) end
	if nil ~= yEnabled then _L.lay:setPositionPercentYEnabled(yEnabled) end
	return _L
end

function _L.setStretch(wEnabled, hEnabled)
	if nil ~= wEnabled then _L.lay:setStretchWidthEnable(wEnabled) end
	if nil ~= hEnabled then _L.lay:setStretchHeightEnable(hEnabled) end
	return _L
end

function _L.setEdge(hEdge, vEdge)
	if nil ~= hEdge then _L.lay:setHorizontalEdge(hEdge) end
	if nil ~= vEdge then _L.lay:setVerticalEdge(vEdge) end
	return _L
end
-------------------------------------------------------------------------------	
]]

local _SCRIPT_HEAD =
[[

local _M = {}

]]

local _CREATE_FUNC_HEAD =
[[
function _M.create(callBackProvider)
	local cc, ccui = cc, ccui
	
	local obj, lay

	local roots = {}

]]

local _CREATE_FUNC_FOOT =
[[
	return roots
end

]]

local _SCRIPT_FOOT =
[[

return _M

]]

--/////////////////////////////////////////////////////////////////////////////

local _M = class("csd2lua")

--/////////////////////////////////////////////////////////////////////////////
local function nextSiblingIter(node)
	local i, c, a = 1, node:numChildren(), node:children()
	return function()
		if i <= c then
			local n = a[i]
			i = i + 1
			return n
		end
		return nil
	end
end

local function isPointEqual(pt, values)
	return pt.x == values[1] and pt.y == values[2]
end

local function isSizeEqual(siz, values)
	return siz.width == values[1] and siz.height == values[2]
end

local function isColorEqual(clr, values)
	if clr.r ~= values[1] or clr.g ~= values[2] or clr.b ~= values[3] or (clr.a and clr.a ~= values[4]) then
		return false
	end
	return true	
end

local function formatColor(value)
	if value and value[4] then
		return string.format("cc.c4b(%s, %s, %s, %s)", tostring(value[1]), tostring(value[2]), tostring(value[3]), tostring(value[4]))
	elseif value then
		return string.format("cc.c3b(%s, %s, %s)", tostring(value[1]), tostring(value[2]), tostring(value[3]))
	else
		return "nil"	
	end	
end

local function formatSize(value)
	if value then
		return string.format("cc.size(%s, %s)", tostring(value[1] or 0), tostring(value[2] or 0)) 
	else
		return "nil"
	end		
end    	

local function formatPoint(value)
    if value then
		return string.format("cc.p(%s, %s)", tostring(value[1] or 0), tostring(value[2] or 0)) 
	else
		return "nil"
	end	
end

local function formatString(value)
	if string.find(value, "[", 1, true) or string.find(value, "]", 1, true) then
		local i, s, f, e = 1	
		while true do
			s = string.rep("=", i)
			f = "[" .. s .. "["
			e = "]" .. s .. "]"
		
			if not string.find(value, f, 1, true) and not string.find(value, e, 1, true) then
				return f .. value .. e
			end
		
			i = i + 1
		end
	end		
	return "[[" .. value .. "]]"
end

local function resourceType(t)
	if t == "Normal" or t == "Default" or t == "MarkedSubImage" then
		return 0
	else -- PlistSubImage
		return 1
	end
end
--/////////////////////////////////////////////////////////////////////////////


--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Node(obj, name, value)
	local opts = self.opts
	local lays = self.lays
	
	if name == "Name" then
		opts[name] = value
	elseif name == "Tag" or name == "RotationSkewX" or name == "RotationSkewY" then
		opts[name] = tonumber(value) or 0
	elseif name == "Rotation" then
	elseif name == "FlipX" or name == "FlipY" then
		opts["Flipped" .. string.sub(name, 5)] = (value == "True")
	elseif name == "ZOrder" then
		opts["LocalZOrder"] = tonumber(value) or 0
	elseif name == "Visible" then
	elseif name == "VisibleForFrame" then
		opts["Visible"] = (value == "True")
	elseif name == "Alpha" then
		opts["Opacity"] = tonumber(value) or 255
	elseif name == "TouchEnable" then
		opts[name .. "d"] = (value == "True")
	elseif name == "UserData" then
	elseif name == "FrameEvent" then
	elseif name == "CallBackType" or name == "CallBackName" then
		opts["Callback" .. string.sub(name, 9)] = value
	elseif name == "PositionPercentXEnabled" or name == "PositionPercentYEnabled" or 
		name == "PercentWidthEnabled" or name == "PercentHeightEnabled" or 
		name == "StretchWidthEnable" or name == "StretchHeightEnable" then
		lays[name] = (value == "True")
	-- fix bad name likes PercentHeightEnable
	elseif name == "PositionPercentXEnable" or name == "PositionPercentYEnable" or
		name == "PercentWidthEnable" or name == "PercentHeightEnable" then
		lays[name .. "d"] = (value == "True")
	elseif name == "HorizontalEdge" or name == "VerticalEdge" then
		if value == "LeftEdge" or value == "BottomEdge" then
			lays[name] = 1
		elseif value == "RightEdge" or value == "TopEdge" then
			lays[name] = 2
		elseif value == "BothEdge" then
			lays[name] = 3
		end	
	elseif name == "LeftMargin" or  name == "RightMargin" or 
		name == "TopMargin" or name == "BottomMargin" then
		lays[name] = tonumber(value) or 0
	elseif name == "Scale9Enable" then
		opts["Scale9Enabled"] = (value == "True")
	elseif name == "Scale9OriginX" or name == "Scale9OriginY" or
		name == "Scale9Width" or name == "Scale9Height" then
		opts[name] = tonumber(value) or 0
	elseif name == "FontSize" then
		opts[name] = tonumber(value) or 22
	elseif name == "FontName" then
		opts[name] = value
	elseif name == "DisplayState" or name == "IsCustomSize" or name == "OutlineEnabled" or name == "ShadowEnabled" then
		opts[name] = (value == "True")
	elseif name == "OutlineSize" and name == "ShadowOffsetX" and name == "ShadowOffsetY" and name == "ShadowBlurRadius" then
		opts[name] = tonumber(value) or 0
	else
		return false
	end
	
--	print("onProperty_Node(" .. name .. ", " .. tostring(value) .. ")")
	return true
end

function _M:onChildren_Node(obj, name, c)
	local opts = self.opts
	local lays = self.lays
	
	if name == "Position" then
		opts[name] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
	elseif name == "Scale" then
		opts[name] = { tonumber(c["@ScaleX"]) or 1, tonumber(c["@ScaleY"]) or 1 }
	elseif name == "AnchorPoint" then
		opts[name] = { tonumber(c["@ScaleX"]) or 0, tonumber(c["@ScaleY"]) or 0 }
	elseif name == "CColor" then
		opts["Color"] = { tonumber(c["@R"]) or 0, tonumber(c["@G"]) or 0, 
			tonumber(c["@B"]) or 0, tonumber(c["@A"])}
	elseif name == "Size" then
		opts[name] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
	elseif name == "PrePosition" then
		lays["PositionPercentX"] = tonumber(c["@X"]) or 0
		lays["PositionPercentY"] = tonumber(c["@Y"]) or 0
	elseif name == "PreSize" then
		lays["PercentWidth"] = tonumber(c["@X"]) or 0
		lays["PercentHeight"] = tonumber(c["@Y"]) or 0
	elseif name == "FileData" then
		local p = c["@Plist"] or ""
		if #p > 0 then self:writPlist(p) end
		opts[name] = { c["@Path"] or "", resourceType(c["@Type"]), p }
	elseif name == "OutlineColor" or name == "ShadowColor" then
		opts[name] = { tonumber(c["@R"]) or 0, tonumber(c["@G"]) or 0, 
			tonumber(c["@B"]) or 0, tonumber(c["@A"]) or 0 }
	elseif name == "FontResource" then
	else
		return false
	end
	
	return true	
end

function _M:handleOpts_Node(obj)
	local opts = self.opts
	
	local tblVal, tblTmp, str = {}, {}, ""
	
	if opts.CallbackType and opts.CallbackName and 
		(opts.CallbackType == "Click" or opts.CallbackType == "Touch") then
		table.insert(tblVal, string.format("	_L.set%sEvent(obj, callBackProvider, \"%s\")\n",
			opts.CallbackType, opts.CallbackName))
	end
	opts.CallbackType = nil
	opts.CallbackName = nil
		
	for name, value in pairs(opts) do
		str = ""
		if name == "Name" then
			local pos = string.find(value, "@class_")
			if pos then
				value = string.sub(value, 1, pos - 1)
			end	
			tblTmp[name] = value				
		elseif name == "Tag" or name == "LocalZOrder" or name == "Opacity"  then
			if obj["get" .. name](obj) ~= value then
				tblTmp[name] = value
			end
		elseif name == "RotationSkewX" or name == "RotationSkewY" or 
			name == "FlippedX" or name == "FlippedY" or name == "Visible" or name == "TouchEnabled" then
			if (type(obj["get" .. name]) == "function" and obj["get" .. name](obj) ~= value) or
			 	(type(obj["is" .. name]) == "function" and obj["is" .. name](obj) ~= value) then
				str = string.format("obj:set%s(%s)\n", name, tostring(value))
			end
		elseif name == "Position" or name == "Scale" then
			if obj["get" .. name .. "X"](obj) ~= value[1] or 
				obj["get" .. name .. "Y"](obj) ~= value[2] then
				if name == "Scale" then
					str = string.format("obj:set%s(%s, %s)\n", name, tostring(value[1]), tostring(value[2]))
				else
					tblTmp[name] = value
				end	
			end
		elseif name == "AnchorPoint" then
			if not isPointEqual(obj["get" .. name](obj), value) then
				tblTmp[name] = value
			end
		elseif name == "Size" then
			-- getSize is deprecated, use getContentSize
			if type(obj["getContentSize"]) == "function" and not isSizeEqual(obj["getContentSize"](obj), value) then
				tblTmp[name] = value
			end
		elseif name == "Color" then               
			if not isColorEqual(obj:getColor(), value) then
				tblTmp[name] = value
			end
		end
		
		if #str > 0 then
			table.insert(tblVal, 	"	" .. str)
		end
	end
	    	
	self:write(string.format("	_L.setValue(obj, \"%s\", %s, %s, %s, %s, %s, %s, %s)\n",
		tostring(tblTmp.Name), tostring(tblTmp.Tag), formatSize(tblTmp.Size), formatPoint(tblTmp.Position), formatPoint(tblTmp.AnchorPoint),
		formatColor(tblTmp.Color), tostring(tblTmp.Opacity), tostring(tblTmp.LocalZOrder)))

    if #tblVal > 0 then
	    self:write(table.concat(tblVal))
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_ImageView(obj, name, value)
	-- nothing to do
	return self:onProperty_Node(obj, name, value)
end

function _M:onChildren_ImageView(obj, name, c)
	-- nothing to do
	return self:onChildren_Node(obj, name, c)
end

function _M:handleOpts_ImageView(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts

	if opts.FileData then
		self:write(string.format("	obj:loadTexture(\"%s\", %s)\n", tostring(opts.FileData[1]), tostring(opts.FileData[2])))
	end	

	if opts.Scale9Enabled then
		local capInsets = string.format("cc.rect(%s, %s, %s, %s)", 
			tostring(opts.Scale9OriginX or 0), tostring(opts.Scale9OriginY or 0), 
			tostring(opts.Scale9Width or 0), tostring(opts.Scale9Height or 0))

		self:write("	obj:ignoreContentAdaptWithSize(false)\n")
		self:write("	obj:setScale9Enabled(true)\n")
		self:write("	obj:setCapInsets(" .. capInsets .. ")\n")
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Button(obj, name, value)
	local opts = self.opts
	
	if name == "ButtonText" then
		opts[name] = value
	else
		return self:onProperty_Node(obj, name, value)
	end

--	print("onProperty_Button(" .. name .. ", " .. tostring(value) .. ")")		
	return true
end

function _M:onChildren_Button(obj, name, c)
	local opts = self.opts

	if name == "TextColor" then
		opts[name] = { tonumber(c["@R"]) or 0, tonumber(c["@G"]) or 0, 
			tonumber(c["@B"]) or 0 }
	elseif name == "NormalFileData" or name == "PressedFileData" or name == "DisabledFileData" then		
		local p = c["@Plist"] or ""
		if #p > 0 then self:writPlist(p) end
		opts[name] = { c["@Path"] or "", resourceType(c["@Type"]), p }
	else	
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Button(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Button(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts

	if opts.NormalFileData then
		self:write(string.format("	obj:loadTextureNormal(\"%s\", %s)\n", tostring(opts.NormalFileData[1]), tostring(opts.NormalFileData[2])))
	end	

	if opts.PressedFileData then
		self:write(string.format("	obj:loadTexturePressed(\"%s\", %s)\n", tostring(opts.PressedFileData[1]), tostring(opts.PressedFileData[2])))
	end	

	if opts.DisabledFileData then
		self:write(string.format("	obj:loadTextureDisabled(\"%s\", %s)\n", tostring(opts.DisabledFileData[1]), tostring(opts.DisabledFileData[2])))
	end	
	
	if opts.FontResource then
	end
	
	if nil ~= opts.DisplayState then
		self:write("	obj:setBright(" .. tostring(opts.DisplayState) .. ")\n")
		self:write("	obj:setEnabled(" .. tostring(opts.DisplayState) .. ")\n")
	end	
	
	if opts.OutlineEnabled and opts.OutlineColor and opts.OutlineSize  then
		self:write(string.format("	obj:enableOutline(%s, %s)\n", formatColor(opts.OutlineColor), tostring(opts.OutlineSize or 0)))
	end
	
	if opts.ShadowEnabled and opts.ShadowColor and opts.ShadowOffsetX and opts.ShadowOffsetY and opts.ShadowBlurRadius then
		self:write(string.format("	obj:enableShadow(%s, cc.size(%d, %d), %s)\n", 
			formatColor(opts.ShadowColor), tonumber(opts.ShadowOffsetX) or 0, tonumber(opts.ShadowOffsetY) or 0, tostring(opts.ShadowBlurRadius)))
	end

	if opts.Scale9Enabled then
		local capInsets = string.format("cc.rect(%s, %s, %s, %s)", 
			tostring(opts.Scale9OriginX or 0), tostring(opts.Scale9OriginY or 0), 
			tostring(opts.Scale9Width or 0), tostring(opts.Scale9Height or 0))

		self:write("	obj:ignoreContentAdaptWithSize(false)\n")
		self:write("	obj:setCapInsets(" .. capInsets .. ")\n")
	end
	
	if opts.ButtonText and not obj:getTitleText() ~= opts.ButtonText then
		self:write("	obj:setTitleText([[" .. tostring(opts.ButtonText) .. "]])\n")
	end
	
	if opts.TextColor and not isColorEqual(obj:getTitleColor(), opts.TextColor) then
		self:write("	obj:setTitleColor(" .. formatColor(opts.TextColor) .. ")\n")
	end
	
	if opts.FontSize and obj:getTitleFontSize() ~= opts.FontSize then
		self:write("	obj:setTitleFontSize(" .. tostring(opts.FontSize) .. ")\n")
	end
	
	if opts.FontName and obj:getTitleFontName() ~= opts.FontName then
		self:write("	obj:setTitleFontName([[" .. tostring(opts.FontName) .. "]])\n")
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Text(obj, name, value)
	local opts = self.opts
	
	if name == "TouchScaleChangeAble" then
		opts["TouchScaleEnabled"] = (value == "True")
	elseif name == "LabelText" then
		opts[name] = value
	elseif name == "AreaWidth" or name == "AreaHeight" then
		opts[name] = tonumber(value) or 0
	elseif name == "HorizontalAlignmentType" then
		if value == "HT_Left" then
			opts[name] = 0
		elseif value == "HT_Center" then
			opts[name] = 1
		elseif value == "HT_Right" then
			opts[name] = 2
		end	
	elseif name == "VerticalAlignmentType" then
		if value == "VT_Top" then
			opts[name] = 0
		elseif value == "VT_Center" then
			opts[name] = 1
		elseif value == "VT_Bottom" then
			opts[name] = 2
		end	
	else	
		return self:onProperty_Node(obj, name, value)
	end

--	print("onProperty_Text(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_Text(obj, name, c)
	-- nothing to do
	return self:onChildren_Node(obj, name, c)
end

function _M:handleOpts_Text(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.LabelText then
		self:write(string.format("	obj:setString(%s)\n", formatString(opts.LabelText)))
	end
	
	if opts.FontSize and obj:getFontSize() ~= opts.FontSize then
		self:write(string.format("	obj:setFontSize(%s)\n", tostring(opts.FontSize)))
	end
	
	if opts.FontName and obj:getFontName() ~= opts.FontName then
		self:write(string.format("	obj:FontName(\"%s\")\n", tostring(opts.FontName)))
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_RichTextEx(obj, name, value)
	return self:onProperty_Text(obj, name, value)
end

function _M:onChildren_RichTextEx(obj, name, c)
	-- nothing to do
	return self:onChildren_Text(obj, name, c)
end

function _M:handleOpts_RichTextEx(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.FontSize and obj:getFontSizeDef() ~= opts.FontSize then
		self:write(string.format("	obj:setFontSizeDef(%s)\n", tostring(opts.FontSize)))
	end
	
	if opts.Color and not isColorEqual(obj:getTextColorDef(), opts.Color) then
		self:write(string.format("	obj:setTextColorDef(%s)\n", formatColor(opts.Color)))
	end

	if opts.LabelText then
		self:write(string.format("	obj:setString(%s)\n", formatString(opts.LabelText)))
	end
	
	print("handleOpts_RichTextEx")
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_TextField(obj, name, value)
	local opts = self.opts
	
	if name == "PlaceHolderText" or name == "LabelText" then
		opts[name] = value
	elseif name == "MaxLengthEnable" or name == "PasswordEnable" then
		opts[name .. "d"] = (value == "True")
	elseif name == "MaxLengthText" then
		opts["MaxLength"] = tonumber(value) or 0
	elseif name == "PasswordStyleText" then
		opts["PasswordStyle"] = value
	else	
		return self:onProperty_Node(obj, name, value)
	end	

--	print("onProperty_TextField(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_TextField(obj, name, c)
	-- nothing to do
	return self:onChildren_Node(obj, name, c)
end

function _M:handleOpts_TextField(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_TextAtlas(obj, name, value)
	local opts = self.opts
	
	if name == "LabelText" or name == "StartChar" then
		opts[name] = value
	elseif name == "CharWidth" or name == "CharHeight" then
		opts[name] = tonumber(value) or 0
	else	
		return self:onProperty_Node(obj, name, value)
	end	

--	print("onProperty_TextField(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_TextAtlas(obj, name, c)
	local opts = self.opts
	
	if name == "LabelAtlasFileImage_CNB" then
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_TextAtlas(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_TextAtlas(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_CheckBox(obj, name, value)
	local opts = self.opts
	
	if name == "CheckedState" or name == "DisplayState" then
		opts[name] = (value == "True")
	else
		return self:onProperty_Node(obj, name, value)
	end

--	print("onProperty_CheckBox(" .. name .. ", " .. tostring(value) .. ")")		
	return true
end

function _M:onChildren_CheckBox(obj, name, c)
	local opts = self.opts
	
	if name == "NormalBackFileData"  or name == "PressedBackFileData" or 
		name == "NodeNormalFileData" or name == "DisableBackFileData" or name == "NodeDisableFileData" then
		local p = c["@Plist"] or ""
		if #p > 0 then self:writPlist(p) end
		opts[name] = { c["@Path"] or "", resourceType(c["@Type"]), p }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_CheckBox(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_CheckBox(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Sprite(obj, name, value)
	-- nothing to do
	return self:onProperty_Node(obj, name, value)
end

function _M:onChildren_Sprite(obj, name, c)
	local opts = self.opts
	
	if name == "BlendFunc" then
		opts[name] = { tonumber(c["@Src"]) or 0, tonumber(c["@Dst"]) or 0 }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Sprite(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Sprite(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Slider(obj, name, value)
	local opts = self.opts
	
	if name == "PercentInfo" then
		opts["Percent"] = tonumber(value) or 0
	else	
		return self:onProperty_Node(obj, name, value)
	end	

--	print("onProperty_Slider(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_Slider(obj, name, c)
	local opts = self.opts
	
	if name == "BackGroundData"  or name == "ProgressBarData" or 
		name == "BallNormalData" or name == "BallPressedData" or name == "BallDisabledData" then
		local p = c["@Plist"] or ""
		if #p > 0 then self:writPlist(p) end
		opts[name] = { c["@Path"] or "", resourceType(c["@Type"]), p }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Slider(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Slider(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_LoadingBar(obj, name, value)
	local opts = self.opts
	
	if name == "ProgressInfo" then
		opts["Percent"] = tonumber(value) or 0
	elseif name == "ProgressType" then	
		if value == "Left_To_Right" then
			opts["Direction"] = 0
		else
			opts["Direction"] = 1
		end	
	else	
		return self:onProperty_Node(obj, name, value)
	end	

--	print("onProperty_Slider(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_LoadingBar(obj, name, c)
	local opts = self.opts
	
	if name == "ImageFileData" then
		local p = c["@Plist"] or ""
		if #p > 0 then self:writPlist(p) end
		opts[name] = { c["@Path"] or "", resourceType(c["@Type"]), p }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_LoadingBar(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_LoadingBar(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Layout(obj, name, value)
	local opts = self.opts
	
	if name == "ClipAble" then
		opts["ClippingEnabled"] = (value == "True")
	elseif name == "ComboBoxIndex" then
		opts["BackGroundColorType"] = tonumber(value) or 0
	elseif name == "BackColorAlpha" then
		opts["BackGroundColorOpacity"] = tonumber(value) or 255
	else
		return self:onProperty_Node(obj, name, value)
	end
	
--	print("onProperty_Layout(" .. name .. ", " .. value .. ")")		
	return true
end

function _M:onChildren_Layout(obj, name, c)
	local opts = self.opts
	
	if name == "SingleColor" or name == "FirstColor" or name == "EndColor" then
		opts[name] = { tonumber(c["@R"]) or 0, tonumber(c["@G"]) or 0, 
			tonumber(c["@B"]) or 0, tonumber(c["@A"]) }
	elseif name == "ColorVector" then
		opts[name] = { tonumber(c["@ScaleX"]) or 1, tonumber(c["@ScaleY"]) or 1 }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
	return true	
end

function _M:handleOpts_Layout(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.FileData then
		if opts.Scale9Enabled then
			local capInsets = string.format("cc.rect(%s, %s, %s, %s)", 
				tostring(opts.Scale9OriginX or 0), tostring(opts.Scale9OriginY or 0), 
				tostring(opts.Scale9Width or 0), tostring(opts.Scale9Height or 0))
			self:write(string.format("	_L:setBgImage(obj, \"%s\", %s, true, %s)\n", tostring(opts.FileData[1]), tostring(opts.FileData[2]), capInsets))
		else	
			self:write(string.format("	obj:setBackGroundImage(\"%s\", %s)\n", tostring(opts.FileData[1]), tostring(opts.FileData[2])))
		end
	end
	
	if nil ~= opts.ClippingEnabled and obj:isClippingEnabled() ~= opts.ClippingEnabled then
		self:write("	obj:setClippingEnabled(" .. tostring(opts.ClippingEnabled) .. ")\n")
	end
	
	if nil ~= opts.BackGroundColorType and opts.BackGroundColorType ~= 0 then
		local bgType, bgOpacity, bgColor, startColor, endColor
	
	--	if opts.BackGroundColorType and obj:getBackGroundColorType() ~= opts.BackGroundColorType then
			bgType = opts.BackGroundColorType
	--		self:write("	obj:setBackGroundColorType(" .. tostring(opts.BackGroundColorType) .. ")\n")
	--	end

		if opts.BackGroundColorType ~= 0 then			
			if opts.FirstColor and opts.EndColor and not isColorEqual(obj:getBackGroundStartColor(), opts.FirstColor) and 
				not isColorEqual(obj:getBackGroundEndColor(), opts.EndColor) then
				startColor = opts.FirstColor
				endColor = opts.EndColor
	--			self:write("	obj:setBackGroundColor(" .. formatColor(opts.FirstColor) .. ", " .. formatColor(opts.EndColor) .. ")\n")
			end
			if opts.SingleColor and not isColorEqual(obj:getBackGroundColor(), opts.SingleColor) then
				bgColor = opts.SingleColor
	--			self:write("	obj:setBackGroundColor(" .. formatColor(opts.SingleColor) .. ")\n")
			end
		
			if opts.BackGroundColorOpacity and obj:getBackGroundColorOpacity() ~= opts.BackGroundColorOpacity then
				bgOpacity = opts.BackGroundColorOpacity
	--			self:write("	obj:setBackGroundColorOpacity(" .. tostring(opts.BackGroundColorOpacity) .. ")\n")
			end
		end

		self:write(string.format(	"	_L.setBgColor(obj, %s, %s, %s, %s, %s)\n",
			tostring(bgType), tostring(bgOpacity), formatColor(bgColor), formatColor(startColor), formatColor(endColor)))
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_ScrollView(obj, name, value)
	local opts = self.opts

	if name == "ScrollDirectionType" then
		if value == "Vertical" then
			opts["Direction"] = 1
		elseif value == "Horizontal" then
			opts["Direction"] = 2
		elseif value == "Vertical_Horizontal" then
			opts["Direction"] = 3
		else
			opts["Direction"] = tonumber(value) or 0
		end
	elseif name == "IsBounceEnabled" then
		opts["BounceEnabled"] = (value == "True")
	else	
		return self:onProperty_Layout(obj, name, value)
	end
	
--	print("onProperty_ScrollView(" .. name .. ", " .. value .. ")")
	return true
end

function _M:onChildren_ScrollView(obj, name, c)
	local opts = self.opts
	
	if name == "InnerNodeSize" then
		opts["InnerContainerSize"] = { tonumber(c["@Width"]) or 0, tonumber(c["@Height"]) or 0 }
	else
		return self:onChildren_Layout(obj, name, c)
	end	

	return true
end
	
function _M:handleOpts_ScrollView(obj)
	self:handleOpts_Layout(obj)

	local opts = self.opts
end
	
--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_ListView(obj, name, value)
	local opts = self.opts

	if name == "ItemMargin" then
		opts["ItemsMargin"] = tonumber(value) or 0
	elseif name == "DirectionType" then
		if value == "" then
			opts["Direction"] = 2
		elseif value == "Vertical" then
			opts["Direction"] = 1
		else
			opts["Direction"] = tonumber(value) or 0
		end
	elseif name == "VerticalType"  then
		if value == "" then
			opts[name] = 3
		elseif value == "Align_Bottom" then
			opts[name] = 4
		elseif value == "Align_VerticalCenter" then
			opts[name] = 5
		else
			opts[name] = tonumber(value) or 3
		end	
	elseif name == "HorizontalType" then
		if value == "" then
			opts[name] = 0
		elseif value == "Align_Right" then
			opts[name] = 1
		elseif value == "Align_HorizontalCenter" then
			opts[name] = 2
		else
			opts[name] = tonumber(value) or 0
		end	
	else
		return self:onProperty_ScrollView(obj, name, value)
	end
	
--	print("onProperty_ListView(" .. name .. ", " .. value .. ")")	
	return true	
end

function _M:onChildren_ListView(obj, name, c)
	-- nothing to do
	return self:onChildren_ScrollView(obj, name, c)
end

function _M:handleOpts_ListView(obj)
	self:handleOpts_Layout(obj)

	local opts = self.opts
	
	if opts.Direction and type(obj.getDirection) == "function" then
		if opts.Direction ~= obj:getDirection() then
			table.insert(tblVal, string.format("	obj:setDirection(%d)\n", opts.Direction))
		end
		if opts.Direction == 2 and opts.VerticalType then
			table.insert(tblVal, string.format("	obj:setGravity(%d)\n", opts.VerticalType))
		elseif opts.Direction == 1 and opts.HorizontalType then
			table.insert(tblVal, string.format("	obj:setGravity(%d)\n", opts.HorizontalType))
		end
	end
end
	
--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_PageView(obj, name, value)
	-- nothing to do
	return self:onProperty_Layout(obj, name, value)
end

function _M:onChildren_PageView(obj, name, c)
	-- nothing to do
	return self:onChildren_Layout(obj, name, c)
end

function _M:handleOpts_PageView(obj)
	self:handleOpts_Layout(obj)

	local opts = self.opts
	
end

--/////////////////////////////////////////////////////////////////////////////
function _M:readNodeProperties(root, obj, className)
--	print("readNodeProperties(" .. className .. ")")

	local opts = self.opts
	local lays = self.lays
	
	local onProperty = self["onProperty_" .. className] or self.onProperty_Node
	
	for _, p in pairs(root:properties()) do
		local name = p.name
		local value = p.value
		
		if not onProperty(self, obj, name, value) then
			if name ~= "IconVisible" and name ~= "ctype" and name ~= "ActionTag" and name ~= "ColorAngle" and
				name ~= "LeftEage" and name ~= "TopEage" and name ~= "RightEage" and name ~= "BottomEage" then
				print("@@ Nothing to do: readNodeProperties(" .. name .. ")")
			end
		end
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:readNodeChildren(root, obj, className)
	local onChildren = self["onChildren_" .. className] or self.onChildren_Node

	for _, c in pairs(root:children()) do
		local name = c:name()
				
		if not onChildren(self, obj, name, c) then
			if name ~= "Children" then
				print("@@ Nothing to do: readNodeChildren(" .. name .. ")")
			end	
		end
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:handleNodeOpts(root, obj, className)
	local handleOpts = self["handleOpts_" .. className] or self.handleOpts_Node
	
	handleOpts(self, obj)
end

--/////////////////////////////////////////////////////////////////////////////
function _M:handleNodeLays(root, obj, className)
	local lays = self.lays
	
    local lay = obj:getComponent("__ui_layout") or ccui.LayoutComponent:create()

    for name, value in pairs(lays) do
        if ((type(lay["get" .. name]) == "function" and lay["get" .. name](lay) == value) or
            (type(lay["is" .. name]) == "function" and lay["is" .. name](lay) == value)) then
			lays[name] = nil
        end
    end
    		
	local margins, sizes, positions, stretchs, edges = "", "", "", "", ""
	if nil ~= lays.LeftMargin or nil ~= lays.TopMargin or 
		nil ~= lays.RightMargin or nil ~= lays.BottomMargin then
		margins = string.format(".setMargin(%s, %s, %s, %s)",
			tostring(lays.LeftMargin), tostring(lays.TopMargin), 
			tostring(lays.RightMargin), tostring(lays.BottomMargin))
	end	
	if (nil ~= lays.PercentWidth or nil ~= lays.PercentHeight) and  
		(nil ~= lays.PercentWidthEnabled or nil ~= lays.PercentHeightEnabled) then
		sizes = string.format(".setSize(%s, %s, %s, %s)",
			tostring(lays.PercentWidth), tostring(lays.PercentHeight), 
			tostring(lays.PercentWidthEnabled), tostring(lays.PercentHeightEnabled))
	end		
	if (nil ~= lays.PositionPercentX or nil ~= lays.PositionPercentY) and 
		(nil ~= lays.PositionPercentXEnabled or nil ~= lays.PositionPercentYEnabled) then
		positions = string.format(".setPosition(%s, %s, %s, %s)",
			tostring(lays.PositionPercentX), tostring(lays.PositionPercentY), 
			tostring(lays.PositionPercentXEnabled), tostring(lays.PositionPercentYEnabled))
	end		
	if nil ~= lays.StretchWidthEnable or nil ~= lays.StretchHeightEnable then
		stretchs = string.format(".setStretch(%s, %s)",
			tostring(lays.StretchWidthEnable), tostring(lays.StretchHeightEnable))
	end		
	if nil ~= lays.HorizontalEdge or nil ~= lays.VerticalEdge then
		edges = string.format(".setEdge(%s, %s)",
			tostring(lays.HorizontalEdge), tostring(lays.VerticalEdge))
	end		
	
	if #margins > 0 or #sizes > 0 or #positions > 0 or #stretchs > 0 or #edges > 0 then
		self:write(string.format("	_L.bind(obj)%s%s%s%s%s\n", margins, sizes, positions, stretchs, edges))
	end	
end

--/////////////////////////////////////////////////////////////////////////////
function _M:parseNodeXml(root, obj, className)
--	print("parseNodeXml(className=" .. className .. ")")

	self.opts = {}
	self.lays = {}
	
	self:readNodeProperties(root, obj, className)
	self:readNodeChildren(root, obj, className)

	self:handleNodeOpts(root, obj, className)
	self:handleNodeLays(root, obj, className)

	return self.opts.Name or ""
end

--/////////////////////////////////////////////////////////////////////////////
local function objScriptOf(className)
	local obj, script = nil, nil
    if className == "ProjectNode" then
		obj = ccui.Node:create()
		script = 
[[
	obj = cc.Node:create()
]]
    elseif className == "SimpleAudio" then
--        reader = ComAudioReader::getInstance();
    elseif className == "Panel" or className == "Layout" then
    	className = "Layout"
		obj = ccui.Layout:create()
		script = 
[[
	obj = ccui.Layout:create()
]]
    elseif className == "TextButton" or className == "Button" then
    	className = "Button"
		obj = ccui.Button:create()
		script = 
[[
	obj = ccui.Button:create()
]]
    elseif className == "TextArea" or className == "Text" or className == "Label" then
    	className = "Text"
		obj = ccui.Text:create()
		script = 
[[
	obj = ccui.Text:create()
]]
    elseif className == "RichTextEx" then
    	className = "RichTextEx"
		obj = require("ccext.RichTextEx"):create()
		script = 
[[
	obj = require("ccext.RichTextEx"):create()
]]
    elseif className == "TextField" then
    	className = "TextField"
		obj = ccui.TextField:create()
		script = 
[[
	obj = ccui.TextField:create()
]]
    elseif className == "LabelAtlas" or className == "TextAtlas" then
    	className = "TextAtlas"
		obj = ccui.TextAtlas:create()
		script = 
[[
	obj = ccui.TextAtlas:create()
]]
    elseif className == "LabelBMFont" or className == "TextBMFont" then
    	className = "TextBMFont"
--        reader = TextBMFontReader::getInstance();
    elseif className == "Slider" then
		obj = ccui.Slider:create()
		script = 
[[
	obj = ccui.Slider:create()
]]
    elseif className == "LoadingBar" then
		obj = ccui.LoadingBar:create()
		script = 
[[
	obj = ccui.LoadingBar:create()
]]
    elseif className == "Sprite" then
		obj = cc.LoadingBar:create()
		script = 
[[
	obj = cc.Sprite:create()
]]
    elseif className == "CheckBox" then
		obj = ccui.CheckBox:create()
		script = 
[[
	obj = ccui.CheckBox:create()
]]
    elseif className == "ImageView" then
		obj = ccui.ImageView:create()
		script = 
[[
	obj = ccui.ImageView:create()
]]
    elseif className == "ScrollView" then
		obj = ccui.ScrollView:create()
		script = 
[[
	obj = ccui.ScrollView:create()
]]
    elseif className == "ListView" then
		obj = ccui.ListView:create()
		script = 
[[
	obj = ccui.ListView:create()
]]
    elseif className == "PageView" then
		obj = ccui.PageView:create()
		script = 
[[
	obj = ccui.PageView:create()
]]
    elseif className == "Node" then
		obj = cc.Node:create()
		script = 
[[
	obj = cc.Node:create()
]]
    end
    
    return obj, script, className
end

--/////////////////////////////////////////////////////////////////////////////
local _createNodeTree, _i = nil, 0
_createNodeTree = function(self, root, classType, rootName)
	local className = string.sub(classType, 1, string.find(classType, "ObjectData") - 1)
--	print("_createNodeTree(classType=" .. classType .. ", className=" .. className .. ")")

	local obj, script, className = objScriptOf(className)
	if not obj or not script then return end

	self:write(script)
	
	if rootName then
		self:write("	" .. rootName .. ":addChild(obj)\n")
	else
		self:write("	roots.root = obj\n")
	end
	
	rootName = self:parseNodeXml(root, obj, className)
	rootName = "roots." .. rootName .. "_" .. tostring(_i)

	_i = _i + 1
	if root.Children then
		local nextSiblingNode = nextSiblingIter(root.Children)
		local node, name = nextSiblingNode()

		self:write("	" .. rootName .. " = obj\n\n")
		while node do
			className = node["@ctype"] or "NodeObjectData"

			name = node["@Name"]
			if name then
				local pos = string.find(name, "@class_")
				if pos then
					className = string.sub(name,  pos + 7) .. "ObjectData"
					node["@Name"] = string.sub(name, 1, pos - 1)
				end					
			end
			
			_createNodeTree(self, node, className, rootName)
			node = nextSiblingNode()
		end
	else
		self:write("\n")
	end
	_i = _i - 1
end

--/////////////////////////////////////////////////////////////////////////////
function _M:createNodeTree(root, classType)
	return _createNodeTree(self, root, classType)
end

--/////////////////////////////////////////////////////////////////////////////
function _M:write(s)
	self._file:write(s)
end

--/////////////////////////////////////////////////////////////////////////////
function _M:writef(fmt, ...)
	self:write(string.format(fmt, ...))
end

--/////////////////////////////////////////////////////////////////////////////
function _M:writPlist(plist)
	if not self._plists then
		self._plists = {}
	end
	for _, value in pairs(self._plists) do
		if value == plist then return end
	end	
	table.insert(self._plists, plist)
	self:write("	cc.SpriteFrameCache:getInstance():addSpriteFrames(\"" .. plist .. "\")\n")
end

--/////////////////////////////////////////////////////////////////////////////
function _M:csd2lua(csdFile, luaFile)
	local xml = require("ccext.XmlParser").newParser():loadFile(csdFile)
	
	if not xml or xml:numChildren() ~= 1 then 
		error("XmlParser:loadFile(" .. csdFile ..") bad XML.")
		return 
	end
		
	local serializeEnabled = false
	local csdVersion, nodeName
	
	local root = xml:children()[1]
	local nextSiblingNode = nextSiblingIter(root)
	local node = nextSiblingNode()
	while node do
		nodeName = node:name()
		
		if nodeName == "PropertyGroup" then
			csdVersion = node["@Version"] or "2.1.0.0"
		elseif nodeName == "Content" and node:numProperties() == 0 then
			serializeEnabled = true
			break
		end
		
		if node:numChildren() > 0 then
			nextSiblingNode = nextSiblingIter(node)
			node = nextSiblingNode()
		else
			node = nextSiblingNode()
		end		
	end	
	
	if not serializeEnabled then
		error("serializeEnabled == false")
		return
	end
	
	local file, err = io.open(luaFile, "w+");

	if file and not err then
		self._file = file
	else
		print(err)
		return
	end

	self:write(_SCRIPT_HELPER)
	self:write(_SCRIPT_HEAD)
	self:write(_CREATE_FUNC_HEAD)

	nextSiblingNode = nextSiblingIter(node)
	node = nextSiblingNode()
	while node do
		nodeName = node:name()

		if nodeName == "Animation" then
			-- TODO.
		elseif nodeName == "ObjectData" then
			self:createNodeTree(node, "NodeObjectData")
		elseif nodeName == "AnimationList" then
			-- TODO.
		end
		
		node = nextSiblingNode()
	end

	self:write(_CREATE_FUNC_FOOT)
	
	self:write("_M.textures = {\n")
	for _, k in pairs(self._plists) do
		self:write("	\""  .. k ..  "\",\n")
	end
	self:write("}\n")
	
	self:write(_SCRIPT_FOOT)

	io.close(file)
end

--/////////////////////////////////////////////////////////////////////////////

return _M

