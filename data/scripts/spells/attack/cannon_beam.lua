local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_WATERSPLASH)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FISHING)

-- Definindo a área do raio de canhão (formato de linha reta)
local area = {
    {0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 1, 0, 0},
    {0, 0, 3, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0}
}

combat:setArea(createCombatArea(area))

-- Função para calcular o dano baseado no nível e habilidades do jogador
function onGetFormulaValues(player, level, maglevel)
    -- Verificar se é um Game Master
    if player:getGroup():getAccess() then
        return -10, -15 -- Dano maior para Game Masters
    end

    local skillLevel = player:getSkillLevel(SKILL_SWORD)
    if player:getSkillLevel(SKILL_CLUB) > skillLevel then
        skillLevel = player:getSkillLevel(SKILL_CLUB)
    end
    if player:getSkillLevel(SKILL_AXE) > skillLevel then
        skillLevel = player:getSkillLevel(SKILL_AXE)
    end
    
    local min = (level / 4) + (skillLevel * 1.2) + 15
    local max = (level / 4) + (skillLevel * 2.0) + 30
    return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- Função para empurrar uma criatura com delay
function pushCreatureWithDelay(creatureId, newPos, oldPos, delay)
    addEvent(function()
        local creature = Creature(creatureId)
        if creature then
            creature:teleportTo(newPos)
            oldPos:sendMagicEffect(CONST_ME_POFF)
        end
    end, delay)
end

-- Função para aplicar efeito com delay
function applyEffectWithDelay(pos, effect, delay)
    addEvent(function()
        pos:sendMagicEffect(effect)
    end, delay)
end

-- Função para empurrar criaturas atingidas pela magia
function onTargetTile(creature, pos)
    local tile = Tile(pos)
    if not tile then
        return true
    end
    
    local creatures = tile:getCreatures()
    if not creatures or #creatures == 0 then
        return true
    end
    
    local direction = creature:getDirection()
    local casterPos = creature:getPosition()
    
    -- Calcular a distância entre o lançador e o tile alvo
    local distance = 0
    if direction == DIRECTION_NORTH then
        distance = casterPos.y - pos.y
    elseif direction == DIRECTION_EAST then
        distance = pos.x - casterPos.x
    elseif direction == DIRECTION_SOUTH then
        distance = pos.y - casterPos.y
    elseif direction == DIRECTION_WEST then
        distance = casterPos.x - pos.x
    end
    
    -- Calcular o delay com base na distância (50ms por tile - mais rápido)
    local delay = math.abs(distance) * 50
    
    -- Calcular a posição para onde o alvo será empurrado (na direção oposta ao lançador)
    local pushPos = Position(pos.x, pos.y, pos.z)
    if direction == DIRECTION_NORTH then
        pushPos.y = pushPos.y - 2  -- Empurrar mais para o norte
    elseif direction == DIRECTION_EAST then
        pushPos.x = pushPos.x + 2  -- Empurrar mais para o leste
    elseif direction == DIRECTION_SOUTH then
        pushPos.y = pushPos.y + 2  -- Empurrar mais para o sul
    elseif direction == DIRECTION_WEST then
        pushPos.x = pushPos.x - 2  -- Empurrar mais para o oeste
    end
    
    -- Aplicar efeito visual no quadrado com delay
    applyEffectWithDelay(pos, CONST_ME_WATERSPLASH, delay)
    
    for _, target in ipairs(creatures) do
        if target ~= creature and target:isCreature() then
            local targetPos = target:getPosition()
            
            -- Verificar se a posição de empurrão é válida
            local pushTile = Tile(pushPos)
            if pushTile and not pushTile:hasProperty(CONST_PROP_IMMOVABLEBLOCKSOLID) then
                -- Empurrar a criatura para a posição calculada com delay
                pushCreatureWithDelay(target:getId(), pushPos, targetPos, delay + 100)
            end
        end
    end
    
    return true
end

combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    -- Verificar se é um jogador
    if creature:isPlayer() then
        local player = creature
        
        -- Game Masters sempre podem usar a magia
        if player:getGroup():getAccess() then
            return combat:execute(creature, var)
        end
        
        -- Para jogadores normais, verificar vocação
        local vocationId = player:getVocation():getId()
        if vocationId == 4 or vocationId == 8 then -- Knight ou Elite Knight
            return combat:execute(creature, var)
        else
            player:sendCancelMessage("Você não pode usar esta magia.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
    end
    
    return combat:execute(creature, var)
end

spell:group("attack")
spell:id(251) -- ID único para a magia
spell:name("Cannon Beam")
spell:words("w-cannon")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_AVALANCHE_RUNE) -- Som padrão
spell:level(60)
spell:mana(100)
spell:isPremium(true)
spell:needDirection(true)
spell:cooldown(3 * 1000) -- 3 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("knight;true", "elite knight;true")
spell:register() 