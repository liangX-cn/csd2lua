# csd2lua
A tools to convert Cocos Studio .csd file to .lua resource


	local csdFile = cc.FileUtils:getInstance():fullPathForFilename("res/StartScene.csd")
	local luaFile = cc.FileUtils:getInstance():fullPathFromRelativeFile("StartScene.lua", csdFile)
	require("ccext.csd2lua").new():csd2lua(csdFile, luaFile)

