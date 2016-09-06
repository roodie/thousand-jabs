local _, internal = ...
internal.apls = internal.apls or {}

internal.apls["legion-dev::Tier19P::Druid_Balance_T19P"] = [[
actions.precombat=flask,type=flask_of_the_whispered_pact
actions.precombat+=/food,type=azshari_salad
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/moonkin_form
actions.precombat+=/blessing_of_elune
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=deadly_grace
actions.precombat+=/new_moon
actions=potion,name=deadly_grace,if=buff.celestial_alignment.up|buff.incarnation.up
actions+=/blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
actions+=/berserking,if=buff.celestial_alignment.up|buff.incarnation.up
actions+=/arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
actions+=/call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains<target.time_to_die
actions+=/new_moon,if=(charges=2&recharge_time<5)|charges=3
actions+=/half_moon,if=(charges=2&recharge_time<5)|charges=3|(target.time_to_die<15&charges=2)
actions+=/full_moon,if=(charges=2&recharge_time<5)|charges=3|target.time_to_die<15
actions+=/stellar_flare,if=remains<7.2
actions+=/moonfire,if=(talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled)
actions+=/sunfire,if=(talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled)
actions+=/astral_communion,if=astral_power.deficit>=75
actions+=/incarnation,if=astral_power>=40
actions+=/celestial_alignment,if=astral_power>=40
actions+=/solar_wrath,if=buff.solar_empowerment.stack=3
actions+=/lunar_strike,if=buff.lunar_empowerment.stack=3
actions+=/call_action_list,name=celestial_alignment_phase,if=buff.celestial_alignment.up|buff.incarnation.up
actions+=/call_action_list,name=single_target
actions.fury_of_elune=incarnation,if=astral_power>=95&cooldown.fury_of_elune.remains<=gcd
actions.fury_of_elune+=/fury_of_elune,if=astral_power>=95
actions.fury_of_elune+=/new_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=90))
actions.fury_of_elune+=/half_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=80))
actions.fury_of_elune+=/full_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=60))
actions.fury_of_elune+=/astral_communion,if=buff.fury_of_elune_up.up&astral_power<=25
actions.fury_of_elune+=/warrior_of_elune,if=buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.up)
actions.fury_of_elune+=/lunar_strike,if=buff.warrior_of_elune.up&(astral_power<=90|(astral_power<=85&buff.incarnation.up))
actions.fury_of_elune+=/new_moon,if=astral_power<=90&buff.fury_of_elune_up.up
actions.fury_of_elune+=/half_moon,if=astral_power<=80&buff.fury_of_elune_up.up&astral_power>cast_time*12
actions.fury_of_elune+=/full_moon,if=astral_power<=60&buff.fury_of_elune_up.up&astral_power>cast_time*12
actions.fury_of_elune+=/moonfire,if=buff.fury_of_elune_up.down&remains<=6.6
actions.fury_of_elune+=/sunfire,if=buff.fury_of_elune_up.down&remains<=5.4
actions.fury_of_elune+=/stellar_flare,if=remains<7.2
actions.fury_of_elune+=/starsurge,if=buff.fury_of_elune_up.down&((astral_power>=92&cooldown.fury_of_elune.remains>gcd*3)|(cooldown.warrior_of_elune.remains<=5&cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.stack<2))
actions.fury_of_elune+=/solar_wrath,if=buff.solar_empowerment.up
actions.fury_of_elune+=/lunar_strike,if=buff.lunar_empowerment.stack=3|(buff.lunar_empowerment.remains<5&buff.lunar_empowerment.up)
actions.fury_of_elune+=/solar_wrath
actions.celestial_alignment_phase=starsurge
actions.celestial_alignment_phase+=/warrior_of_elune,if=buff.lunar_empowerment.stack>=2&((astral_power<=70&buff.blessing_of_elune.down)|(astral_power<=58&buff.blessing_of_elune.up))
actions.celestial_alignment_phase+=/lunar_strike,if=buff.warrior_of_elune.up
actions.celestial_alignment_phase+=/solar_wrath,if=buff.solar_empowerment.up
actions.celestial_alignment_phase+=/lunar_strike,if=buff.lunar_empowerment.up
actions.celestial_alignment_phase+=/solar_wrath,if=talent.natures_balance.enabled&dot.sunfire_dmg.remains<5&cast_time<dot.sunfire_dmg.remains
actions.celestial_alignment_phase+=/lunar_strike,if=talent.natures_balance.enabled&dot.moonfire_dmg.remains<5&cast_time<dot.moonfire_dmg.remains
actions.celestial_alignment_phase+=/solar_wrath
actions.single_target=new_moon,if=astral_power<=90
actions.single_target+=/half_moon,if=astral_power<=80
actions.single_target+=/full_moon,if=astral_power<=60
actions.single_target+=/starsurge
actions.single_target+=/warrior_of_elune,if=buff.lunar_empowerment.stack>=2&((astral_power<=80&buff.blessing_of_elune.down)|(astral_power<=72&buff.blessing_of_elune.up))
actions.single_target+=/lunar_strike,if=buff.warrior_of_elune.up
actions.single_target+=/solar_wrath,if=buff.solar_empowerment.up
actions.single_target+=/lunar_strike,if=buff.lunar_empowerment.up
actions.single_target+=/solar_wrath,if=talent.natures_balance.enabled&dot.sunfire_dmg.remains<5&cast_time<dot.sunfire_dmg.remains
actions.single_target+=/lunar_strike,if=talent.natures_balance.enabled&dot.moonfire_dmg.remains<5&cast_time<dot.moonfire_dmg.remains
actions.single_target+=/solar_wrath
]]

