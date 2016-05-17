result = ""

if status.path
then
    if status.branch ~= "" then result = result .. status.branch
    else if status.tag ~= "" then result = result .. status.tag
    else if status.hash_short ~= "" then result = result .. status.hash_short
            end end end

    if status.ahead > 0 then result = result .. "▲" .. status.ahead end
    if status.behind > 0 then result = result .. "▼" .. status.behind end
    if status.new_files > 0 then result = result .. "□" .. status.new_files end
    if status.index_files > 0 then result = result .. "■" .. status.index_files end
    if status.working_files > 0 then result = result .. "▣" .. status.working_files end
    if status.stash > 0 then result = result .. "▷" .. status.stash end
    if status.state > 0 then result = result .. "◊" .. status.state_name end
end

return result
