import std.stdio : writeln, write;
import std.getopt : getopt, defaultGetoptPrinter;
import gitstatus : GitStatus;
import formatter : Format, DebugFormat, SimpleFormat, MustacheFormat, FORMATTERS;


int main(string[] args)
{
	bool doQuery;
	string formatter_str = "simple";
	auto helpInfo = getopt(
			args,
			"q|query", "Return 1 if there is no git repo.", &doQuery,
			"f|format", "The formatter to use.", &formatter_str
		);
	if (helpInfo.helpWanted)
	{
		defaultGetoptPrinter("Some information about the program.",
			helpInfo.options);
		return 0;
	}

	auto status = new GitStatus();
	Format fmt = null;

    foreach (FormatT; FORMATTERS)
    {
		if (FormatT.name == formatter_str) {
			fmt = new FormatT();
			break;
		}
    }

	if (fmt is null) {
		writeln("Formatter not found.");
		return 1;
	}
	else {
		write(fmt.format(status));
	}
	if (doQuery)
		return status.path?0:1;
	return 0;
}