internal.apls["legion-dev::Tier19P::Druid_Feral_T19P"] = [[
actions.precombat=flask,type=flask_of_the_seventh_demon
actions.precombat+=/food,type=nightborne_delicacy_platter
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/healing_touch,if=talent.bloodtalons.enabled
actions.precombat+=/cat_form
actions.precombat+=/prowl
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=deadly_grace
actions=dash,if=!buff.cat_form.up
actions+=/cat_form
actions+=/wild_charge
actions+=/displacer_beast,if=movement.distance>10
actions+=/dash,if=movement.distance&buff.displacer_beast.down&buff.wild_charge_movement.down
actions+=/rake,if=buff.prowl.up|buff.shadowmeld.up
actions+=/auto_attack
actions+=/skull_bash
actions+=/berserk,if=buff.tigers_fury.up
actions+=/incarnation,if=cooldown.tigers_fury.remains<gcd
actions+=/use_item,slot=trinket2,if=(buff.tigers_fury.up&(target.time_to_die>trinket.stat.any.cooldown|target.time_to_die<45))|buff.incarnation.remains>20
actions+=/potion,name=deadly_grace,if=((buff.berserk.remains>10|buff.incarnation.remains>20)&(target.time_to_die<180|(trinket.proc.all.react&target.health.pct<25)))|target.time_to_die<=40
actions+=/tigers_fury,if=(!buff.clearcasting.react&energy.deficit>=60)|energy.deficit>=80|(t18_class_trinket&buff.berserk.up&buff.tigers_fury.down)
actions+=/incarnation,if=energy.time_to_max>1&energy>=35
actions+=/ferocious_bite,cycle_targets=1,if=dot.rip.ticking&dot.rip.remains<3&target.time_to_die>3&(target.health.pct<25|talent.sabertooth.enabled)
actions+=/healing_touch,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&(combo_points>=5|buff.predatory_swiftness.remains<1.5|(talent.bloodtalons.enabled&combo_points=2&buff.bloodtalons.down&cooldown.ashamanes_frenzy.remains<gcd)|(talent.elunes_guidance.enabled&((cooldown.elunes_guidance.remains<gcd&combo_points=0)|(buff.elunes_guidance.up&combo_points>=4))))
actions+=/call_action_list,name=sbt_opener,if=talent.sabertooth.enabled&time<20
actions+=/healing_touch,if=equipped.ailuro_pouncers&talent.bloodtalons.enabled&buff.predatory_swiftness.stack>1&buff.bloodtalons.down
actions+=/call_action_list,name=finisher
actions+=/call_action_list,name=generator
actions.finisher=pool_resource,for_next=1
actions.finisher+=/savage_roar,if=!buff.savage_roar.up&(combo_points=5|(talent.brutal_slash.enabled&spell_targets.brutal_slash>desired_targets&action.brutal_slash.charges>0))
actions.finisher+=/pool_resource,for_next=1
actions.finisher+=/thrash_cat,cycle_targets=1,if=remains<=duration*0.3&spell_targets.thrash_cat>=5
actions.finisher+=/pool_resource,for_next=1
actions.finisher+=/swipe_cat,if=spell_targets.swipe_cat>=8
actions.finisher+=/rip,cycle_targets=1,if=(!ticking|(remains<8&target.health.pct>25&!talent.sabertooth.enabled)|persistent_multiplier>dot.rip.pmultiplier)&target.time_to_die-remains>tick_time*4&combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|buff.clearcasting.react|talent.soul_of_the_forest.enabled|!dot.rip.ticking|(dot.rake.remains<1.5&spell_targets.swipe_cat<6))
actions.finisher+=/savage_roar,if=(buff.savage_roar.remains<=10.5|(buff.savage_roar.remains<=7.2&!talent.jagged_wounds.enabled))&combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|buff.clearcasting.react|talent.soul_of_the_forest.enabled|!dot.rip.ticking|(dot.rake.remains<1.5&spell_targets.swipe_cat<6))
actions.finisher+=/swipe_cat,if=combo_points=5&(spell_targets.swipe_cat>=6|(spell_targets.swipe_cat>=3&!talent.bloodtalons.enabled))&combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|(talent.moment_of_clarity.enabled&buff.clearcasting.react))
actions.finisher+=/ferocious_bite,max_energy=1,cycle_targets=1,if=combo_points=5&(energy.time_to_max<1|buff.berserk.up|buff.incarnation.up|buff.elunes_guidance.up|cooldown.tigers_fury.remains<3|set_bonus.tier18_4pc|(talent.moment_of_clarity.enabled&buff.clearcasting.react))
actions.generator=brutal_slash,if=spell_targets.brutal_slash>desired_targets&combo_points<5
actions.generator+=/ashamanes_frenzy,if=combo_points<=2&buff.elunes_guidance.down&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(buff.savage_roar.up|!talent.savage_roar.enabled)
actions.generator+=/pool_resource,if=talent.elunes_guidance.enabled&combo_points=0&energy<action.ferocious_bite.cost+25-energy.regen*cooldown.elunes_guidance.remains
actions.generator+=/elunes_guidance,if=talent.elunes_guidance.enabled&combo_points=0&energy>=action.ferocious_bite.cost+25
actions.generator+=/pool_resource,for_next=1
actions.generator+=/thrash_cat,if=talent.brutal_slash.enabled&spell_targets.thrash_cat>=9
actions.generator+=/pool_resource,for_next=1
actions.generator+=/swipe_cat,if=spell_targets.swipe_cat>=6
actions.generator+=/shadowmeld,if=combo_points<5&energy>=action.rake.cost&dot.rake.pmultiplier<2.1&buff.tigers_fury.up&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(!talent.incarnation.enabled|cooldown.incarnation.remains>18)&!buff.incarnation.up
actions.generator+=/pool_resource,for_next=1
actions.generator+=/rake,cycle_targets=1,if=combo_points<5&(!ticking|(!talent.bloodtalons.enabled&remains<duration*0.3)|(talent.bloodtalons.enabled&buff.bloodtalons.up&(!talent.soul_of_the_forest.enabled&remains<=7|remains<=5)&persistent_multiplier>dot.rake.pmultiplier*0.80))&target.time_to_die-remains>tick_time
actions.generator+=/moonfire_cat,cycle_targets=1,if=combo_points<5&remains<=4.2&target.time_to_die-remains>tick_time*2
actions.generator+=/pool_resource,for_next=1
actions.generator+=/thrash_cat,cycle_targets=1,if=remains<=duration*0.3&spell_targets.swipe_cat>=2
actions.generator+=/brutal_slash,if=combo_points<5&((raid_event.adds.exists&raid_event.adds.in>(1+max_charges-charges_fractional)*15)|(!raid_event.adds.exists&(charges_fractional>2.66&time>10)))
actions.generator+=/swipe_cat,if=combo_points<5&spell_targets.swipe_cat>=3
actions.generator+=/shred,if=combo_points<5&(spell_targets.swipe_cat<3|talent.brutal_slash.enabled)
actions.sbt_opener=healing_touch,if=talent.bloodtalons.enabled&combo_points=5&!buff.bloodtalons.up&!dot.rip.ticking
actions.sbt_opener+=/tigers_fury,if=!dot.rip.ticking&combo_points=5
]]

