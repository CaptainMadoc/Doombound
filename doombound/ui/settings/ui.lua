widgets = {}

gbSettings = {
    crosshairColor = {255,255,255},
    autoReload = true,
    cameraPan = true
}

function call(wid)
    if widgets[wid] then
        widgets[wid]()
    end
end

function init()
    local loadedSettings = status.statusProperty("gbSettings", {})
    gbSettings = sb.mergeJson(gbSettings, loadedSettings)

end

function saveConfig()
    status.setStatusProperty("gbSettings", gbSettings)
end

function update(dt)

end