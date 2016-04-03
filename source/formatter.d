import std.typetuple: TypeTuple;

import temple;
import mustache;
import gitstatus: GitStatus;

alias FORMATTERS = TypeTuple!(SimpleFormat, DebugFormat, MustacheFormat);


abstract class Format {
    immutable static string name;
    string format (ref GitStatus status);
}

class DebugFormat: Format {
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
