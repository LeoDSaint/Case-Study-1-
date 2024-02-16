# 8 Week SQL Challenge Case Study #1 — Danny’s Diner

**Author:** Adewale Ashogbon

**Date:** May 17, 2023

**Duration:** 5 min read

---
![image](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*7vbHeSc5CN99Ud7n9vJu6Q.png)


Japanese food, sushi, curry, and ramen are the main specialties at the recently launched eatery Danny’s Diner. Danny makes the decision to launch his business in the first few months of 2021 to indulge his passion for Japanese cuisine.

The restaurant is battling to stay afloat, and Danny understands that in order to make better judgments, he must use the data his company has acquired. This data analysis project’s main goal is to provide answers to various questions regarding customer spending patterns, frequency of visits, and preferred menu items.

This knowledge will enable Danny to provide his devoted clients with a more personalized experience, ultimately boosting client loyalty and retention.

I took on the position of a data analyst in this project to assist Danny in better understanding his customers and making decisions by analyzing the data from his restaurant. To accomplish this, Danny has provided a sample of customer data, which contains three essential datasets: sales, menu, and members. You can check out the datasets [here](https://8weeksqlchallenge.com/case-study-1/).

## Case Study Questions

We are to answer the following case study questions using SQL:

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu, and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What were the total items and amount spent by each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x point multiplier, how many points would each customer have?
10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi. How many points do customers A and B have at the end of January?

## Solution

For the Case study, I used PostgreSQL.

1. **Total Amount Spent by Each Customer:**
    ```sql
    SELECT 
        DISTINCT customer_id,
        SUM(m.price) AS Amount_Spent
    FROM dannys_diner.menu AS m
    INNER JOIN dannys_diner.sales AS s
    USING (product_id)
    GROUP BY 1
    ORDER BY 1 ASC;
    ```
    - Customer A spent $76, Customer B spent $74, and Customer C spent $36.

![image](https://miro.medium.com/v2/resize:fit:628/format:webp/1*-Uz8_3JYCu04RQSsRqKoww.png)

2. **Number of Days Each Customer Visited:**
    ```sql
    SELECT
        DISTINCT s.customer_id,
        COUNT(DISTINCT s.order_date) AS days_visited
    FROM dannys_diner.sales AS s
    GROUP BY 1
    ORDER BY 1 ASC;
    ```
    - Customer A visited 4 times, B visited 6 times, and C visited 2 times.

![image](https://miro.medium.com/v2/resize:fit:640/format:webp/1*lvV00C82CvUcs68UWYuwwQ.png)

3. **First Item Purchased by Each Customer:**
    ```sql
    WITH cte AS (
        SELECT
            DISTINCT s.customer_id AS customer,
            s.order_date,
            m.product_name,
            RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS row_n
        FROM dannys_diner.sales AS s
        INNER JOIN dannys_diner.menu AS m
        USING (product_id)
        ORDER BY 2 ASC
    )

    SELECT customer, product_name AS first_item 
    FROM cte
    WHERE row_n = 1;
    ```
    -Answer:


*Sushi and curry were Customer A’s first orders.*

*Curry was Customer B’s first order.*


*Ramen was Customer C’s first order.*

![image](https://miro.medium.com/v2/resize:fit:640/format:webp/1*qnURiHegoafA4HHqNC78Og.png)

4. **Most Purchased Item and Its Frequency:**
    ```sql
    SELECT
        DISTINCT m.product_name AS p_name,
        COUNT(s.order_date)
    FROM dannys_diner.sales AS s
    INNER JOIN dannys_diner.menu AS m
    USING (product_id)
    GROUP BY 1 
    ORDER BY 2 DESC
    LIMIT 1;
    ```
    - Ramen was the most frequently purchased item, with 8 purchases.

![image](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*mNlkNjW6nCFsrhvt2NxZsw.png)

5. **Most Popular Item for Each Customer:**
    ```sql
    WITH cte AS (
        SELECT
            s.customer_id AS cust,
            m.product_name AS p_name,
            COUNT(s.order_date) AS c
        FROM dannys_diner.sales AS s
        INNER JOIN dannys_diner.menu AS m
        USING (product_id)
        GROUP BY 1,2
    ),
    q1 AS (
        SELECT
            cust,
            p_name,
            RANK() OVER (PARTITION BY cust ORDER BY c DESC) AS m
        FROM cte
    )

    SELECT cust, p_name
    FROM q1 
    WHERE m = 1;
    ```
    -Answer

*Ramen was Customer ‘A’s’ most popular item, which he or she purchased three times.*


*The most popular items for Customers ‘B’ were Ramen ,Sushi,Curry which the individual bought twice each.* 


*Customers ‘C’ bought Ramen three times.*

![image](https://miro.medium.com/v2/resize:fit:720/format:webp/1*YikRVRGtg6okX4UWCGoLMA.png)

6. **Which item was purchased first by the customer after they became a member?**
 ```sql
WITH CTE AS(
     SELECT 
           s.customer_id AS customer , 
           s.product_id AS p_id,
           RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank

FROM sales AS s
LEFT JOIN members AS m
ON s.customer_id = m.customer_id

WHERE s.order_date > m.join_date)

SELECT
      c.customer AS customer , 
      m.product_name AS item 
FROM CTE AS c
LEFT JOIN menu AS m
ON c.p_id = m.product_id
WHERE c.rank = 1
ORDER BY 1 ;
  ```



Answer:

- Customer A’s first order as a member is ramen.

  
- Customer B’s first order as a member is sushi. 

*However, Customer ‘C’ lacks join_date information, which means Customer ‘C’ did not sign up for membership.*

![image](https://miro.medium.com/v2/resize:fit:750/format:webp/1*KSF8cOQTsk8zIyljTYigQQ.png)

7 **Which item was purchased just before the customer became a member?**
 ```sql
WITH CTE AS(SELECT s.customer_id AS customer , s.product_id AS p_id,
   RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank

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
  ```

Answer:
- Customer B purchased curry just before they became a member.

- While,

- Customer A purchased curry&sushi just before they became a member.

![image](https://miro.medium.com/v2/resize:fit:828/format:webp/1*7XJ8psUcIcqx43ATKGvECQ.png)

8. **What is the total items and amount spent for each member before they became a member?**

 ```sql

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
  ```
- Answer :

- Customer A made 2 purchases worth $25 before signing up for the membership.


- Customer B, on the other hand, made a total of three purchases for $40.

![image](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*zRntVrDQ7SCdYv-oDrmmhQ.png)
9. **If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

 ```sql
SELECT 
  s.customer_id AS customer,
 
  SUM(CASE WHEN m.product_name = 'curry' OR m.product_name ='ramen' THEN 10* m.price
      ELSE 20*m.price END )AS customer_point


FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 1 ;
  ```
- Answer :
- Customer A has 860 points
- Customer B has 940 points
- Customer C has 360 points

![image](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*9khnfFBq2-N5J2uqXSDGVg.png)

10. **In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

- Assumptions:

On Day -X to Day 1 (the day a customer becomes a member), each $1 spent earns 10 points. However, for sushi, each $1 spent earns 20 points.
From Day 1 to Day 7 (the first week of membership), each $1 spent for any item earns 20 points.
From Day 8 to the last day of January 2021, each $1 spent earns 10 points. However, sushi continues to earn double the points at 20 points per $1 spent.
Steps:

- Create a CTE called dates_cte.
In dates_cte, calculate the valid_date by adding 6 days to the join_date and determine the last_date of the month by subtracting 1 day from the last day of January 2021.
From dannys_diner.sales table, join dates_cte on customer_id column, ensuring that the order_date of the sale is not later than the last_date (sales.order_date <= dates.last_date).
Then, join dannys_diner.menu table based on the product_id column.
In the outer query, calculate the points by using a CASE statement to determine the points based on our assumptions above.
If the product_name is 'sushi', multiply the price by 2 and then by 10. For orders placed between join_date and valid_date, also multiply the price by 2 and then by 10.
For all other products, multiply the price by 10.
Calculate the sum of points for each customer.
 ```sql
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
  ```

- Answer:

- Customer A has 1,370 points.
- Customer B has 820 points.

![image](https://miro.medium.com/v2/resize:fit:640/format:webp/0*jClElTj5YmpfoEcq.png)


**Bonus Questions**
*Join All The Things*
Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
![image](https://miro.medium.com/v2/resize:fit:828/format:webp/1*unCTTXk18NSz422vU6w0rg.png)
 ```sql
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
ORDER BY members.customer_id, sales.order_date
  ```
![image](https://miro.medium.com/v2/resize:fit:1100/format:webp/1*v3nWCStOxxYNMYTcjxdT0g.png)

## Insights

**From the analysis, we discover the following:**

*1. Customer B is the most frequent customer with 6 visits, while Customer A spent the highest with a total of $76.*

*2. Ramen is the most popular item on the menu, purchased 8 times.*

*3. Customer A and C’s favorite item is Ramen, while Customer B loves Ramen, Sushi, and Curry equally.*

*4. Customer A’s first order was Sushi and Curry, Customer B’s was Curry, and Customer C’s was Ramen.*

*5. Sushi and Curry were the items Customer A purchased just before the join date. Customer B's was Curry.*

*6. Before the join date, Customer A made 2 purchases totaling $25, and Customer B made 3 purchases totaling $40.*

*7. Total points obtained by Customer A, B, and C are 860, 940, and 360, respectively.*

*Thank you.*
