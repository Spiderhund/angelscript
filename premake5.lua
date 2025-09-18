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
_asAddonMap[_asAddonList[3]] = { path = "contextmgr", define = "AS_ADDON_CONTEXT_MANAGER", desc = "Set if the Context Manager add-on should be included" };
_asAddonMap[_asAddonList[4]] = { path = "datetime", define = "AS_ADDON_DATE_TIME", desc = "Set if the Date Time add-on should be included" };
_asAddonMap[_asAddonList[5]] = { path = "debugger", define = "AS_ADDON_DEBUGGER", desc = "Set if the Debugger add-on should be included" };
_asAddonMap[_asAddonList[6]] = { path = "scriptany", define = "AS_ADDON_SCRIPT_ANY", desc = "Set if the Script Any add-on should be included" };
_asAddonMap[_asAddonList[7]] = { path = "scriptarray", define = "AS_ADDON_SCRIPT_ARRAY", desc = "Set if the Script Array add-on should be included" };
_asAddonMap[_asAddonList[8]] = { path = "scriptbuilder", define = "AS_ADDON_SCRIPT_BUILDER", desc = "Set if the Script Builder add-on should be included" };
_asAddonMap[_asAddonList[9]] = { path = "scriptdictionary", define = "AS_ADDON_SCRIPT_DICTIONARY", desc = "Set if the Script Dictionary add-on should be included" };
_asAddonMap[_asAddonList[10]] = { path = "scriptfile", define = "AS_ADDON_SCRIPT_FILE", desc = "Set if the Script File add-on should be included" };
_asAddonMap[_asAddonList[11]] = { path = "scriptgrid", define = "AS_ADDON_SCRIPT_GRID", desc = "Set if the Script Grid add-on should be included" };
_asAddonMap[_asAddonList[12]] = { path = "scripthandle", define = "AS_ADDON_SCRIPT_HANDLE", desc = "Set if the Script Handle add-on should be included" };
_asAddonMap[_asAddonList[13]] = { path = "scripthelper", define = "AS_ADDON_SCRIPT_HELPER", desc = "Set if the Script Helper add-on should be included" };
_asAddonMap[_asAddonList[14]] = { path = "scriptmath", define = "AS_ADDON_SCRIPT_MATH", desc = "Set if the Script Math add-on should be included" };
_asAddonMap[_asAddonList[15]] = { path = "scriptsocket", define = "AS_ADDON_SCRIPT_SOCKET", desc = "Set if the Script Socket add-on should be included" };
_asAddonMap[_asAddonList[16]] = { path = "scriptstdstring", define = "AS_ADDON_SCRIPT_STD_STRING", desc = "Set if the Script Standard String add-on should be included" };
_asAddonMap[_asAddonList[17]] = { path = "serializer", define = "AS_ADDON_SERIALIZER", desc = "Set if the Serializer add-on should be included" };
_asAddonMap[_asAddonList[18]] = { path = "weakref", define = "AS_ADDON_WEAK_REFERENCE", desc = "Set if the Weak Reference add-on should be included" };

project "AngelScript"
    kind "StaticLib"
    language "C++"
    systemversion "latest"
	cppdialect "C++17"
	
    targetdir(ANGELSCRIPT_TARGET_DIR);
    objdir(ANGELSCRIPT_OBJ_DIR);

	newaction {
		trigger = "as_stage",
		description = "Stage AngelScript headers to be under the same angelscript namespace",
		execute = _stage_angelscript_headers
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
        "include/**.h",
		"source/**.h",
        "source/**.c*",
		"source/as_callfunc_x64_msvc_asm.asm"
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
	
	filter { "configurations:not *release* or options:as_release_compiler", "configurations:not *Release* or options:as_release_compiler" }
		defines { "AS_COMPILER" }
		
	filter { "files:source/as_callfunc_x64_msvc_asm.asm", "platforms:*64*" }
		buildmessage "AngelScript: Compiling %[%{file.relpath}]"
		buildcommands {
			'ml64.exe /c  /nologo /Fo"%{ANGELSCRIPT_OBJ_DIR}/as_callfunc_x64_msvc_asm.obj" /W3 /Zi /Ta "%{!file.relpath}"'
		}
		buildoutputs {
			"%{ANGELSCRIPT_OBJ_DIR}/as_callfunc_x64_msvc_asm.obj"
		}

local _AS = {};
_AS.includes = { "%{!prj.location}/sdk/angelscript/include" };
_AS.libdirs = {};
_AS.links = { "AngelScript" };
_AS.defines = {};

for _, key in ipairs(_asAddonList) do
	if (_OPTIONS[key]) then
		local addon = _asAddonMap[key];
		table.insert(_AS.includes, "%{!prj.location}/sdk/add_on/%{addon.path}");
		table.insert(_AS.defines, addon.define);
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

function _stage_angelscript_headers()
	local orgPath = "%{!prj.location}/sdk";
	local orgASInclude = "%{orgPath}/angelscript/include";
	local orgAddonInclude = "%{orgPath}/add_on";
	local newRootPath = "%{!prj.location}/include/angelscript";
	
	print(orgPath);
	print(orgASInclude);
	print(orgAddonInclude);
	print(newRootPath);
	
	-- os.mkdir("%{!prj.location}/include/angelscript");
	-- os.mkdir("%{!prj.location}/include/angelscript/addon");
end

function link_angelscript()
	includedirs(_AS.includes);
	
	if (#_AS.defines > 0) then defines(_AS.defines) end
	if (#_AS.libdirs > 0) then libdirs(_AS.libdirs) end
	if (#_AS.links > 0) then links(_AS.links) end
end