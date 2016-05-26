string = require("string")

return string.format(
[[
local git_path="%s"
local git_branch="%s"
local git_tag="%s"
local git_hash="%s"
local git_hash_short="%s"
local git_ahead="%s"
local git_behind="%s"
local git_new_files="%s"
local git_index_files="%s"
local git_working_files="%s"
local git_stash="%s"
local git_state="%s"
local git_state_name="%s"
]],
status.path,
status.branch,
status.tag,
status.hash,
status.hash_short,
status.ahead,
status.behind,
status.new_files,
status.index_files,
status.working_files,
status.stash,
status.state,
status.state_name
)
