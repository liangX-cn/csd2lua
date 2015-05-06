---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- xml.lua - XML parser for use with the Corona SDK.
--
-- version: 1.2
--
-- CHANGELOG:
--
-- 1.2 - Created new structure for returned table
-- 1.1 - Fixed base directory issue with the loadFile() function.
--
-- NOTE: This is a modified version of Alexander Makeev's Lua-only XML parser
-- found here: http://lua-users.org/wiki/LuaXml
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

local _M = {}

function _M.newParser()

	local XmlParser = {};

	function XmlParser:ToXmlString(value)
		value = string.gsub(value, "&", "&amp;"); -- '&' -> "&amp;"
		value = string.gsub(value, "<", "&lt;"); -- '<' -> "&lt;"
		value = string.gsub(value, ">", "&gt;"); -- '>' -> "&gt;"
		value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
		value = string.gsub(value, "([^%w%&%;%p%\t% ])", function(c)
			return string.format("&#x%X;", string.byte(c))
		end);
		return value;
	end

	function XmlParser:FromXmlString(value)
		value = string.gsub(value, "&#x([%x]+)%;", function(h)
			return string.char(tonumber(h, 16))
		end);
		value = string.gsub(value, "&#([0-9]+)%;", function(h)
			return string.char(tonumber(h, 10))
		end);
		value = string.gsub(value, "&quot;", "\"");
		value = string.gsub(value, "&apos;", "'");
		value = string.gsub(value, "&gt;", ">");
		value = string.gsub(value, "&lt;", "<");
		value = string.gsub(value, "&amp;", "&");
		return value;
	end

	function XmlParser:ParseArgs(node, s)
		string.gsub(s, "(%w+)=([\"'])(.-)%2", function(w, _, a)
			--print("@@@@@@@@@@@@ " .. tostring(w) .. "=" .. tostring(a))
			node:addProperty(w, self:FromXmlString(a))
		end)
	end

	function XmlParser:ParseNode(s)
		local ni, j, label, xarg, empty = string.find(s, "^([%w_:]+)(.-)(%/?)$")
		local lNode = _M.newNode(label)
		self:ParseArgs(lNode, xarg)
		return empty, lNode
	end

	function XmlParser:ParseXmlText(xmlText)
		local i, j, k = 1, 1, 1
		local nodes = {}
		local top = _M.newNode()
		table.insert(nodes, top)
		while true do
			j, k = string.find(xmlText, "<", i)
			if not j then break end

			local text = string.sub(xmlText, i, j - 1);
			if not string.find(text, "^%s*$") then
				local lVal = (top:value() or "") .. self:FromXmlString(text)
				nodes[#nodes]:setValue(lVal)
				i = j
			end

			local x = string.sub(xmlText, k+1, k+1)
			if (x == "?") then
				j, k = string.find(xmlText, "%?>", i)
				j = j + 1
			elseif (x == "!") then
				local cdataStart = string.sub(xmlText, k+2, k+8)
				if (cdataStart == "[CDATA[") then
					j, k = string.find(xmlText, "]]>", i)
					local cdataText = string.sub(xmlText, i+9, j-1)
					top:setValue((top:value() or "")..cdataText)
					j = j + 2
				else
					error("should be <![[ but was "..cdataStart)
				end
			elseif (x == "/") then
				i = j + 2
				j, k = string.find(xmlText, ">", i)
				local value = string.sub(xmlText, i, j-1)
				local toclose = table.remove(nodes)

				top = nodes[#nodes]
				if #nodes < 1 then
					error("XmlParser: nothing to close with " .. value)
				end
				if toclose:name() ~= value then
					error("XmlParser: trying to close " .. toclose:name() .. " with " .. value)
				end
				top:addChild(toclose)
			else
				i = j + 1
				j, k = string.find(xmlText, ">", i)
				local name = string.sub(xmlText, i, j-1)
				local empty, lNode = self:ParseNode(name)
				if (empty == "/") then
					top:addChild(lNode)
				else
					table.insert(nodes, lNode)
					top = lNode
				end
			end
			i = j + 1
		end
        local text = string.sub(xmlText, i);
        if #nodes > 1 then
            error("XmlParser: unclosed " .. nodes[#nodes]:name())
        end
		return top
	end

	function XmlParser:loadFile(xmlFilename)
		local path = cc.FileUtils:getInstance():fullPathForFilename(xmlFilename)
		local hFile, err = io.open(path, "r");

		if hFile and not err then
			local xmlText = hFile:read("*a"); -- read file content
			io.close(hFile);
			return self:ParseXmlText(xmlText), nil;
		else
			print(err)
			return nil
		end
	end

	return XmlParser
end

function _M.newNode(name)
	local node = {}
	node.___value = nil
	node.___name = name
	node.___children = {}
	node.___props = {}

	function node:value() return self.___value end
	function node:setValue(val) self.___value = val end
	function node:name() return self.___name end
	function node:setName(name) self.___name = name end
	function node:children() return self.___children end
	function node:numChildren() return #self.___children end
	function node:addChild(child)
		if self[child:name()] ~= nil then
			if type(self[child:name()].name) == "function" then
				local tempTable = {}
				table.insert(tempTable, self[child:name()])
				self[child:name()] = tempTable
			end
			table.insert(self[child:name()], child)
		else
			self[child:name()] = child
		end
		table.insert(self.___children, child)
	end

	function node:properties() return self.___props end
	function node:numProperties() return #self.___props end
	function node:addProperty(name, value)
		local lName = "@" .. name
		if self[lName] ~= nil then
			if type(self[lName]) == "string" then
				local tempTable = {}
				table.insert(tempTable, self[lName])
				self[lName] = tempTable
			end
			table.insert(self[lName], value)
		else
			self[lName] = value
		end
		table.insert(self.___props, { name = name, value = self[lName] })
	end

	return node
end

return _M