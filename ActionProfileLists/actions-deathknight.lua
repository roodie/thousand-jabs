local _, internal = ...
internal.apls = internal.apls or {}

internal.apls["legion-dev::deathknight::frost"] = [[
actions.precombat=flask,name=countless_armies
actions.precombat+=/food,name=fishbrul_special
actions.precombat+=/augmentation,name=defiled
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=old_war
actions=auto_attack
actions+=/pillar_of_frost
actions+=/mind_freeze
actions+=/arcane_torrent,if=runic_power.deficit>20
actions+=/blood_fury,if=!talent.breath_of_sindragosa.enabled|dot.breath_of_sindragosa.ticking
actions+=/berserking,if=buff.pillar_of_frost.up
actions+=/potion,name=old_war
actions+=/sindragosas_fury,if=buff.pillar_of_frost.up
actions+=/obliteration
actions+=/breath_of_sindragosa,if=runic_power>=50
actions+=/run_action_list,name=bos,if=dot.breath_of_sindragosa.ticking
actions+=/call_action_list,name=shatter,if=talent.shattering_strikes.enabled
actions+=/call_action_list,name=generic,if=!talent.shattering_strikes.enabled
actions.bos=howling_blast,target_if=!dot.frost_fever.ticking
actions.bos+=/call_action_list,name=core
actions.bos+=/horn_of_winter
actions.bos+=/empower_rune_weapon,if=runic_power<=70
actions.bos+=/hungering_rune_weapon
actions.bos+=/howling_blast,if=buff.rime.react
actions.core=frost_strike,if=buff.obliteration.up&!buff.killing_machine.react
actions.core+=/remorseless_winter,if=(spell_targets.remorseless_winter>=2|talent.gathering_storm.enabled)&!(talent.frostscythe.enabled&buff.killing_machine.react&spell_targets.frostscythe>=2)
actions.core+=/frostscythe,if=(buff.killing_machine.react&spell_targets.frostscythe>=2)
actions.core+=/glacial_advance,if=spell_targets.glacial_advance>=2
actions.core+=/frostscythe,if=spell_targets.frostscythe>=3
actions.core+=/obliterate,if=buff.killing_machine.react
actions.core+=/obliterate
actions.core+=/glacial_advance
actions.core+=/remorseless_winter,if=talent.frozen_pulse.enabled
actions.generic=howling_blast,target_if=!dot.frost_fever.ticking
actions.generic+=/howling_blast,if=buff.rime.react
actions.generic+=/frost_strike,if=runic_power>=80
actions.generic+=/call_action_list,name=core
actions.generic+=/horn_of_winter,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.generic+=/horn_of_winter,if=!talent.breath_of_sindragosa.enabled
actions.generic+=/frost_strike,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.generic+=/frost_strike,if=!talent.breath_of_sindragosa.enabled
actions.generic+=/empower_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.generic+=/hungering_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.generic+=/empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled
actions.generic+=/hungering_rune_weapon,if=!talent.breath_of_sindragosa.enabled
actions.shatter=frost_strike,if=debuff.razorice.stack=5
actions.shatter+=/howling_blast,target_if=!dot.frost_fever.ticking
actions.shatter+=/howling_blast,if=buff.rime.react
actions.shatter+=/frost_strike,if=runic_power>=80
actions.shatter+=/call_action_list,name=core
actions.shatter+=/horn_of_winter,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.shatter+=/horn_of_winter,if=!talent.breath_of_sindragosa.enabled
actions.shatter+=/frost_strike,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.shatter+=/frost_strike,if=!talent.breath_of_sindragosa.enabled
actions.shatter+=/empower_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.shatter+=/hungering_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
actions.shatter+=/empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled
actions.shatter+=/hungering_rune_weapon,if=!talent.breath_of_sindragosa.enabled
]]

