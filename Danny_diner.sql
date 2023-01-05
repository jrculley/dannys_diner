/* --------------------
   Case Study Questions
   --------------------*/

/*1. What is the total amount each customer spent at the restaurant?
	SELECT 
		sales.customer_id,
		SUM(menu.price) as amt_spent
	FROM sales
	LEFT JOIN menu ON sales.product_id = menu.product_id
	GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
	SELECT
		customer_id,
		count(distinct order_date) as Vist_QTY
	FROM sales
	GROUP BY customer_id;
    
-- 3. What was the first item from the menu purchased by each customer?
	WITH CTE AS (
	SELECT
		Sales.customer_id,
		menu.product_name, 
		RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS num
	FROM sales 
		JOIN menu
			ON sales.product_id=menu.product_id
	)
	SELECT DISTINCT customer_id, product_name
	FROM CTE
	WHERE num=1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
	SELECT 
		menu.product_name,
		count(sales.product_id) as num_purchas
	FROM SALES
	INNER JOIN menu ON sales.product_id = menu.product_id
	GROUP BY menu.product_name
	ORDER BY count(sales.product_id) desc
	LIMIT 1;

-- 5. Which item was the most popular for each customer?
	WITH CTE AS (
	SELECT
		Sales.customer_id,
        sales.product_id,
        count(product_id) id_count,
		RANK() OVER (PARTITION BY sales.customer_id ORDER BY count(sales.product_id)) AS num_ordered
	FROM sales 
	GROUP BY sales.customer_id , sales.product_id
	)
	SELECT
		cte.customer_id,
        menu.product_name
	FROM cte
	INNER JOIN menu ON cte.product_id=menu.product_id
    WHERE num_ordered = 1;
    
-- 6. Which item was purchased first by the customer after they became a member?
	WITH CTE AS (
	SELECT 
		sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        RANK() OVER (partition by sales.customer_id order by sales.order_date) as ordered
	FROM sales
	INNER JOIN members on sales.customer_id = members.customer_id
    WHERE sales.order_date > members.join_date)
    
    SELECT 
		cte.customer_id,
        menu.product_name
	FROM CTE
    INNER JOIN menu ON cte.product_id = menu.product_id
    WHERE ordered=1
    ORDER BY cte.customer_id;
-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (
	SELECT 
		sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        RANK() OVER (partition by sales.customer_id order by sales.order_date) as ordered
	FROM sales
	INNER JOIN members on sales.customer_id = members.customer_id
    WHERE sales.order_date < members.join_date)
    
    SELECT 
		cte.customer_id,
        menu.product_name
	FROM CTE
    INNER JOIN menu ON cte.product_id = menu.product_id
    WHERE ordered=1
    ORDER BY cte.customer_id;
    
-- 8. What is the total items and amount spent for each member before they became a member?
select
	sales.customer_id,
    count(sales.product_id) as items,
    sum(menu.price) as spent
FROM sales
INNER JOIN members on sales.customer_id = members.customer_id
INNER JOIN menu on sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH Tpoints as (
	SELECT
    menu.product_id,
    CASE
		when menu.product_id = 1 then menu.price*20
        ELSE menu.price*10
	END AS points
FROM menu ) 

SELECT
		sales.customer_id,
        sum(tpoints.points) as total_points
	FROM sales
    INNER JOIN tpoints ON sales.product_id = tpoints.product_id
    GROUP BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with purchased as (
	SELECT
    sales.customer_id,
    sales.product_id,
    sales.order_date,
    members.join_date,
    CASE
		when sales.order_date between members.join_date and date_add(members.join_date, interval 7 day) or menu.product_id = 1 then menu.price*20
        ELSE menu.price*10
	END AS points
FROM sales
INNER JOIN menu on sales.product_id = menu.product_id
INNER JOIN members on sales.customer_id = members.customer_id
where sales.order_date <= '2021-01-31')

select
	customer_id,
    sum(points)
from purchased
group by customer_id;