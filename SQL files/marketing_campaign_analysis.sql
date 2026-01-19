-- 1)How is each campaign performing in terms of reach, engagement, and conversions?

SELECT
    c.campaign_id,
    c.campaign_name,
    c.channel,
    c.region,
    SUM(p.impressions) AS total_impressions,
    SUM(p.clicks) AS total_clicks,
    SUM(p.conversions) AS total_conversions,
    ROUND(SUM(p.clicks) / SUM(p.impressions), 4) AS ctr,
    ROUND(SUM(p.conversions) / SUM(p.clicks), 4) AS conversion_rate,
    SUM(p.revenue) AS total_revenue
FROM campaigns c
JOIN campaign_performance p
    ON c.campaign_id = p.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.channel, c.region
ORDER BY total_revenue DESC;

-- 2)Which campaigns are profitable and which are wasting budget?

SELECT
    c.campaign_name,
    c.channel,
    SUM(p.revenue) AS total_revenue,
    c.budget,
    ROUND((SUM(p.revenue) - c.budget) / c.budget, 2) AS roi
FROM campaigns c
JOIN campaign_performance p
    ON c.campaign_id = p.campaign_id
GROUP BY c.campaign_name, c.channel, c.budget
ORDER BY roi DESC;

-- 3)Which marketing channel performs best overall?

SELECT
    c.channel,
    SUM(p.impressions) AS impressions,
    SUM(p.clicks) AS clicks,
    SUM(p.conversions) AS conversions,
    ROUND(SUM(p.conversions) / SUM(p.clicks), 4) AS conversion_rate,
    SUM(p.revenue) AS total_revenue
FROM campaigns c
JOIN campaign_performance p
    ON c.campaign_id = p.campaign_id
GROUP BY c.channel
ORDER BY total_revenue DESC;

-- 4)Which regions generate the most value?

SELECT
    c.region,
    SUM(p.revenue) AS total_revenue,
    SUM(p.conversions) AS total_conversions
FROM campaigns c
JOIN campaign_performance p
    ON c.campaign_id = p.campaign_id
GROUP BY c.region
ORDER BY total_revenue DESC;

-- 5)Which customer segments are most cost-effective to acquire?

SELECT
    cu.segment,
    COUNT(a.customer_id) AS customers_acquired,
    ROUND(AVG(a.acquisition_cost), 2) AS avg_cac
FROM customers cu
JOIN customer_acquisition a
    ON cu.customer_id = a.customer_id
GROUP BY cu.segment
ORDER BY avg_cac;

-- 6)Which campaigns should be scaled or removed?

WITH campaign_roi AS (
    SELECT
        c.campaign_name,
        ROUND((SUM(p.revenue) - c.budget) / c.budget, 2) AS roi
    FROM campaigns c
    JOIN campaign_performance p
        ON c.campaign_id = p.campaign_id
    GROUP BY c.campaign_name, c.budget
)
SELECT
    campaign_name,
    roi,
    CASE
        WHEN roi >= 1 THEN 'High Performing'
        WHEN roi BETWEEN 0 AND 0.99 THEN 'Average Performing'
        ELSE 'Low Performing'
    END AS performance_category
FROM campaign_roi
ORDER BY roi DESC;



