#!/usr/bin/env python3
"""
Verification script to ensure age group exports contain only correct session types
"""

import pandas as pd
import sys

def verify_export(filepath, expected_age_group, expected_session_type):
    """Verify that an export file contains only the expected session type"""
    try:
        df = pd.read_csv(filepath)
        
        print(f"\n{'='*60}")
        print(f"Verifying: {filepath}")
        print(f"Expected Age Group: {expected_age_group}")
        print(f"Expected Session Type: {expected_session_type}")
        print(f"{'='*60}")
        
        print(f"\n📊 Export Statistics:")
        print(f"  Total rows: {len(df)}")
        
        if 'session_type' in df.columns:
            session_types = df['session_type'].value_counts()
            print(f"\n  Session Types:")
            for st, count in session_types.items():
                marker = "✅" if st == expected_session_type else "❌"
                print(f"    {marker} {st}: {count}")
        
        if 'age_group' in df.columns:
            age_groups = df['age_group'].value_counts()
            print(f"\n  Age Groups:")
            for ag, count in age_groups.items():
                marker = "✅" if ag == expected_age_group else "❌"
                print(f"    {marker} {ag}: {count}")
        
        # Verification
        errors = []
        warnings = []
        
        if 'session_type' in df.columns:
            wrong_types = df[df['session_type'] != expected_session_type]
            if len(wrong_types) > 0:
                errors.append(f"❌ Found {len(wrong_types)} rows with wrong session_type!")
                print(f"\n  ❌ ERROR: Found incorrect session types:")
                print(wrong_types[['session_id', 'session_type', 'age_group']].head())
            else:
                print(f"\n  ✅ All {len(df)} rows have correct session_type: {expected_session_type}")
        
        if 'age_group' in df.columns:
            wrong_ages = df[df['age_group'] != expected_age_group]
            if len(wrong_ages) > 0:
                warnings.append(f"⚠️ Found {len(wrong_ages)} rows with different age_group")
                print(f"\n  ⚠️ WARNING: Found rows with different age_group:")
                print(wrong_ages[['session_id', 'session_type', 'age_group']].head())
            else:
                print(f"\n  ✅ All {len(df)} rows have correct age_group: {expected_age_group}")
        
        # Check age_months if available
        if 'age_months' in df.columns:
            if expected_age_group == '2-3.5':
                age_range = (24, 42)
            elif expected_age_group == '3.5-5.5':
                age_range = (42, 66)
            elif expected_age_group == '5.5-6.9':
                age_range = (66, 83)
            else:
                age_range = None
            
            if age_range:
                out_of_range = df[(df['age_months'] < age_range[0]) | (df['age_months'] >= age_range[1])]
                if len(out_of_range) > 0:
                    warnings.append(f"⚠️ Found {len(out_of_range)} rows with age_months outside range")
                    print(f"\n  ⚠️ WARNING: Found rows with age_months outside {age_range[0]}-{age_range[1]} months:")
                    print(out_of_range[['session_id', 'age_months', 'session_type']].head())
                else:
                    print(f"\n  ✅ All ages are within range {age_range[0]}-{age_range[1]} months")
        
        # Final verdict
        if errors:
            print(f"\n❌ VERIFICATION FAILED:")
            for error in errors:
                print(f"  {error}")
            return False
        elif warnings:
            print(f"\n⚠️ VERIFICATION PASSED WITH WARNINGS:")
            for warning in warnings:
                print(f"  {warning}")
            return True
        else:
            print(f"\n✅ VERIFICATION PASSED: Export is clean and correct!")
            return True
            
    except FileNotFoundError:
        print(f"❌ File not found: {filepath}")
        return False
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return False

if __name__ == "__main__":
    print("🔍 Age Group Export Verification Tool")
    print("="*60)
    
    # Expected mappings
    mappings = [
        ('age_2_3_5_training.csv', '2-3.5', 'ai_doctor_bot'),
        ('age_3_5_5_5_training.csv', '3.5-5.5', 'frog_jump'),
        ('age_5_5_6_9_training.csv', '5.5-6.9', 'color_shape'),
    ]
    
    results = []
    for filepath, age_group, session_type in mappings:
        result = verify_export(filepath, age_group, session_type)
        results.append((filepath, result))
    
    print(f"\n{'='*60}")
    print("📋 SUMMARY")
    print(f"{'='*60}")
    
    all_passed = True
    for filepath, passed in results:
        status = "✅ PASSED" if passed else "❌ FAILED"
        print(f"  {status}: {filepath}")
        if not passed:
            all_passed = False
    
    if all_passed:
        print(f"\n✅ All exports verified successfully!")
        print("   Your datasets are ready for separate model training.")
    else:
        print(f"\n❌ Some exports failed verification.")
        print("   Please check the exports and re-export with correct filters.")
    
    sys.exit(0 if all_passed else 1)
