local combat = {}

-- Funções de dano para cada etapa do chicote
local function calcDamage1(player, level, maglevel)
    return (20 + level * 0.4 + maglevel * 0.4), -(22 + level * 0.5 + maglevel * 0.5)
end

local function calcDamage2(player, level, maglevel)
    return (18 + level * 0.3 + maglevel * 0.3), -(20 + level * 0.4 + maglevel * 0.4)
end

-- Criação dos objetos de combate para cada etapa
for i = 1, 12 do
    combat[i] = Combat()
    combat[i]:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
    combat[i]:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_TELEPORT) -- Efeito de teleporte
    
    -- Define a função de cálculo de dano
    if i == 1 then
        combat[i]:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "calcDamage1")
    else
        combat[i]:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "calcDamage2")
    end
end

-- Áreas dinâmicas do chicote para cada direção
local areasNorth = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 1, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [3] = createCombatArea({
        {0, 1, 1, 1, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    })
}

local areasEast = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 1, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0},
        {0, 0, 3, 1, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [3] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0},
        {0, 0, 3, 1, 0},
        {0, 0, 0, 1, 0},
        {0, 0, 0, 0, 0}
    })
}

local areasSouth = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 1, 0, 0}
    }),
    [3] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 1, 1, 1, 0}
    })
}

local areasWest = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 1, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 1, 0, 0, 0},
        {0, 1, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [3] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 1, 0, 0, 0},
        {0, 1, 3, 0, 0},
        {0, 1, 0, 0, 0},
        {0, 0, 0, 0, 0}
    })
}

-- Padrões avançados do chicote para a sequência final
local advancedAreasNorth = {
    [1] = createCombatArea({
        {0, 0, 1, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 1, 1, 1, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [3] = createCombatArea({
        {1, 1, 0, 1, 1},
        {0, 1, 1, 1, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    })
}

local advancedAreasEast = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0},
        {0, 0, 3, 1, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0},
        {0, 0, 3, 1, 1},
        {0, 0, 0, 1, 0},
        {0, 0, 0, 0, 0}
    }),
    [3] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 1, 1},
        {0, 0, 3, 1, 0},
        {0, 0, 0, 1, 1},
        {0, 0, 0, 0, 0}
    })
}

local advancedAreasSouth = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 0, 1, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 0, 1, 0, 0},
        {0, 1, 1, 1, 0}
    }),
    [3] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 3, 0, 0},
        {0, 1, 1, 1, 0},
        {1, 1, 0, 1, 1}
    })
}

local advancedAreasWest = {
    [1] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 1, 0, 0, 0},
        {0, 1, 3, 0, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [2] = createCombatArea({
        {0, 0, 0, 0, 0},
        {0, 1, 0, 0, 0},
        {1, 1, 3, 0, 0},
        {0, 1, 0, 0, 0},
        {0, 0, 0, 0, 0}
    }),
    [3] = createCombatArea({
        {0, 0, 0, 0, 0},
        {1, 1, 0, 0, 0},
        {0, 1, 3, 0, 0},
        {1, 1, 0, 0, 0},
        {0, 0, 0, 0, 0}
    })
}

-- Função para executar cada etapa do chicote
local function castStep(parameters)
    local cid = parameters.cid
    local step = parameters.step
    local dir = parameters.dir
    local sequential = parameters.sequential
    local advanced = parameters.advanced or false
    
    local creature = Creature(cid)
    if not creature then
        return
    end
    
    -- Define a área baseada na direção
    local combatIndex = sequential and step or 1
    if dir == DIRECTION_NORTH then
        if advanced then
            combat[combatIndex]:setArea(advancedAreasNorth[step])
        else
            combat[combatIndex]:setArea(areasNorth[step])
        end
    elseif dir == DIRECTION_EAST then
        if advanced then
            combat[combatIndex]:setArea(advancedAreasEast[step])
        else
            combat[combatIndex]:setArea(areasEast[step])
        end
    elseif dir == DIRECTION_SOUTH then
        if advanced then
            combat[combatIndex]:setArea(advancedAreasSouth[step])
        else
            combat[combatIndex]:setArea(areasSouth[step])
        end
    elseif dir == DIRECTION_WEST then
        if advanced then
            combat[combatIndex]:setArea(advancedAreasWest[step])
        else
            combat[combatIndex]:setArea(areasWest[step])
        end
    end
    
    -- Executa o combate
    combat[combatIndex]:execute(creature, Variant(creature:getPosition()))
end

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    local player = creature:getPlayer()
    if not player then
        return false
    end
    
    -- Storage para controlar a sequência do chicote
    local storage = 48505
    local sequence = player:getStorageValue(storage)
    local direction = player:getDirection()
    
    -- Gerar parâmetros para as funções de casting
    local parameters = {
        cid = creature:getId(),
        dir = direction,
        sequential = false
    }
    
    -- Executar a sequência apropriada baseada no storage
    if sequence == -1 then
        -- Primeira sequência - um chicote básico em 3 etapas
        for i = 1, 3 do
            parameters.step = i
            addEvent(castStep, i * 150, parameters)
        end
        
        player:setStorageValue(storage, 0)
        addEvent(function() 
            if player:isCreature() then
                player:setStorageValue(storage, -1)
            end
        end, 5 * 1000)
        
    elseif sequence == 0 then
        -- Segunda sequência - chicote em direção alternada
        parameters.sequential = true
        for i = 1, 3 do
            parameters.step = 4 - i  -- 3, 2, 1 (invertido)
            addEvent(castStep, i * 150, parameters)
        end
        
        player:setStorageValue(storage, 1)
        addEvent(function() 
            if player:isCreature() then
                player:setStorageValue(storage, 0)
            end
        end, 5 * 1000)
        
    elseif sequence == 1 then
        -- Terceira sequência - chicote mais rápido
        for i = 1, 3 do
            parameters.step = i
            addEvent(castStep, i * 100, parameters)
        end
        
        player:setStorageValue(storage, 2)
        addEvent(function() 
            if player:isCreature() then
                player:setStorageValue(storage, 1)
            end
        end, 5 * 1000)
        
    elseif sequence == 2 then
        -- Quarta sequência - chicotadas alternadas rápidas
        parameters.sequential = true
        for i = 1, 3 do
            parameters.step = 4 - i  -- 3, 2, 1 (invertido)
            addEvent(castStep, i * 100, parameters)
        end
        
        player:setStorageValue(storage, 3)
        addEvent(function() 
            if player:isCreature() then
                player:setStorageValue(storage, 1)
            end
        end, 5 * 1000)
        
    elseif sequence == 3 then
        -- Sequência final - chicotadas avançadas em ambas direções
        parameters.advanced = true
        for i = 1, 3 do
            parameters.step = i
            addEvent(castStep, i * 100, parameters)
        end
        
        -- Pequena pausa
        addEvent(function()
            if not player:isCreature() then
                return
            end
            
            parameters.sequential = true
            for i = 1, 3 do
                parameters.step = 4 - i -- Invertido
                addEvent(castStep, i * 100, parameters)
            end
        end, 400)
        
        player:setStorageValue(storage, -1)
    end
    
    return true
end

spell:group("attack")
spell:id(255) -- ID único para a magia
spell:name("Water Whip")
spell:words("w-whip")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:level(30)
spell:mana(60)
spell:isPremium(false)
spell:needDirection(true)
spell:cooldown(5 * 1000) -- 5 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:vocation("sorcerer;true", "master sorcerer;true", "druid;true", "elder druid;true")
spell:register() 