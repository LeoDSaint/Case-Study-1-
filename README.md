# 8 Week SQL Challenge Case Study #1 — Danny’s Diner

**Author:** Adewale Ashogbon

**Date:** May 17, 2023

**Duration:** 5 min read

---

Japanese food, sushi, curry, and ramen are the main specialties at the recently launched eatery Danny’s Diner. Danny makes the decision to launch his business in the first few months of 2021 to indulge his passion for Japanese cuisine.

The restaurant is battling to stay afloat, and Danny understands that in order to make better judgments, he must use the data his company has acquired. This data analysis project’s main goal is to provide answers to various questions regarding customer spending patterns, frequency of visits, and preferred menu items.

This knowledge will enable Danny to provide his devoted clients with a more personalized experience, ultimately boosting client loyalty and retention.

I took on the position of a data analyst in this project to assist Danny in better understanding his customers and making decisions by analyzing the data from his restaurant. To accomplish this, Danny has provided a sample of customer data, which contains three essential datasets: sales, menu, and members. You can check out the datasets [here](link_to_datasets).

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
    - Customer A's first orders were Sushi and Curry, Customer B's was Curry, and Customer C's was Ramen.

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
    - Customer A's most popular item was Ramen (3 times), Customer B's were Ramen, Sushi, and Curry (2 times each), and Customer C's was Ramen (3 times).

... (continue for other questions and answers)

## Insights

From the analysis, we discover the following:
1. Customer B is the most frequent customer with 6 visits, while Customer A spent the highest with a total of $76.
2. Ramen is the most popular item on the menu, purchased 8 times.
3. Customer A and C’s favorite item is Ramen, while Customer B loves Ramen, Sushi, and Curry equally.
4. Customer A’s first order was Sushi and Curry, Customer B’s was Curry, and Customer C’s was Ramen.
5. Sushi and Curry were the items Customer A purchased just before the join date. Customer B's was Curry.
6. Before the join date, Customer A made 2 purchases totaling $25, and Customer B made 3 purchases totaling $40.
7. Total points obtained by Customer A, B, and C are 860, 940, and 360, respectively.

Thank you.
