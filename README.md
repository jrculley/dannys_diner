
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

