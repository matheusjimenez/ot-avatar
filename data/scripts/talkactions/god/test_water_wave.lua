local testWaterWave = TalkAction("/testwaterwave")

function testWaterWave.onSay(player, words, param)
    -- Verificar se o jogador é um Game Master
    if not player:getGroup():getAccess() then
        return true
    end

    -- Criar log
    logCommand(player, words, param)

    -- Ensinar a magia Water Wave ao jogador
    player:learnSpell("Water Wave")
    
    -- Executar a magia diretamente
    local spell = Spell("Water Wave")
    if spell then
        local position = player:getPosition()
        local direction = player:getDirection()
        local variant = {}
        
        if direction == DIRECTION_NORTH then
            position.y = position.y - 1
        elseif direction == DIRECTION_SOUTH then
            position.y = position.y + 1
        elseif direction == DIRECTION_EAST then
            position.x = position.x + 1
        elseif direction == DIRECTION_WEST then
            position.x = position.x - 1
        end
        
        variant.type = VARIANT_POSITION
        variant.pos = position
        
        spell:execute(player, variant)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Magia Water Wave executada com sucesso!")
    else
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Erro ao executar a magia Water Wave.")
    end
    
    return true
end

testWaterWave:separator(" ")
testWaterWave:groupType("god")
testWaterWave:register() 