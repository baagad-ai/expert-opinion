# Input: SaaS Pricing Strategy Memo

**Artifact type:** Internal strategy memo  
**Author:** Head of Product, Vantara Analytics  
**Date:** 2024-02-01  
**Context:** Submitted to the leadership team for review ahead of the Q2 pricing overhaul. Vantara provides B2B analytics dashboards for e-commerce teams.

---

## Memo: Revised Pricing Strategy — Q2 2024

### Executive Summary

We propose migrating from our current single-tier unlimited plan ($79/mo flat) to a three-tier seat-based model. This restructuring is projected to increase ARPU by 40% within 12 months while maintaining our conversion rate among SMB customers. The free tier will be sunset as part of this transition.

---

### Proposed Tier Structure

| Tier | Price | Seats | Features |
|------|-------|-------|----------|
| **Starter** | $29/mo | 1 seat | Core dashboards, 90-day data retention, email support |
| **Growth** | $99/mo | Up to 5 seats | All Starter features + custom reports, API access, 1-year retention, Slack alerts |
| **Enterprise** | $299/mo | Unlimited seats | All Growth features + SSO, dedicated CSM, priority SLA, data export, white-labeling |

Annual billing discount: 20% off (billed annually). No per-seat overages — each tier is a flat rate.

---

### Free Tier Sunset Plan

Our current free tier (capped at 1 seat, 30-day data retention) has approximately 2,400 registered users. Of these:
- **~320 users** have been active in the last 30 days ("engaged free users")
- **~2,080 users** have been inactive for 90+ days (dormant accounts)

Proposed sunset timeline:
1. **Week 1–2:** Email all free users announcing the change with a 90-day grace period.
2. **Week 3:** Offer engaged free users a 6-month Starter plan at $9/mo (limited-time migration offer).
3. **Month 4:** Deactivate all remaining free accounts.

**Assumption:** We expect 15–20% of the 320 engaged free users to convert to paid plans, yielding approximately 48–64 net new Starter subscribers.

---

### Competitive Landscape

**Competitor A — Databox ($59/$169/$399/mo):** Seat-based model, 3 tiers. Their free tier remains active and is heavily marketed as a product-led growth (PLG) driver. They report 18% free-to-paid conversion. Removing our free tier puts us at a structural PLG disadvantage versus Databox.

**Competitor B — Klipfolio ($99/$199/custom):** No free tier, feature-gated trials only. Their customer profile skews mid-market (50–500 employees). Our Starter tier at $29/mo is positioned below their entry point, giving us a price-based moat for early-stage e-commerce teams.

---

### Annual Discount Structure

We will offer 20% annual discount across all tiers:
- Starter annual: $278/yr (vs. $348 monthly)
- Growth annual: $950/yr (vs. $1,188 monthly)
- Enterprise annual: $2,870/yr (vs. $3,588 monthly)

Target: 35% of new subscribers on annual plans within 6 months of launch. This improves cash flow and reduces monthly churn exposure.

---

### Key Assumptions & Risks

1. Seat-based pricing aligns with how enterprise buyers budget (per-seat line items). Usage-based pricing (e.g., per dashboard or per API call) was considered and rejected — we lack the billing infrastructure and the model creates unpredictable invoices that slow enterprise procurement.
2. The $29 Starter price point is below our current CAC-to-LTV target for SMB — it is a deliberate loss-leader to compete with Databox's free tier removal gap.
3. The 90-day free tier grace period is operationally simple but may create a concentrated churn spike at day 90 if conversion rates are lower than projected.
