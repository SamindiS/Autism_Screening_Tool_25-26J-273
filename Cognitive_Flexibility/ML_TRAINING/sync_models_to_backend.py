"""
Sync trained model artifacts from ML_TRAINING/models/ into the backend ML engine folder.

Copies:
- model_age_2_3_5_questionnaire.pkl
- model_age_3_5_5_5_frog_jump.pkl
- model_age_5_5_6_9_color_shape.pkl

And their scalers.

Also generates features_*.json from scaler.feature_names_in_ so the backend can
prepare features in the exact training order.

Run from project root:
  python ML_TRAINING/sync_models_to_backend.py
"""

from __future__ import annotations

import json
import shutil
from pathlib import Path

import joblib


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = PROJECT_ROOT / "ML_TRAINING" / "models"
DEST_DIR = PROJECT_ROOT / "senseai_backend" / "ml_engine" / "models"


MODELS = [
    {
        "model": "model_age_2_3_5_questionnaire.pkl",
        "scaler_candidates": [
            "scaler_age_2_3_5_questionnaire.pkl",
            "scaler_model_age_2_3_5_questionnaire.pkl",
        ],
        "features": "features_age_2_3_5_questionnaire.json",
    },
    {
        "model": "model_age_3_5_5_5_frog_jump.pkl",
        "scaler_candidates": [
            "scaler_age_3_5_5_5_frog_jump.pkl",
            "scaler_model_age_3_5_5_5_frog_jump.pkl",
        ],
        "features": "features_age_3_5_5_5_frog_jump.json",
    },
    {
        "model": "model_age_5_5_6_9_color_shape.pkl",
        "scaler_candidates": [
            "scaler_age_5_5_6_9_color_shape.pkl",
            "scaler_model_age_5_5_6_9_color_shape.pkl",
        ],
        "features": "features_age_5_5_6_9_color_shape.json",
    },
]


def _find_first_existing(dir_path: Path, candidates: list[str]) -> Path:
    for name in candidates:
        p = dir_path / name
        if p.exists():
            return p
    raise FileNotFoundError(f"None of these files exist in {dir_path}: {candidates}")


def main() -> None:
    print(f"[INFO] PROJECT_ROOT: {PROJECT_ROOT}")
    print(f"[INFO] SRC_DIR: {SRC_DIR}")
    print(f"[INFO] DEST_DIR: {DEST_DIR}")
    DEST_DIR.mkdir(parents=True, exist_ok=True)

    for spec in MODELS:
        model_name = spec["model"]
        features_name = spec["features"]

        src_model = SRC_DIR / model_name
        if not src_model.exists():
            raise FileNotFoundError(f"Missing model in training folder: {src_model}")

        src_scaler = _find_first_existing(SRC_DIR, spec["scaler_candidates"])

        dest_model = DEST_DIR / model_name
        # Write scalers using the backend preferred naming: scaler_age_*.pkl
        dest_scaler_name = spec["scaler_candidates"][0]
        dest_scaler = DEST_DIR / dest_scaler_name
        dest_features = DEST_DIR / features_name

        print(f"\n[COPY] {model_name}")
        shutil.copy2(src_model, dest_model)
        print(f"  - model -> {dest_model}")

        shutil.copy2(src_scaler, dest_scaler)
        print(f"  - scaler -> {dest_scaler} (from {src_scaler.name})")

        # Generate features json from scaler.feature_names_in_
        scaler = joblib.load(dest_scaler)
        feature_names = list(getattr(scaler, "feature_names_in_", []))
        if not feature_names:
            raise RuntimeError(
                f"Scaler {dest_scaler.name} has no feature_names_in_. "
                f"Train using a pandas DataFrame so feature names are preserved."
            )

        with open(dest_features, "w", encoding="utf-8") as f:
            json.dump(feature_names, f, indent=2)
        print(f"  - features -> {dest_features} ({len(feature_names)} features)")

    print("\n[OK] Sync complete. Restart the backend + ML engine.")


if __name__ == "__main__":
    main()

