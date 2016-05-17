import std.stdio : writeln, write;
import std.getopt : getopt, defaultGetoptPrinter;
import std.concurrency : send, receiveTimeout, ownerTid, spawn;
import core.time : dur, Duration;
import gitstatus : GitStatus;
import formatter : Format, FORMATTERS;


GitStatus gitStatusTimeout(in Duration d) {
	static GitStatus create() {
		return new GitStatus();
	}

	static void thread() {
		shared GitStatus status = cast(shared) create();
		send(ownerTid, status);
	}

	GitStatus status;

	if (dur!"seconds"(0) == d){
		status = create();
	}
	else {
		spawn(&thread);
		receiveTimeout(d, (shared GitStatus _status){status=cast(GitStatus)_status;});
	}

	return status;
}


int main(string[] args)
{
	bool doQuery;
	float timeout = 0;
	string formatter_str = "descriptive";
	auto helpInfo = getopt(
			args,
			"q|query", "Return 1 if there is no git repo.", &doQuery,
			"f|format", "The formatter to use.", &formatter_str,
			"t|timeout", "Timeout as decimal seconds.", &timeout,
		);
	if (helpInfo.helpWanted)
	{
		defaultGetoptPrinter("Some information about the program.",
			helpInfo.options);
		return 0;
	}

	auto status = gitStatusTimeout(dur!"msecs"(cast(int) (timeout*1000)));
	if (status is null)
		return 0;
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
