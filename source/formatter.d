import std.typetuple: TypeTuple;

import gitstatus: GitStatus;
import luad.all: LuaState, LuaFunction, LuaTable;
import luad.error: LuaErrorException;

alias FORMATTERS = TypeTuple!(DescriptiveFormat, ShellDataFormat);


abstract class Format {
    immutable static string name;
    string format (ref GitStatus status);
}

class DescriptiveFormat: Format {
    immutable static string name = "descriptive";
    override string format(ref GitStatus status) {
        auto lua = new LuaState();
        lua.openLibs();
        auto prompt_function = getLuaFunc(lua);
        auto luaStatus = lua.newTable;
        lua.set("status", luaStatus);
        luaStatus["path"] = status.path;
        luaStatus["branch"] = status.branch;
        luaStatus["tag"] = status.tag;
        luaStatus["hash"] = status.hash;
        luaStatus["hash_short"] = status.hash_short;
        luaStatus["new_files"] = status.new_files;
        luaStatus["working_files"] = status.working_files;
        luaStatus["index_files"] = status.index_files;
        luaStatus["ahead"] = status.ahead;
        luaStatus["behind"] = status.behind;
        luaStatus["state"] = status.state;
        luaStatus["state_name"] = status.state_name;
        luaStatus["stash"] = status.stash;

        try {
            return prompt_function.call!string();
        }
        catch (LuaErrorException e) {
            throw e;
        }
    }

    LuaFunction getLuaFunc(LuaState lua) {
        return lua.loadString(import("lua/simple.lua"));
    }
}

class ShellDataFormat: DescriptiveFormat {
    immutable static string name = "shelldata";
    override LuaFunction getLuaFunc(LuaState lua) {
        return lua.loadString(import("lua/shelldata.lua"));
    }
}


class FileFormat: DescriptiveFormat {
    immutable static string name = "file";
    string path = "";

    this(string path) {
        this.path = path;
    }

    override LuaFunction getLuaFunc(LuaState lua) {
        return lua.loadFile(path);
    }
}
