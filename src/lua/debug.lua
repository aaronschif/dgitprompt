string = require("string")

return string.format(
[[Path:      %s
Branch:    %s
Hash:      %s
Tag:       %s
State:     %s
Ahead:     %s
Behind:    %s
Files
    New:       %s
    Index:     %s
    Working:   %s
]],
status.path,
status.branch,
status.hash,
status.tag,
status.state,
status.ahead,
status.behind,

status.new_files,
status.index_files,
status.working_files
)
