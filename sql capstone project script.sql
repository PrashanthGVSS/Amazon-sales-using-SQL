#DATA WRANGLING

CREATE DATABASE salesdata; 

CREATE TABLE sales (
    Invoice_id VARCHAR(30) NOT NULL,
    Branch VARCHAR(5) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    VAT FLOAT NOT NULL,
    Total DECIMAL(10, 2) NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    Payment_method VARCHAR(20) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT NOT NULL,
    gross_income DECIMAL(10, 2) NOT NULL,
    Rating FLOAT(10,2) NOT NULL
);

# Feature Engineering
-- Add the time_of_day column

SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add day_name column

SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = DAYNAME(date);

-- Add month_name column

SELECT
	date,
	MONTHNAME(date)
FROM sales;
ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = MONTHNAME(date);
.....................................................................................

# Business Questions 

# 1.What is the count of distinct cities in the dataset?

SELECT COUNT(DISTINCT City) AS distinct_city_count
FROM sales;

# 2.For each branch, what is the corresponding city?
SELECT DISTINCT branch,city
FROM sales;

# 3.What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT `Product_line`) AS distinct_product_line_count
FROM sales;

# 4.Which payment method occurs most frequently?
SELECT Payment_method, COUNT(*) AS payment_count
FROM sales
GROUP BY Payment_method
ORDER BY payment_count DESC
LIMIT 1;

# 5.Which product line has the highest sales?
SELECT `Product_line`, SUM(Total) AS total_sales
FROM sales
GROUP BY `Product_line`
ORDER BY total_sales DESC
LIMIT 1;

# 6.How much revenue is generated each month?
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue;

# 7.In which month did the cost of goods sold reach its peak?
SELECT month_name AS month,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month
ORDER BY total_cogs DESC
LIMIT 1;

# 8.Which product line generated the highest revenue?
SELECT product_line, SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
limit 1;

# 9.In which city was the highest revenue recorded?
SELECT branch, city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue desc
limit 1;

# 10.Which product line incurred the highest Value Added Tax?
SELECT product_line, AVG(VAT) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC
LIMIT 1;

# 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT AVG(quantity) AS avg_qnty
FROM sales;
SELECT product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

# 12.Identify the branch that exceeded the average number of products sold?
SELECT branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

# 13.Which product line is most frequently associated with each gender?
SELECT gender,product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

# 14.Calculate the average rating for each product line.
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

# 15.Count the sales occurrences for each time of day on every weekday.
SELECT 
    DAYNAME(Date) AS DayName,
    CASE 
        WHEN HOUR(Time) BETWEEN 0 AND 5 THEN 'Night'
        WHEN HOUR(Time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(Time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(Time) BETWEEN 18 AND 23 THEN 'Evening'
    END AS TimeOfDay,
    COUNT(*) AS SalesCount
FROM 
    sales
GROUP BY 
    DayName, TimeOfDay
ORDER BY 
    FIELD(DayName, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    FIELD(TimeOfDay, 'Night', 'Morning', 'Afternoon', 'Evening');
    
# 16.Identify the customer type contributing the highest revenue?
   SELECT customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

# 17.Determine the city with the highest VAT percentage.
SELECT city, ROUND(AVG(VAT), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

# 18.Identify the customer type with the highest VAT payments.
SELECT
	customer_type,
	AVG(VAT) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

# 19.What is the count of distinct customer types in the dataset?
SELECT
	COUNT(DISTINCT 'Customer_type') AS distinct_customer_type 
FROM sales;

# 20.What is the count of distinct payment methods in the dataset?
SELECT
	COUNT(DISTINCT Payment_method) as distinct_payment_methods
FROM sales;

# 21.Which customer type occurs most frequently?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

# 22.Identify the customer type with the highest purchase frequency.
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;

# 23.Determine the predominant gender among customers.
SELECT gender, COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

# 24.Examine the distribution of genders within each branch.
SELECT gender, COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

# 25.Identify the time of day when customers provide the most ratings.
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

# 26.Determine the time of day with the highest customer ratings for each branch.
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

# 27.Identify the day of the week with the highest average ratings.
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC
limit 1;

# 28.Determine the day of the week with the highest average ratings for each branch.
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC
limit 1;
