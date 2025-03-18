local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_SMALLPLANTS)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_FOOTPRINT)

-- Função para verificar se a posição é válida para andar
function isWalkable(pos)
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
    
    -- Verificar se há criaturas na posição
    local creatures = tile:getCreatures()
    if #creatures > 0 then
        return false
    end
    
    return true
end

-- Função para o movimento do dash
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
    local lookPos = position:getNextPosition(direction)
    
    -- Verificar se a posição para onde o jogador olha é válida para andar
    if isWalkable(lookPos) then
        -- Move o jogador na direção que está olhando
        player:teleportTo(lookPos)
        lookPos:sendMagicEffect(CONST_ME_SMALLPLANTS)
    else
        -- Se não puder se mover, causa dano ao jogador
        player:addHealth(-20)
        position:sendMagicEffect(CONST_ME_POFF)
        player:sendTextMessage(MESSAGE_STATUS, "Você perdeu 20 pontos de vida.")
    end
end

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    local player = creature:getPlayer()
    if not player then
        return false
    end
    
    -- Calculando o número de movimentos para durar 1,5 segundos
    -- Cada movimento ocorre a cada 90ms, então 1500ms / 90ms = aproximadamente 16-17 movimentos
    local movementCount = 17
    
    -- Efeito inicial para mostrar que a magia está sendo lançada
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
    
    for i = 0, movementCount - 1 do
        addEvent(onDash, 90 * i, player:getId(), i)
    end
    
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