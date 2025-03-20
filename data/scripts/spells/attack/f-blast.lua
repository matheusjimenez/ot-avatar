local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)
combat:setArea(createCombatArea({
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 1, 3, 1, 0, 0},
    {0, 0, 0, 1, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0}
}))

function onGetFormulaValues(player, level, magicLevel)
    local min = (level * 0.2 + magicLevel * 0.8) * -1 +10
    local max = (level * 0.4 + magicLevel * 1.6) * -1 +20
    return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
    local position = variant:getPosition()
    if position.x == 0 then
        local target = creature:getTarget()
        if target then
            position = target:getPosition()
        end
    end
    
    local parameters = {
        cid = creature:getId(),
        pos = position,
        combat = combat,
        var = variant
    }
    
    -- Adiciona efeito de fogo quando o jogador lança o feitiço
    creature:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
    creature:getPosition():sendDistanceEffect(position, CONST_ANI_FIRE)
    
    addEvent(function(params)
        if Creature(params.cid) then
            local pos = params.pos
            local cid = params.cid
            
            -- Executar o dano usando o combat diretamente - isso vai aplicar o dano na área definida
            combat:execute(Creature(cid), params.var)
            
            -- Efeito central adicional
            Position(pos.x, pos.y, pos.z):sendMagicEffect(CONST_ME_FIREAREA)
            
            -- Adiciona um segundo conjunto de efeitos após um pequeno atraso
            addEvent(function()
                -- Segunda onda de efeitos na área
                Position(pos.x, pos.y, pos.z):sendMagicEffect(CONST_ME_HITBYFIRE)
                Position(pos.x + 1, pos.y, pos.z):sendMagicEffect(CONST_ME_FIREAREA)
                Position(pos.x - 1, pos.y, pos.z):sendMagicEffect(CONST_ME_FIREAREA)
                Position(pos.x, pos.y + 1, pos.z):sendMagicEffect(CONST_ME_FIREAREA)
                Position(pos.x, pos.y - 1, pos.z):sendMagicEffect(CONST_ME_FIREAREA)
            end, 150)
        end
    end, 100, parameters)
    
    return true
end

spell:group("attack")
spell:id(251) -- ID único para o feitiço (ajuste conforme necessário)
spell:name("Fire Blast")
spell:words("f-blast")
spell:level(20)
spell:mana(40)
spell:isPremium(false)
spell:cooldown(1 * 1000)
spell:groupCooldown(2 * 1000)
spell:needLearn(false)
spell:needTarget(true)
spell:needDirection(false)
spell:vocation("sorcerer;true", "master sorcerer;true", "druid;true", "elder druid;true")
spell:register() 