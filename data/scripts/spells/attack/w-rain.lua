local spellConfig = {
    {effect = CONST_ME_MAGIC_BLUE,
     area = createCombatArea({
        {1, 2, 1},
        {0, 0, 0},
        {0, 1, 0}})
    },
    {effect = CONST_ME_HITBYPOISON,
     area = createCombatArea({
        {0, 1, 0, 0, 0},
        {1, 0, 2, 1, 0},
        {0, 0, 0, 0, 0},
        {0, 0, 1, 0, 1},
        {1, 0, 0, 1, 0}})
    },
    {effect = CONST_ME_HITBYPOISON,
     area = createCombatArea({
        {0, 0, 1, 0, 1},
        {1, 0, 2, 0, 1},
        {0, 0, 0, 1, 0},
        {0, 1, 0, 0, 1},
        {1, 0, 1, 0, 0}})
    },
    {effect = CONST_ME_ICEAREA,
     area = createCombatArea({
        {0, 0, 1, 0, 1},
        {1, 0, 2, 0, 1},
        {0, 0, 0, 1, 0},
        {0, 1, 0, 0, 1},
        {1, 0, 1, 0, 0}})
    },
    {effect = CONST_ME_HITBYPOISON,
     area = createCombatArea({
        {0, 0, 1, 0, 1, 0, 0},
        {0, 0, 0, 0, 0, 1, 0},
        {1, 0, 0, 2, 0, 0, 1},
        {0, 0, 1, 0, 1, 0, 0},
        {1, 0, 0, 0, 0, 0, 1},
        {0, 0, 1, 0, 0, 0, 0},
        {0, 0, 1, 0, 1, 0, 0}})
    },
    {effect = CONST_ME_WATER_DROP,
     area = createCombatArea({
        {0, 0, 1, 0, 1, 0, 0},
        {0, 1, 0, 1, 0, 1, 0},
        {1, 0, 1, 2, 0, 0, 1},
        {0, 0, 0, 0, 1, 0, 0},
        {0, 1, 0, 0, 0, 0, 1},
        {1, 0, 0, 1, 0, 1, 0},
        {0, 0, 1, 0, 1, 0, 0}})
    },
    {effect = CONST_ME_WATER_DROP,
     area = createCombatArea({
        {0, 0, 1, 0, 1, 0, 0},
        {0, 1, 0, 1, 0, 1, 0},
        {1, 0, 1, 2, 0, 0, 1},
        {0, 0, 0, 0, 1, 0, 0},
        {0, 1, 0, 0, 0, 0, 1},
        {1, 0, 0, 1, 0, 1, 0},
        {0, 0, 1, 0, 1, 0, 0}})
    }
}

-- Função para aplicar o efeito de veneno
local function applyPoisonEffect(creature, target)
    if not target:isCreature() or target:isPlayer() then
        return false
    end
    
    -- Criar condição de veneno (duração de 10 segundos)
    local condition = Condition(CONDITION_POISON)
    condition:setParameter(CONDITION_PARAM_DELAYED, true)
    condition:setParameter(CONDITION_PARAM_MINVALUE, 125) -- Dano mínimo por tick
    condition:setParameter(CONDITION_PARAM_MAXVALUE, 150) -- Dano máximo por tick
    condition:setParameter(CONDITION_PARAM_STARTVALUE, 150) -- Dano inicial
    condition:setParameter(CONDITION_PARAM_TICKINTERVAL, 1000) -- Intervalo entre ticks (3 segundos)
    condition:setParameter(CONDITION_PARAM_FORCEUPDATE, true)
    condition:setParameter(CONDITION_PARAM_TICKS, 10000) -- Duração total (10 segundos)
    
    -- Aplicar a condição ao alvo
    target:addCondition(condition)
    return true
end

-- Criar os objetos de combate
local combats = {}
for i, config in ipairs(spellConfig) do
    local combat = Combat()
    combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
    combat:setParameter(COMBAT_PARAM_EFFECT, config.effect)
    combat:setArea(config.area)
    
    -- Configurar fórmula de dano
    function onGetFormulaValues(player, level, maglevel)
        local min = (level * 0.593) + (maglevel * 0.593) + 50
        local max = (level * 0.929) + (maglevel * 0.929) + 100
        return -min, -max
    end
    
    combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
    
    -- Callback para efeito de projétil
    function onTargetTile(creature, pos)
        local basePos = creature:getPosition()
        local fromPos = Position(basePos.x - 6, basePos.y - 8, basePos.z)
        fromPos:sendDistanceEffect(pos, CONST_ANI_SMALLICE)
    end
    
    combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
    
    -- Callback para aplicar o efeito de veneno após o dano
    function poisonCallback(creature, target)
        applyPoisonEffect(creature, target)
        return true
    end
    
    combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "poisonCallback")
    
    combats[i] = combat
end

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    -- Verificar se o jogador é um druida
    local player = creature:getPlayer()
    if player then
        local vocationId = player:getVocation():getId()
        if not player:getGroup():getAccess() and vocationId ~= 2 and vocationId ~= 6 then
            player:sendCancelMessage("Apenas Druidas podem usar esta magia.")
            player:getPosition():sendMagicEffect(CONST_ME_POFF)
            return false
        end
    end
    
    -- Executar cada combate com um atraso
    for i, combat in ipairs(combats) do
        addEvent(function()
            if creature:isCreature() then
                return combat:execute(creature, variant)
            end
        end, (250 * i))
    end
    return true
end

spell:group("attack")
spell:id(254) -- ID único para a magia
spell:name("Poison Rain")
spell:words("w-rain")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_LARGE)
spell:level(60)
spell:mana(150)
spell:isPremium(true)
spell:cooldown(40 * 1000) -- 40 segundos de cooldown
spell:groupCooldown(4 * 1000)
spell:needLearn(false)
spell:vocation("druid;true", "elder druid;true")
spell:register()