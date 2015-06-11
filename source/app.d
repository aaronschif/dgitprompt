import std.stdio : writeln, write;
import std.getopt : getopt, defaultGetoptPrinter;
import temple;
import mustache;

import gitstatus : GitStatus;


void print_simple(GitStatus status) {
	auto ctx = new TempleContext();
	auto temp = compile_temple_file!"simple.emd";

	ctx.status = status;
	write(temp.toString(ctx));
}

void print_mustache(GitStatus status) {
	alias MustacheEngine!(string) Mustache;
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


	write(mustache.render("src/mustache/simple", context));
}

void print_debug(GitStatus status) {
	auto ctx = new TempleContext();
	auto temp = compile_temple_file!"debug.emd";

	ctx.status = status;
	write(temp.toString(ctx));
}

int main(string[] args)
{
	bool doQuery;
	string formatter = "simple";
	auto helpInfo = getopt(
			args,
			"q|query", "Return 1 if there is no git repo.", &doQuery,
			"f|format", "The formatter to use.", &formatter
		);
	if (helpInfo.helpWanted)
	{
		defaultGetoptPrinter("Some information about the program.",
			helpInfo.options);
		return 0;
	}

	auto status = new GitStatus();
	switch(formatter) {
		case "debug":
			print_debug(status);
			break;
		case "simple":
			print_simple(status);
			break;
		case "mustache":
			print_mustache(status);
			break;
		default:
			writeln("Formatter not found.");
			break;
	}
	if (doQuery)
		return status.path?0:1;
	return 0;
}
