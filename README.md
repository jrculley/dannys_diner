
![image](https://user-images.githubusercontent.com/121979698/210649496-ef04500d-9e5b-4b5f-9ed1-4a1dd917895f.png)

My attempt at solving Data with Danny using mysql.

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program.
Additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided 3 tables worth of data about his customers. The Scehma is found below.
![image](https://user-images.githubusercontent.com/121979698/210691373-a096a0b1-5e08-4787-bd5a-9c1867a307fc.png)

## Case Study Solutions.

**1. What is the total amount each customer spent at the restaurant?** 
```SQL
SELECT 
	sales.customer_id,
	SUM(menu.price) as amt_spent
FROM sales
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id;
```
  
In order to find the amount spent by each customer we had to join sales table that showed what items each customer purchased and join to it the menu table that listed the price for each item. We then sumed up the amount spent for each customer.

|customer_id | amt_spent|
|---|---|
|A | 76|
|B | 74|
|C | 36|

**2. How many days has each customer visited the restaurant? **
```SQL
SELECT
	customer_id,
	count(distinct order_date) as Visit_QTY
FROM sales
GROUP BY customer_id;
```
Here we just are referencing the sales table and are counting the distinct dates that each customer purchased an item. We use distinct because if a customer ordered 2 items on the same date, it would count as 2 visits rather than 1. 

|customer_id | Visit_QTY|
|---|---|
|A|	4|
|B|	6|
|C|	2|

**3. What was the first item from the menu purchased by each customer?**
```SQL
WITH CTE AS (
	SELECT
		Sales.customer_id,
		menu.product_name, 
		RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS num
	FROM sales 
		JOIN menu
			ON sales.product_id=menu.product_id
	)
SELECT DISTINCT 
	customer_id, 
	product_name
FROM CTE
WHERE num=1;
```
In order to find the first item ordered by each customer we had to first rank their purchase by order_date using the Rank() OVER function. This created a common table expression (CTE). Referencing that CTE we selected which ever product was the top rank of order date (num=1). Customer A had ordered 2 things on their first visit.

|customer_id | product_name|
|---|---|
|A |sushi|
|A |curry|
|B |curry|
|C |ramen|

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```SQL
SELECT 
	menu.product_name,
	count(sales.product_id) as num_purchas
FROM SALES
INNER JOIN menu ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY count(sales.product_id) desc
LIMIT 1;
```
Here we count each product id that was purchased and ordered by the highest amoutn descending. Since we are wanting the top item, we limit our result to one only showing the most purchased item.

|product_name | num_purchas|
|---|---|
|ramen|	8|

**5. Which item was the most popular for each customer?**
```SQL	
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
```
Here we want to first count the amount of times that a customer ordered each item and then rank them to find which is the most popular. Referencing this CTE we are only wanting to showcase where the rank is 1 for each customer.

|customer_id | product_name|
|---|---|
|A |sushi|
|B |sushi|
|B |curry|
|B |ramen|
|C |ramen|
    
**6. Which item was purchased first by the customer after they became a member?**
```SQL
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
```
Here we again utilze a CTE to rank items ordered by each customer. We are only wanting to rank those items after the date that cutomer has become a member. We then reference that CTE to only see which was the first item ordered. Customer C was not a member, which is why they aren't referenced here.

|customer_id| product_name|
|---|---|
|A| ramen|
|B |sushi|

**7. Which item was purchased just before the customer became a member?**
```SQL
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
```
Here we use mostly the same query, we are just looking for when the purchased date was before they became a member.
|customer_id | product_name|
|---|---|
|A | sushi|
|A | curry|
|B | curry|
    
**8. What is the total items and amount spent for each member before they became a member?**
```SQL
SELECT
	sales.customer_id,
	count(sales.product_id) as items,
	sum(menu.price) as spent
FROM sales
INNER JOIN members on sales.customer_id = members.customer_id
INNER JOIN menu on sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id
```
Here we are just counting the number of items that each customer purchased before they became a member, then adding them together based on the price of each item.

|customer_id| items| spent|
|---|---|---|
|B |3| 40|
|A |2| 25|

**9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```SQL
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
```
We need to create another CTE to be able to count how many points each item will be worth using a case statement. Referencing those points we add up how many points each customer would get based on the products that they purchased.

|customer_id| points|
|---|---|
|A| 860|
|B| 940|
|C| 360|



**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```SQL
WITH purchased AS (
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
	WHERE sales.order_date <= '2021-01-31')
SELECT
	customer_id,
    	sum(points) as points
FROM purchased
GROUP BY customer_id;
```

We need to first create the case in which the members are getting points. Here we say that they get double points if they order sushi at anytime OR they are ordering any item during the week after they become a member, otherswise its just the normal 10 points. We also only want to count the points that are earned in the month of January. We then just add up all the points based on the customers purchases.

|customer_id| points|
|---|---|
|B| 940|
|A |1370|
