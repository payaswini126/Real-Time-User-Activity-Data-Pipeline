<img src="https://github.com/Mohamed-Abdelkarem/e-commerce-data-engineering-project-/blob/main/Dimensional%20Model%20Design%20Overview/third%20dimensional%20model%20design.png" alt="third dimensional model design" width="400" height="450">

--- 

## Fact Tables
1. **Fact_Order**: Records transactional data for each order, linking to User, Date, Time, and Seller dimensions. It includes attributes like order status, approval times, pickup and delivery dates, enabling comprehensive tracking of the order lifecycle.
2. **Fact_Feedback**: Stores customer feedback related to orders, with fields like feedback score, sent date, and answer date. This table is key for analyzing customer satisfaction and service response times.
3. **Fact_Payment**: Contains payment transaction details for orders, including payment type, installments, and total payment value. It’s useful for financial analysis and understanding customer payment preferences.
4. **Fact_Product**: Tracks product-specific transactions, with references to Product and Seller. It includes metrics like item price and shipping cost, supporting analysis of product-level sales and profitability.

--- 

## Dimension Tables
1. **Date Dimension**: Contains details for each calendar date, including day of the week, month, quarter, and year. This allows for time-based analysis in various resolutions (daily, weekly, monthly).
2. **Time Dimension**: Stores time-related attributes such as hour, minute, AM/PM, and time of day. It enables granular analysis of events throughout the day.
3. **Seller Dimension**: Holds information about each seller, including attributes like seller ID, zip code, city, and state. Useful for analyzing performance by geographical location.
4. **User Dimension**: Contains user-specific information such as name, zip code, city, and state. This table helps in demographic analysis of users.
5. **Product Dimension**: Provides details about each product, including category, name length, weight, and dimensions. It supports analysis of product characteristics and categories.
