# Retail Mart Promotions Analysis using SQL and PowerBI
![sale logo](https://github.com/Banuvathyrr/Retail-Mart-Promotions-Analysis-using-SQL-and-Power-BI/assets/145739539/b68e3e3e-85fc-46ad-9fe0-da902edc4d91)  

### Introduction  
AtliQ Mart is a retail giant operating over 50 supermarkets across the southern region of India.
AtliQ Mart conducted extensive promotional campaigns during Diwali 2023 and Sankranti 2024 across all its stores.

### Project Overview
This project aims to gain a deeper understanding of how effective our promotions have been, enabling us to make informed decisions for our future promotional campaigns.

### Data Sources
The dataset contains 4 CSV files:
1. dim_campaigns
2. dim_products
3. dim_stores
4. fact_events

### Tools
- MySQL - Data Cleaning and Data analysis
- PowerBi -Data analysis and creating dashboards
- Powerpoint - Creating video presentation

### Data Cleaning/Preparation
- Column names renamed.  
- Checked datatype of each column and changed it if there is any mismatch.  
- Extracted numeric values from the text columns.  
- New columns created for better analysis of the data.  

### Exploratory Data Analysis
EDA involved exploring promotions data to answer the following key questions:
- Provide a list of products with a base price greater than 500 and featured in promo type of 'BOGOF'
- How many number of stores in each city?
- Create a report that displays each campaign with total revenue before and after promotion (expressed in millions)
- Compute Incremental Sold Unit percentage for each category and rank them
- List top 5 products ranked by Incremental revenue percentage across all campaigns.

### Data Analysis
```
1. SELECT 
	  store_id,Incremental_Revenue
  FROM
	  fact_events
  ORDER BY 
	  Incremental_Revenue DESC
  LIMIT 10;
```

```
2. WITH CTE_rank as
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

```
```
3. SELECT
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
```

### Results/ Findings
- During the **Diwali campaign**, the **500 cashback** promotional offer resulted in significant **revenue**. Conversely, during the **Sankranti campaign**, the **BOGOF promotion** demonstrated notable success.
- In the case of the BOGOF promotion, it was observed that as the incremental units sold increased, the corresponding incremental revenue did not exhibit a proportional increase. 
- Instead, the relationship between incremental sold units and incremental revenue appeared to follow a linear trend with a lesser slope. 
- This suggests that while sales volume increased, the generated revenue did not rise at an equivalent rate, indicating potential factors, such as the type of product, promo-type influencing revenue generation beyond solely increasing sales volume.
- Although the product category remained the same (Combo) for both the Diwali and Sankranti campaigns in the case of the 500 cashback promotion, **the total revenue yielded during the Diwali campaign was significantly higher compared to the Sankranti campaign**. 
- This disparity may be attributed to the **timing** of the campaigns, as the Diwali campaign preceded the Sankranti campaign, allowing consumers to utilize the cashback promotion for purchasing combo sets during the Diwali campaign itself.
- During the **Sankranti campaign**, there was a **surge in purchases of groceries, home appliances, and home care products, resulting in increased quantity sold**. However, this did not translate into significantly higher revenue, as these product categories typically do not yield substantial revenue.

### Recommendation
- **Store Expansion Strategy**: Implementing a store expansion strategy by adding number of stores in each city can significantly enhance revenue generation. 
- **Streamlining Promotional Strategies**: To optimize our campaign strategy and maximize revenue potential, we propose removing the 25% off, 33% off, and 50% off promotions for both campaigns. Our analysis demonstrates that these promotions have shown to be less effective compared to the Cashback and BOGOF promotions. By reallocating resources to focus on the more successful promotions, we aim to drive greater impact and ensure the highest possible return on investment.
- **Strategic Expansion of BOGOF Promotion**: For the Diwali campaign, we propose extending the BOGOF (Buy One, Get One Free) promotion strategy to include groceries. This strategic adjustment aims to capitalize on the high demand for groceries during the festive period. 
- **Introducing 500 Cashback Offer**: During the Sankranti campaign, we propose introducing the 500 cashback promotional offer to a new set of product categories, apart from combo sets. Recognizing that customers may have already purchased combo sets during the Diwali campaign, this strategic adjustment aims to maintain consumer interest and incentivize purchases in different product categories.

### Dashboard 
- Check the dashboard here: https://www.novypro.com/project/retail-mart-promotion-analysis-power-bi

### Video Presentation link:
- Check for the presentation in google drive: https://drive.google.com/drive/folders/1F1y6BL5GIRh6MmGLdEedMCvBPxGwC36f

### Acknowledgements
- This Project is a Codebasics Resume project challenge#9 (https://codebasics.io/challenge/codebasics-resume-project-challenge)













