CREATE DATABASE Pizzahut;
USE pizzahut;

-- Q1 Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Number
FROM
    orders;

-- 	Q2 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Q3 Identify the highest-priced pizza.

select * from pizzas;
select * from pizza_types;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        LEFT JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;    

-- Q4 Identify the most common pizza size ordered.

select * from pizzas;
select * from order_details;

SELECT 
    pizzas.size, COUNT(order_details.quantity) common_pizza
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY common_pizza DESC;

-- Q5 List the top 5 most ordered pizza types along with their quantities.

select * from pizza_types;
select * from order_details;
select * from pizzas;

SELECT 
    pizzas.pizza_type_id,
    SUM(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.pizza_type_id
ORDER BY quantity DESC
LIMIT 5;

-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

-- Q7 Determine the distribution of orders by hour of the day.

SELECT HOUR(time), count(order_id) 
FROM orders
group by HOUR(time)
order by count(order_id) desc;

-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.


SELECT 
    ROUND(AVG(total_order), 0) AS avrg_num_order
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS total_order
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity; 
    
-- Q10 Determine the top 3 most ordered pizza types based on revenue.

-- revenue = quantity*price 

SELECT 
    pizzas.pizza_type_id,
    round(SUM(pizzas.price * order_details.quantity),2) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.pizza_type_id
ORDER BY revenue DESC;

-- Q11 Calculate the percentage contribution of each pizza type to total revenue.
 
 
SELECT 
    pizza_types.category,
    (SUM(pizzas.price * order_details.quantity) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS revenue
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Q12 Analyze the cumulative revenue generated over time.

SELECT date, SUM(revenue) OVER (order by date) as cum_revenue
FROM
(SELECT orders.date, SUM(order_details.quantity*pizzas.price) as revenue
FROM orders
JOIN order_details
ON orders.order_id = order_details.order_id
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.date) as sales;


-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue from
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) as most_order 
FROM
(SELECT 
    pizza_types.category,
    pizza_types.name,
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS revenue
FROM
    pizza_types
        JOIN
    Pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as A) as b
WHERE most_order <= 3;