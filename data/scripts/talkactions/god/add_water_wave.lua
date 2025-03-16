local addWaterWave = TalkAction("/addwaterwave")

function addWaterWave.onSay(player, words, param)
    -- Verificar se o jogador é um Game Master
    if not player:getGroup():getAccess() then
        return true
    end

    -- Criar log
    logCommand(player, words, param)

    -- Adicionar a magia Water Wave ao jogador
    player:addSpell("Water Wave")
    player:learnSpell("Water Wave")
    
    -- Garantir que o jogador possa usar a magia
    player:setStorageValue(38912, 1) -- Ativar modo de magia GM
    
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "A magia Water Wave foi adicionada ao seu personagem e o modo de magia GM foi ativado.")
    return true
end

addWaterWave:separator(" ")
addWaterWave:groupType("god")
addWaterWave:register() 