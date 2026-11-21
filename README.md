# Customer Segmentation: SQL Analysis

**Business question:** Which customers are worth targeting for promotions at a specialty food retailer, and what should we offer them?

**Tools:** SQL (SQLite, DB Browser for SQLite), Tableau Public
**Data:** [Customer Personality Analysis (Kaggle)](https://www.kaggle.com/datasets/imakash3011/customer-personality-analysis)Public customer dataset (2,240 customers; 2,216 after removing 24 rows with missing income).
**Related:** [Tableau dashboard](https://public.tableau.com/app/profile/brinn.jones/viz/CustomerSegmentationDashboard_17939693369080/CustomerSegmentationSpecialtyFoodRetailerSampleData#1)

## Approach
1. Imported the raw file and split it into three tables: `customers`, `spend`, and `campaigns`.
2. Cleaned the data: removed rows with missing income and cast fields to the right types.
3. Wrote queries using joins, CASE segmentation, CTEs, UNION ALL, and window functions.
4. Visualized the segments in Tableau.

## Key findings
| Income bracket | Customers | Avg. spend | Campaign response rate |
|---|---|---|---|
| High ($70K+) | 508 | $1,377 | 28.0% |
| Mid ($35K-$70K) | 1,159 | $519 | 11.7% |
| Low (under $35K) | 549 | $80 | 10.0% |

- High-income customers spend about **17x more** than low-income customers ($1,377 vs. $80).
- They are about 23% of customers but generate about **52% of revenue**. Low-income customers are about 25% of customers but only 3% of revenue.
- High-income customers also respond to campaigns at nearly **3x the rate** of the other groups (28% vs. 10-12%).
- Wine makes up about **50% of total spend**, followed by meat at about 28%.

## Recommendation
Focus promotions on the high-income segment, led by wine and meat offers. They spend the most and are the most likely to respond, so each campaign dollar goes further there.

## Data notes
- 24 customers had no income recorded and were excluded.
- One record has an income of $666,666 (an outlier). Excluding it changes the High-bracket average by about $2.
- Some birth years are implausible (earliest is 1893), so age was not used in this analysis.
- Response rate reflects the dataset's single "Response" flag (the most recent campaign).

## Files
- `queries.sql`: table setup and all 5 queries, each labeled with the question it answers
