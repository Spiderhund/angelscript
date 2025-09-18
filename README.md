<p align="center"><img src="https://repository-images.githubusercontent.com/1036687907/6cd0e5bb-3856-4ad1-ac4c-da02be8e3ed7" alt="angelscript logo" width="50%" height="50%"></p>

The AngelCode Scripting Library, or AngelScript as it is also known, is an extremely flexible cross-platform scripting library designed to allow applications to extend their functionality through external scripts. It has been designed from the beginning to be an easy to use component, both for the application programmer and the script writer.

The official repository for AngelScript is: https://github.com/anjo76/angelscript

Please go to https://www.angelcode.com/angelscript for more information.

**This fork contains AngelScript version 2.38.0**

## Premake 5

This fork of AngelScript has been made compatible with the Premake project generator. The following covers how to set it up and link it into your own project.

Pull this into your project as you see fit (git submodule, copy into project).

Run the action `./premake5 as_init`. This will move the AngelScript project header files into a common namespace. That means that in your project, instead of including AngelScript headers like this:

```
#include "angelscript.h"
#include "scriptstdstring.h"
```

You will instead be including them like so:

```
#include "angelscript/angelscript.h"
#include "angelscript/addon/scriptstdstring.h"
```

You will need to run the `as_init` action every time your reinitialize the AngelScript submodule or if you pull in new changes to the AngelScript repository.

Now add any needed options from the list below to your generator CLI.

| Option                     | Description                                                                       |
|----------------------------|-----------------------------------------------------------------------------------|
| as_dynamic                 | Set if AngelScript should be compiled as a dynamic library                        |
| as_release_compiler        | Set if AngelScript should include script compilation capabilities in release mode |
| as_deprecated              | Set if deprecated functionality should be retained for backwards compatibility    |
| as_addon_autowrapper       | Set if the Auto Wrapper add-on should be included                                 |
| as_addon_context_manager   | Set if the Context Manager add-on should be included                              |
| as_addon_date_time         | Set if the Date Time add-on should be included                                    |
| as_addon_debugger          | Set if the Debugger add-on should be included                                     |
| as_addon_script_any        | Set if the Script Any add-on should be included                                   |
| as_addon_script_array      | Set if the Script Array add-on should be included                                 |
| as_addon_script_builder    | Set if the Script Builder add-on should be included                               |
| as_addon_script_dictionary | Set if the Script Dictionary add-on should be included                            |
| as_addon_script_file       | Set if the Script File add-on should be included                                  |
| as_addon_script_grid       | Set if the Script Grid add-on should be included                                  |
| as_addon_script_handle     | Set if the Script Handle add-on should be included                                |
| as_addon_script_helper     | Set if the Script Helper add-on should be included                                |
| as_addon_script_math       | Set if the Script Math add-on should be included                                  |
| as_addon_script_socket     | Set if the Script Socket add-on should be included                                |
| as_addon_script_std_string | Set if the Script Standard String add-on should be included                       |
| as_addon_serializer        | Set if the Serializer add-on should be included                                   |
| as_addon_weak_ref          | Set if the Weak Reference add-on should be included                               |

As an example, if you want to include the script builder and standard string addons, do the following:

```
premake5 vs2022 --as_addon_script_builder --as_addon_script_std_string
```

Now make sure to include the AngelScript project in your workspace, include it before any projects that need to link with AngelScript. Also, make sure to define these two variables before you include AngelScript:

```
ANGELSCRIPT_TARGET_DIR = "%{!wks.location}/bin/angelscript"; -- This sets the path where the AngelScript static library will be built to
ANGELSCRIPT_OBJ_DIR = "%{!wks.location}/obj/angelscript";    -- This sets the path where the intermediate object files will be stored
```

These tell the AngelScript project where to build the library to and where to store intermediate files. At this point you can include AngelScript into your workspace:

```
include "libs/angelscript"; -- Include the AngelScript project into your workspace
include "myproject"; -- Include the project which needs to link with AngelScript
```

Once this is done, jump into your project file and call `link_angelscript()` to automatically set up include directories, lib directories (if needed), defines, and links within your project. Like so:

```
project "MyProject"
	kind "ConsoleApp"
    language "C++"
    systemversion "latest"
	cppdialect "C++17"
	
	link_angelscript()
```

It is worth noting that the AngelScript project expects you to have configurations including either "debug", "Debug", "release", or "Release" somewhere in their names. As well as platforms including 32, 64, or 86. Examples:

```
configurations { "Debug", "Release", "RuntimeDebug", "RuntimeRelease", "DebugEditor", "ReleaseEditor" }
platforms { "win32", "win64", "x86", "x64" }
```

These configuration and platform patterns are used to properly compile AngelScript in debug and release mode, for either 32 or 64 bit systems.

Generate or regenerate your project files and you should be good to go.

### Defines

These defines will possibly be set within your projects linking with AngelScript.

| Define                       | Description                                                                       |
|------------------------------|-----------------------------------------------------------------------------------|
| `AS_DYNAMIC`                 | AngelScript is compiled and linked as a dynamic library                           |
| `AS_COMPILER`                | AngelScript is compiled with script compilation capabilities                      |
| `AS_DEPRECATED`              | AngelScript is compiled with deprecated functionality for backwards compatibility |
| `AS_ADDON_AUTO_WRAPPER`      | The Auto Wrapper addon is available                                               |
| `AS_ADDON_CONTEXT_MANAGER`   | The Context Manager addon is available                                            |
| `AS_ADDON_DATE_TIME`         | The Date Time addon is available                                                  |
| `AS_ADDON_DEBUGGER`          | The Debugger addon is available                                                   |
| `AS_ADDON_SCRIPT_ANY`        | The Script Any addon is available                                                 |
| `AS_ADDON_SCRIPT_ARRAY`      | The Script Array addon is available                                               |
| `AS_ADDON_SCRIPT_BUILDER`    | The Script Builder addon is available                                             |
| `AS_ADDON_SCRIPT_DICTIONARY` | The Script Dictionary addon is available                                          |
| `AS_ADDON_SCRIPT_FILE`       | The Script File addon is available                                                |
| `AS_ADDON_SCRIPT_GRID`       | The Script Grid addon is available                                                |
| `AS_ADDON_SCRIPT_HANDLE`     | The Script Handle addon is available                                              |
| `AS_ADDON_SCRIPT_HELPER`     | The Script Helper addon is available                                              |
| `AS_ADDON_SCRIPT_MATH`       | The Script Math addon is available                                                |
| `AS_ADDON_SCRIPT_SOCKET`     | The Script Socket addon is available                                              |
| `AS_ADDON_SCRIPT_STD_STRING` | The Script Standard String addon is available                                     |
| `AS_ADDON_SERIALIZER`        | The Serializer addon is available                                                 |
| `AS_ADDON_WEAK_REFERENCE`    | The Weak Reference addon is available                                             |

### Todo

Implement support for more platforms. Currently this project only supports Windows.