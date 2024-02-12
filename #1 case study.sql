-- 1. What is the total amount each customer spent at the restaurant?
SELECT
    DISTINCT sales.customer_id,
    SUM(menu.price) AS amount_spent
FROM
    sales
    JOIN menu USING (product_id)
GROUP BY
    1
ORDER BY 2 DESC;
-- 2. How many days has each customer visited the restaurant?
SELECT DISTINCT sales.customer_id,COUNT( DISTINCT sales.order_date) AS days_visited
FROM sales
GROUP BY 1
ORDER BY 2 DESC;
--3 What was the first item from the menu purchased by each customer?
WITH CTE AS (
SELECT customer,
        product,
        RANK() OVER(PARTITION BY customer ORDER BY date ) AS item_rank

FROM(

SELECT s.customer_id AS customer,
                    s.order_date AS date,
                    m.product_name AS product

        
        FROM  sales AS s
        LEFT JOIN menu AS m
        ON s.product_id = m.product_id) AS subquery)


SELECT customer, product 
FROM CTE
WHERE item_rank = 1;

-- 4 What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT  
		m.product_name AS p_id,
		COUNT(s.order_date) AS order_time,
		RANK() OVER(ORDER BY COUNT(s.order_date) DESC) AS rank


FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY 1
LIMIT 1;


--5. Which item was the most popular for each customer?
WITH CTE AS (SELECT
		s.customer_id AS customer ,
		m.product_name AS product_name,
		COUNT(s.order_date) AS order_times,
		RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.order_date) DESC) AS rank
FROM sales AS s
LEFT JOIN  menu AS m
ON s.product_id = m.product_id
GROUP BY  1,2)

SELECT customer, product_name
FROM CTE 
WHERE rank= 1;

--6. Which item was purchased first by the customer after they became a member?
SELECT 
		DISTINCT s.customer_id, 
		CASE WHEN m.customer_id= 'A'THEN m.join_date 
			 WHEN m.customer_id = 'B' THEN m.join_date
			 WHEN m.customer_id = 'C' THEN m.join_date END  AS join_date 
		

FROM sales AS s
LEFT JOIN members AS m
ON s.customer_id = m.customer_id;


WITH CTE AS(SELECT s.customer_id AS customer , s.product_id AS p_id,
  	RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank

FROM sales AS s
LEFT JOIN members AS m
ON s.customer_id = m.customer_id

WHERE s.order_date > m.join_date)

SELECT
		c.customer AS customer , m.product_name AS item 
FROM CTE AS c
LEFT JOIN menu AS m
ON c.p_id = m.product_id
WHERE c.rank = 1
ORDER BY 1 ;

--7 Which item was purchased just before the customer became a member?


WITH CTE AS(SELECT s.customer_id AS customer , s.product_id AS p_id,
  	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank

FROM sales AS s
LEFT JOIN members AS m
ON s.customer_id = m.customer_id

WHERE m.join_date>s.order_date)

SELECT
		c.customer AS customer , m.product_name AS item 
FROM CTE AS c
LEFT JOIN menu AS m
ON c.p_id = m.product_id
WHERE c.rank = 1
ORDER BY 1 ;




--8 What is the total items and amount spent for each member before they became a member?

SELECT 
		s.customer_id, 
		COUNT( s.product_id) AS items_bought , 
		SUM(m.price) AS total_amount_spent

FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
LEFT JOIN members AS mm
ON s.customer_id = mm.customer_id
WHERE mm.join_date>s.order_date
GROUP BY 1
ORDER BY 1;


-


--9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT	
		s.customer_id AS customer,
	
		SUM(CASE WHEN m.product_name = 'curry' OR m.product_name ='ramen' THEN 10* m.price
	     ELSE 20*m.price END )AS customer_point


FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 1 ;





-- -- 10. In the first week after a customer joins the program
-- (including their join date) they earn 2x points on all items, not just sushi - 
--how many points do customer A and B have at the end of January?





WITH dates_cte AS (
  SELECT 
    customer_id, 
    join_date, 
    join_date + 6 AS valid_date, 
    DATE_TRUNC(
      'month', '2021-01-31'::DATE)
      + interval '1 month' 
      - interval '1 day' AS last_date
  FROM members
)

SELECT 
  sales.customer_id, 
  SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
    WHEN sales.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * menu.price
    ELSE 10 * menu.price END) AS points
FROM sales
JOIN dates_cte AS dates
  ON sales.customer_id = dates.customer_id
  AND sales.order_date <= dates.last_date
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;




-- Bonus question 

SELECT 
		s.customer_id AS customer_id,
		s.order_date AS order_date,
		mm.product_name AS product_name,
		mm.price AS price ,
        CASE WHEN s.order_date>= m.join_date THEN 'Y'
			ELSE 'N' END AS member
			
FROM
    sales AS s
LEFT JOIN 
	members AS m
ON 
	s.customer_id = m.customer_id
LEFT JOIN 
	menu AS mm
ON 
	s.product_id = mm.product_id
ORDER BY
		1,2;
	


--Bonus Question
SELECT 
  sales.customer_id, 
  sales.order_date,  
  menu.product_name, 
  menu.price,
  CASE
    WHEN members.join_date > sales.order_date THEN 'N'
    WHEN members.join_date <= sales.order_date THEN 'Y'
    ELSE 'N' END AS member_status
FROM sales
LEFT JOIN members
  ON sales.customer_id = members.customer_id
JOIN menu
  ON sales.product_id = menu.product_id
ORDER BY members.customer_id, sales.order_date;


