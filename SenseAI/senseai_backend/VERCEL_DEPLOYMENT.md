# Vercel deployment – tablet app access

## 1. Disable Deployment Protection (for 401 "Authentication Required")

If the tablet app gets **401** and the health check returns an HTML "Authentication Required" page, Vercel **Deployment Protection** is blocking unauthenticated requests. The tablet cannot use Vercel SSO.

**Fix:**

1. Open [Vercel Dashboard](https://vercel.com) → your project.
2. Go to **Settings** → **Deployment Protection**.
3. Set **Vercel Authentication** (or overall protection) to **None**, or use **Standard** so that **Production** is public and only preview deployments are protected.
4. Save. No redeploy needed for this change.

After this, `https://your-project.vercel.app/health` and `/api/*` should respond without login.

---

## 2. Firestore index (for "The query requires an index")

If after login you see:

```text
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

**Fix:**

1. Open the **exact link** from the error message in your browser (Firebase Console).
2. Confirm the composite index (e.g. `sessions`, fields `created_by_clinician_id`, `created_at`).
3. Click **Create index** and wait until it finishes building.

Then run the app again; the sessions query will use the new index.
