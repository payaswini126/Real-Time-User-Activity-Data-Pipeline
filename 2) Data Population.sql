use ecommerce
------- CREATE THE DIMENSION TABLES -------

-------------- 1) Populate Date Dimension
DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate DATE = '2030-12-30';

-- Temporary table to store dates
CREATE TABLE #TempDates (
    CalendarDate DATE PRIMARY KEY
);

-- Generate sequence of dates
DECLARE @CurrentDate DATE = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO #TempDates (CalendarDate) VALUES (@CurrentDate);
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

-- Insert into Date Dimension
INSERT INTO Dim_Date (date_key, calendar_date, day_of_week, day_of_month, day_of_year, weekday_flag, week_of_month, month_name, quarter, year)
SELECT
    CONVERT(INT, FORMAT(CalendarDate, 'yyyyMMdd')), -- date_key
    CalendarDate,
    DATENAME(WEEKDAY, CalendarDate),
    DAY(CalendarDate),
    DATEPART(DAYOFYEAR, CalendarDate),
    CASE WHEN DATENAME(WEEKDAY, CalendarDate) IN ('Saturday', 'Sunday') THEN 'N' ELSE 'Y' END,
    DATEPART(WEEK, CalendarDate),
    DATENAME(MONTH, CalendarDate),
    DATEPART(QUARTER, CalendarDate),
    YEAR(CalendarDate)
FROM #TempDates;

-- Drop temporary table
DROP TABLE #TempDates;

-- select * from Dim_Date  

--------------------------------------------------------
-------------- 2) Populate Time Dimension (for Each Minute)
-- Populate Time Dimension (for Each Minute) with Leading Zeros in time_key
DECLARE @StartTime TIME = '00:00:00';
DECLARE @EndTime TIME = '23:59:59';

-- Drop temporary table if it exists
IF OBJECT_ID('tempdb..#TempTimes') IS NOT NULL
    DROP TABLE #TempTimes;

-- Temporary table to store times
CREATE TABLE #TempTimes (
    TimeOfDay TIME PRIMARY KEY
);

-- Generate sequence of times in 1-minute intervals
DECLARE @CurrentTime TIME = @StartTime;

WHILE @CurrentTime <= @EndTime
    BEGIN
        INSERT INTO #TempTimes (TimeOfDay) VALUES (@CurrentTime);
        SET @CurrentTime = DATEADD(MINUTE, 1, @CurrentTime); -- 1-minute interval

        -- Display progress every 1000 rows
        IF @@ROWCOUNT % 200 = 0
            PRINT 'Inserted ' + CONVERT(VARCHAR, @@ROWCOUNT) + ' rows.';
    END;

-- Insert into Time Dimension with leading zeros in time_key
INSERT INTO Dim_Time (time_key, time, hour, minute, am_pm, time_of_day)
SELECT
    CAST(CONVERT(VARCHAR, DATEPART(HOUR, TimeOfDay) * 100 + DATEPART(MINUTE, TimeOfDay), 108) AS INT), -- time_key with leading zeros
    TimeOfDay,
    DATEPART(HOUR, TimeOfDay),
    DATEPART(MINUTE, TimeOfDay),
    CASE WHEN DATEPART(HOUR, TimeOfDay) < 12 THEN 'AM' ELSE 'PM' END,
    CASE
        WHEN DATEPART(HOUR, TimeOfDay) >= 0 AND DATEPART(HOUR, TimeOfDay) < 6 THEN 'Early Morning'
        WHEN DATEPART(HOUR, TimeOfDay) >= 6 AND DATEPART(HOUR, TimeOfDay) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, TimeOfDay) >= 12 AND DATEPART(HOUR, TimeOfDay) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM #TempTimes;

-- Drop temporary table
DROP TABLE #TempTimes;


select * from Dim_Time
select count(*) from #TempTimes

DELETE FROM Dim_Time
--------------------------------------------------------
-------------- 3) Populate Seller Dimension
INSERT INTO Dim_Seller (seller_id, seller_zip_code, seller_city, seller_state)
SELECT
    seller_id,
    CAST(seller_zip_code AS INT),
    seller_city,
    seller_state
FROM seller;

-- select count(*) from Dim_Seller -- 3095
-- select count(distinct seller_id) from seller -- 3095

--------------------------------------------------------
-------------- 4) Prepare & Clean "users" table --> Populate User Dimension
-- investigating duplicated rows in "users" table
select user_name, customer_zip_code, customer_city, customer_state, count(*) 'count'
from users
group by user_name, customer_zip_code, customer_city, customer_state
having count(*) > 1
order by count(*) desc

-- this user_name has 17 duplicate rows!!!
select * from users where user_name = '8d50f5eadf50201ccdcedfb9e2ac8455' 

-- total count in "users", with duplicates --> 99441
select count(*) from users

-- find duplicate rows in "users" table --> 3089 duplicated rows (2770 unique .. some are repeated more than 2)
SELECT user_name, customer_zip_code, customer_city, customer_state, COUNT(*)
FROM users
GROUP BY user_name, customer_zip_code, customer_city, customer_state
HAVING COUNT(*) > 1;

