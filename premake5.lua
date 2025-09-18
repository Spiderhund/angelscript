local _asAddonList = {
	"as_addon_autowrapper",
	"as_addon_context_manager",
	"as_addon_date_time",
	"as_addon_debugger",
	"as_addon_script_any",
	"as_addon_script_array",
	"as_addon_script_builder",
	"as_addon_script_dictionary",
	"as_addon_script_file",
	"as_addon_script_grid",
	"as_addon_script_handle",
	"as_addon_script_helper",
	"as_addon_script_math",
	"as_addon_script_socket",
	"as_addon_script_std_string",
	"as_addon_serializer",
	"as_addon_weak_ref"
}

local _asAddonMap = {}
_asAddonMap[_asAddonList[1]] = { path = "autowrapper", define = "AS_ADDON_AUTO_WRAPPER", desc = "Set if the Auto Wrapper add-on should be included" };
_asAddonMap[_asAddonList[2]] = { path = "contextmgr", define = "AS_ADDON_CONTEXT_MANAGER", desc = "Set if the Context Manager add-on should be included" };
_asAddonMap[_asAddonList[3]] = { path = "datetime", define = "AS_ADDON_DATE_TIME", desc = "Set if the Date Time add-on should be included" };
_asAddonMap[_asAddonList[4]] = { path = "debugger", define = "AS_ADDON_DEBUGGER", desc = "Set if the Debugger add-on should be included" };
_asAddonMap[_asAddonList[5]] = { path = "scriptany", define = "AS_ADDON_SCRIPT_ANY", desc = "Set if the Script Any add-on should be included" };
_asAddonMap[_asAddonList[6]] = { path = "scriptarray", define = "AS_ADDON_SCRIPT_ARRAY", desc = "Set if the Script Array add-on should be included" };
_asAddonMap[_asAddonList[7]] = { path = "scriptbuilder", define = "AS_ADDON_SCRIPT_BUILDER", desc = "Set if the Script Builder add-on should be included" };
_asAddonMap[_asAddonList[8]] = { path = "scriptdictionary", define = "AS_ADDON_SCRIPT_DICTIONARY", desc = "Set if the Script Dictionary add-on should be included" };
_asAddonMap[_asAddonList[9]] = { path = "scriptfile", define = "AS_ADDON_SCRIPT_FILE", desc = "Set if the Script File add-on should be included" };
_asAddonMap[_asAddonList[10]] = { path = "scriptgrid", define = "AS_ADDON_SCRIPT_GRID", desc = "Set if the Script Grid add-on should be included" };
_asAddonMap[_asAddonList[11]] = { path = "scripthandle", define = "AS_ADDON_SCRIPT_HANDLE", desc = "Set if the Script Handle add-on should be included" };
_asAddonMap[_asAddonList[12]] = { path = "scripthelper", define = "AS_ADDON_SCRIPT_HELPER", desc = "Set if the Script Helper add-on should be included" };
_asAddonMap[_asAddonList[13]] = { path = "scriptmath", define = "AS_ADDON_SCRIPT_MATH", desc = "Set if the Script Math add-on should be included" };
_asAddonMap[_asAddonList[14]] = { path = "scriptsocket", define = "AS_ADDON_SCRIPT_SOCKET", desc = "Set if the Script Socket add-on should be included" };
_asAddonMap[_asAddonList[15]] = { path = "scriptstdstring", define = "AS_ADDON_SCRIPT_STD_STRING", desc = "Set if the Script Standard String add-on should be included" };
_asAddonMap[_asAddonList[16]] = { path = "serializer", define = "AS_ADDON_SERIALIZER", desc = "Set if the Serializer add-on should be included" };
_asAddonMap[_asAddonList[17]] = { path = "weakref", define = "AS_ADDON_WEAK_REFERENCE", desc = "Set if the Weak Reference add-on should be included" };

local _asNewIncludeRoot = path.join(_SCRIPT_DIR, "include");
local _asOrgASInclude = path.join(_SCRIPT_DIR, "sdk", "angelscript", "include");
local _asOrgAddonInclude = path.join(_SCRIPT_DIR, "sdk", "add_on");
local _asNewASInclude = path.join(_asNewIncludeRoot, "angelscript");
local _asNewAddonInclude = path.join(_asNewASInclude, "addon");

