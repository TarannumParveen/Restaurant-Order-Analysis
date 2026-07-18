CREATE TABLE menu_items (
  menu_item_id SMALLINT NOT NULL,
  item_name VARCHAR(45),
  category VARCHAR(45),
  price DECIMAL(5,2),
  PRIMARY KEY (menu_item_id)
);
SELECT * FROM menu_items;
-----------------------------------------------------------------------------------------------------------------------------
CREATE TABLE order_detailss(
             order_details_id int,
			 order_id int,
			 order_date date,
			 order_time time,
			 item_id int
);
SELECT * FROM order_detailss;

-------------------------------------------------------------------------------------------------------------------
--Basics — SELECT, WHERE, ORDER BY, LIMIT--
-- Q1. Most expensive and cheap item in the menu table?
--Expensive--
SELECT item_name, category, price
FROM menu_items
ORDER BY price DESC
LIMIT 1;

--Cheap--
SELECT item_name, category, price
FROM menu_items
ORDER BY price ASC
LIMIT 1;

--Q2. Item where price is less than $12? 
SELECT * FROM menu_items
WHERE price<12;

--Q3. Order date earliest-latest?
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM order_detailss;

--Q4. Total unique orders ?
SELECT COUNT(DISTINCT order_id) AS total_unique_orders
FROM order_detailss;

--Q5. Alphabetically item names sort 
SELECT item_name, category
FROM menu_items
ORDER BY item_name ASC;

------------------------------------------------------------------------------------------
--Aggregations — GROUP BY, COUNT, SUM, AVG

--Q6. Category-wise total revenue aur order volume 
SELECT
    m.category,
    COUNT(*) AS order_volume,
    ROUND(SUM(m.price), 2) AS total_revenue,
    ROUND(AVG(m.price), 2) AS avg_item_price
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE m.category IS NOT NULL  -- excludes rows where item_id didn't match any menu item
GROUP BY m.category
ORDER BY total_revenue DESC;

--Q7. Har din kitne orders aaye (daily order count)?
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS orders_count
FROM order_detailss
GROUP BY order_date
ORDER BY order_date;

--Q8. Average items per order kitna hai?
SELECT
    ROUND(
        CAST(COUNT(*) AS DECIMAL) / COUNT(DISTINCT order_id),
        2
    ) AS avg_items_per_order
FROM order_detailss;

--Q9. Category-wise average price
SELECT
    category,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS num_menu_items
FROM menu_items
GROUP BY category
ORDER BY avg_price DESC;
 

--Q10. Sabse busy order date kaunsi thi (max min orders)?
SELECT
    order_date,
    COUNT(DISTINCT order_id) AS max_orders_count
FROM order_detailss
GROUP BY order_date
ORDER BY orders_count DESC
LIMIT 5;

SELECT
    order_date,
    COUNT(DISTINCT order_id) AS min_orders_count
FROM order_detailss
GROUP BY order_date
ORDER BY orders_count ASC
LIMIT 5;

----------------------------------------------------------------------------------------------
--Q11. Order details ko menu items se JOIN karke full order info nikaalo
SELECT 
    o.order_id,
    o.order_date,
    o.order_time,
    m.item_name,
    m.category,
    m.price
FROM order_detailss o
INNER JOIN menu_items m ON o.item_id = m.menu_item_id
ORDER BY o.order_id;

--Q12. Top 5 / Bottom 5 selling items 
-- TOP 5
SELECT m.item_name, m.category, COUNT(*) AS times_ordered
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE m.item_name IS NOT NULL
GROUP BY m.item_name, m.category
ORDER BY times_ordered DESC
LIMIT 5;

-- BOTTOM 5
SELECT m.item_name, m.category, COUNT(*) AS times_ordered
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE m.item_name IS NOT NULL
GROUP BY m.item_name, m.category
ORDER BY times_ordered ASC
LIMIT 5;
 
--Q13. Kitne order_details rows hain jinka item_id kisi menu item se match nahi karta? (orphan records)
SELECT COUNT(*) AS orphan_rows
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE m.menu_item_id IS NULL;

--Q14. Har order ka total value nikaalo (JOIN + GROUP BY combine)
SELECT
    o.order_id,
    o.order_date,
    COUNT(*) AS num_items,
    ROUND(SUM(m.price), 2) AS order_total
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_id;
 
--Q15. Highest-value single order kaunsa tha, kya order kiya gaya?
-- Step 1: Order totals nikaal ke sabse bada order dhoondo
SELECT
    o.order_id,
    ROUND(SUM(m.price), 2) AS order_total
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY o.order_id
ORDER BY order_total DESC
LIMIT 1;

-- Step 2: Us order_id (440) ke saare items dekho
SELECT
    m.item_name,
    m.category,
    m.price
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE o.order_id = 440;

------------------------------------------------------------------------------------------------------------------
--Part 4: Subqueries
--Q16. Konse items overall average price se mehenge hain?
SELECT item_name, category, price
FROM menu_items
WHERE price > (SELECT AVG(price) FROM menu_items)
ORDER BY price DESC;

--Q17. Konse orders "average order value" se zyada the?

