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

function _M.create(callBackProvider)
	local cc, ccui = cc, ccui
	
	local obj, lay

	local roots = {}

]]

local _SCRIPT_FOOT =
[[
	return roots
end

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

--/////////////////////////////////////////////////////////////////////////////
function _M:parseNodeXml(root, obj, className)
--	print("parseNodeXml(className=" .. className .. ")")
	
	local opts = {}
	local lays = {}
	
	for _, p in pairs(root:properties()) do
		local name = p.name
		local value = p.value
		
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
			lays[name .. "d"] = (value == "True")
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
		elseif name == "ClipAble" then
			opts["ClippingEnabled"] = (value == "True")
		elseif name == "ComboBoxIndex" then
			if className == "Layout" then
				opts["BackGroundColorType"] = tonumber(value)
			end
		elseif name == "BackColorAlpha" then
			if className == "Layout" then
				opts["BackGroundColorOpacity"] = tonumber(value)
			end
		elseif name == "Scale9Enable" then
		elseif name == "Scale9OriginX" then
		elseif name == "Scale9OriginY" then
		elseif name == "Scale9Width" then
		elseif name == "Scale9Height" then
		elseif name == "LabelText" then
			opts["String"] = value
		elseif name == "FontSize" then
			opts["FontSize"] = tonumber(value)
		end
	end
	
	for _, c in pairs(root:children()) do
		local name = c:name()
		
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
			if obj and type(obj.getContentSize) == "function" then
				opts["ContentSize"] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
			end	
			if obj and not obj.getContentSize and type(obj.getSize) == "function" then
				opts["Size"] = { tonumber(c["@X"]) or 0, tonumber(c["@Y"]) or 0 }
			end	
		elseif name == "PrePosition" then
			lays["PositionPercentX"] = tonumber(c["@X"]) or 0
			lays["PositionPercentY"] = tonumber(c["@Y"]) or 0
		elseif name == "PreSize" then
			lays["PercentWidth"] = tonumber(c["@X"]) or 0
			lays["PercentHeight"] = tonumber(c["@Y"]) or 0
		elseif name == "FileData" or name == "NormalFileData" or 
			name == "PressedFileData" or name == "DisabledFileData" then
			local f = c["@Path"] or ""
			local t = c["@Type"] or ""
			local p = c["@Plist"] or ""
			if t == "Normal" or t == "Default" or t == "MarkedSubImage" then
				t = 0
			else
				t = 1
				if #p > 0 then self:writPlist(p) end
			end

			opts[name] = { f, t, p }
        elseif name == "SingleColor" or name == "FirstColor" or name == "EndColor" or name == "TextColor" then
            opts[name] = { tonumber(c["@R"]) or 0, tonumber(c["@G"]) or 0, 
            	tonumber(c["@B"]) or 0, tonumber(c["@A"]) }
		elseif name == "ColorVector" then
		end
	end
	
	local tblVal, tblLay, str = {}, {}, ""
	
	if opts.CallbackType and opts.CallbackName and 
		(opts.CallbackType == "Click" or opts.CallbackType == "Touch") then
		table.insert(tblVal, string.format("	_L.set%sEvent(obj, callBackProvider, \"%s\")\n",
			opts.CallbackType, opts.CallbackName))
	end
	opts.CallbackType = nil
	opts.CallbackName = nil
	
	for name, value in pairs(opts) do
--		print("opts name=" .. tostring(name) .. " value=" .. tostring(value))
--		if type(obj["set" .. name]) == "function" then
            str = ""
            if name == "Name" or name == "Tag" or name == "LocalZOrder" or name == "Opacity" then
            	if obj["get" .. name](obj) == value then
                	opts[name] = nil    
                end
            elseif name == "Position" or name == "Scale" then
                if obj["get" .. name .. "X"](obj) ~= value[1] or 
                	obj["get" .. name .. "Y"](obj) ~= value[2] then
                	if name == "Scale" then
                		str = string.format("obj:set%s(%s, %s)\n", name, tostring(value[1]), tostring(value[2]))
					end	
                else
                	opts[name] = nil    
                end
            elseif name == "AnchorPoint" then
                if isPointEqual(obj["get" .. name](obj), value) then
                	opts[name] = nil    
                end
            elseif name == "ContentSize" or name == "Size" then
                if isSizeEqual(obj["get" .. name](obj), value) then
                	opts[name] = nil    
                end
			elseif name == "Color" then               
                if isColorEqual(obj:getColor(), value) then
                	opts[name] = nil    
                end
			elseif name == "FileData" or name == "NormalFileData" or 
				name == "PressedFileData" or name == "DisabledFileData" then
				if name == "FileData" then
					if className == "ImageView"  then
						str = string.format("obj:loadTexture(\"%s\", %s)\n", tostring(value[1]), tostring(value[2]))
					elseif className == "Layout" then
						str = string.format("obj:setBackGroundImage(\"%s\", %s)\n", tostring(value[1]), tostring(value[2]))
	                end
	            elseif className == "Button"  then
	                local s = string.sub(name, 1, string.find(name, "FileData") - 1)
					str = string.format("obj:loadTexture%s(\"%s\", %s)\n", s, tostring(value[1]), tostring(value[2]))
				end
			elseif name == "SingleColor" or name == "FirstColor" or name == "EndColor" or name == "TextColor" then	 
				local clr
				if value[4] then
					clr = string.format("cc.c4b(%s, %s, %s, %s)", tostring(value[1]), tostring(value[2]), tostring(value[3]), tostring(value[4]))
				else
					clr = string.format("cc.c3b(%s, %s, %s)", tostring(value[1]), tostring(value[2]), tostring(value[3]))
				end	
	            if className == "Layout" then
	                if name == "SingleColor" and not isColorEqual(obj:getBackGroundColor(), value) then
	                	str = "obj:setBackGroundColor(" .. clr .. ")\n"
					end
				elseif className == "Button" then	
	                if name == "TextColor" and not isColorEqual(obj:getTitleColor(), value) then
						str = "obj:setTitleColor(" .. clr .. ")\n"
					end
				end
            elseif (type(obj["get" .. name]) == "function" and obj["get" .. name](obj) ~= value) or
				(type(obj["is" .. name]) == "function" and obj["is" .. name](obj) ~= value) then
				if type(value) == "number" or type(value) == "boolean" then
					str = "obj:set" .. name .. "(" .. tostring(value) .. ")\n"
				elseif type(value) == "string" then
					str = "obj:set" .. name .. "([[" .. tostring(value) .. "]])\n"
				end
			else
				opts[name] = nil	
			end
            
            if #str > 0 then
                table.insert(tblVal, 	"	" .. str)
            end
--		end
	end
	
    local lay = obj:getComponent("__ui_layout") or ccui.LayoutComponent:create()
    local flg = false

    for name, value in pairs(lays) do
        if ((type(lay["get" .. name]) == "function" and lay["get" .. name](lay) ~= value) or
            (type(lay["is" .. name]) == "function" and lay["is" .. name](lay) ~= value)) then
--			if type(value) == "number" or type(value) == "boolean" then
--                str = "lay:set" .. name .. "(" .. tostring(value) .. ")\n"
--            elseif type(value) == "string" then
--                str = "lay:set" .. name .. "(\"" .. tostring(value) .. "\")\n"
--            end
--
--            table.insert(tblLay, 	"	" .. str)
		else
			lays[name] = nil
        end
    end

    local size, position, ancpoint, color = nil, nil, nil, nil
    if opts.ContentSize then
    	size = string.format("cc.size(%s, %s)", tostring(opts.ContentSize[1] or 0), 
    		tostring(opts.ContentSize[2] or 0)) 
    elseif opts.Size then	
    	size = string.format("cc.size(%s, %s)", tostring(opts.Size[1] or 0), 
    		tostring(opts.Size[2] or 0)) 
    end    	
    if opts.Position then
    	position = string.format("cc.p(%s, %s)", tostring(opts.Position[1] or 0), 
    		tostring(opts.Position[2] or 0)) 
    end    	
    if opts.AnchorPoint then
    	ancpoint = string.format("cc.p(%s, %s)", tostring(opts.AnchorPoint[1] or 0), 
    		tostring(opts.AnchorPoint[2] or 0)) 
    end    	
    if opts.Color then
    	if opts.Color[4] then
			color = string.format("cc.c4b(%d, %d, %d, %d)", opts.Color[1] or 0, 
				opts.Color[2] or 0, opts.Color[3] or 0, opts.Color[4] or 0) 
    	else
			color = string.format("cc.c3b(%d, %d, %d)", opts.Color[1] or 0, 
				opts.Color[2] or 0, opts.Color[3] or 0) 
    	end	
    end    	
	self:write(string.format("	_L.setValue(obj, \"%s\", %s, %s, %s, %s, %s, %s, %s)\n",
		tostring(opts.Name), tostring(opts.Tag), tostring(size), tostring(position), tostring(ancpoint),
		tostring(color), tostring(opts.Opacity), tostring(opts.LocalZOrder)))
		
    if #tblVal > 0 then
	    self:write(table.concat(tblVal))
	end
    		
--    if #tblLay > 0 then
        --self:write(table.concat(tblLay))
        local margins, sizes, positions, stretchs, edges = "", "", "", "", ""
        if nil ~= lays.LeftMargin or nil ~= lays.TopMargin or 
        	nil ~= lays.RightMargin or nil ~= lays.BottomMargin then
			margins = string.format(".setMargin(%s, %s, %s, %s)",
				tostring(lays.LeftMargin), tostring(lays.TopMargin), 
				tostring(lays.RightMargin), tostring(lays.BottomMargin))
		end	
        if nil ~= lays.PercentWidth or nil ~= lays.PercentHeight or 
        	nil ~= lays.PercentWidthEnabled or nil ~= lays.PercentHeightEnabled then
			sizes = string.format(".setSize(%s, %s, %s, %s)",
				tostring(lays.PercentWidth), tostring(lays.PercentHeight), 
				tostring(lays.PercentWidthEnabled), tostring(lays.PercentHeightEnabled))
		end		
        if nil ~= lays.PositionPercentX or nil ~= lays.PositionPercentY 
        	or nil ~= lays.PositionPercentXEnabled or nil ~= lays.PositionPercentYEnabled then
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
--    end

	return opts.Name or ""
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
--        reader = LayoutReader::getInstance();
    elseif className == "TextArea" or className == "Text" or className == "Label" then
    	className = "Text"
		obj = ccui.Text:create()
		script = 
[[
	obj = ccui.Text:create()
]]
    elseif className == "TextField" then
    	className = "TextField"
		obj = ccui.TextField:create()
		script = 
[[
	obj = ccui.TextField:create()
]]
    elseif className == "TextButton" or className == "Button" then
    	className = "Button"
		obj = ccui.Button:create()
		script = 
[[
	obj = ccui.Button:create()
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
    
    return obj, script
end

--/////////////////////////////////////////////////////////////////////////////
local _createNodeTree, _i = nil, 0
_createNodeTree = function(self, root, classType, rootName)
	local className = string.sub(classType, 1, string.find(classType, "ObjectData") - 1)
--	print("_createNodeTree(classType=" .. classType .. ", className=" .. className .. ")")

	local obj, script = objScriptOf(className)
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
		local node = nextSiblingNode()

		self:write("	" .. rootName .. " = obj\n\n")
		while node do
			_createNodeTree(self, node, node["@ctype"] or "NodeObjectData", rootName)
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

	self:write(_SCRIPT_FOOT)
	
	io.close(file)
end

--/////////////////////////////////////////////////////////////////////////////

return _M