project "AngelScript"
    kind "StaticLib"
    language "C++"
    systemversion "latest"
	cppdialect "C++17"
	
    targetdir(ANGELSCRIPT_TARGET_DIR);
    objdir(ANGELSCRIPT_OBJ_DIR);

	newaction {
		trigger = "as_init",
		description = "Initialize AngelScript headers to be under the same angelscript namespace",
		execute = function() _stage_angelscript_headers() end
	}

	newoption {
		trigger = "as_dynamic",
		description = "Set if AngelScript should be compiled as a dynamic library"
	}
	
	newoption {
		trigger = "as_release_compiler",
		description = "Set if AngelScript should include script compilation capabilities in release mode"
	}
	
	newoption {
		trigger = "as_deprecated",
		description = "Set if deprecated functionality should be retained for backwards compatibility"
	}

	for _, key in ipairs(_asAddonList) do
		local addon = _asAddonMap[key];
		newoption {
			trigger = key,
			description = addon.desc
		}
	end

	flags {
		"MultiProcessorCompile"
	}

    files {
		"sdk/angelscript/include/**.h",
		"sdk/angelscript/source/**.h",
		"sdk/angelscript/source/**.c*",
		
		"sdk/angelscript/source/as_callfunc_x64_msvc_asm.asm"
    }
	
	includedirs {
		"sdk/angelscript/include"
	}
	
	defines { "_LIB" }
	
	filter "options:as_dynamic"
		kind "SharedLib"
		defines { "ANGELSCRIPT_EXPORT" }
		
	filter "options:as_deprecated"
		defines { "AS_DEPRECATED" }
	
	filter "configurations:*Debug*"
		defines { "AS_DEBUG", "_DEBUG" }
	
	filter "configurations:*Release*"
		defines { "NDEBUG" }
		
	filter { "configurations:*Release* or configurations:*release*", "options:not as_release_compiler" }
		defines { "AS_NO_COMPILER" }
		
	filter { "files:source/as_callfunc_x64_msvc_asm.asm", "platforms:*64*" }
		buildmessage "AngelScript: Compiling %[%{file.relpath}]"
		buildcommands {
			'ml64.exe /c  /nologo /Fo"%{ANGELSCRIPT_OBJ_DIR}/as_callfunc_x64_msvc_asm.obj" /W3 /Zi /Ta "%{!file.relpath}"'
		}
		buildoutputs {
			"%{ANGELSCRIPT_OBJ_DIR}/as_callfunc_x64_msvc_asm.obj"
		}

	filter {}
	
local _AS = {};
_AS.includes = { _asNewIncludeRoot };
_AS.libdirs = {};
_AS.links = { "AngelScript" };
_AS.defines = {};

for _, key in ipairs(_asAddonList) do
	if (_OPTIONS[key]) then
		local addon = _asAddonMap[key];
		table.insert(_AS.defines, addon.define);
		
		files {
			path.join("sdk/add_on/", addon.path, "**.h"),
			path.join("sdk/add_on/", addon.path, "**.c*")
		}
	end
end

if (_OPTIONS["as_dynamic"]) then
	table.insert(_AS.defines, "ANGELSCRIPT_DLL_LIBRARY_IMPORT");
	table.insert(_AS.defines, "AS_DYNAMIC");
	table.insert(_AS.libdirs, "%{ANGELSCRIPT_TARGET_DIR}");
end

if (_OPTIONS["as_deprecated"]) then
	table.insert(_AS.defines, "AS_DEPRECATED");
end

function _copy_angelscript_files(srcRootPath, dstRootPath)
	local patterns = { "**.h" }
	
	for _, pattern in ipairs(patterns) do
		for _, filePath in ipairs(os.matchfiles(path.join(srcRootPath, pattern))) do
			local relativeSrcPath = path.getrelative(srcRootPath, filePath);
			local dstPath = path.join(dstRootPath, relativeSrcPath);
			
			if (not os.isdir(path.getdirectory(dstPath))) then
				os.mkdir(path.getdirectory(dstPath));
			end
			
			os.copyfile(filePath, dstPath);
		end
	end
end

function _stage_angelscript_headers()	
	if (os.isdir(_asNewASInclude)) then
		print("AngelScript: Removing existing header files");
		os.rmdir(_asNewASInclude);
	end
	
	print("AngelScript: Creating folders for header files");
	os.mkdir(_asNewASInclude);
	os.mkdir(_asNewAddonInclude);
	
	print("AngelScript: Copying AngelScript header to namespace location");
	_copy_angelscript_files(_asOrgASInclude, _asNewASInclude);
	
	print("AngelScript: Copying needed addons headers to namespace location");
	for _, key in ipairs(_asAddonList) do
		local addon = _asAddonMap[key];
		_copy_angelscript_files(path.join(_asOrgAddonInclude, addon.path), path.join(_asNewAddonInclude));
	end
end

function link_angelscript()
	print("AngelScript: Linking into '" .. premake.api.scope.current.name .. "'");

	includedirs(_AS.includes);
	
	if (#_AS.defines > 0) then defines(_AS.defines) end
	if (#_AS.libdirs > 0) then libdirs(_AS.libdirs) end
	if (#_AS.links > 0) then links(_AS.links) end
	
	filter { "configurations:not *release* or options:as_release_compiler", "configurations:not *Release* or options:as_release_compiler" }
		defines { "AS_COMPILER" }
end