-- Note: yahan ek subquery istemal ki gayi hai FROM clause mein
-- (isko "derived table" kehte hain) taaki pehle order-level totals
-- nikaal sakein, phir unki average nikaal ke compare karein.
 
SELECT order_id, ROUND(order_total, 2) AS order_total
FROM (
    SELECT o.order_id, SUM(m.price) AS order_total
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    GROUP BY o.order_id
) AS order_totals
WHERE order_total > (
    SELECT AVG(order_total)
    FROM (
        SELECT o.order_id, SUM(m.price) AS order_total
        FROM order_detailss o
        LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
        GROUP BY o.order_id
    ) AS all_totals
)
ORDER BY order_total DESC;

--Q18. Sabse zyada order hua item — subquery se nikaalo (bina LIMIT use kiye)
SELECT m.item_name, COUNT(*) AS times_ordered
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE m.item_name IS NOT NULL
GROUP BY m.item_name
HAVING COUNT(*) = (
    SELECT MAX(item_count)
    FROM (
        SELECT COUNT(*) AS item_count
        FROM order_detailss o2
        LEFT JOIN menu_items m2 ON o2.item_id = m2.menu_item_id
        WHERE m2.item_name IS NOT NULL
        GROUP BY m2.item_name
    ) AS item_counts
);

--Q19. Har category mein sabse mehenga item kaunsa hai (correlated subquery)
--       (CORRELATED subquery - inner query outer query ke row pe depend karti hai)
 
SELECT m1.category, m1.item_name, m1.price
FROM menu_items m1
WHERE m1.price = (
    SELECT MAX(m2.price)
    FROM menu_items m2
    WHERE m2.category = m1.category    -- <-- yehi correlation hai (outer row ka reference)
)
ORDER BY m1.price DESC;
 

--Q20. Konsa customer/order pattern outlier hai (statistical subquery
--      (average items/order se 2x zyada waale outlier maan rahe hain)
 
SELECT order_id, COUNT(*) AS num_items
FROM order_detailss
GROUP BY order_id
HAVING COUNT(*) > (
    SELECT AVG(item_count) * 2         -- normal se 2x zyada = outlier threshold
    FROM (
        SELECT COUNT(*) AS item_count
        FROM order_detailss
        GROUP BY order_id
    ) AS per_order_counts
)
ORDER BY num_items DESC;

--------------------------------------------------------------------------------------------------------------
--Part 5: Window Functions
--Q21. Har category mein items ko revenue ke hisaab se RANK karo
SELECT category, item_name, revenue,
       RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM (
    SELECT m.category, m.item_name, ROUND(SUM(m.price), 2) AS revenue
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    WHERE m.item_name IS NOT NULL
    GROUP BY m.category, m.item_name
) t
ORDER BY category, rank_in_category;

--Q22. Running total of daily revenue (cumulative sum)
SELECT order_date, daily_revenue,
       ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS running_total
FROM (
    SELECT o.order_date, SUM(m.price) AS daily_revenue
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    GROUP BY o.order_date
) t
ORDER BY order_date;

--Q23. Har order ka category ke andar percentage-of-total nikaalo
SELECT category, item_name, revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (PARTITION BY category), 1) AS pct_of_category
FROM (
    SELECT m.category, m.item_name, SUM(m.price) AS revenue
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    WHERE m.item_name IS NOT NULL
    GROUP BY m.category, m.item_name
) t
ORDER BY category, pct_of_category DESC;

--Q24. Day-over-day order count % change (LAG/LEAD)
SELECT order_date, orders_count,
       LAG(orders_count) OVER (ORDER BY order_date) AS prev_day_orders,
       ROUND(100.0 * (orders_count - LAG(orders_count) OVER (ORDER BY order_date))
             / LAG(orders_count) OVER (ORDER BY order_date), 1) AS pct_change
FROM (
    SELECT order_date, COUNT(DISTINCT order_id) AS orders_count
    FROM order_detailss
    GROUP BY order_date
) t
ORDER BY order_date;

--Q25. Top 3 items per category (PARTITION BY + RANK)
SELECT category, item_name, times_ordered, rnk
FROM (
    SELECT m.category, m.item_name, COUNT(*) AS times_ordered,
           RANK() OVER (PARTITION BY m.category ORDER BY COUNT(*) DESC) AS rnk
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    WHERE m.item_name IS NOT NULL
    GROUP BY m.category, m.item_name
) t
WHERE rnk <= 3
ORDER BY category, rnk;

