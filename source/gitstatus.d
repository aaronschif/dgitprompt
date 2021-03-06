import std.string: toStringz;
import std.file: FileException, isDir, exists;
import std.conv: to;
import std.path: dirName, rootName, absolutePath, buildPath;

import c.git;


class GitStatus
{
	this() {
		path = findGitPath();

		if (path) {
			find_status(&cstatus, toStringz(path));
		}
	}

	const string path;

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

	const string[] STATES = ["NONE", "MERGE", "REVERT", "CHERRYPICK", "BISECT", "REBASE",
	    "INTERACTIVE", "REBASE_MERGE", "MAILBOX", "MAILBOX_OR_REBASE"];

	auto findGitPath() {
		string currentDir, root;
		try {
			currentDir = absolutePath(".");
			root = rootName(currentDir);
		}
		catch (FileException) {
			return null;
		} // Folder might not exist.

		while (currentDir != root) {
			string gitPath = buildPath(currentDir, ".git");
			if (gitPath.exists && gitPath.isDir)
				return gitPath;
			currentDir = dirName(currentDir);
		}

		return null;
	}
}
