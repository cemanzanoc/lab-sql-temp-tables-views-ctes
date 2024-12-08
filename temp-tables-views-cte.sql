-- Use this 'sakila' Database
USE sakila;

-- Challenge: Create a Customer Summary Report
-- Step 1: Create a View that summarizes rental information for each customer. View include: customer's ID, name, email, rental_count
CREATE VIEW customer_rental_summary AS
SELECT
	c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM
	customer c
JOIN
	rental r ON c.customer_id = r.customer_id
GROUP BY
	c.customer_id, name, c.email;

-- Visualize the table created
SELECT * FROM customer_rental_summary;

-- Step 2: Create a Temporary Table. Use rental_summary view from Step 1 to join with the payment table and calculate the total amount paid by each customer
CREATE TEMPORARY TABLE temp_customer_summary AS
SELECT
	crs.customer_id,
    crs.name,
    crs.email,
    crs.rental_count,
    COALESCE(SUM(p.amount),0) AS total_paid
FROM
	customer_rental_summary AS crs
JOIN
	payment p ON crs.customer_id = p.customer_id
GROUP BY
	crs.customer_id,
    crs.name,
    crs.email,
    crs.rental_count;

-- Visualise temporary table
SELECT * FROM temp_customer_summary;

-- Step 3: Create a CTE and the Customer Summary Report.Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH customer_summary_cte AS (
    SELECT
        crs.customer_id,
        crs.name,
        crs.email,
        crs.rental_count,
		(ROUND(COALESCE(ts.total_paid, 0) / NULLIF(crs.rental_count, 0),2)) AS average_payment_per_rental,
        ts.total_paid
    FROM
        customer_rental_summary crs
    LEFT JOIN
        temp_customer_summary ts ON crs.customer_id = ts.customer_id
)
SELECT
    name,
    email,
    rental_count,
    total_paid,
    average_payment_per_rental
FROM
    customer_summary_cte;




    