internal.apls["legion-dev::Tier19P::Druid_Guardian_T19P"] = [[
actions.precombat=flask,type=flask_of_the_seventh_demon
actions.precombat+=/food,type=azshari_salad
actions.precombat+=/bear_form
actions.precombat+=/snapshot_stats
actions=auto_attack
actions+=/skull_bash
actions+=/blood_fury
actions+=/berserking
actions+=/arcane_torrent
actions+=/use_item,slot=trinket2
actions+=/barkskin
actions+=/bristling_fur,if=buff.ironfur.remains<2&rage<40
actions+=/ironfur,if=buff.ironfur.down|rage.deficit<25
actions+=/frenzied_regeneration,if=!ticking&incoming_damage_6s%health.max>0.25+(2-charges_fractional)*0.15
actions+=/pulverize,cycle_targets=1,if=buff.pulverize.down
actions+=/mangle
actions+=/pulverize,cycle_targets=1,if=buff.pulverize.remains<gcd
actions+=/lunar_beam
actions+=/incarnation
actions+=/thrash_bear,if=active_enemies>=2
actions+=/pulverize,cycle_targets=1,if=buff.pulverize.remains<3.6
actions+=/thrash_bear,if=talent.pulverize.enabled&buff.pulverize.remains<3.6
actions+=/moonfire,cycle_targets=1,if=!ticking
actions+=/moonfire,cycle_targets=1,if=remains<3.6
actions+=/moonfire,cycle_targets=1,if=remains<7.2
actions+=/moonfire
]]

