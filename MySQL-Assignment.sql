use blinkit;

-- Customer Insights
-- 1.1 Top 10 customers by total order value
SELECT 
    c.customer_id, SUM(o.order_total) AS total_values
FROM
    customers c
        JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_values
LIMIT 10;

-- 1.2 Count the number of customers in each segment (Premium, Regular, Inactive, New)
SELECT 
    COUNT(customer_id), customer_segment
FROM
    blinkit.customers
GROUP BY customer_segment;

-- 1.3 Find customers with an average order value above 500 and more than 10 orders
SELECT 
    customer_id, total_orders, avg_order_value
FROM
    blinkit.customers
WHERE
    avg_order_value > 500
        AND total_orders > 10;

-- 2. Order and Delivery Performance
-- 2.1 List orders that were delivered late along with reasons for delay
SELECT 
    o.order_id,
    o.customer_id,
    o.promised_delivery_time,
    o.actual_delivery_time,
    dp.reasons_if_delayed
FROM
    orders o
        JOIN
    delivery_performance dp ON o.order_id = dp.order_id
WHERE
    dp.reasons_if_delayed IS NOT NULL
        AND dp.reasons_if_delayed <> '';

-- 2.2 Calculate the average delivery time (in minutes) per delivery partner
SELECT 
    delivery_partner_id,
    AVG(delivery_time_minutes) AS average_time
FROM
    delivery_performance
GROUP BY delivery_partner_id
ORDER BY average_time;

-- 2.3 Find the top 5 stores by total order revenue
SELECT 
    store_id, SUM(order_total) AS Total_Revenue
FROM
    orders
GROUP BY store_id
ORDER BY Total_Revenue DESC
LIMIT 5;

-- 3. Product and Inventory Analysis
-- 3.1 Identify products that have had damaged stock more than 5 times in total
SELECT 
    product_id, SUM(damaged_stock) AS total_damaged_stock
FROM
    inventory
GROUP BY product_id
HAVING total_damaged_stock > 5;

-- 3.2 Calculate the total quantity ordered for each product
SELECT 
    oi.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM
    order_items oi
        JOIN
    products p ON p.product_id = oi.product_id
GROUP BY oi.product_id , p.product_name
ORDER BY total_quantity DESC;

-- 3.3 Find products that often fall below the minimum stock level
SELECT 
    p.product_id,
    p.product_name,
    p.min_stock_level,
    SUM(i.stock_received - i.damaged_stock) current_stock
FROM
    products p
        JOIN
    inventory i ON p.product_id = i.product_id
GROUP BY p.product_id , p.product_name , p.min_stock_level
HAVING current_stock < p.min_stock_level;

-- 4. Marketing Campaign Effectiveness
-- 4.1 Calculate total revenue generated and ROAS for each marketing campaign
SELECT 
    campaign_id,
    campaign_name,
    SUM(revenue_generated) AS total_revenue,
    SUM(spend) AS total_spend,
    SUM(revenue_generated) / SUM(spend) AS ROAS
FROM
    marketing_performance
GROUP BY campaign_id , campaign_name;

-- 4.2 Find the campaign with the highest conversion rate (conversions/impressions)
SELECT 
    campaign_id,
    campaign_name,
    conversions,
    impressions,
    (conversions / impressions) conversion_rate
FROM
    marketing_performance
ORDER BY conversion_rate DESC
LIMIT 1;

-- 4.3 List all campaigns targeted at Premium customers and their performance metrics
SELECT 
    campaign_id,
    campaign_name,
    impressions,
    clicks,
    conversions,
    spend,
    revenue_generated,
    roas
FROM
    marketing_performance
WHERE
    target_audience = 'Premium';
    
-- 5. Customer Feedback Analysis
-- 5.1 Count feedback entries by sentiment (Positive, Neutral, Negative)
SELECT 
    sentiment, COUNT(feedback_id) feedback_entries
FROM
    customer_feedback
GROUP BY sentiment;

-- 5.2 List customers who gave negative feedback and their corresponding orders
SELECT 
    cf.customer_id,
    c.customer_name,
    cf.order_id,
    cf.feedback_text
FROM
    customer_feedback cf
        JOIN
    customers c ON cf.customer_id = c.customer_id
WHERE
    cf.sentiment = 'Negative';