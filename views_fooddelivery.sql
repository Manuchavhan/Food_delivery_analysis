--1.sales summary
CREATE OR REPLACE VIEW vw_sales_summary AS

SELECT

    o.order_id,
    o.order_time::date AS order_date,
    o.customer_id,
    o.restaurant_id,
    o.status,

    SUM(oi.price * oi.quantity) AS order_value

FROM orders_medium o

JOIN order_items oi
ON o.order_id = oi.order_id

GROUP BY
    o.order_id,
    o.order_time::date,
    o.customer_id,
    o.restaurant_id,
    o.status;

--2.monthly sales view
CREATE OR REPLACE VIEW vw_monthly_sales AS

SELECT

    DATE_TRUNC('month', o.order_time)::date AS month,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.price * oi.quantity) AS revenue,

    ROUND(
        AVG(order_value),
        2
    ) AS average_order_value

FROM orders_medium o

JOIN order_items oi
ON o.order_id = oi.order_id

JOIN
(
    SELECT
        order_id,
        SUM(price * quantity) AS order_value
    FROM order_items
    GROUP BY order_id
) t

ON o.order_id = t.order_id

GROUP BY
    DATE_TRUNC('month', o.order_time)::date;

--3.customer summary view
CREATE OR REPLACE VIEW vw_customer_summary AS

SELECT

    c.customer_id,
    c.city,
    c.signup_date,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COALESCE(
        SUM(oi.price * oi.quantity),
        0
    ) AS total_spent,

    ROUND(
        COALESCE(AVG(t.order_value),0),
        2
    ) AS average_order_value


FROM customers_medium c

LEFT JOIN orders_medium o
ON c.customer_id = o.customer_id


LEFT JOIN order_items oi
ON o.order_id = oi.order_id


LEFT JOIN
(
    SELECT
        order_id,
        SUM(price*quantity) AS order_value

    FROM order_items

    GROUP BY order_id

) t

ON o.order_id=t.order_id


GROUP BY

c.customer_id,
c.city,
c.signup_date;

--4.restaurants performance view
CREATE OR REPLACE VIEW vw_restaurant_performance AS

SELECT

    r.restaurant_id,
    r.cuisine,
    r.city,
    r.rating,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COALESCE(
        SUM(oi.price * oi.quantity),
        0
    ) AS revenue,

    ROUND(
        AVG(
            EXTRACT(EPOCH FROM
            (o.delivery_time-o.order_time))/60
        ),
        2
    ) AS avg_delivery_minutes


FROM restaurants r

LEFT JOIN orders_medium o
ON r.restaurant_id=o.restaurant_id


LEFT JOIN order_items oi
ON o.order_id=oi.order_id


GROUP BY

r.restaurant_id,
r.cuisine,
r.city,
r.rating;

--5.Delivery performance view
CREATE OR REPLACE VIEW vw_delivery_performance AS

SELECT

    restaurant_id,

    COUNT(order_id) AS total_orders,

    COUNT(
        CASE 
            WHEN status='Delivered'
            THEN order_id
        END
    ) AS delivered_orders,


    COUNT(
        CASE
            WHEN status!='Delivered'
            THEN order_id
        END
    ) AS cancelled_orders,


    ROUND(
        AVG(
            EXTRACT(EPOCH FROM
            (delivery_time-order_time))/60
        ),
        2
    ) AS avg_delivery_minutes


FROM orders_medium

WHERE delivery_time IS NOT NULL

GROUP BY restaurant_id;