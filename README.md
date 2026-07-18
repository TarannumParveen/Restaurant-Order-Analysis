# Restaurant-Order-Analysis
Analysis of a restaurant's order data (12,000+ order records, 32 menu items across 4 cuisines) using PostgreSQL/MySQL. The project is organized into 7 parts covering SQL fundamentals through advanced query techniques.
Restaurant Order Analysis — SQL Project

Analysis of a restaurant's order data (12,000+ order records, 32 menu items across 4 cuisines) using PostgreSQL/MySQL. The project is organized into 7 parts covering SQL fundamentals through advanced query techniques.

Dataset
menu_items — 32 items across American, Asian, Mexican, and Italian categories
order_details — 12,234 order line-items (Jan–Mar 2023)

Source: Maven Analytics – Restaurant Orders

Project Structure

PartTopicConcepts Covered1BasicsSELECT, WHERE, ORDER BY, LIMIT2AggregationsGROUP BY, COUNT, SUM, AVG3JoinsINNER JOIN, LEFT JOIN, anti-join pattern4SubqueriesScalar subqueries, derived tables, correlated subqueries, HAVING5Window FunctionsRANK, PARTITION BY, running totals, LAG6CTEsWITH clause, chained CTEs, moving averages7AdvancedCASE WHEN, self-joins, multi-subquery summaries

Key Insights
Italian cuisine generated the highest revenue ($49K+) despite lower order volume than Asian cuisine — indicating a premium, high-margin pricing strategy.
Hamburger + Edamame was the most frequent item combo (90 co-occurrences), identified via self-join — useful for combo-meal design.
Afternoon hours drove the highest revenue, informing staffing decisions.
Average order value: $29.80, with ~40% of orders exceeding this average.


Tools
PostgreSQL / MySQL, pgAdmin / MySQL Workbench

How to Run
Run create_restaurant_db.sql to set up the schema and load data
Run queries from part1_...sql through part7_...sql in order
