local _, internal = ...
internal.apls = internal.apls or {}

internal.apls['legion-dev::warlock::affliction'] = [[
actions.precombat=flask,type=whispered_pact
actions.precombat+=/food,type=nightborne_delicacy_platter
actions.precombat+=/summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
actions.precombat+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
actions.precombat+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>=3
actions.precombat+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies<3&artifact.lord_of_flames.rank=0
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/snapshot_stats
actions.precombat+=/grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
actions.precombat+=/life_tap,if=talent.empowered_life_tap.enabled&!buff.empowered_life_tap.remains
actions.precombat+=/potion,name=deadly_grace
actions=reap_souls,if=!buff.deadwind_harvester.remains&(buff.soul_harvest.remains|buff.tormented_souls.react>=8|target.time_to_die<=buff.tormented_souls.react*5|trinket.proc.any.react|trinket.stacking_proc.any.react)
actions+=/soul_effigy,if=!pet.soul_effigy.active
actions+=/agony,cycle_targets=1,if=remains<=tick_time+gcd
actions+=/service_pet,if=dot.corruption.remains&dot.agony.remains
actions+=/summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<3&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
actions+=/summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>=3
actions+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<3&equipped.132379&!cooldown.sindorei_spite_icd.remains
actions+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>=3&equipped.132379&!cooldown.sindorei_spite_icd.remains
actions+=/berserking
actions+=/blood_fury
actions+=/arcane_torrent
actions+=/soul_harvest
actions+=/potion,name=deadly_grace,if=buff.soul_harvest.remains|trinket.proc.any.react|target.time_to_die<=45
actions+=/corruption,if=remains<=tick_time+gcd
actions+=/corruption,cycle_targets=1,if=(talent.absolute_corruption.enabled|!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=tick_time+gcd
actions+=/siphon_life,if=remains<=tick_time+gcd
actions+=/siphon_life,cycle_targets=1,if=(!talent.malefic_grasp.enabled||!talent.soul_effigy.enabled)&remains<=tick_time+gcd
actions+=/life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
actions+=/phantom_singularity
actions+=/haunt
actions+=/unstable_affliction,if=talent.writhe_in_agony.enabled&talent.contagion.enabled
actions+=/unstable_affliction,if=talent.writhe_in_agony.enabled&(soul_shard>=4|trinket.proc.intellect.react|trinket.stacking_proc.mastery.react|trinket.proc.mastery.react|trinket.proc.crit.react|trinket.proc.versatility.react|buff.soul_harvest.remains|buff.deadwind_harvester.remains|buff.compounding_horror.react=5|target.time_to_die<=20)
actions+=/unstable_affliction,if=talent.malefic_grasp.enabled&target.time_to_die<30
actions+=/unstable_affliction,if=talent.malefic_grasp.enabled&soul_shard>=4
actions+=/unstable_affliction,if=talent.malefic_grasp.enabled&!prev_gcd.3.unstable_affliction&dot.agony.remains>cast_time+6.5&(dot.corruption.remains>cast_time+6.5|talent.absolute_corruption.enabled)&(dot.siphon_life.remains>cast_time+6.5|!talent.siphon_life.enabled)
actions+=/unstable_affliction,if=talent.haunt.enabled&(soul_shard>=4|debuff.haunt.remains|target.time_to_die<30)
actions+=/reap_souls,if=!buff.deadwind_harvester.remains&!trinket.has_stacking_stat.any&!trinket.has_stat.any&prev_gcd.1.unstable_affliction
actions+=/life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3
actions+=/agony,cycle_targets=1,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
actions+=/agony,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&!dot.unstable_affliction_1.remains&!dot.unstable_affliction_2.remains&!dot.unstable_affliction_3.remains&!dot.unstable_affliction_4.remains&!dot.unstable_affliction_5.remains
actions+=/corruption,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
actions+=/corruption,if=remains<=duration*0.3&target.time_to_die>=remains&!dot.unstable_affliction_1.remains&!dot.unstable_affliction_2.remains&!dot.unstable_affliction_3.remains&!dot.unstable_affliction_4.remains&!dot.unstable_affliction_5.remains
actions+=/corruption,cycle_targets=1,if=(talent.absolute_corruption.enabled|!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=duration*0.3&target.time_to_die>=remains
actions+=/siphon_life,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
actions+=/siphon_life,if=remains<=duration*0.3&target.time_to_die>=remains&!dot.unstable_affliction_1.remains&!dot.unstable_affliction_2.remains&!dot.unstable_affliction_3.remains&!dot.unstable_affliction_4.remains&!dot.unstable_affliction_5.remains
actions+=/siphon_life,cycle_targets=1,if=(!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=duration*0.3&target.time_to_die>=remains
actions+=/life_tap,if=mana.pct<=10
actions+=/drain_soul,chain=1,interrupt=1
actions+=/life_tap
]]

internal.apls['legion-dev::warlock::demonology'] = [[
actions.precombat=flask,type=whispered_pact
actions.precombat+=/food,type=azshari_salad
actions.precombat+=/summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
actions.precombat+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
actions.precombat+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>=3
actions.precombat+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies<3&artifact.lord_of_flames.rank=0
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=deadly_grace
actions.precombat+=/demonic_empowerment
actions.precombat+=/demonbolt,if=talent.demonbolt.enabled
actions.precombat+=/shadow_bolt,if=!talent.demonbolt.enabled
actions=implosion,if=wild_imp_remaining_duration<=action.shadow_bolt.execute_time&(buff.demonic_synergy.remains|talent.soul_conduit.enabled|(!talent.soul_conduit.enabled&spell_targets.implosion>1)|wild_imp_count<=4)
actions+=/implosion,if=prev_gcd.1.hand_of_guldan&((wild_imp_remaining_duration<=3&buff.demonic_synergy.remains)|(wild_imp_remaining_duration<=4&spell_targets.implosion>2))
actions+=/shadowflame,if=((debuff.shadowflame.stack>0&remains<action.shadow_bolt.cast_time+travel_time)|(charges=2&soul_shard<5))&spell_targets.demonwrath<5
actions+=/service_pet
actions+=/summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<3&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
actions+=/summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>=3
actions+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<3&equipped.132379&!cooldown.sindorei_spite_icd.remains
actions+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>=3&equipped.132379&!cooldown.sindorei_spite_icd.remains
actions+=/call_dreadstalkers,if=(!talent.summon_darkglare.enabled|talent.power_trip.enabled)&(spell_targets.implosion<3|!talent.implosion.enabled)
actions+=/hand_of_guldan,if=soul_shard>=4&!talent.summon_darkglare.enabled
actions+=/summon_darkglare,if=prev_gcd.1.hand_of_guldan|prev_gcd.1.call_dreadstalkers|talent.power_trip.enabled
actions+=/summon_darkglare,if=cooldown.call_dreadstalkers.remains>5&soul_shard<3
actions+=/summon_darkglare,if=cooldown.call_dreadstalkers.remains<=action.summon_darkglare.cast_time&(soul_shard>=3|soul_shard>=1&buff.demonic_calling.react)
actions+=/call_dreadstalkers,if=talent.summon_darkglare.enabled&(spell_targets.implosion<3|!talent.implosion.enabled)&(cooldown.summon_darkglare.remains>2|prev_gcd.1.summon_darkglare|cooldown.summon_darkglare.remains<=action.call_dreadstalkers.cast_time&soul_shard>=3|cooldown.summon_darkglare.remains<=action.call_dreadstalkers.cast_time&soul_shard>=1&buff.demonic_calling.react)
actions+=/hand_of_guldan,if=(soul_shard>=3&prev_gcd.1.call_dreadstalkers)|soul_shard>=5|(soul_shard>=4&cooldown.summon_darkglare.remains>2)
actions+=/demonic_empowerment,if=(((talent.power_trip.enabled&(!talent.implosion.enabled|spell_targets.demonwrath<=1))|!talent.implosion.enabled|(talent.implosion.enabled&!talent.soul_conduit.enabled&spell_targets.demonwrath<=3))&(wild_imp_no_de>3|prev_gcd.1.hand_of_guldan))|(prev_gcd.1.hand_of_guldan&wild_imp_no_de=0&wild_imp_remaining_duration<=0)|(prev_gcd.1.implosion&wild_imp_no_de>0)
actions+=/demonic_empowerment,if=dreadstalker_no_de>0|darkglare_no_de>0|doomguard_no_de>0|infernal_no_de>0|service_no_de>0
actions+=/doom,cycle_targets=1,if=!talent.hand_of_doom.enabled&target.time_to_die>duration&(!ticking|remains<duration*0.3)
actions+=/arcane_torrent
actions+=/berserking
actions+=/blood_fury
actions+=/soul_harvest
actions+=/potion,name=deadly_grace,if=buff.soul_harvest.remains|target.time_to_die<=45|trinket.proc.any.react
actions+=/shadowflame,if=charges=2&spell_targets.demonwrath<5
actions+=/thalkiels_consumption,if=(dreadstalker_remaining_duration>execute_time|talent.implosion.enabled&spell_targets.implosion>=3)&wild_imp_count>3&wild_imp_remaining_duration>execute_time
actions+=/life_tap,if=mana.pct<=30
actions+=/demonwrath,chain=1,interrupt=1,if=spell_targets.demonwrath>=3
actions+=/demonwrath,moving=1,chain=1,interrupt=1
actions+=/demonbolt
actions+=/shadow_bolt
actions+=/life_tap
]]

internal.apls['legion-dev::warlock::destruction'] = [[
actions.precombat=flask,type=whispered_pact
actions.precombat+=/food,type=azshari_salad
actions.precombat+=/summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
actions.precombat+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
actions.precombat+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>=3
actions.precombat+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies<3&artifact.lord_of_flames.rank=0
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/snapshot_stats
actions.precombat+=/grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
actions.precombat+=/life_tap,if=talent.empowered_life_tap.enabled&!buff.empowered_life_tap.remains
actions.precombat+=/potion,name=deadly_grace
actions.precombat+=/chaos_bolt
actions=havoc,target=2,if=active_enemies>1&active_enemies<6&!debuff.havoc.remains
actions+=/dimensional_rift,if=charges=3
actions+=/immolate,if=remains<=tick_time
actions+=/immolate,cycle_targets=1,if=active_enemies>1&remains<=tick_time&(!talent.roaring_blaze.enabled|(!debuff.roaring_blaze.remains&action.conflagrate.charges<2))
actions+=/immolate,if=talent.roaring_blaze.enabled&remains<=duration&!debuff.roaring_blaze.remains&target.time_to_die>10&(action.conflagrate.charges=2+set_bonus.tier19_4pc|(action.conflagrate.charges>=1+set_bonus.tier19_4pc&action.conflagrate.recharge_time<cast_time+gcd)|target.time_to_die<24)
actions+=/berserking
actions+=/blood_fury
actions+=/arcane_torrent
actions+=/potion,name=deadly_grace,if=(buff.soul_harvest.remains|trinket.proc.any.react|target.time_to_die<=45)
actions+=/shadowburn,if=buff.conflagration_of_chaos.remains<=action.chaos_bolt.cast_time
actions+=/shadowburn,if=(charges=1&recharge_time<action.chaos_bolt.cast_time|charges=2)&soul_shard<5
actions+=/conflagrate,if=talent.roaring_blaze.enabled&(charges=2+set_bonus.tier19_4pc|(charges>=1+set_bonus.tier19_4pc&recharge_time<gcd)|target.time_to_die<24)
actions+=/conflagrate,if=talent.roaring_blaze.enabled&debuff.roaring_blaze.stack>0&dot.immolate.remains>dot.immolate.duration*0.3&(active_enemies=1|soul_shard<3)&soul_shard<5
actions+=/conflagrate,if=!talent.roaring_blaze.enabled&!buff.backdraft.remains&buff.conflagration_of_chaos.remains<=action.chaos_bolt.cast_time
actions+=/conflagrate,if=!talent.roaring_blaze.enabled&!buff.backdraft.remains&(charges=1&recharge_time<action.chaos_bolt.cast_time|charges=2)&soul_shard<5
actions+=/life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
actions+=/dimensional_rift,if=equipped.144369&!buff.lessons_of_spacetime.remains&((!talent.grimoire_of_supremacy.enabled&!cooldown.summon_doomguard.remains)|(talent.grimoire_of_service.enabled&!cooldown.service_pet.remains)|(talent.soul_harvest.enabled&!cooldown.soul_harvest.remains))
actions+=/service_pet
actions+=/summon_infernal,if=artifact.lord_of_flames.rank>0&!buff.lord_of_flames.remains
actions+=/summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<3&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
actions+=/summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>=3
actions+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0&buff.lord_of_flames.remains&!pet.doomguard.active
actions+=/summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<3&equipped.132379&!cooldown.sindorei_spite_icd.remains
actions+=/summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>=3&equipped.132379&!cooldown.sindorei_spite_icd.remains
actions+=/soul_harvest
actions+=/channel_demonfire,if=dot.immolate.remains>cast_time
actions+=/havoc,if=active_enemies=1&talent.wreak_havoc.enabled&equipped.132375&!debuff.havoc.remains
actions+=/rain_of_fire,if=active_enemies>=4&cooldown.havoc.remains<=12&!talent.wreak_havoc.enabled
actions+=/rain_of_fire,if=active_enemies>=6&talent.wreak_havoc.enabled
actions+=/dimensional_rift,if=!equipped.144369|charges>1|((!talent.grimoire_of_service.enabled|recharge_time<cooldown.service_pet.remains)&(!talent.soul_harvest.enabled|recharge_time<cooldown.soul_harvest.remains)&(!talent.grimoire_of_supremacy.enabled|recharge_time<cooldown.summon_doomguard.remains))
actions+=/life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3
actions+=/cataclysm
actions+=/chaos_bolt
actions+=/shadowburn
actions+=/conflagrate,if=!talent.roaring_blaze.enabled&!buff.backdraft.remains
actions+=/immolate,if=!talent.roaring_blaze.enabled&remains<=duration*0.3
actions+=/incinerate
actions+=/life_tap
]]

