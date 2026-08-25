-- Customers Table
CREATE TABLE customers_medium (
    customer_id VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL
);


-- Restaurants Table
CREATE TABLE restaurants (
    restaurant_id VARCHAR(10) PRIMARY KEY,
    cuisine VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    rating NUMERIC(2,1)
);


-- Menu Items Table
CREATE TABLE menu_items (
    item_id VARCHAR(10) PRIMARY KEY,
    restaurant_id VARCHAR(10) NOT NULL,
    price NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_menu_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
);


-- Orders Table
CREATE TABLE orders_medium (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    restaurant_id VARCHAR(10) NOT NULL,
    order_time TIMESTAMP NOT NULL,
    delivery_time TIMESTAMP,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers_medium(customer_id),

    CONSTRAINT fk_order_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
);


-- Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR(10) NOT NULL,
    item_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    price NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (order_id, item_id),

    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (order_id)
        REFERENCES orders_medium(order_id),

    CONSTRAINT fk_orderitems_item
        FOREIGN KEY (item_id)
        REFERENCES menu_items(item_id)
);

SELECT 'customers' AS table_name, COUNT(*) FROM customers_medium
UNION ALL
SELECT 'restaurants', COUNT(*) FROM restaurants
UNION ALL
SELECT 'menu_items', COUNT(*) FROM menu_items
UNION ALL
SELECT 'orders', COUNT(*) FROM orders_medium
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;