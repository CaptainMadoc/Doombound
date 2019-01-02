IBL = {}

function IBL:dumpItem()
    if datamanager and datamanager.uninit then
        pcall(function() datamanager:uninit() end)
    end
    return item.descriptor()
end

function IBL:run(func, ...)
    local x, p = pcall(func, ...)
    if not x then
        sb.logError("Uh Oh looks like we got bit by a bug!")
        sb.logInfo("Captured Item: \n"..sb.printJson(self:dumpItem(), 0).."\n")
        sb.logError(p)
        return x, false
    end
    return x, true
end