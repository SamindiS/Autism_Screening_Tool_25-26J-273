/**
 * Age cohort helpers: canonical study labels vs legacy strings used in ML tooling.
 *
 * Canonical (app / Firestore):  '2-3.4' | '3.5-5.4' | '5.5-6.9'
 * Legacy (ML engine / exports): '2-3.5' | '3.5-5.5' | '5.5-6.9' (same month bands)
 */

const CANONICAL = {
  FIRST: '2-3.4',
  SECOND: '3.5-5.4',
  THIRD: '5.5-6.9',
};

const LEGACY = {
  FIRST: '2-3.5',
  SECOND: '3.5-5.5',
  THIRD: '5.5-6.9',
};

const TO_CANONICAL = {
  [CANONICAL.FIRST]: CANONICAL.FIRST,
  [CANONICAL.SECOND]: CANONICAL.SECOND,
  [CANONICAL.THIRD]: CANONICAL.THIRD,
  [LEGACY.FIRST]: CANONICAL.FIRST,
  [LEGACY.SECOND]: CANONICAL.SECOND,
  [LEGACY.THIRD]: CANONICAL.THIRD,
};

const TO_ML_ENGINE = {
  [CANONICAL.FIRST]: LEGACY.FIRST,
  [CANONICAL.SECOND]: LEGACY.SECOND,
  [CANONICAL.THIRD]: LEGACY.THIRD,
  [LEGACY.FIRST]: LEGACY.FIRST,
  [LEGACY.SECOND]: LEGACY.SECOND,
  [LEGACY.THIRD]: LEGACY.THIRD,
};

function normalizeToCanonical(ageGroup) {
  if (!ageGroup) return null;
  const key = String(ageGroup).trim();
  return TO_CANONICAL[key] || null;
}

/** Accept canonical or legacy filter keys; internal logic uses canonical. */
function normalizeExportAgeGroupParam(ageGroup) {
  const c = normalizeToCanonical(ageGroup);
  return c || String(ageGroup).trim();
}

function sessionAgeGroupMatchesFilter(filterAgeGroup, sessionAgeGroup) {
  const f = normalizeToCanonical(filterAgeGroup);
  const s = normalizeToCanonical(sessionAgeGroup);
  if (f && s) return f === s;
  if (!f || !sessionAgeGroup) return false;
  return String(sessionAgeGroup).trim() === String(filterAgeGroup).trim();
}

function monthsInCanonicalCohort(canonicalBand, ageMonths) {
  if (ageMonths == null || Number.isNaN(ageMonths)) return false;
  if (canonicalBand === CANONICAL.FIRST) return ageMonths >= 24 && ageMonths < 42;
  if (canonicalBand === CANONICAL.SECOND) return ageMonths >= 42 && ageMonths < 66;
  if (canonicalBand === CANONICAL.THIRD) return ageMonths >= 66 && ageMonths < 83;
  return false;
}

function ageGroupToMlEngine(ageGroup) {
  if (!ageGroup) return ageGroup;
  const key = String(ageGroup).trim();
  return TO_ML_ENGINE[key] || key;
}

module.exports = {
  CANONICAL,
  LEGACY,
  normalizeToCanonical,
  normalizeExportAgeGroupParam,
  sessionAgeGroupMatchesFilter,
  monthsInCanonicalCohort,
  ageGroupToMlEngine,
};
