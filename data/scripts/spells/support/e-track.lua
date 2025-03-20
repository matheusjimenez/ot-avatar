local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_SMALLPLANTS)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_FOOTPRINT)

-- Função para verificar se a posição é válida para andar
function isWalkable(pos, playerId)
    local tile = Tile(pos)
    if not tile then
        return false
    end
    
    -- Verificar se o tile está bloqueado
    if tile:hasProperty(CONST_PROP_BLOCKSOLID) or 
       tile:hasProperty(CONST_PROP_BLOCKPATH) or 
       tile:hasProperty(CONST_PROP_IMMOVABLEBLOCKSOLID) or
       tile:hasProperty(CONST_PROP_IMMOVABLEBLOCKPATH) then
        return false
    end
    
    -- Verificar se é uma protection zone
    if tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        return false
    end
    
    -- Verificar se há criaturas na posição
    local creatures = tile:getCreatures()
    if #creatures > 0 then
        -- Se só tiver uma criatura e for o próprio jogador, permite o movimento
        if playerId and #creatures == 1 and creatures[1]:getId() == playerId then
            return true
        end
        return false
    end
    
    return true
end

-- Função para o movimento do dash (versão simplificada)
function onDash(cid, count)
    local creature = Creature(cid)
    if not creature then
        return
    end
    
    local player = creature:getPlayer()
    if not player then
        return
    end
    
    local position = player:getPosition()
    local direction = player:getDirection()
    
    -- Calcular próxima posição manualmente
    local lookPos = {x = position.x, y = position.y, z = position.z}
    if direction == DIRECTION_NORTH then
        lookPos.y = lookPos.y - 1
    elseif direction == DIRECTION_SOUTH then
        lookPos.y = lookPos.y + 1
    elseif direction == DIRECTION_EAST then
        lookPos.x = lookPos.x + 1
    elseif direction == DIRECTION_WEST then
        lookPos.x = lookPos.x - 1
    end
    
    -- Verificar se a posição de destino é válida
    local destPos = Position(lookPos.x, lookPos.y, lookPos.z)
    if isWalkable(destPos, player:getId()) then
        -- Tentar mover o jogador
        player:teleportTo(destPos)
        destPos:sendMagicEffect(CONST_ME_SMALLPLANTS)
    else
        -- Se não puder se mover, causa dano ao jogador
        player:addHealth(-20)
        position:sendMagicEffect(CONST_ME_POFF)
        player:sendTextMessage(MESSAGE_STATUS, "Você perdeu 20 pontos de vida.")
    end
end

