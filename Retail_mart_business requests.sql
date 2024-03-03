use retail_events_db;

SELECT 
	*
FROM 
	fact_events;
    
/* 1) Provide a list of products with a base price greater than 500 and featured in promo type of 'BOGOF'
This information will help us identify high valued products that are currently being heavily discounted,
which can be useful for evaluating our pricing and promotion strategies*/
SELECT DISTINCT
	dp.product_code, 
    dp.product_name,
    fe.promo_type,
    fe.base_price
FROM 
	fact_events fe
INNER JOIN
	dim_products dp
ON 
	fe.product_code = dp.product_code
WHERE 
	base_price > 500 and promo_type = 'BOGOF'
ORDER BY
	dp.product_code asc;
    
    
/* 2) How many number of stores in each city, results wil be sorted in descending number of store counts
allowing us to identify cities with highest store presence */
SELECT 
	city as City, COUNT(*) as Store_count
FROM 
	dim_stores
GROUP BY 
	city
ORDER BY 
	Store_count desc;
    

/* Add a new column */
ALTER TABLE fact_events
ADD COLUMN base_price_after_promo DECIMAL(10, 2);

ALTER TABLE fact_events
ADD COLUMN Revenue_before_promo DECIMAL(10, 2);

ALTER TABLE fact_events
ADD COLUMN Revenue_after_promo DECIMAL(10, 2);

ALTER TABLE fact_events
ADD COLUMN Incremental_Revenue DECIMAL(10, 2);

ALTER TABLE fact_events
ADD COLUMN Incremental_Revenue_percentage DECIMAL(10, 2);

ALTER TABLE fact_events
ADD COLUMN Incremental_Sold_Units INT;

ALTER TABLE fact_events
ADD COLUMN Incremental_Sold_Units_Percentage INT;

/* To check the base_price_after_promo column*/
SELECT
	*,
	CASE 
		WHEN promo_type = '50% OFF' THEN base_price* 0.50
        WHEN promo_type = '25% OFF' THEN base_price* 0.75
        WHEN promo_type = '33% OFF' THEN base_price* 0.67
        WHEN promo_type = '500 Cashback' THEN base_price - 500
        ELSE base_price
	END AS base_price_after_promo
FROM 
	fact_events;


/*Update values in the new column*/
UPDATE 
	fact_events
SET 
	base_price_after_promo = CASE 
                                WHEN promo_type = '50% OFF' THEN base_price * 0.50
                                WHEN promo_type = '25% OFF' THEN base_price * 0.75
                                WHEN promo_type = '33% OFF' THEN base_price * 0.67
                                WHEN promo_type = '500 Cashback' THEN base_price - 500
                                ELSE base_price
                             END;


UPDATE 
	fact_events
SET 
	Revenue_before_promo = base_price * quantity_sold_before_promo;
    

UPDATE 
	fact_events
SET 
	Revenue_after_promo = base_price_after_promo * quantity_sold_after_promo;
    

    

UPDATE 
	fact_events
SET 
	Incremental_Revenue = Revenue_after_promo - Revenue_before_promo;
    

UPDATE 
	fact_events
SET 
	Incremental_Revenue_percentage = ((Revenue_after_promo - Revenue_before_promo)/Revenue_before_promo)*100;
    


UPDATE 
	fact_events
SET 
	Incremental_Sold_Units = (quantity_sold_after_promo - quantity_sold_before_promo);
 
  
UPDATE 
	fact_events
SET 
	Incremental_Sold_Units_percentage = ((quantity_sold_after_promo - quantity_sold_before_promo)/quantity_sold_before_promo)*100;
    

SELECT 
	*
FROM 
	fact_events;
    

/* 3) Create a report that displays each campaign with total revenue before and after promotion */
SELECT
    dc.campaign_name as Campaign_name, 
	ROUND(SUM(Revenue_before_promo)/ 1000000, 2) as Total_Revenue_before_promo_mln,
    ROUND(SUM(Revenue_after_promo)/ 1000000, 2) as Total_Revenue_after_promo_mln
FROM
	fact_events fe
INNER JOIN 
	 dim_campaigns dc
ON 	
    dc.campaign_id = fe.campaign_id
GROUP BY
    dc.campaign_name;
    

/* 4) Compute Incremental Sold Unit percentage for each category and rank them */
WITH CTE_rank as
(
SELECT 
	dp.category as Category_name, 
	AVG(fe.Incremental_Sold_Units_Percentage) as ISU_perc
FROM
	fact_events fe
INNER JOIN
	dim_products dp ON fe.product_code = dp.product_code
INNER JOIN
	dim_campaigns dc ON fe.campaign_id = fe.campaign_id
WHERE 
	dc.campaign_name ='Diwali'
GROUP BY 
	dp.category
)
SELECT
	Category_name,
	ISU_perc,
    RANK() OVER (ORDER BY ISU_perc DESC) as rankn
FROM CTE_rank;


/* 5) Top 5 products ranked by Incremental revenue percentage across all campaigns */
SELECT
	 dp.product_name as Product_name,
     dp.category as Category,
     AVG(fe.Incremental_Revenue_percentage) as IR_perc,
     RANK() OVER(ORDER BY AVG(fe.Incremental_Revenue_percentage) DESC) as rankn
FROM
	fact_events fe
INNER JOIN
	dim_products dp ON fe.product_code = dp.product_code
GROUP BY
	dp.product_name, dp.category
LIMIT 5;

/* INCREMENTAL REVENUE BY TOP 10 STORES */
SELECT 
	store_id,
    Incremental_Revenue
FROM
	fact_events
ORDER BY 
	Incremental_Revenue DESC
LIMIT 10;

SELECT 
	store_id,
    Incremental_Sold_Units
FROM
	fact_events
ORDER BY 
	Incremental_Sold_Units ASC
LIMIT 10;