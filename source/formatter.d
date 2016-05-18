import std.typetuple: TypeTuple;

/*import temple;*/
import mustache;
import gitstatus: GitStatus;
import luad.all: LuaState, LuaFunction, LuaTable;
import luad.error: LuaErrorException;

alias FORMATTERS = TypeTuple!(MustacheFormat, DescriptiveFormat, ShellDataFormat);


abstract class Format {
    immutable static string name;
    string format (ref GitStatus status);
}

/*class DebugFormat: Format {
    immutable static string name = "debug";
    override string format (ref GitStatus status) {
        auto ctx = new TempleContext();
        auto temp = compile_temple_file!"debug.emd";

        ctx.status = status;
        return temp.toString(ctx);
    }
}

class SimpleFormat: Format {
    immutable static string name = "simple";
    override string format (ref GitStatus status) {
        auto ctx = new TempleContext();
        auto temp = compile_temple_file!"simple.emd";

        ctx.status = status;
        return temp.toString(ctx);
    }
}
*/

class MustacheFormat: Format {
    immutable static string name = "mustache";
    override string format (ref GitStatus status) {
        alias Mustache = MustacheEngine!(string);
    	Mustache mustache;
        auto context = new Mustache.Context;

    	if (status.path) context.useSection("GIT");

    	if (status.branch) context.useSection("BRANCH");
    	context["branch"] = status.branch;

    	if (status.tag) context.useSection("TAG");
    	context["tag"] = status.tag;

    	if (status.state) context.useSection("STATE");
    	context["state_string"] = status.state_name;
    	context["state"] = status.state;

    	if (status.new_files) context.useSection("NEW");
    	context["new"] = status.new_files;

    	if (status.working_files) context.useSection("WORKING");
    	context["working"] = status.working_files;

    	if (status.index_files) context.useSection("INDEX");
    	context["index"] = status.index_files;

    	if (status.ahead) context.useSection("AHEAD");
    	context["ahead"] = status.ahead;

    	if (status.behind) context.useSection("BEHIND");
    	context["behind"] = status.behind;

    	if (status.stash) context.useSection("STASH");
    	context["stash"] = status.stash;


    	return mustache.render("src/mustache/simple", context);
    }
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
