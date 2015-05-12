# csd2lua

一个将 Cocos Studio 2.* 工程文件 .csd 转换成 .lua 资源的小工具，暂时仅支持 Cocos Studio “对象”面板上除了“声音”外的静态对象导出。另外，主要目的是支持“自定义控件”导出。




基本用法：

	require("ccext.csd2lua").new():csd2lua("FullPathName.csd", "Save_FullPathName.lua")




使用方式：

	1、是基于 Cocos2d-x Lua 的项目工程（在 Cocos2d-x 3.6/Cocos Studio 2.2.5/6 上测试过）
	
	2、把本工具的 ccext 目录拷贝进项目 src 目录
	
	3、先用 Cocos Studio 执行一次导出，以便图片资源啊已经完整导出到对应目录下
	
	4、参考例子 ConvertCSD.lua 和 main.lua。
	
		自己修改 ConvertCSD.lua 里的文件列表 _CSDFILES = { "**.csd", "**.csd" }，拷贝此文件进你项目
		把本 main.lua 里那句 require("ConvertCSD").doConvert() 拷贝到你真正的 main.lua
	
	5、要转换的时候，开启执行那句 require("ConvertCSD").doConvert()，否则注释掉即可




工具特点：

	1、尽量去冗余化，比如 setFlippX(false)、setScaleX(1) 这些凡是跟默认参数值相同的，不必要导出的，就不导出此参数
	
	2、精简和压缩所导出的 LUA 语句行数。测试范例是 Cocos Studio  2.2.1 导出为 8600 多行，本工具导出为 1300 行
	
	3、你还可以改造代码，实现自定义控件导出
	
		比如参考里面的 RichTextEx 部分，凡是“用户数据”（UserData）字段是 @class_YYYY 格式的，将以自定义 YYYY 控件导出。
		比如一个 ccui.Text 是以 ccui.Text:create() 导出，但如果“用户数据”内容是 @class_RichTextEx，将以 require("ccext.RichTextEx"):create() 导出

	4、本工程所有用到的图片资源以 _M.textures = { ... } 方式列出，以方便制作 loading 界面，因为载入时速度影响最大的是资源读取