-----------------------------------------------------------------------------------------------------------------------------
--Part 6: CTEs (WITH clause) — Multi-step logic
--Q26. CTE se pehle daily revenue nikaalo, phir 7-day moving average
WITH daily_rev AS (
    SELECT o.order_date, SUM(m.price) AS revenue
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    GROUP BY o.order_date
)
SELECT
    order_date,
    ROUND(revenue, 2) AS revenue,
    ROUND(AVG(revenue) OVER (
        ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_7day
FROM daily_rev
ORDER BY order_date;

--Q27. CTE se peak hours identify karo (time-of-day bucketing)
WITH bucketed AS (
    SELECT
        order_id,
        CASE
            WHEN EXTRACT(HOUR FROM order_time) BETWEEN 5 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 16 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM order_time) BETWEEN 17 AND 20 THEN 'Evening'
            ELSE 'Night'
        END AS time_bucket
    FROM order_detailss
)
SELECT time_bucket, COUNT(DISTINCT order_id) AS orders
FROM bucketed
GROUP BY time_bucket
ORDER BY orders DESC;

--Q28. Multi-step: unreliable/duplicate orders filter karke clean revenue nikaalo
WITH valid_orders AS (
    SELECT o.order_id, o.item_id, m.price, m.category
    FROM order_detailss o
    INNER JOIN menu_items m ON o.item_id = m.menu_item_id   -- INNER JOIN se orphans apne aap exclude
),
category_revenue AS (
    SELECT category, ROUND(SUM(price), 2) AS clean_revenue, COUNT(*) AS valid_items
    FROM valid_orders
    GROUP BY category
)
SELECT * FROM category_revenue
ORDER BY clean_revenue DESC;

--Q29. CTE se customer segments banao (order-size based: small/medium/large)
WITH order_sizes AS (
    SELECT order_id, COUNT(*) AS num_items
    FROM order_detailss
    GROUP BY order_id
),
segmented AS (
    SELECT order_id, num_items,
        CASE
            WHEN num_items <= 2 THEN 'Small'
            WHEN num_items BETWEEN 3 AND 5 THEN 'Medium'
            ELSE 'Large'
        END AS order_segment
    FROM order_sizes
)
SELECT order_segment, COUNT(*) AS num_orders, ROUND(AVG(num_items), 2) AS avg_items
FROM segmented
GROUP BY order_segment
ORDER BY avg_items;

--Q30. Recursive ya multi-CTE se month-wise growth trend
WITH monthly_rev AS (
    SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS month, SUM(m.price) AS revenue
    FROM order_detailss o
    LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
    GROUP BY month
),
with_prev AS (
    SELECT month, ROUND(revenue, 2) AS revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
    FROM monthly_rev
)
SELECT
    month,
    revenue,
    ROUND(prev_month_revenue, 2) AS prev_month,
    ROUND(100.0 * (revenue - prev_month_revenue) / prev_month_revenue, 1) AS pct_growth
FROM with_prev
ORDER BY month;

-------------------------------------------------------------------------------------------------------------------------------
--Part 7: Advanced / Combined — CASE WHEN, real business logic

--Q31. CASE WHEN se price ko "Budget/Mid/Premium" bucket karo
SELECT
    CASE
        WHEN price < 10 THEN 'Budget'
        WHEN price BETWEEN 10 AND 15 THEN 'Mid-range'
        ELSE 'Premium'
    END AS price_tier,
    COUNT(*) AS num_items,
    ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY price_tier
ORDER BY avg_price;
 
--Q32. Time-of-day bucket (Morning/Afternoon/Evening/Night) — CASE se
SELECT
    CASE
            WHEN EXTRACT(HOUR FROM order_time) BETWEEN 5 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 16 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM order_time) BETWEEN 17 AND 20 THEN 'Evening'
            ELSE 'Night'
    END AS time_bucket,
    ROUND(SUM(m.price), 2) AS revenue
FROM order_detailss o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY time_bucket
ORDER BY revenue DESC;

--Q33. Weekday vs Weekend order pattern comparison
SELECT
    CASE
        WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend'   -- 0=Sunday, 6=Saturday
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(COUNT(DISTINCT order_id) * 1.0 / COUNT(DISTINCT order_date), 1) AS avg_orders_per_day
FROM order_detailss
GROUP BY day_type;
 

--Q34. Combo analysis — kaunse items saath order hote hain (self-join)
SELECT
    m1.item_name AS item_a,
    m2.item_name AS item_b,
    COUNT(*) AS times_ordered_together
FROM order_detailss o1
JOIN order_detailss o2
    ON o1.order_id = o2.order_id       -- same order
    AND o1.item_id < o2.item_id        -- avoids duplicate pairs (A,B) and (B,A)
JOIN menu_items m1 ON o1.item_id = m1.menu_item_id
JOIN menu_items m2 ON o2.item_id = m2.menu_item_id
GROUP BY item_a, item_b
ORDER BY times_ordered_together DESC
LIMIT 10;
 
--Q35. Final: Ek single query jo sab kuch combine kare — executive summary (revenue, top item, peak time — ek query mein)
SELECT
    (SELECT COUNT(DISTINCT order_id) FROM order_detailss) AS total_orders,
 
    (SELECT ROUND(SUM(m.price),2)
     FROM order_detailss o LEFT JOIN menu_items m ON o.item_id = m.menu_item_id) AS total_revenue,
 
    (SELECT m.item_name
     FROM order_detailss o LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
     WHERE m.item_name IS NOT NULL
     GROUP BY m.item_name ORDER BY COUNT(*) DESC LIMIT 1) AS best_selling_item,
 
    (SELECT m.category
     FROM order_detailss o LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
     WHERE m.category IS NOT NULL
     GROUP BY m.category ORDER BY SUM(m.price) DESC LIMIT 1) AS top_revenue_category;