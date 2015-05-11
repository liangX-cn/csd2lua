cc.FileUtils:getInstance():addSearchPath("cocosstudio/")

local _M  = {}

local _CSDFILES = {
	"Start/StartScene.csd",
	"Dialog/Dialog.csd",
	"Lobby/LobbyScene.csd",
	"Game/GameScene.csd",
	
	"Test/TestScene.csd",
	"Test/TestLayer.csd",
}

function _M.doConvert()
	local fileUtils = cc.FileUtils:getInstance()
	
	for _, v in pairs(_CSDFILES) do
		local csdFile = fileUtils:fullPathForFilename(string.format("cocosstudio/%s", v))
		local luaFile = fileUtils:fullPathForFilename("res")  .. "/" .. string.gsub(v, ".csd", ".lua")
		
		if not csdFile or csdFile == "" then
			print("\n")
			print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			error("Not found: " .. "cocosstudio/" .. v)
			break
		end
				
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		print("【.csd】: " .. string.format("cocosstudio/%s", v))
		print("【.lua】: " .. string.format("res/%s", v))
		
		require("ccext.csd2lua").new():csd2lua(csdFile, luaFile)

		print("\n\n")
	end
end

return _M
