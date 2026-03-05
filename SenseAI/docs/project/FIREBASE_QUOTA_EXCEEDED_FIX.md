# Firebase Quota Exceeded - How to Fix

## 🔴 Problem: "Quota exceeded" in Firebase Console

Your Firebase Firestore database has exceeded its **free tier (Spark plan) limits**. This is why data isn't saving.

---

## 📊 Firebase Free Tier Limits (Spark Plan)

### What You Get for Free:
- **Storage**: 1 GB total
- **Reads**: 50,000/day
- **Writes**: 20,000/day
- **Deletes**: 20,000/day
- **Network Egress**: 10 GB/month

### What Happens When Exceeded:
- ❌ All write operations are blocked
- ❌ Data cannot be saved
- ❌ Error: "Quota exceeded"

---

## ✅ Solutions (Choose One)

### Option 1: Upgrade to Blaze Plan (Pay-as-you-go) ⭐ RECOMMENDED

**Cost**: 
- **Free tier limits still apply** (same as Spark)
- **Pay only for usage above free tier**
- For research projects: Usually $0-5/month

**Steps**:
1. Go to Firebase Console
2. Click "Upgrade" button (you saw it in the sidebar)
3. Select "Blaze Plan"
4. Add billing information
5. **You still get free tier** - only pay for overage

**Benefits**:
- ✅ Unlimited usage
- ✅ Same free tier limits
- ✅ Pay only for what you use
- ✅ No more quota errors

---

### Option 2: Wait for Quota Reset (Temporary)

**Free tier resets daily**:
- Read/write quotas reset every 24 hours
- Storage quota doesn't reset (cumulative)

**Problem**: 
- If you've used 1 GB storage, you need to delete data
- Daily quotas reset, but storage doesn't

**Steps**:
1. Wait until next day (for read/write quotas)
2. Delete old/unnecessary data (for storage quota)
3. Continue using the system

---

### Option 3: Clean Up Data (Free Solution)

**If storage quota exceeded**:

1. **Delete Old Backups**:
   ```bash
   # Check backup folder size
   cd senseai_backend/backups
   # Delete old backups if needed
   ```

2. **Delete Test Data**:
   - Go to Firebase Console
   - Delete test children/sessions
   - Keep only real data

3. **Delete Orphaned Records**:
   - Use integrity check to find orphaned data
   - Delete sessions without children
   - Delete trials without sessions

---

### Option 4: Use Local SQLite Only (Offline Mode)

**Temporary workaround**:
- Disable Firebase sync temporarily
- Use only local SQLite database
- Export data manually when needed

**Not recommended** for production, but works for testing.

---

## 🎯 Recommended: Upgrade to Blaze Plan

### Why Blaze Plan is Best:

1. **Still Free for Most Usage**:
   - Same free tier limits
   - Only pay if you exceed
   - Research projects rarely exceed

2. **No More Quota Errors**:
   - Unlimited capacity
   - No blocking
   - Smooth operation

3. **Cost Estimate**:
   - **Typical research project**: $0-5/month
   - **Heavy usage**: $10-20/month
   - **Very heavy**: $50+/month (unlikely for your project)

4. **Easy to Upgrade**:
   - Click "Upgrade" in Firebase Console
   - Add billing (credit card)
   - Takes 2 minutes
   - Can downgrade anytime

---

## 📋 Quick Fix Steps

### Immediate Solution (Upgrade):

1. **Go to Firebase Console**:
   - https://console.firebase.google.com
   - Select your project: "SenseAI-Cognitive"

2. **Click "Upgrade"**:
   - In the sidebar (you saw it: "Upgrade" button)
   - Or go to: Project Settings → Usage and Billing

3. **Select Blaze Plan**:
   - Choose "Blaze (Pay as you go)"
   - Add billing information
   - Confirm upgrade

4. **Restart Backend**:
   ```powershell
   # Stop backend (Ctrl+C)
   cd senseai_backend
   npm start
   ```

5. **Test Data Saving**:
   - Try creating a child
   - Try creating a session
   - Should work now!

---

## 🔍 Check Your Current Usage

### In Firebase Console:

1. Go to **Firestore Database**
2. Click **"Usage"** tab
3. See:
   - Storage used
   - Reads today
   - Writes today
   - Deletes today

### What to Look For:
- **Storage**: If > 1 GB, need to delete data or upgrade
- **Writes**: If > 20,000/day, need to upgrade
- **Reads**: If > 50,000/day, need to upgrade

---

## 💡 Prevention Tips

### For Future:

1. **Regular Cleanup**:
   - Delete test data regularly
   - Remove old backups
   - Clean orphaned records

2. **Monitor Usage**:
   - Check Firebase Console weekly
   - Set up usage alerts (in Blaze plan)
   - Track data growth

3. **Optimize Queries**:
   - Use pagination
   - Limit query results
   - Cache data when possible

4. **Use Backups Wisely**:
   - Don't keep all backups in Firebase
   - Export backups to local files
   - Delete old backups

---

## 🚨 Emergency: Data Not Saving Right Now

### Quick Workaround:

1. **Export Current Data**:
   ```bash
   cd senseai_backend
   node scripts/export_firebase_to_csv.js
   ```

2. **Upgrade to Blaze** (2 minutes):
   - Firebase Console → Upgrade
   - Add billing
   - Confirm

3. **Continue Working**:
   - Data will save immediately after upgrade
   - No data loss
   - All existing data preserved

---

## 📊 Cost Breakdown (Blaze Plan)

### Free Tier (Included):
- 1 GB storage
- 50,000 reads/day
- 20,000 writes/day
- 20,000 deletes/day
- 10 GB network/month

### Pay-As-You-Go (Above Free Tier):
- Storage: $0.18/GB/month
- Reads: $0.06 per 100,000
- Writes: $0.18 per 100,000
- Deletes: $0.02 per 100,000
- Network: $0.12/GB

### Example Costs:
- **Small project** (within free tier): **$0/month**
- **Medium project** (2x free tier): **$2-5/month**
- **Large project** (10x free tier): **$10-20/month**

---

## ✅ Action Plan

### Right Now:
1. ✅ **Upgrade to Blaze Plan** (recommended)
2. ✅ **Restart backend**
3. ✅ **Test data saving**

### This Week:
1. ✅ **Monitor usage** in Firebase Console
2. ✅ **Clean up test data** if needed
3. ✅ **Set up usage alerts** (optional)

### Long Term:
1. ✅ **Regular data cleanup**
2. ✅ **Optimize queries**
3. ✅ **Monitor costs**

---

## 🆘 Still Having Issues?

### If Upgrade Doesn't Work:

1. **Check Billing**:
   - Verify billing is active
   - Check payment method
   - Wait 5-10 minutes for activation

2. **Clear Cache**:
   - Restart backend
   - Clear browser cache
   - Try again

3. **Check Firebase Status**:
   - https://status.firebase.google.com
   - Check for outages

4. **Contact Support**:
   - Firebase Support (if on Blaze plan)
   - Check Firebase documentation

---

## 📝 Summary

**Problem**: Firebase free tier quota exceeded  
**Solution**: Upgrade to Blaze plan (recommended)  
**Cost**: Usually $0-5/month for research projects  
**Time**: 2 minutes to upgrade  
**Result**: Data saves immediately after upgrade  

---

**Upgrade now and your data will save!** 🚀



