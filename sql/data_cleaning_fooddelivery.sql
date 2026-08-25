--NULL VALUES

SELECT *
FROM orders_medium
WHERE delivery_time IS NULL;



SELECT *
FROM restaurants
WHERE rating IS NULL;

--CHECK DUPLICATES CUSTOMERS

SELECT customer_id, COUNT(*)
FROM customers_medium
GROUP BY customer_id
HAVING COUNT(*) > 1;

--INVALID PRICE

SELECT *
FROM menu_items
WHERE price <= 0;

--INVALID QUANTITIES

SELECT *
FROM order_items
WHERE quantity <= 0;

--CANCLED ORDERS

SELECT status, COUNT(*)
FROM orders_medium
GROUP BY status;