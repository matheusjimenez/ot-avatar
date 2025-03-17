local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GREEN_RINGS)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_POISON)
combat:setArea(createCombatArea(AREA_BEAM8))

-- Função para calcular o dano baseado no nível e habilidades do jogador
local function calculateDamage(player)
    -- Verificar se é um Game Master
    if player:getGroup():getAccess() then
        return -800, -1500 -- Dano maior para Game Masters
    end

    local magicLevel = player:getMagicLevel()
    local level = player:getLevel()
    
    local min = (level / 5) + (magicLevel * 1.8) + 15
    local max = (level / 5) + (magicLevel * 3) + 30
    return -min, -max
end

-- Função para aplicar o efeito de veneno
local function applyPoisonEffect(creature, target)
    if not target:isCreature() or target:isPlayer() then
        return false
    end
    
    -- Criar condição de veneno (duração de 15 segundos)
    local condition = Condition(CONDITION_POISON)
    condition:setParameter(CONDITION_PARAM_DELAYED, true)
    condition:setParameter(CONDITION_PARAM_MINVALUE, 20) -- Dano mínimo por tick
    condition:setParameter(CONDITION_PARAM_MAXVALUE, 40) -- Dano máximo por tick
    condition:setParameter(CONDITION_PARAM_STARTVALUE, 40) -- Dano inicial
    condition:setParameter(CONDITION_PARAM_TICKINTERVAL, 4000) -- Intervalo entre ticks (4 segundos)
    condition:setParameter(CONDITION_PARAM_FORCEUPDATE, true)
    condition:setParameter(CONDITION_PARAM_TICKS, 15000) -- Duração total (15 segundos)
    
    -- Aplicar a condição ao alvo
    target:addCondition(condition)
    return true
end

-- Callback para aplicar o efeito de veneno após o dano
local function poisonCallback(creature, target)
    applyPoisonEffect(creature, target)
    return true
end

combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "poisonCallback")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    local player = creature:getPlayer()
    if not player then
        return false
    end
    
    -- Verificar se o jogador é um druida
    local vocationId = player:getVocation():getId()
    if not player:getGroup():getAccess() and vocationId ~= 2 and vocationId ~= 6 then
        player:sendCancelMessage("Apenas Druidas podem usar esta magia.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end
    
    -- Calcular dano baseado no nível e habilidades
    local minDamage, maxDamage = calculateDamage(player)
    
    -- Configurar dano
    combat:setParameter(COMBAT_PARAM_MIN, minDamage)
    combat:setParameter(COMBAT_PARAM_MAX, maxDamage)
    
    -- Executar o feitiço
    return combat:execute(creature, variant)
end

spell:group("attack")
spell:id(253) -- ID único para a magia
spell:name("Poison Beam")
spell:words("exevo terra beam")
spell:castSound(SOUND_EFFECT_TYPE_SPELL_OR_RUNE)
spell:level(40)
spell:mana(80)
spell:isPremium(true)
spell:cooldown(8 * 1000) -- 8 segundos de cooldown
spell:groupCooldown(2 * 1000)
spell:needDirection(true)
spell:needLearn(false)
spell:vocation("druid;true", "elder druid;true")
spell:register() 