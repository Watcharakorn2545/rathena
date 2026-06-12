// Copyright (c) rAthena Dev Teams - Licensed under GNU GPL
// For more information, see LICENCE in the main folder

#include "chaincrushcombo.hpp"

#include <config/core.hpp>

#include "map/status.hpp"

SkillChainCrushCombo::SkillChainCrushCombo() : WeaponSkillImpl(CH_CHAINCRUSH) {
}

void SkillChainCrushCombo::calculateSkillRatio(const Damage* wd, const block_list* src, const block_list* target, uint16 skill_lv, int32& skillratio, int32 mflag) const {
#ifdef RENEWAL
	skillratio += -100 + 200 * skill_lv + 100;
	RE_LVL_DMOD(100);
#else
	skillratio += 300 + 100 * skill_lv + 100;
#endif

	int32 lv = status_get_lv(src);
	skillratio = skillratio * (1000 + lv) / 1000;

	if (const status_change* sc = status_get_sc(src); sc != nullptr && sc->getSCE(SC_GT_ENERGYGAIN))
		skillratio += skillratio * 50 / 100;
}
