import std.string : toStringz;
import pathlib;

import c.git;


class GitStatus
{
	this() {
		path = findGitPath();

		if (path) {
			find_status(&cstatus, toStringz(path));
		}
	}

	string path;

	@property string branch() {
		return to!string(cstatus.branch);
	}

	@property string tag() {
		return to!string(cstatus.tag);
	}

	@property string hash() {
		return to!string(cstatus.hash);
	}

	@property string hash_short() {
		auto result = hash();
		return result?result[0..5]:"";
	}

	@property int new_files() {
		return cstatus.new_files;
	}

	@property int working_files() {
		return cstatus.working_files;
	}

	@property int index_files() {
		return cstatus.index_files;
	}

	@property size_t ahead() {
		return cstatus.ahead;
	}

	@property size_t behind() {
		return cstatus.behind;
	}

	@property int state() {
		return cstatus.state;
	}

	@property string state_name() {
		return STATES[state];
	}

	@property int stash() {
		return cstatus.stash;
	}

	private:
	private CGitStatus cstatus;

	string[] STATES = ["NONE", "MERGE", "REVERT", "CHERRYPICK", "BISECT", "REBASE",
	    "INTERACTIVE", "REBASE_MERGE", "MAILBOX", "MAILBOX_OR_REBASE"];

	auto findGitPath() {
		auto currentDir = cwd();
		foreach(path; currentDir.parents ~ currentDir) {
			auto gitPath = path ~ ".git";
			if (gitPath.isDir)
				return path.toString();
		}
		return null;
	}
}
