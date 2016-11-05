local _, internal = ...
internal.apls = internal.apls or {}

internal.apls["legion-dev::priest::shadow"] = [[
actions.precombat=flask,type=flask_of_the_whispered_pact
actions.precombat+=/food,type=azshari_salad
actions.precombat+=/augmentation,type=defiled
actions.precombat+=/snapshot_stats
actions.precombat+=/potion,name=deadly_grace
actions.precombat+=/shadowform,if=!buff.shadowform.up
actions.precombat+=/mind_blast
actions=potion,name=deadly_grace,if=buff.bloodlust.react|target.time_to_die<=40|(buff.voidform.stack>80&buff.power_infusion.up)
actions+=/variable,op=set,name=actors_fight_time_mod,value=0
actions+=/variable,op=set,name=actors_fight_time_mod,value=-((-(450)+(time+target.time_to_die))%10),if=time+target.time_to_die>450&time+target.time_to_die<600
actions+=/variable,op=set,name=actors_fight_time_mod,value=((450-(time+target.time_to_die))%5),if=time+target.time_to_die<=450
actions+=/variable,op=set,name=s2mcheck,value=0.8*(135+((raw_haste_pct*25)*(2+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank)-(1*talent.sanlayn.enabled))))-(variable.actors_fight_time_mod*nonexecute_actors_pct)
actions+=/variable,op=min,name=s2mcheck,value=180
actions+=/call_action_list,name=s2m,if=buff.voidform.up&buff.surrender_to_madness.up
actions+=/call_action_list,name=vf,if=buff.voidform.up
actions+=/call_action_list,name=main
actions.main=surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=variable.s2mcheck
actions.main+=/mindbender,if=talent.mindbender.enabled&!talent.surrender_to_madness.enabled
actions.main+=/mindbender,if=talent.mindbender.enabled&talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck+60
actions.main+=/shadow_word_pain,if=dot.shadow_word_pain.remains<(3+(4%3))*gcd
actions.main+=/vampiric_touch,if=dot.vampiric_touch.remains<(4+(4%3))*gcd
actions.main+=/void_eruption,if=insanity>=85|(talent.auspicious_spirits.enabled&insanity>=(80-shadowy_apparitions_in_flight*4))
actions.main+=/shadow_crash,if=talent.shadow_crash.enabled
actions.main+=/mindbender,if=talent.mindbender.enabled&set_bonus.tier18_2pc
actions.main+=/shadow_word_pain,if=!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
actions.main+=/vampiric_touch,if=!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
actions.main+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&cooldown.shadow_word_death.charges=2&insanity<=90
actions.main+=/shadow_word_death,if=talent.reaper_of_souls.enabled&cooldown.shadow_word_death.charges=2&insanity<=70
actions.main+=/mind_blast,if=talent.legacy_of_the_void.enabled&(insanity<=81|(insanity<=75.2&talent.fortress_of_the_mind.enabled))
actions.main+=/mind_blast,if=!talent.legacy_of_the_void.enabled|(insanity<=96|(insanity<=95.2&talent.fortress_of_the_mind.enabled))
actions.main+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
actions.main+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
actions.main+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
actions.main+=/shadow_word_void,if=(insanity<=70&talent.legacy_of_the_void.enabled)|(insanity<=85&!talent.legacy_of_the_void.enabled)
actions.main+=/mind_flay,line_cd=10,if=!talent.mind_spike.enabled&active_enemies>=2&active_enemies<4,interrupt=1,chain=1
actions.main+=/mind_sear,if=active_enemies>=2,interrupt=1,chain=1
actions.main+=/mind_flay,if=!talent.mind_spike.enabled,interrupt=1,chain=1
actions.main+=/mind_spike,if=talent.mind_spike.enabled
actions.main+=/shadow_word_pain
actions.s2m=shadow_crash,if=talent.shadow_crash.enabled
actions.s2m+=/mindbender,if=talent.mindbender.enabled
actions.s2m+=/void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5
actions.s2m+=/berserking,if=buff.voidform.stack>=80
actions.s2m+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+15)<100&!buff.power_infusion.up&buff.insanity_drain_stacks.stack<=77&cooldown.shadow_word_death.charges=2
actions.s2m+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+65)<100&!buff.power_infusion.up&buff.insanity_drain_stacks.stack<=77&cooldown.shadow_word_death.charges=2
actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&dot.vampiric_touch.remains<3.5*gcd&target.time_to_die>10,cycle_targets=1
actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)&target.time_to_die>10,cycle_targets=1
actions.s2m+=/void_bolt,if=dot.vampiric_touch.remains<3.5*gcd&(talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))&target.time_to_die>10,cycle_targets=1
actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1
actions.s2m+=/void_bolt
actions.s2m+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+15)<100
actions.s2m+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+65)<100
actions.s2m+=/power_infusion,if=buff.insanity_drain_stacks.stack>=77
actions.s2m+=/wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
actions.s2m+=/dispersion,if=current_insanity_drain*gcd.max>insanity&!buff.power_infusion.up
actions.s2m+=/mind_blast
actions.s2m+=/wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28
actions.s2m+=/shadow_word_death,if=cooldown.shadow_word_death.charges=2
actions.s2m+=/shadowfiend,if=!talent.mindbender.enabled,if=buff.voidform.stack>15
actions.s2m+=/shadow_word_void,if=(insanity-(current_insanity_drain*gcd.max)+75)<100
actions.s2m+=/shadow_word_pain,if=!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
actions.s2m+=/vampiric_touch,if=!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
actions.s2m+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
actions.s2m+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
actions.s2m+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
actions.s2m+=/wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable|action.void_bolt.usable_in<gcd.max*0.8
actions.s2m+=/mind_flay,line_cd=10,if=!talent.mind_spike.enabled&active_enemies>=2&active_enemies<4,chain=1,interrupt_immediate=1,interrupt_if=action.void_bolt.usable
actions.s2m+=/mind_sear,if=active_enemies>=2,interrupt=1
actions.s2m+=/mind_flay,if=!talent.mind_spike.enabled,chain=1,interrupt_immediate=1,interrupt_if=action.void_bolt.usable
actions.s2m+=/mind_spike,if=talent.mind_spike.enabled
actions.vf=surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)&target.time_to_die<=variable.s2mcheck-(buff.insanity_drain_stacks.stack)
actions.vf+=/shadow_crash,if=talent.shadow_crash.enabled
actions.vf+=/void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+60
actions.vf+=/void_torrent,if=!talent.surrender_to_madness.enabled
actions.vf+=/mindbender,if=talent.mindbender.enabled&!talent.surrender_to_madness.enabled
actions.vf+=/mindbender,if=talent.mindbender.enabled&talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+30
actions.vf+=/power_infusion,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.stack<=30&!talent.surrender_to_madness.enabled
actions.vf+=/power_infusion,if=buff.voidform.stack>=10&talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+25
actions.vf+=/berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.stack<=20&!talent.surrender_to_madness.enabled
actions.vf+=/berserking,if=buff.voidform.stack>=10&talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+60
actions.vf+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&dot.vampiric_touch.remains<3.5*gcd&target.time_to_die>10,cycle_targets=1
actions.vf+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)&target.time_to_die>10,cycle_targets=1
actions.vf+=/void_bolt,if=dot.vampiric_touch.remains<3.5*gcd&(talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))&target.time_to_die>10,cycle_targets=1
actions.vf+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1
actions.vf+=/void_bolt
actions.vf+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+10)<100
actions.vf+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100
actions.vf+=/wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
actions.vf+=/mind_blast
actions.vf+=/wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28
actions.vf+=/shadow_word_death,if=cooldown.shadow_word_death.charges=2
actions.vf+=/shadowfiend,if=!talent.mindbender.enabled,if=buff.voidform.stack>15
actions.vf+=/shadow_word_void,if=(insanity-(current_insanity_drain*gcd.max)+25)<100
actions.vf+=/shadow_word_pain,if=!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
actions.vf+=/vampiric_touch,if=!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
actions.vf+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
actions.vf+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
actions.vf+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
actions.vf+=/wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable|action.void_bolt.usable_in<gcd.max*0.8
actions.vf+=/mind_flay,line_cd=10,if=!talent.mind_spike.enabled&active_enemies>=2&active_enemies<4,chain=1,interrupt_immediate=1,interrupt_if=action.void_bolt.usable
actions.vf+=/mind_sear,if=active_enemies>=2,interrupt_immediate=1,interrupt_if=action.void_bolt.usable
actions.vf+=/mind_flay,if=!talent.mind_spike.enabled,chain=1,interrupt_immediate=1,interrupt_if=action.void_bolt.usable
actions.vf+=/mind_spike,if=talent.mind_spike.enabled
actions.vf+=/shadow_word_pain
]]