-- deleting duplicate rows
WITH DuplicatesCTE AS (
    SELECT user_name, customer_zip_code, customer_city, customer_state,
		   ROW_NUMBER() OVER (PARTITION BY user_name, customer_zip_code, customer_city, customer_state
                           ORDER BY (SELECT NULL)) AS RowNum
    FROM users)
delete FROM DuplicatesCTE
WHERE RowNum > 1;

-- total count in "users", with duplicates --> 96352
select count(*) from users

delete from Dim_User


-- --- NOW START POPULATING THE Dim_User DIMENSION
INSERT INTO Dim_User (user_name, customer_zip_code, customer_city, customer_state)
SELECT
    user_name,
    CAST(customer_zip_code AS INT),
    customer_city,
    customer_state
FROM [users];

-- select count(distinct user_name) from Dim_User -- 96096
-- select count(distinct user_name) from [users] -- 96096
-- select * from Dim_User
--------------------------------------------------------
-------------- 5) Populate Product Dimension
select * from products

-- Populate Product Dimension
INSERT INTO Dim_Product (product_id, product_category, product_name_length, product_description_length, 
						product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT product_id, product_category, product_name_lenght, product_description_lenght, product_photos_qty, 
		product_weight_g, product_length_cm, product_height_cm, product_width_cm
FROM products;

-- select count(*) from products -- 32951
-- select count(*) from Dim_Product -- 32951

--------------------------------------------------------
-------------- 6) Populate Order Fact Table
INSERT INTO Fact_Order (
    order_id,
    user_key,
    order_status,
    order_date,
    order_time,
    order_approved_date,
    order_approved_time,
    pickup_date,
    pickup_time,
    pickup_limit_date,
    delivered_date,
    delivered_time,
    estimated_delivery_date
)
SELECT
    o.order_id,
    u.user_key,
    o.order_status,
    CONVERT(INT, CONVERT(VARCHAR, o.order_date, 112)), -- Date part as INT
    CONVERT(INT, REPLACE(CONVERT(VARCHAR, o.order_date, 108), ':', '')), -- Time part as INT without leading zero
    CONVERT(INT, CONVERT(VARCHAR, o.order_approved_date, 112)),
    CONVERT(INT, REPLACE(CONVERT(VARCHAR, o.order_approved_date, 108), ':', '')),
    CONVERT(INT, CONVERT(VARCHAR, o.pickup_date, 112)),
    CONVERT(INT, REPLACE(CONVERT(VARCHAR, o.pickup_date, 108), ':', '')),
    CONVERT(INT, CONVERT(VARCHAR, oi.pickup_limit_date, 112)), -- Using pickup_limit_date from order_item
    CONVERT(INT, CONVERT(VARCHAR, o.delivered_date, 112)),
    CONVERT(INT, REPLACE(CONVERT(VARCHAR, o.delivered_date, 108), ':', '')),
    CONVERT(INT, CONVERT(VARCHAR, o.estimated_time_delivery, 112))
FROM [orders] o
JOIN Dim_User u ON o.user_name = u.user_name
JOIN order_item oi ON o.order_id = oi.order_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Fact_Order fo
   WHERE fo.order_id = o.order_id -- Assuming order_id is the primary key in Fact_Order
);

--------------------------------------------------------
-------------- 7) Populate Feedback Fact Table
INSERT INTO Fact_Feedback (
    feedback_id,
    order_id,
    feedback_score,
    feedback_form_sent_date,
    feedback_answer_date,
    feedback_answer_time
)
SELECT
    f.feedback_id,
    o.order_id,
    f.feedback_score,
    CONVERT(INT, CONVERT(VARCHAR, f.feedback_form_sent_date, 112)), -- Form sent date (as INT)
    CONVERT(INT, CONVERT(VARCHAR, f.feedback_answer_date, 112)), -- Answer date (as INT)
    CONVERT(INT, SUBSTRING(REPLACE(CONVERT(VARCHAR, f.feedback_answer_time, 108), ':', ''), 0, 5)) -- Answer time (as INT)
FROM original_feedback f
JOIN Fact_Order o ON f.order_id = o.order_id;

--------------------------------------------------------
-------------- 8) Populate Payment Fact Table
-- Populate Fact_Payment Fact Table
INSERT INTO Fact_Payment (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    o.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value
FROM original_payment p
JOIN Fact_Order o ON p.order_id = o.order_id;

--------------------------------------------------------
-------------- 9) Populate Product Fact Table
-- Populate Fact_Product Fact Table
INSERT INTO Fact_Product (
    seller_key,
    product_key,
    order_id,
    order_item_id,
    price,
    shipping_cost
)
SELECT
    s.seller_key,
    p.product_key,
    o.order_id,
    oi.order_item_id,
    oi.price,
    oi.shipping_cost
FROM order_item oi
JOIN Fact_Order o ON oi.order_id = o.order_id
JOIN Dim_Product p ON oi.product_id = p.product_id
JOIN Dim_Seller s ON p.seller_id = s.seller_id;
