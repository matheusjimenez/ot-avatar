local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 13)

-- Definição da área
local area = {
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 3, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0}
}

-- Área para os pulsos subsequentes
local pulseArea = {
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 3, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0}
}

combat:setArea(createCombatArea(area))

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    -- Função para empurrar o alvo
    local function pushTarget(pos, cid, targetId)
        local attacker = Creature(cid)
        local target = Creature(targetId)
        
        if not attacker or not target then
            return false
        end
        
        local direction = attacker:getDirection()
        local x = 0
        local y = 0
        
        if direction == DIRECTION_NORTH then
            y = -1
        elseif direction == DIRECTION_SOUTH then
            y = 1
        elseif direction == DIRECTION_EAST then
            x = 1
        elseif direction == DIRECTION_WEST then
            x = -1
        end
        
        local toPos = Position(target:getPosition())
        toPos.x = toPos.x + x
        toPos.y = toPos.y + y
        
        if target:getTile():queryAdd(target, toPos) == RETURNVALUE_NOERROR then
            target:teleportTo(toPos, true)
            return true
        end
        
        return false
    end
    
    -- Função para executar um pulso do combate
    local function doPulse(cid, variant, count)
        local creature = Creature(cid)
        if not creature then
            return
        end
        
        local targets = {}
        
        -- Cria um novo combate para este pulso
        local pulseCombat = Combat()
        pulseCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
        pulseCombat:setParameter(COMBAT_PARAM_EFFECT, 13)
        pulseCombat:setFormula(COMBAT_FORMULA_LEVELMAGIC, -1, 0, -1, 0)
        
        -- Configura a área apropriada
        if count == 1 then
            pulseCombat:setArea(createCombatArea(area))
        else
            pulseCombat:setArea(createCombatArea(pulseArea))
        end
        
        -- Função de callback para coletar alvos
        local function onTargetCreature(attacker, target)
            if target and target:isCreature() then
                table.insert(targets, target:getId())
            end
            return true
        end
        
        pulseCombat:setCallback(CALLBACK_PARAM_TARGETCREATURE, onTargetCreature)
        
        -- Executa o combate
        pulseCombat:execute(creature, variant)
        
        -- Agenda o empurrão para cada alvo após um pequeno delay
        for _, targetId in ipairs(targets) do
            addEvent(pushTarget, 100, creature:getPosition(), creature:getId(), targetId)
        end
        
        -- Agenda o próximo pulso se necessário
        if count < 15 then
            addEvent(doPulse, 150, cid, variant, count + 1)
        end
    end
    
    -- Inicia a sequência de pulsos
    doPulse(creature:getId(), variant, 1)
    
    return true
end

spell:name("Blood Control")
spell:words("w-blood")
spell:group("attack")
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(20)
spell:mana(40)
spell:isAggressive(true)
spell:needTarget(true)
spell:needLearn(false)
spell:register()