local _, internal = ...
internal.apls = internal.apls or {}

internal.apls["legion-dev::Tier19P::Shaman_Elemental_T19P"] = [[
actions.precombat=flask,type=whispered_pact
actions.precombat+=/food,type=salty_squid_roll
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=draenic_intellect
actions.precombat+=/stormkeeper
actions.precombat+=/totem_mastery
actions=wind_shear
actions+=/bloodlust,if=target.health.pct<25|time>0.500
actions+=/potion,name=draenic_intellect,if=buff.ascendance.up|target.time_to_die<=30
actions+=/totem_mastery,if=buff.resonance_totem.remains<2
actions+=/fire_elemental
actions+=/storm_elemental
actions+=/elemental_mastery
actions+=/blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
actions+=/berserking,if=!talent.ascendance.enabled|buff.ascendance.up
actions+=/run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
actions+=/run_action_list,name=single
actions.single=ascendance,if=dot.flame_shock.remains>buff.ascendance.duration&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!buff.stormkeeper.up
actions.single+=/flame_shock,if=!ticking
actions.single+=/flame_shock,if=maelstrom>=20&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<=duration
actions.single+=/earth_shock,if=maelstrom>=92
actions.single+=/icefury,if=raid_event.movement.in<5
actions.single+=/lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
actions.single+=/elemental_blast
actions.single+=/flame_shock,if=maelstrom>=20,target_if=refreshable
actions.single+=/frost_shock,if=talent.icefury.enabled&buff.icefury.up&((maelstrom>=20&raid_event.movement.in>buff.icefury.remains)|buff.icefury.remains<(1.5*spell_haste*buff.icefury.stack))
actions.single+=/frost_shock,moving=1,if=buff.icefury.up
actions.single+=/earth_shock,if=maelstrom>=86
actions.single+=/icefury,if=maelstrom<=70&raid_event.movement.in>30&((talent.ascendance.enabled&cooldown.ascendance.remains>buff.icefury.duration)|!talent.ascendance.enabled)
actions.single+=/liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
actions.single+=/stormkeeper,if=(talent.ascendance.enabled&cooldown.ascendance.remains>10)|!talent.ascendance.enabled
actions.single+=/totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
actions.single+=/lava_beam,if=active_enemies>1&spell_targets.lava_beam>1,target_if=!debuff.lightning_rod.up
actions.single+=/lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
actions.single+=/chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1,target_if=!debuff.lightning_rod.up
actions.single+=/chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
actions.single+=/lightning_bolt,target_if=!debuff.lightning_rod.up
actions.single+=/lightning_bolt
actions.single+=/frost_shock,if=maelstrom>=20&dot.flame_shock.remains>19
actions.single+=/flame_shock,moving=1,target_if=refreshable
actions.single+=/flame_shock,moving=1
actions.aoe=stormkeeper
actions.aoe+=/ascendance
actions.aoe+=/liquid_magma_totem
actions.aoe+=/flame_shock,if=spell_targets.chain_lightning=3&maelstrom>=20,target_if=refreshable
actions.aoe+=/earthquake_totem
actions.aoe+=/lava_burst,if=buff.lava_surge.up&spell_targets.chain_lightning=3
actions.aoe+=/lava_beam
actions.aoe+=/chain_lightning,target_if=!debuff.lightning_rod.up
actions.aoe+=/chain_lightning
actions.aoe+=/lava_burst,moving=1
actions.aoe+=/flame_shock,moving=1,target_if=refreshable
]]

internal.apls["legion-dev::Tier19P::Shaman_Enhancement_T19P"] = [[
actions.precombat=flask,type=seventh_demon
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/food,type=nightborne_delicacy_platter
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=draenic_agility
actions.precombat+=/lightning_shield
actions=wind_shear
actions+=/bloodlust,if=target.health.pct<25|time>0.500
actions+=/auto_attack
actions+=/feral_spirit
actions+=/use_item,slot=trinket2
actions+=/potion,name=draenic_agility,if=pet.feral_spirit.remains>10|pet.frost_wolf.remains>5|pet.fiery_wolf.remains>5|pet.lightning_wolf.remains>5|target.time_to_die<=30
actions+=/berserking,if=buff.ascendance.up|!talent.ascendance.enabled|level<100
actions+=/blood_fury
actions+=/boulderfist,if=buff.boulderfist.remains<gcd|charges_fractional>1.75
actions+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<gcd
actions+=/flametongue,if=buff.flametongue.remains<gcd
actions+=/windsong
actions+=/ascendance
actions+=/fury_of_air,if=!ticking
actions+=/doom_winds
actions+=/crash_lightning,if=active_enemies>=3
actions+=/windstrike
actions+=/stormstrike
actions+=/frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8
actions+=/flametongue,if=buff.flametongue.remains<4.8
actions+=/lightning_bolt,if=talent.overcharge.enabled&maelstrom>=60
actions+=/lava_lash,if=buff.hot_hand.react
actions+=/earthen_spike
actions+=/crash_lightning,if=active_enemies>1|talent.crashing_storm.enabled|(pet.feral_spirit.remains>5|pet.frost_wolf.remains>5|pet.fiery_wolf.remains>5|pet.lightning_wolf.remains>5)
actions+=/sundering
actions+=/lava_lash,if=maelstrom>=90
actions+=/rockbiter
actions+=/flametongue
actions+=/boulderfist
]]