internal.apls["legion-dev::deathknight::unholy"] = [[
actions.precombat=flask,name=countless_armies
actions.precombat+=/food,name=the_hungry_magister
actions.precombat+=/augmentation,name=defiled
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=old_war
actions.precombat+=/raise_dead
actions.precombat+=/army_of_the_dead
actions=auto_attack
actions+=/arcane_torrent,if=runic_power.deficit>20
actions+=/blood_fury
actions+=/berserking
actions+=/potion,name=old_war,if=buff.unholy_strength.react
actions+=/outbreak,target_if=!dot.virulent_plague.ticking
actions+=/dark_transformation,if=equipped.137075&cooldown.dark_arbiter.remains>165
actions+=/dark_transformation,if=equipped.137075&!talent.shadow_infusion.enabled&cooldown.dark_arbiter.remains>55
actions+=/dark_transformation,if=equipped.137075&talent.shadow_infusion.enabled&cooldown.dark_arbiter.remains>35
actions+=/dark_transformation,if=equipped.137075&target.time_to_die<cooldown.dark_arbiter.remains-8
actions+=/dark_transformation,if=equipped.137075&cooldown.summon_gargoyle.remains>160
actions+=/dark_transformation,if=equipped.137075&!talent.shadow_infusion.enabled&cooldown.summon_gargoyle.remains>55
actions+=/dark_transformation,if=equipped.137075&talent.shadow_infusion.enabled&cooldown.summon_gargoyle.remains>35
actions+=/dark_transformation,if=equipped.137075&target.time_to_die<cooldown.summon_gargoyle.remains-8
actions+=/dark_transformation,if=!equipped.137075&rune<=3
actions+=/blighted_rune_weapon,if=rune<=3
actions+=/run_action_list,name=valkyr,if=talent.dark_arbiter.enabled&pet.valkyr_battlemaiden.active
actions+=/call_action_list,name=generic
actions.aoe=death_and_decay,if=spell_targets.death_and_decay>=2
actions.aoe+=/epidemic,if=spell_targets.epidemic>4
actions.aoe+=/scourge_strike,if=spell_targets.scourge_strike>=2&(dot.death_and_decay.ticking|dot.defile.ticking)
actions.aoe+=/clawing_shadows,if=spell_targets.clawing_shadows>=2&(dot.death_and_decay.ticking|dot.defile.ticking)
actions.aoe+=/epidemic,if=spell_targets.epidemic>2
actions.castigator=festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
actions.castigator+=/death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
actions.castigator+=/scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=3&runic_power.deficit>23
actions.castigator+=/scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=3&runic_power.deficit>23
actions.castigator+=/scourge_strike,if=rune>=2&debuff.festering_wound.stack>=3&runic_power.deficit>23
actions.castigator+=/death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
actions.castigator+=/death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
actions.castigator+=/death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
actions.castigator+=/death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled
actions.generic=dark_arbiter,if=!equipped.137075&runic_power.deficit<30
actions.generic+=/dark_arbiter,if=equipped.137075&runic_power.deficit<30&cooldown.dark_transformation.remains<2
actions.generic+=/summon_gargoyle,if=!equipped.137075,if=rune<=3
actions.generic+=/summon_gargoyle,if=equipped.137075&cooldown.dark_transformation.remains<10&rune<=3
actions.generic+=/soul_reaper,if=debuff.festering_wound.stack>=7&cooldown.apocalypse.remains<2
actions.generic+=/apocalypse,if=debuff.festering_wound.stack>=7
actions.generic+=/death_coil,if=runic_power.deficit<30
actions.generic+=/death_coil,if=!talent.dark_arbiter.enabled&buff.sudden_doom.up&!buff.necrosis.up&rune<=3
actions.generic+=/death_coil,if=talent.dark_arbiter.enabled&buff.sudden_doom.up&cooldown.dark_arbiter.remains>5&rune<=3
actions.generic+=/festering_strike,if=debuff.festering_wound.stack<7&cooldown.apocalypse.remains<5
actions.generic+=/wait,sec=cooldown.apocalypse.remains,if=cooldown.apocalypse.remains<=1&cooldown.apocalypse.remains
actions.generic+=/soul_reaper,if=debuff.festering_wound.stack>=3
actions.generic+=/festering_strike,if=debuff.soul_reaper.up&!debuff.festering_wound.up
actions.generic+=/scourge_strike,if=debuff.soul_reaper.up&debuff.festering_wound.stack>=1
actions.generic+=/clawing_shadows,if=debuff.soul_reaper.up&debuff.festering_wound.stack>=1
actions.generic+=/defile
actions.generic+=/call_action_list,name=aoe,if=active_enemies>=2
actions.generic+=/call_action_list,name=instructors,if=equipped.132448
actions.generic+=/call_action_list,name=standard,if=!talent.castigator.enabled&!equipped.132448
actions.generic+=/call_action_list,name=castigator,if=talent.castigator.enabled&!equipped.132448
actions.instructors=festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
actions.instructors+=/death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
actions.instructors+=/scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
actions.instructors+=/clawing_shadows,if=buff.necrosis.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
actions.instructors+=/scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
actions.instructors+=/clawing_shadows,if=buff.unholy_strength.react&debuff.festering_wound.stack>=5&runic_power.deficit>29
actions.instructors+=/scourge_strike,if=rune>=2&debuff.festering_wound.stack>=5&runic_power.deficit>29
actions.instructors+=/clawing_shadows,if=rune>=2&debuff.festering_wound.stack>=5&runic_power.deficit>29
actions.instructors+=/death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
actions.instructors+=/death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
actions.instructors+=/death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
actions.instructors+=/death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled
actions.standard=festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
actions.standard+=/death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
actions.standard+=/scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
actions.standard+=/clawing_shadows,if=buff.necrosis.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
actions.standard+=/scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
actions.standard+=/clawing_shadows,if=buff.unholy_strength.react&debuff.festering_wound.stack>=1&runic_power.deficit>15
actions.standard+=/scourge_strike,if=rune>=2&debuff.festering_wound.stack>=1&runic_power.deficit>15
actions.standard+=/clawing_shadows,if=rune>=2&debuff.festering_wound.stack>=1&runic_power.deficit>15
actions.standard+=/death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
actions.standard+=/death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
actions.standard+=/death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
actions.standard+=/death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled
actions.valkyr=death_coil
actions.valkyr+=/apocalypse,if=debuff.festering_wound.stack=8
actions.valkyr+=/festering_strike,if=debuff.festering_wound.stack<8&cooldown.apocalypse.remains<5
actions.valkyr+=/call_action_list,name=aoe,if=active_enemies>=2
actions.valkyr+=/festering_strike,if=debuff.festering_wound.stack<=3
actions.valkyr+=/scourge_strike,if=debuff.festering_wound.up
actions.valkyr+=/clawing_shadows,if=debuff.festering_wound.up
]]

