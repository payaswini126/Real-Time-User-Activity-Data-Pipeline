use ecommerce
------- CREATE THE DIMENSION TABLES -------

-- 1) Dim_Date
CREATE TABLE Dim_Date (
    date_key INT PRIMARY KEY,
    calendar_date DATETIME,
    day_of_week NVARCHAR(10),
    day_of_month INT,
    day_of_year INT,
    weekday_flag CHAR(1),
    week_of_month INT,
    month_name NVARCHAR(20),
    quarter INT,
    year INT
);

-- 2) Dim_Time
CREATE TABLE Dim_Time (
    time_key INT PRIMARY KEY,
    time TIME,
    hour INT,
    minute INT,
    am_pm CHAR(2),
    time_of_day NVARCHAR(20)
);

-- 3) Dim_Seller
CREATE TABLE Dim_Seller (
    seller_key INT IDENTITY(1,1) PRIMARY KEY,
    seller_id NVARCHAR(32),
    seller_zip_code INT,
    seller_city NVARCHAR(50),
    seller_state NVARCHAR(30)
);

-- 4) Dim_User
CREATE TABLE Dim_User (
    user_key INT IDENTITY(1,1) PRIMARY KEY,
    user_name NVARCHAR(32),
    customer_zip_code INT,
    customer_city NVARCHAR(50),
    customer_state NVARCHAR(30)
);

-- 5) Dim_Product
CREATE TABLE Dim_Product (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id NVARCHAR(32),
    product_category NVARCHAR(255),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);


-- 6) Fact_Order
drop table Fact_Product
drop table Fact_Payment
drop table Dim_User--
drop table Dim_Date--
drop table Fact_Order
drop table Fact_Feedback
drop table Dim_Time--

CREATE TABLE Fact_Order (
    user_key INT FOREIGN KEY REFERENCES Dim_User(user_key),
    order_id NVARCHAR(32) PRIMARY KEY,
    order_status NVARCHAR(10),
    order_date INT REFERENCES Dim_Date(date_key),
    order_time INT REFERENCES Dim_Time(time_key),
    order_approved_date INT REFERENCES Dim_Date(date_key),
    order_approved_time INT REFERENCES Dim_Time(time_key),
    pickup_date INT REFERENCES Dim_Date(date_key),
    pickup_time INT REFERENCES Dim_Time(time_key),
    pickup_limit_date INT REFERENCES Dim_Date(date_key),
    delivered_date INT REFERENCES Dim_Date(date_key),
    delivered_time INT REFERENCES Dim_Time(time_key),
    estimated_delivery_date INT REFERENCES Dim_Date(date_key)
);

ALTER TABLE Fact_Order
ALTER COLUMN user_key NVARCHAR(32);

-- 7) Fact_Feedback
CREATE TABLE Fact_Feedback (
    feedback_id NVARCHAR(32) PRIMARY KEY,
    order_id NVARCHAR(32) FOREIGN KEY REFERENCES Fact_Order(order_id),
    feedback_score INT,
    feedback_form_sent_date INT REFERENCES Dim_Date(date_key),
    feedback_answer_date INT REFERENCES Dim_Date(date_key),
    feedback_answer_time INT REFERENCES Dim_Time(time_key)
);

-- 8) Fact_Payment
CREATE TABLE Fact_Payment (
    order_id NVARCHAR(32) FOREIGN KEY REFERENCES Fact_Order(order_id),
    payment_sequential INT,
    payment_type NVARCHAR(15),
    payment_installments INT,
    payment_value DECIMAL(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- 9) Fact_Product
CREATE TABLE Fact_Product (
    order_id NVARCHAR(32) FOREIGN KEY REFERENCES Fact_Order(order_id),
    order_item_id NVARCHAR(32),
    product_key INT FOREIGN KEY REFERENCES Dim_Product(product_key),
    seller_key INT FOREIGN KEY REFERENCES Dim_Seller(seller_key),
    price DECIMAL(10, 2),
    shipping_cost DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);
------------------------------------------------------------------
------- CREATE THE INDEXES -------
/* create for [PK - FK - columns used in WHERE - columns used in JOIN] */

CREATE INDEX IX_Fact_Order_UserKey ON Fact_Order (user_key);
CREATE INDEX IX_Fact_Feedback_OrderId ON Fact_Feedback (order_id);
CREATE INDEX IX_Fact_Payment_OrderId ON Fact_Payment (order_id);
CREATE INDEX IX_Fact_Payment_PaymentType ON Fact_Payment (payment_type);
CREATE INDEX IX_Fact_Product_OrderId ON Fact_Product (order_id);
CREATE INDEX IX_Fact_Product_SellerKey ON Fact_Product (seller_key);
