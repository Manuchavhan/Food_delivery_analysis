--TOTAL REVENUE
SELECT
SUM(price*quantity) AS total_revenue
FROM order_items;

--AVERAGE ORDER VALUE
SELECT
AVG(order_total)
FROM
(
SELECT
order_id,
SUM(price*quantity) order_total
FROM order_items
GROUP BY order_id
)t;

--TOP 10 CUSTOMERS
SELECT
c.customer_id,
COUNT(o.order_id) total_orders

FROM customers_medium c

JOIN orders_medium o
ON c.customer_id=o.customer_id

GROUP BY c.customer_id

ORDER BY total_orders DESC
LIMIT 10;

--TOP RESTAURANTS
SELECT
r.restaurant_id,
COUNT(o.order_id) total_orders

FROM restaurants r

JOIN orders_medium o

ON r.restaurant_id=o.restaurant_id

GROUP BY r.restaurant_id

ORDER BY total_orders DESC;

--REVENUE BY RESTAURANTS
SELECT
r.restaurant_id,
SUM(oi.price*oi.quantity) revenue

FROM restaurants r

JOIN orders_medium o
ON r.restaurant_id=o.restaurant_id

JOIN order_items oi
ON o.order_id=oi.order_id

GROUP BY r.restaurant_id

ORDER BY revenue DESC;

--REVENUE BY CUSINE
SELECT
r.cuisine,
SUM(oi.price*oi.quantity) revenue

FROM restaurants r

JOIN orders_medium o

ON r.restaurant_id=o.restaurant_id

JOIN order_items oi

ON oi.order_id=o.order_id

GROUP BY r.cuisine

ORDER BY revenue DESC;

--MONTHLY REVENUE
SELECT

EXTRACT(month from order_time) AS month,

SUM(oi.price*quantity) revenue

FROM orders_medium o

JOIN order_items oi

ON o.order_id=oi.order_id

GROUP BY month

ORDER BY month;

--AVERAGE DELEVERY TIME
SELECT

AVG(EXTRACT(EPOCH FROM
(delivery_time-order_time))/60)

AS avg_delivery_minutes

FROM orders_medium

WHERE status='Delivered';

--FASTEST RESTAURANT
SELECT

restaurant_id,

AVG(EXTRACT(EPOCH FROM
(delivery_time-order_time))/60)

avg_delivery

FROM orders_medium

WHERE status='Delivered'

GROUP BY restaurant_id

ORDER BY avg_delivery;

--ORDERS BY CITY
SELECT

c.city,

COUNT(o.order_id)

FROM customers_medium c

JOIN orders_medium o

ON c.customer_id=o.customer_id

GROUP BY c.city;

--REPEAT CUSTOMERS
SELECT

customer_id,

COUNT(order_id)

FROM orders_medium

GROUP BY customer_id

HAVING COUNT(order_id)>1;

--TOP SELLING MENU ITEMS
SELECT

m.item_id,

SUM(quantity) total_quantity

FROM menu_items m

JOIN order_items oi

ON m.item_id=oi.item_id

GROUP BY m.item_id

ORDER BY total_quantity DESC;

--TOP RESTAURANTS IN EACH CITY
WITH cte AS
(
SELECT

r.city,

r.restaurant_id,

COUNT(o.order_id) total_orders,

RANK() OVER(PARTITION BY r.city
ORDER BY COUNT(o.order_id) DESC) rnk

FROM restaurants r

JOIN orders_medium o

ON r.restaurant_id=o.restaurant_id

GROUP BY r.city,r.restaurant_id
)

SELECT *

FROM cte

WHERE rnk=1;

--MONTHLY GROWTH
WITH revenue AS
(
SELECT

DATE_TRUNC('month',order_time) as month,

SUM(price*quantity) revenue

FROM orders_medium o

JOIN order_items oi

ON o.order_id=oi.order_id

GROUP BY month
)

SELECT

month,

revenue,

LAG(revenue) OVER(ORDER BY month),

ROUND(
(revenue-LAG(revenue) OVER(ORDER BY month))
/
LAG(revenue) OVER(ORDER BY month)
*100
,2)

AS growth_percent

FROM revenue;