-- Função para mostrar o efeito de canalização
function showChannelingEffect(playerId)
    local player = Player(playerId)
    if not player then
        return
    end
    
    local position = player:getPosition()
    
    -- Efeitos variados relacionados à terra
    local effects = {
        CONST_ME_SMALLPLANTS,
        CONST_ME_GROUNDSHAKER,
        CONST_ME_STONES,
        CONST_ME_HITBYPOISON,
        CONST_ME_POISONAREA
    }
    
    -- Efeito principal na posição do jogador
    position:sendMagicEffect(effects[math.random(1, #effects)])
    
    -- Efeitos adicionais em um raio de 1 sqm ao redor do jogador
    for x = -1, 1 do
        for y = -1, 1 do
            if x ~= 0 or y ~= 0 then -- Não repetir na posição central
                local effectPos = Position(position.x + x, position.y + y, position.z)
                -- 40% de chance de mostrar um efeito nos tiles vizinhos
                if math.random(1, 100) <= 40 then
                    effectPos:sendMagicEffect(effects[math.random(1, #effects)])
                end
            end
        end
    end
    
    -- Adicionar tremor no chão e efeito sonoro
    if math.random(1, 100) <= 50 then
        position:sendMagicEffect(CONST_ME_GROUNDSHAKER)
    end
end

-- Função para verificar movimento durante canalização
function checkPlayerMovement(playerId, startPos)
    local player = Player(playerId)
    if not player then
        return false
    end
    
    local currentPos = player:getPosition()
    
    -- Verifica se o jogador se moveu
    if currentPos.x ~= startPos.x or currentPos.y ~= startPos.y or currentPos.z ~= startPos.z then
        return false
    end
    
    return true
end

-- Função para iniciar o dash após a canalização
function startDashAfterChanneling(playerId, startPos)
    local player = Player(playerId)
    if not player then
        return
    end
    
    -- Verifica se o jogador ainda está na mesma posição
    if not checkPlayerMovement(playerId, startPos) then
        player:sendTextMessage(MESSAGE_STATUS, "Sua magia foi interrompida porque você se moveu.")
        return
    end
    
    -- Verificar se o jogador está em uma protection zone
    local tile = Tile(player:getPosition())
    if tile and tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        player:sendTextMessage(MESSAGE_STATUS, "Você não pode usar esta magia em uma zona de proteção.")
        return
    end
    
    -- Efeito explosivo final antes de começar o dash
    local position = player:getPosition()
    for x = -2, 2 do
        for y = -2, 2 do
            local effectPos = Position(position.x + x, position.y + y, position.z)
            addEvent(function() 
                effectPos:sendMagicEffect(CONST_ME_SMALLPLANTS)
            end, math.random(0, 200))
        end
    end
    position:sendMagicEffect(CONST_ME_BIGPLANTS)
    
    -- Calculando o número de movimentos para durar 1,5 segundos
    -- Cada movimento ocorre a cada 90ms, então 1500ms / 90ms = aproximadamente 16-17 movimentos
    local movementCount = 17
    
    for i = 0, movementCount - 1 do
        addEvent(onDash, 90 * i, playerId, i)
    end
    
    -- Remover a condição de paralisia
    player:removeCondition(CONDITION_PARALYZE)
end

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    local player = creature:getPlayer()
    if not player then
        return false
    end
    
    -- Verificar se o jogador está em uma protection zone
    local tile = Tile(player:getPosition())
    if tile and tile:hasFlag(TILESTATE_PROTECTIONZONE) then
        player:sendTextMessage(MESSAGE_STATUS, "Você não pode usar esta magia em uma zona de proteção.")
        return false
    end
    
    -- Armazenar a posição inicial do jogador
    local startPos = player:getPosition()
    
    -- Efeito inicial ao começar a canalizar
    local position = player:getPosition()
    position:sendMagicEffect(CONST_ME_MAGIC_GREEN)
    
    -- Criar um círculo de energia verde ao redor do jogador
    for x = -1, 1 do
        for y = -1, 1 do
            if math.abs(x) == 1 or math.abs(y) == 1 then
                local effectPos = Position(position.x + x, position.y + y, position.z)
                effectPos:sendMagicEffect(CONST_ME_SMALLPLANTS)
            end
        end
    end
    
    -- Aplicar condição de paralisia por 3 segundos
    local condition = Condition(CONDITION_PARALYZE)
    condition:setParameter(CONDITION_PARAM_TICKS, 3000) -- 3 segundos
    condition:setFormula(-1, 0, -1, 0)
    player:addCondition(condition)
    
    -- Informar ao jogador
    player:sendTextMessage(MESSAGE_STATUS, "Você está canalizando a energia da terra. Não se mova por 3 segundos.")
    
    -- Mostrar efeitos visuais durante a canalização com mais frequência para melhor visual
    for i = 0, 12 do -- Aumentei o número de efeitos (a cada 250ms)
        addEvent(showChannelingEffect, i * 250, player:getId())
    end
    
    -- Verificar se o jogador se moveu durante a canalização
    for i = 1, 2 do
        addEvent(function()
            if not checkPlayerMovement(player:getId(), startPos) then
                player:sendTextMessage(MESSAGE_STATUS, "Verificando se você se moveu...")
            end
        end, i * 1000)
    end
    
    -- Iniciar o dash após o período de canalização (3 segundos)
    addEvent(startDashAfterChanneling, 3000, player:getId(), startPos)
    
    return true
end

spell:group("support")
spell:id(251) -- ID único para a magia
spell:name("Earth Track")
spell:words("e-track")
spell:level(30)
spell:mana(80)
spell:isPremium(true)
spell:cooldown(10 * 1000) -- 10 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("sorcerer;true", "druid;true", "knight;true", "paladin;true")
spell:register() 