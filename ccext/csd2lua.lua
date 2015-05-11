--[[***************************************************************************
	A tools to convert a Cocos Studio .csd file to a .lua resource file
	https://github.com/liangX-cn/csd2lua

 	Require:
		Cocos2d-x Lua Project (Tested on Cocos2d-x 3.6)
		XmlParser.lua

	Usage:
		require(THIS_LUA).new():csd2lua(csdFullPathFileName, luaFullPathFileName)

--***************************************************************************]]

local _M = class("csd2lua")

--/////////////////////////////////////////////////////////////////////////////
local _SCRIPT_HELPER = 
[[
-- exported by csd2lua tools: https://github.com/liangX-cn/csd2lua

local _L = require("ccext.LuaResHelper")	
]]

local _SCRIPT_HEAD =
[[

local _M = { CCSVER = "%s" }

]]

local _CREATE_FUNC_HEAD =
[[
function _M.create(callBackProvider)
	local cc, ccui, ccs = cc, ccui, ccs
	local ccspc = cc.SpriteFrameCache:getInstance()
	local ccsam = ccs.ArmatureDataManager:getInstance()
	
	local setValue, bind = _L.setValue, _L.bind
	local setBgColor, setBgImage = _L.setBgColor, _L.setBgImage
	local setClickEvent, setTouchEvent = _L.setClickEvent, _L.setTouchEvent
	
	local roots, obj, inc = {}

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
	elseif name == "OutlineSize" or name == "ShadowOffsetX" or name == "ShadowOffsetY" or name == "ShadowBlurRadius" then
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
		local f, t, p = c["@Path"] or "", resourceType(c["@Type"]), c["@Plist"] or ""
		if #p > 0 then 
			self:addTexture(t, p) 
		else	
			self:addTexture(t, f) 
		end
		opts[name] = { f, t, p }
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
	local lays = self.lays
	
	local tblVal, tblTmp, str = {}, {}, ""
	
	if opts.CallbackType and opts.CallbackName and 
		(opts.CallbackType == "Click" or opts.CallbackType == "Touch") then
		table.insert(tblVal, string.format("	set%sEvent(obj, callBackProvider, \"%s\")\n",
			opts.CallbackType, opts.CallbackName))
	end
		
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
	
	self:writef("	setValue(obj, \"%s\", %s, %s, %s, %s, %s, %s, %s, %s)\n",
		tostring(tblTmp.Name), tostring(tblTmp.Tag), formatSize(tblTmp.Size), formatPoint(tblTmp.Position), formatPoint(tblTmp.AnchorPoint),
		formatColor(tblTmp.Color), tostring(tblTmp.Opacity), tostring(tblTmp.LocalZOrder), tostring(opts.IgnoreContentAdaptWithSize))

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
--	local opts = self.opts
--
--	if name == "Size" and opts.Scale9Enabled then
--		opts["Scale9Size"] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
--	else
		return self:onChildren_Node(obj, name, c)
--	end
--	
--	print("onChildren_ImageView(" .. name .. ", " .. tostring(opts[name]) .. ")")
--	return true	
end

function _M:handleOpts_ImageView(obj)
	local opts = self.opts

	if opts.Scale9Enabled then
		local capInsets = string.format("cc.rect(%s, %s, %s, %s)", 
			tostring(opts.Scale9OriginX or 0), tostring(opts.Scale9OriginY or 0), 
			tostring(opts.Scale9Width or 0), tostring(opts.Scale9Height or 0))

		self:write("	obj:setScale9Enabled(true)\n")
		self:write("	obj:setCapInsets(" .. capInsets .. ")\n")
--		
--		if opts.Scale9Size then
--			self:writef("	obj:setContentSize(%s)\n", formatSize(opts.Scale9Size))
--		end
	end

	if opts.Size and obj:isIgnoreContentAdaptWithSize() then
		opts["IgnoreContentAdaptWithSize"] = false
	end	
	
	self:handleOpts_Node(obj)

	if opts.FileData then
		self:writef("	obj:loadTexture(\"%s\", %s)\n", tostring(opts.FileData[1]), tostring(opts.FileData[2]))
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
		local f, t, p = c["@Path"] or "", resourceType(c["@Type"]), c["@Plist"] or ""
		if #p > 0 then 
			self:addTexture(t, p) 
		else	
			self:addTexture(t, f) 
		end
		opts[name] = { f, t, p }
--	elseif name == "Size" and opts.Scale9Enabled then
--		opts["Scale9Size"] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
	else	
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Button(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Button(obj)
	local opts = self.opts

	if opts.Scale9Enabled then
		local capInsets = string.format("cc.rect(%s, %s, %s, %s)", 
			tostring(opts.Scale9OriginX or 0), tostring(opts.Scale9OriginY or 0), 
			tostring(opts.Scale9Width or 0), tostring(opts.Scale9Height or 0))

		self:write("	obj:setCapInsets(" .. capInsets .. ")\n")
--
--		if opts.Scale9Size then
--			self:writef("	obj:setContentSize(%s)\n", formatSize(opts.Scale9Size))
--		end	
	end

	self:handleOpts_Node(obj)

	if opts.NormalFileData then
		self:writef("	obj:loadTextureNormal(\"%s\", %s)\n", tostring(opts.NormalFileData[1]), tostring(opts.NormalFileData[2]))
	end	

	if opts.PressedFileData then
		self:writef("	obj:loadTexturePressed(\"%s\", %s)\n", tostring(opts.PressedFileData[1]), tostring(opts.PressedFileData[2]))
	end	

	if opts.DisabledFileData then
		self:writef("	obj:loadTextureDisabled(\"%s\", %s)\n", tostring(opts.DisabledFileData[1]), tostring(opts.DisabledFileData[2]))
	end	
	
	if opts.FontResource then
	end
	
	if nil ~= opts.DisplayState then
		if obj:isBright() ~= opts.DisplayState then
			self:writef("	obj:setBright(%s)\n", tostring(opts.DisplayState))
		end
		
		if obj:isEnabled() ~= opts.DisplayState then
			self:writef("	obj:setEnabled(%s)\n", tostring(opts.DisplayState))
		end
	end
	
	if opts.OutlineEnabled then
		self:writef("	obj:enableOutline(%s, %s)\n", formatColor(opts.OutlineColor or {0, 0, 0, 0}), tostring(opts.OutlineSize or 0))
	end
	
	if opts.ShadowEnabled then
		self:writef("	obj:enableShadow(%s, cc.size(%d, %d), %s)\n", 
			formatColor(opts.ShadowColor or { 0, 0, 0, 0}), tonumber(opts.ShadowOffsetX) or 0, tonumber(opts.ShadowOffsetY) or 0, tostring(opts.ShadowBlurRadius or 0))
	end
	
	if opts.ButtonText and not obj:getTitleText() ~= opts.ButtonText then
		self:write("	obj:setTitleText(" .. formatString(opts.ButtonText) .. ")\n")
	end
	
	if opts.TextColor and not isColorEqual(obj:getTitleColor(), opts.TextColor) then
		self:write("	obj:setTitleColor(" .. formatColor(opts.TextColor) .. ")\n")
	end
	
	if opts.FontSize and obj:getTitleFontSize() ~= opts.FontSize then
		self:write("	obj:setTitleFontSize(" .. tostring(opts.FontSize) .. ")\n")
	end
	
	if opts.FontName and obj:getTitleFontName() ~= opts.FontName then
		self:write("	obj:setTitleFontName(" .. formatString(opts.FontName) .. ")\n")
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
			opts["TextHorizontalAlignment"] = 0
		elseif value == "HT_Center" then
			opts["TextHorizontalAlignment"] = 1
		elseif value == "HT_Right" then
			opts["TextHorizontalAlignment"] = 2
		end	
	elseif name == "VerticalAlignmentType" then
		if value == "VT_Top" then
			opts["TextVerticalAlignment"] = 0
		elseif value == "VT_Center" then
			opts["TextVerticalAlignment"] = 1
		elseif value == "VT_Bottom" then
			opts["TextVerticalAlignment"] = 2
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
		self:writef("	obj:setString(%s)\n", formatString(opts.LabelText))
	end
	
	if opts.FontSize and obj:getFontSize() ~= opts.FontSize then
		self:writef("	obj:setFontSize(%s)\n", tostring(opts.FontSize))
	end
	
	if opts.FontName and obj:getFontName() ~= opts.FontName then
		self:writef("	obj:FontName(\"%s\")\n", tostring(opts.FontName))
	end
	
	if nil ~= opts.TouchScaleChangeAble and obj:isTouchScaleChangeAble() ~= opts.TouchScaleChangeAble then
		self:writef("	obj:setTouchScaleChangeAble(%s)\n", tostring(opts.TouchScaleChangeAble))
	end
	
	if (nil ~= opts.AreaWidth or nil ~= opts.AreaHeight) and 
		obj:getTextAreaSize().width ~= (opts.opts.AreaWidth or 0) and
		obj:getTextAreaSize().height ~= (opts.opts.AreaHeight or 0) then
		self:writef("	obj:setTextAreaSize(cc.size(%s))\n", tostring(opts.AreaWidth or 0), tostring(opts.AreaHeight or 0))
	end	
	
	if opts.TextHorizontalAlignment and obj:getTextHorizontalAlignment() ~= opts.TextHorizontalAlignment then
		self:writef("	obj:setTextHorizontalAlignment(%s)\n", tostring(opts.TextHorizontalAlignment))
	end
	
	if opts.TextVerticalAlignment and obj:getTextVerticalAlignment() ~= opts.TextVerticalAlignment then
		self:writef("	obj:setTextVerticalAlignment(%s)\n", tostring(opts.TextVerticalAlignment))
	end

	if opts.OutlineEnabled then
		self:writef("	obj:enableOutline(%s, %s)\n", formatColor(opts.OutlineColor or {0, 0, 0, 0}), tostring(opts.OutlineSize or 0))
	end
	
	if opts.ShadowEnabled then
		self:writef("	obj:enableShadow(%s, cc.size(%d, %d), %s)\n", 
			formatColor(opts.ShadowColor or { 0, 0, 0, 0}), tonumber(opts.ShadowOffsetX) or 0, tonumber(opts.ShadowOffsetY) or 0, tostring(opts.ShadowBlurRadius or 0))
	end
	
	if opts.Color and not isColorEqual(obj:getTextColor(), opts.Color) then
		self:writef("	obj:setTextColor(%s)\n", formatColor(opts.Color))
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_RichTextEx(obj, name, value)
	-- nothing to do
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
		self:writef("	obj:setFontSizeDef(%s)\n", tostring(opts.FontSize))
	end
	
	if opts.Color and not isColorEqual(obj:getTextColorDef(), opts.Color) then
		self:writef("	obj:setTextColorDef(%s)\n", formatColor(opts.Color))
	end

	if opts.LabelText then
		self:writef("	obj:setString(%s)\n", formatString(opts.LabelText))
	end
	
	print("handleOpts_RichTextEx")
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_TextField(obj, name, value)
	local opts = self.opts
	
	if name == "LabelText" or name == "PlaceHolderText" or name == "PasswordStyleText" then
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

	if opts.LabelText then
		self:writef("	obj:setString(%s)\n", formatString(opts.LabelText))
	end
	
	if opts.PlaceHolderText then
		self:writef("	obj:setPlaceHolder(%s)\n", formatString(opts.PlaceHolderText))
	end
	
	if opts.FontSize and obj:getFontSize() ~= opts.FontSize then
		self:writef("	obj:setFontSize(%s)\n", tostring(opts.FontSize))
	end
	
	if opts.FontName and obj:getFontName() ~= opts.FontName then
		self:writef("	obj:FontName(\"%s\")\n", tostring(opts.FontName))
	end
	
	if opts.MaxLengthEnabled then
		if obj:isMaxLengthEnabled() ~= opts.MaxLengthEnabled then
			self:writef("	obj:setMaxLengthEnabled(%s)\n", tostring(opts.MaxLengthEnabled))
		end	
		
		if opts.MaxLength and obj:getMaxLength() ~= opts.MaxLength then
			self:writef("	obj:setMaxLength(%s)\n", tostring(opts.MaxLength))
		end
	end
	
	if opts.PasswordEnabled then
		if obj:isPasswordEnabled() ~= opts.PasswordEnabled then
			self:writef("	obj:setPasswordEnabled(%s)\n", tostring(opts.PasswordEnabled))
		end

		if opts.PasswordStyleText then
			self:writef("	obj:setPasswordStyleText(%s)\n", formatString(opts.PasswordStyleText))
		end
	end
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

--	print("onProperty_TextAtlas(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_TextAtlas(obj, name, c)
	local opts = self.opts
	
	if name == "LabelAtlasFileImage_CNB" then
		local f = c["@Path"] or "", 0, ""
		self:addTexture(0, f) 
		opts[name] = f
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_TextAtlas(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_TextAtlas(obj)
	local opts = self.opts
	
	if not obj:isIgnoreContentAdaptWithSize() then
		opts["IgnoreContentAdaptWithSize"] = true
	end	

	self:handleOpts_Node(obj)

	if opts.LabelAtlasFileImage_CNB and opts.StartChar and opts.CharWidth and opts.CharHeight then
		self:writef("	obj:setProperty(%s, \"%s\", %s, %s, %s)\n", 
			formatString(opts.LabelText), opts.LabelAtlasFileImage_CNB, 
			tostring(opts.CharWidth), tostring(opts.CharHeight),
			formatString(opts.StartChar))
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_TextBMFont(obj, name, value)
	local opts = self.opts
	
	if name == "LabelText" then
		opts[name] = value
	else	
		return self:onProperty_Node(obj, name, value)
	end	

--	print("onProperty_TextBMFont(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_TextBMFont(obj, name, c)
	local opts = self.opts
	
	if name == "LabelBMFontFile_CNB" then
		local f = c["@Path"] or "", 0, ""
--		self:addTexture(0, f) 
		opts[name] = f
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_TextBMFont(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_TextBMFont(obj)
	local opts = self.opts
	
	if not obj:isIgnoreContentAdaptWithSize() then
		opts["IgnoreContentAdaptWithSize"] = true
	end	

	self:handleOpts_Node(obj)

	if opts.LabelText then
		self:writef("	obj:setString(%s)\n", formatString(opts.LabelText))
	end

	if opts.LabelBMFontFile_CNB then
		self:writef("	obj:setFntFile(\"%s\")\n", opts.LabelBMFontFile_CNB)
	end
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
	
	if name == "NormalBackFileData"  or name == "PressedBackFileData" or name == "DisableBackFileData" or
		name == "NodeNormalFileData" or name == "NodeDisableFileData" then
		local f, t, p = c["@Path"] or "", resourceType(c["@Type"]), c["@Plist"] or ""
		if #p > 0 then 
			self:addTexture(t, p) 
		else	
			self:addTexture(t, f) 
		end
		opts[name] = { f, t, p }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_CheckBox(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_CheckBox(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.NormalBackFileData then
		self:writef("	obj:loadTextureBackGround(\"%s\", %s)\n", tostring(opts.NormalBackFileData[1]), tostring(opts.NormalBackFileData[2]))
	end
	
	if opts.PressedBackFileData then
		self:writef("	obj:loadTextureBackGroundSelected(\"%s\", %s)\n", tostring(opts.PressedBackFileData[1]), tostring(opts.PressedBackFileData[2]))
	end
	
	if opts.DisableBackFileData then
		self:writef("	obj:loadTextureBackGroundDisabled(\"%s\", %s)\n", tostring(opts.DisableBackFileData[1]), tostring(opts.DisableBackFileData[2]))
	end
	
	if opts.NodeNormalFileData then
		self:writef("	obj:loadTextureFrontCross(\"%s\", %s)\n", tostring(opts.NodeNormalFileData[1]), tostring(opts.NodeNormalFileData[2]))
	end
	
	if opts.NodeDisableFileData then
		self:writef("	obj:loadTextureFrontCrossDisabled(\"%s\", %s)\n", tostring(opts.NodeDisableFileData[1]), tostring(opts.NodeDisableFileData[2]))
	end
	
	if nil ~= opts.CheckedState and obj:isSelected() ~= opts.CheckedState then
		self:writef("	obj:setSelected(%s)\n", tostring(opts.CheckedState))
	end
	
	if nil ~= opts.DisplayState then
		if obj:isBright() ~= opts.DisplayState then
			self:writef("	obj:setBright(%s)\n", tostring(opts.DisplayState))
		end
		
		if obj:isEnabled() ~= opts.DisplayState then
			self:writef("	obj:setEnabled(%s)\n", tostring(opts.DisplayState))
		end
	end
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
	
	if opts.FileData then
		if opts.FileData[2] == 0 then
			self:writef("	obj:setTexture(\"%s\")\n", opts.FileData[1])
		elseif opts.FileData[2] == 1 then
			self:writef("	obj:setSpriteFrame(\"%s\")\n", opts.FileData[1])
		end
	end
	
	if opts.BlendFunc then
		-- TODO
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Particle(obj, name, value)
	-- nothing to do
	return self:onProperty_Node(obj, name, value)
end

function _M:onChildren_Particle(obj, name, c)
	local opts = self.opts
	
	if name == "FileData" then
		-- nothing to do(done in objScriptOf())
	elseif name == "BlendFunc" then
		opts[name] = { tonumber(c["@Src"]) or 0, tonumber(c["@Dst"]) or 0 }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Particle(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Particle(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.FileData then
		-- nothing to do(done in objScriptOf())
	end
	
	if opts.BlendFunc then
		-- TODO
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_TMXTiledMap(obj, name, value)
	-- nothing to do
	return self:onProperty_Node(obj, name, value)
end

function _M:onChildren_TMXTiledMap(obj, name, c)
	local opts = self.opts
	
	if name == "FileData" then
		-- nothing to do(done in objScriptOf())
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_TMXTiledMap(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_TMXTiledMap(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.FileData then
		-- nothing to do(done in objScriptOf())
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_ProjectNode(obj, name, value)
	-- nothing to do
	return self:onProperty_Node(obj, name, value)
end

function _M:onChildren_ProjectNode(obj, name, c)
	local opts = self.opts
	
	if name == "FileData" then
		-- nothing to do(done in objScriptOf())
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_ProjectNode(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_ProjectNode(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.FileData then
		-- nothing to do(done in objScriptOf())
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_Armature(obj, name, value)
	local opts = self.opts
	
	if name == "IsLoop" or name == "IsAutoPlay" then
		opts[name] = (value == "True")
	elseif name == "CurrentAnimationName" then
		opts[name] = value
	else	
		return self:onProperty_Node(obj, name, value)
	end	

--	print("onProperty_Armature(" .. name .. ", " .. tostring(value) .. ")")		
	return true	
end

function _M:onChildren_Armature(obj, name, c)
	local opts = self.opts
	
	if name == "FileData" then
		opts["ArmatureFileInfo"] = c["@Path"]
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Armature(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Armature(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.ArmatureFileInfo then
		self:writef("	ccsam:addArmatureFileInfo(\"%s\")\n", opts.ArmatureFileInfo)
	end
	
	self:write("	obj:init(\"DemoPlayer\")\n")
	
	if opts.CurrentAnimationName then
		local loop = 0
		if opts.IsLoop then loop = 1 end
		if opts.IsAutoPlay then
			self:writef("	obj:getAnimation():play(\"%s\", -1, %d)\n", opts.CurrentAnimationName, loop)
		else
			self:writef("	obj:getAnimation():play(\"%s\")\n", opts.CurrentAnimationName)
			self:write("	obj:getAnimation():gotoAndPause(0)\n")
		end	
	end
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
		local f, t, p = c["@Path"] or "", resourceType(c["@Type"]), c["@Plist"] or ""
		if #p > 0 then 
			self:addTexture(t, p) 
		else	
			self:addTexture(t, f) 
		end
		opts[name] = { f, t, p }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_Slider(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_Slider(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.Percent and obj:getPercent() ~= opts.Percent then
		self:writef("	obj:setPercent(%s)\n", tostring(opts.Percent))
	end

	if opts.BackGroundData then
		self:writef("	obj:loadBarTexture(\"%s\", %s)\n", tostring(opts.BackGroundData[1]), tostring(opts.BackGroundData[2]))
	end

	if opts.BallNormalData then
		self:writef("	obj:loadSlidBallTextureNormal(\"%s\", %s)\n", tostring(opts.BallNormalData[1]), tostring(opts.BallNormalData[2]))
	end

	if opts.BallPressedData then
		self:writef("	obj:loadSlidBallTexturePressed(\"%s\", %s)\n", tostring(opts.BallPressedData[1]), tostring(opts.BallPressedData[2]))
	end

	if opts.BallDisabledData then
		self:writef("	obj:loadSlidBallTextureDisabled(\"%s\", %s)\n", tostring(opts.BallDisabledData[1]), tostring(opts.BallDisabledData[2]))
	end

	if opts.ProgressBarData then
		self:writef("	obj:loadProgressBarTexture(\"%s\", %s)\n", tostring(opts.ProgressBarData[1]), tostring(opts.ProgressBarData[2]))
	end
	
	if nil ~= opts.DisplayState then
		if obj:isBright() ~= opts.DisplayState then
			self:writef("	obj:setBright(%s)\n", tostring(opts.DisplayState))
		end
		
		if obj:isEnabled() ~= opts.DisplayState then
			self:writef("	obj:setEnabled(%s)\n", tostring(opts.DisplayState))
		end
	end
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
		local f, t, p = c["@Path"] or "", resourceType(c["@Type"]), c["@Plist"] or ""
		if #p > 0 then 
			self:addTexture(t, p) 
		else	
			self:addTexture(t, f) 
		end
		opts[name] = { f, t, p }
	else
		return self:onChildren_Node(obj, name, c)
	end
	
--	print("onChildren_LoadingBar(" .. name .. ", " .. tostring(opts[name]) .. ")")
	return true	
end

function _M:handleOpts_LoadingBar(obj)
	self:handleOpts_Node(obj)

	local opts = self.opts
	
	if opts.Percent and obj:getPercent() ~= opts.Percent then
		self:writef("	obj:setPercent(%s)\n", tostring(opts.Percent))
	end
	
	if opts.Direction and obj:getDirection() ~= opts.Direction then
		self:writef("	obj:setDirection(%s)\n", tostring(opts.Direction))
	end

	if opts.ImageFileData then
		self:writef("	obj:loadTexture(\"%s\", %s)\n", tostring(opts.ImageFileData[1]), tostring(opts.ImageFileData[2]))
	end
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
		opts[name] = { tonumber(c["@ScaleX"]) or 0, tonumber(c["@ScaleY"]) or 1 }
	elseif name == "Size" and opts.Scale9Enabled then
		opts["Scale9Size"] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
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
			self:writef("	setBgImage(obj, \"%s\", %s, true, %s)\n", tostring(opts.FileData[1]), tostring(opts.FileData[2]), capInsets)
			
			if opts.Scale9Size then
				self:writef("	obj:setContentSize(%s)\n", formatSize(opts.Scale9Size))
			end
		else	
			self:writef("	obj:setBackGroundImage(\"%s\", %s)\n", tostring(opts.FileData[1]), tostring(opts.FileData[2]))
		end
	end
	
	if nil ~= opts.ClippingEnabled and obj:isClippingEnabled() ~= opts.ClippingEnabled then
		self:write("	obj:setClippingEnabled(" .. tostring(opts.ClippingEnabled) .. ")\n")
	end
	
	if nil ~= opts.BackGroundColorType and opts.BackGroundColorType ~= 0 then
		local bgType, bgOpacity, bgColor, startColor, endColor, colorVec
	
		if obj:getBackGroundColorType() ~= opts.BackGroundColorType then
			bgType = opts.BackGroundColorType
		end

		if opts.BackGroundColorType == 1 and opts.SingleColor and 
			not isColorEqual(obj:getBackGroundColor(), opts.SingleColor) then
			bgColor = opts.SingleColor
		end

		if opts.BackGroundColorType == 2 and opts.FirstColor and opts.EndColor and 
			not isColorEqual(obj:getBackGroundStartColor(), opts.FirstColor) and 
			not isColorEqual(obj:getBackGroundEndColor(), opts.EndColor) then
			startColor = opts.FirstColor
			endColor = opts.EndColor
		end
		
		if opts.BackGroundColorType == 2 and opts.ColorVector and 
			not isPointEqual(obj:getBackGroundColorVector(), opts.ColorVector) then
			colorVec = opts.ColorVector
		end
	
		if opts.BackGroundColorOpacity and obj:getBackGroundColorOpacity() ~= opts.BackGroundColorOpacity then
			bgOpacity = opts.BackGroundColorOpacity
		end

		self:writef("	setBgColor(obj, %s, %s, %s, %s, %s, %s)\n",
			tostring(bgType), tostring(bgOpacity), formatColor(bgColor), formatColor(startColor), formatColor(endColor), formatPoint(colorVec))
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_ScrollView(obj, name, value)
	local opts = self.opts

	if name == "ScrollDirectionType" then
		if value == "Vertical" then
			opts["ScrollDirection"] = 1
		elseif value == "Horizontal" then
			opts["ScrollDirection"] = 2
		elseif value == "Vertical_Horizontal" then
			opts["ScrollDirection"] = 3
		else
			opts["ScrollDirection"] = tonumber(value) or 0
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
	
	if opts.InnerContainerSize and not isSizeEqual(obj:getInnerContainerSize(), opts.InnerContainerSize) then
		self:writef("	obj:setInnerContainerSize(%s)\n", formatSize(opts.InnerContainerSize))
	end
	
	if opts.ScrollDirection and obj:getDirection() ~= opts.ScrollDirection then
		self:writef("	obj:setDirection(%s)\n", tostring(opts.ScrollDirection))
	end
	
	if nil ~= opts.BounceEnabled and obj:isBounceEnabled() ~= opts.BounceEnabled then
		self:writef("	obj:setBounceEnabled(%s)\n", tostring(opts.BounceEnabled))
	end
end
	
--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_ListView(obj, name, value)
	local opts = self.opts

	if name == "ItemMargin" then
		opts["ItemsMargin"] = tonumber(value) or 0
	elseif name == "DirectionType" then
		opts["Gravity"] = value
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
	local opts = self.opts
	opts.ScrollDirection = nil

	self:handleOpts_ScrollView(obj)
	
	if opts.ItemsMargin and obj:getItemsMargin() ~= opts.ItemsMargin then
		self:writef("	obj:setItemsMargin(%d)\n", tonumber(opts.ItemsMargin) or 0)
	end
	
	if opts.VerticalType or opts.HorizontalType then
		if nil == opts.Gravity or opts.Gravity == "" then
			self:write("	obj:setDirection(2)\n")
			self:writef("	obj:setGravity(%d)\n", tonumber(opts.VerticalType) or 0)
		elseif opts.Gravity == "Vertical" then
			self:write("	obj:setDirection(1)\n")
			self:writef("	obj:setGravity(%d)\n", tonumber(opts.HorizontalType) or 0)
		end	
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:onProperty_PageView(obj, name, value)
	local opts = self.opts
	
	if name == "ScrollDirectionType" then
		-- nothing to do
	else
		return self:onProperty_Layout(obj, name, value)
	end	
	
--	print("onProperty_PageView(" .. name .. ", " .. value .. ")")	
	return true	
end

function _M:onChildren_PageView(obj, name, c)
	-- nothing to do
	return self:onChildren_Layout(obj, name, c)
end

function _M:handleOpts_PageView(obj)
	self:handleOpts_Layout(obj)
	-- nothing to do
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
			if name ~= "IconVisible" and name ~= "ctype" and name ~= "ActionTag" and name ~= "ColorAngle" and name ~= "CanEdit" and
				name ~= "LeftEage" and name ~= "TopEage" and name ~= "RightEage" and name ~= "BottomEage" then
				print("@@ Nothing to do: readNodeProperties(" .. name .. " @" .. className .. ")")
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
				print("@@ Nothing to do: readNodeChildren(" .. name .. " @" .. className .. ")")
			end	
		end
	end
end

--/////////////////////////////////////////////////////////////////////////////
function _M:handleNodeOpts(root, obj, className)
	local handleOpts = self["handleOpts_" .. className] or self.handleOpts_Node
	
	local opts = self.opts
	local lays = self.lays
	
	if type(obj.ignoreContentAdaptWithSize) == "function" then
		if (opts.IsCustomSize or lays.PercentWidthEnabled or lays.PercentHeightEnabled or opts.Scale9Enabled) 
			and obj:isIgnoreContentAdaptWithSize() then
			opts["IgnoreContentAdaptWithSize"] = false
		end
	end

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
		self:writef("	bind(obj)%s%s%s%s%s\n", margins, sizes, positions, stretchs, edges)
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
function _M:objScriptOf(className, root)
	local obj, script = nil, nil
    if className == "ProjectNode" then
		local fileData = root["FileData"] 
		if fileData and fileData["@Path"] then
			local path = string.gsub(fileData["@Path"], ".csd", ".lua")
			obj = cc.Node:create()
			script = string.format("	inc = require(\"%s\").create(callBackProvider)\n", path)
			script = script .. "	if inc.animation then inc.root:runAction(inc.animation) end\n"
			script = script .. "	obj = inc.root\n"
		end	
    elseif className == "GameNode" or className == "SingleNode" or className == "Node" then
		obj = cc.Node:create()
		script = "	obj = cc.Node:create()\n"
    elseif className == "SimpleAudio" then
--        reader = ComAudioReader::getInstance();
    elseif className == "Panel" or className == "Layout" then
    	className = "Layout"
		obj = ccui.Layout:create()
		script = "	obj = ccui.Layout:create()\n"
    elseif className == "TextButton" or className == "Button" then
    	className = "Button"
		obj = ccui.Button:create()
		script = "	obj = ccui.Button:create()\n"
    elseif className == "TextArea" or className == "Text" or className == "Label" then
    	className = "Text"
		obj = ccui.Text:create()
		script = "	obj = ccui.Text:create()\n"
    elseif className == "RichTextEx" then
		obj = require("ccext.RichTextEx"):create()
		script = "	obj = require(\"ccext.RichTextEx\"):create()\n"
    elseif className == "TextField" then
		obj = ccui.TextField:create()
		script = "	obj = ccui.TextField:create()\n"
    elseif className == "LabelAtlas" or className == "TextAtlas" then
    	className = "TextAtlas"
		obj = ccui.TextAtlas:create()
		script = "	obj = ccui.TextAtlas:create()\n"
    elseif className == "LabelBMFont" or className == "TextBMFont" then
    	className = "TextBMFont"
		obj = ccui.TextBMFont:create()
		script = "	obj = ccui.TextBMFont:create()\n"
    elseif className == "Slider" then
		obj = ccui.Slider:create()
		script = "	obj = ccui.Slider:create()\n"
    elseif className == "LoadingBar" then
		obj = ccui.LoadingBar:create()
		script = "	obj = ccui.LoadingBar:create()\n"
    elseif className == "Sprite" then
		obj = cc.Sprite:create()
		script = "	obj = cc.Sprite:create()\n"
    elseif className == "CheckBox" then
		obj = ccui.CheckBox:create()
		script = "	obj = ccui.CheckBox:create()\n"
    elseif className == "ImageView" then
		obj = ccui.ImageView:create()
		script = "	obj = ccui.ImageView:create()\n"
    elseif className == "ScrollView" then
		obj = ccui.ScrollView:create()
		script = "	obj = ccui.ScrollView:create()\n"
    elseif className == "ListView" then
		obj = ccui.ListView:create()
		script = "	obj = ccui.ListView:create()\n"
    elseif className == "PageView" then
		obj = ccui.PageView:create()
		script = "	obj = ccui.PageView:create()\n"
	elseif className == "Particle" then
		local fileData = root["FileData"] 
		if fileData and fileData["@Path"] then
			obj = cc.ParticleSystemQuad:create()
			script = string.format("	obj = cc.ParticleSystemQuad:create(\"%s\")\n", fileData["@Path"])
		end
	elseif className == "GameMap" then
		className = "TMXTiledMap"
		local fileData = root["FileData"] 
		if fileData and fileData["@Path"] then
--			obj = cc.TMXTiledMap:create(fileData["@Path"])
			obj = cc.Node:create()
			script = string.format("	obj = cc.TMXTiledMap:create(\"%s\")\n", fileData["@Path"])
		end
	elseif className == "ArmatureNode" then
		className = "Armature"
		obj = ccs.Armature:create()
		script = "	obj = ccs.Armature:create()\n"
	elseif className == "SimpleAudio" then
    end
    
    return obj, script, className
end

--/////////////////////////////////////////////////////////////////////////////
local _createNodeTree, _i = nil, 0
_createNodeTree = function(self, root, classType, rootName, rootClassName)
	local pos = string.find(classType, "ObjectData")
	if pos then	
		classType = string.sub(classType, 1, pos - 1)
	end	

	local obj, script, className = self:objScriptOf(classType, root)
	if not obj or not script then return end

	self:write(script)
		
	if rootName then
		if rootClassName == "PageView" and className == "Layout" then
			self:write("	" .. rootName .. ":addPage(obj)\n")
		elseif rootClassName == "ListView" then
			self:write("	" .. rootName .. ":pushBackCustomItem(obj)\n")
		else
			self:write("	" .. rootName .. ":addChild(obj)\n")
		end	
	else
		self:write("	roots.root = obj\n")
	end
	
	rootName = self:parseNodeXml(root, obj, className)
	rootName = "roots." .. rootName .. "_" .. tostring(_i)
	rootClassName = className

	_i = _i + 1
	if root.Children then
		local nextSiblingNode = nextSiblingIter(root.Children)
		local node, udata = nextSiblingNode()

		self:write("	" .. rootName .. " = obj\n\n")
		while node do
			className = node["@ctype"] or "NodeObjectData"

			udata = node["@UserData"]
			if udata then
				local pos = string.find(udata, "@class_", 1, true)
				if pos then
					className = string.sub(udata,  pos + 7)	-- .. "ObjectData"
				end					
			end
			
			_createNodeTree(self, node, className, rootName, rootClassName)
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
function _M:addTexture(t, texture)
	if not self._textures then
		self._textures = {}
	end
	for _, value in pairs(self._textures) do
		if value == texture then return end
	end	
	table.insert(self._textures, texture)
	if t == 1 then
		self:write("	ccspc:addSpriteFrames(\"" .. texture .. "\")\n")
	end	
end

--/////////////////////////////////////////////////////////////////////////////
function _M:csd2lua(csdFile, luaFile)
	local xml = require("ccext.XmlParser").newParser():loadFile(csdFile)
	
	if not xml or xml:numChildren() ~= 1 then 
		error("XmlParser:loadFile(" .. csdFile ..") bad XML.")
		return 
	end
	
	local nextSiblingNode = nextSiblingIter(xml:children()[1])
	local node, name, serializeEnabled = nextSiblingNode(), nil, false
	
	while node do
		name = node:name()
		
		if name == "PropertyGroup" then
			self._csdVersion = node["@Version"] or "2.1.0.0"
		elseif name == "Content" and node:numProperties() == 0 then
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
	self:write(string.format(_SCRIPT_HEAD, self._csdVersion or ""))
	self:write(_CREATE_FUNC_HEAD)
	
	local tblAni = {}

	nextSiblingNode = nextSiblingIter(node)
	node = nextSiblingNode()
	while node do
		name = node:name()

		if name == "Animation" then
			table.insert(tblAni, "	obj = ccs.ActionTimeline:create()\n")
			table.insert(tblAni, string.format("	obj:setDuration(%d)\n", tonumber(node["@Duration"]) or 0))
			table.insert(tblAni, string.format("	obj:setTimeSpeed(%d)\n", tonumber(node["@Speed"]) or 1))
			table.insert(tblAni, "	roots.animation = obj\n\n")
		elseif name == "ObjectData" then
			self:createNodeTree(node, "NodeObjectData")
		elseif name == "AnimationList" then
			-- TODO.
		end
		
		node = nextSiblingNode()
	end
	
	if #tblAni > 0 then
		self:write(table.concat(tblAni))
	end

	self:write(_CREATE_FUNC_FOOT)
	
	self:write("_M.textures = {\n")
	for _, v in pairs(self._textures or {}) do
		self:write("	\""  .. v ..  "\",\n")
	end
	self:write("}\n")
	
	self:write(_SCRIPT_FOOT)

	io.close(file)
end

--/////////////////////////////////////////////////////////////////////////////

return _M
