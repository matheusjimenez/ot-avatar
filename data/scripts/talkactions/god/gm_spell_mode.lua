local gmSpellMode = TalkAction("/gmspellmode")

function gmSpellMode.onSay(player, words, param)
    -- Verificar se o jogador é um Game Master
    if not player:getGroup():getAccess() then
        return true
    end

    -- Criar log
    logCommand(player, words, param)

    -- Alternar o modo de magia para Game Masters
    local currentValue = player:getStorageValue(38912) -- Storage específico para este recurso
    
    if currentValue == 1 then
        player:setStorageValue(38912, 0)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Modo de magia GM desativado. Você agora está sujeito às restrições normais de vocação.")
    else
        player:setStorageValue(38912, 1)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Modo de magia GM ativado. Você pode usar qualquer magia independentemente da vocação.")
    end
    
    return true
end

gmSpellMode:separator(" ")
gmSpellMode:groupType("god")
gmSpellMode:register() 