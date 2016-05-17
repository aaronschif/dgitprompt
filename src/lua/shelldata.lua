result = ""

-- if status.path
-- then
--     if status.branch then result = result .. status.branch
--         else if status.tag then result = result .. status.tag
--             else if status.hash_short then result = result .. status.hash_short
--             end end end
--
--     if status.ahead > 0 then result = result .. "▲" .. status.ahead end
--     if status.behind > 0 then result = result .. "▼" .. status.behind end
--     if status.new_files > 0 then result = result .. "□" .. status.new_files end
--     if status.index_files > 0 then result = result .. "■" .. status.index_files end
--     if status.working_files > 0 then result = result .. "▣" .. status.working_files end
--     if status.stash > 0 then result = result .. "▷" .. status.stash end
--     if status.state > 0 then result = result .. "◊" .. status.state end
-- end

function add(key, val)
    result = result .. "local git_" .. key .. "=" .. val .. "\n"
end

add("path", status.path)

add("branch", status.branch)
add("tag", status.tag)
add("hash", status.hash)
add("hash_short", status.hash_short)

add("ahead", status.ahead)
add("behind", status.behind)
add("new_files", status.new_files)
add("index_files", status.index_files)
add("working_files", status.working_files)
add("stash", status.stash)
add("state", status.state)
add("state_name", status.state_name)


return result
