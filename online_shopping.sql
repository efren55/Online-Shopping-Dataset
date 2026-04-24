#create database online_shopping;
use online_shopping;
#alter table shopping rename column MyUnknownColumn to id;
select * from shopping limit 100;
select 'Registros',count(*) from shopping;

#ANALYZING NULL VALUES
with null_values as (
	select 'Null values' as category,sum(gender is null) as gender,sum(location is null) as location,sum(tenure_months is null) as tenure_months,
    sum(transaction_id is null) as transaction_id,sum(product_sku is null) product_sku,sum(product_description is null) as product_description,sum(product_category is null) as product_category,
    sum(quantity is null) as quantity,sum(avg_price is null) as avg_price,sum(delivery_charges is null) as delivery_chearges,sum(coupon_status is null) as coupon_status,
    sum(gst is null) as gst,sum(date is null) as date,sum(offline_spend is null) as offline_spend,sum(month is null) as month, sum(coupon_code is null) as coupon_code,
    sum(discount_pct is null) as discount_pct from shopping
)
select * from null_values;

#GENERAL ANALYSIS OF THE DATASET
select gender,count(*) as amount from shopping group by gender;
select customerid,count(*) as amount from shopping group by customerid order by amount desc;
select location,count(*) as amount from shopping group by location order by amount desc;
select tenure_months,count(*) as amount from shopping group by tenure_months order by amount;
select transaction_date, count(*) as amount from shopping group by transaction_date order by amount desc;
select year(transaction_date) as año,count(*) as amount from shopping group by año;
select month(transaction_date) as mes,count(*) amount from shopping group by mes order by amount desc;
select transaction_id,count(*) as amount from shopping group by transaction_id order by amount desc;
select product_category, count(*) as amount from shopping group by product_category order by amount desc;
select quantity,count(*) as amount from shopping group by quantity order by amount desc;
select delivery_charges,count(*) as amount from shopping group by delivery_charges order by amount desc;
select coupon_status,count(*) as amount from shopping group by coupon_status order by amount desc;
select offline_spend,count(*) as amount from shopping group by offline_spend order by amount desc;
select online_spend,count(*) as amount from shopping group by online_spend order by amount desc;
select coupon_code,count(*) as amount from shopping group by coupon_code order by amount desc;
select discount_pct,count(*) as amount from shopping group by discount_pct order by amount desc;
select avg_price,count(*) as amount from shopping group by avg_price order by amount desc;

#AVERAGE OF AVERAGE PRICE
select 'Average',round(avg(avg_price),2) as average from shopping;

#WORKING ON CUSTOMERID
with customer_id as(
	select customerid,count(*) as amount from shopping group by customerid
)
select 'Quantity',count(*) as amount from customer_id;

#ARE THE USERS WITH MORE ACTIVITY WERE MEN OR WOMEN?
with user_sex as(
    SELECT customerid, gender, COUNT(*) AS amount
    FROM shopping
    GROUP BY customerid, gender
    ORDER BY amount DESC
    LIMIT 50
)
select * from user_sex;

with activity as (
	select customerid,count(*) as total from shopping group by customerid
 ),
 percentage as (
	select a.customerid,percent_rank() over (order by a.total desc) as percentile,s.gender from activity as a join shopping as s on a.customerid=s.customerid
    group by a.customerid,a.total,s.gender
 )
 select case when percentile <=0.1 then 'Top 10%' else 'Resto' end as segment, sum(case when gender='M' then 1 else 0 end) as 'Men',
 sum(case when gender='F' then 1 else 0 end) as 'Women' from percentage group by segment;
 

#¿DÓNDE VIVEN LOS USUARIOS CON MAYOR ACTIVIDAD?
with user_location as (
	select customerid,location,count(*) as amount from shopping group by customerid,location order by amount desc limit 50
)
select * from user_location;

with localidad as(
	select customerid, count(*) as total from shopping group by customerid
), percentage as (
	select l.customerid,percent_rank() over(order by l.total desc) as percentile,s.location from localidad as l join 
    shopping as s on l.customerid=s.customerid group by l.customerid,l.total,s.location
)
select location,sum(case when percentile <= 0.1 then 1 else 0 end) as 'Top 10', sum(case when percentile > 0.1 then 1 else 0 end) as 'Resto'
from percentage group by location;


#SUBSCRIPTION BY THE USERS WITH MORE ACTIVITY VS THE REST

with user_time as (
	select customerid,tenure_months,count(*) as amount from shopping group by customerid,tenure_months
)
select 'Average_high' as category,round(avg(tenure_months),2) as Average from (select tenure_months 
from user_time order by amount desc limit 50) as table_high union all
select 'Average_low', round(avg(tenure_months),2) from (select tenure_months from user_time order by amount asc limit 50) as table_low;

with users_time as(
	select customerid,count(*) as total from shopping group by customerid
), percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.tenure_months from users_time as u join shopping as s on u.customerid=s.customerid 
    group by u.customerid,s.tenure_months,u.total
)
select case when percentile <= 0.1 then 'Top 10' else 'Resto' end as Users, round(avg(tenure_months),2) as avg_tenure from percentage group by Users; 


#USERS WITH MORE SHOPPING
with user_month as (
	select customerid,sum(if(month(transaction_date)=1,1,0)) as January,sum(if(month(transaction_date)=2,1,0)) as February,sum(if(month(transaction_date)=3,1,0)) as March,
    sum(if(month(transaction_date)=4,1,0)) as April, sum(if(month(transaction_date)=5,1,0)) as May,sum(if(month(transaction_date)=6,1,0)) as June,
    sum(if(month(transaction_date)=7,1,0)) as July,sum(if(month(transaction_date)=8,1,0)) as August,sum(if(month(transaction_date)=9,1,0)) as September,
    sum(if(month(transaction_date)=10,1,0)) as October,sum(if(month(transaction_date)=11,1,0)) as November,sum(if(month(transaction_date)=12,1,0)) as December,
    count(*) as total from shopping group by customerid
)
select * from user_month order by total desc limit 50;

#USERS WITH MORE SHOPPING BY THE TOP USERS VS THE REST
with users_month as (
	select customerid,count(*) as total from shopping group by customerid
), percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,month(s.transaction_date) as months from users_month as u join shopping as s on u.customerid=s.customerid
    group by u.customerid,u.total,months
)
select months,sum(case when percentile <= 0.1 then 1 else 0 end) as 'Top 10', sum(case when percentile > 0.1 then 1 else 0 end) as 'Resto' from percentage group by months;


#SHOPPING BY THE TOP USERS VS THE REST
with users_month as(
	select customerid,count(*) as total_activity,percent_rank() over (order by count(*) desc) as percentile from shopping group by customerid
)
select case 
	when percentile <= 0.1 then 'Top 10%'
    else 'Resto'
 end as segment,round(avg(total_activity),2) as avg_activity,count(*) as num_users from users_month group by segment; #188 compras anuales
 
 
#DISTRIBUTION OF THE DIFFERENT TYPES OF PRODUCTS PURCHASED BY USERS
WITH user_segments AS (
    SELECT 
        customerid,
        COUNT(*) as total_compras,
        PERCENT_RANK() OVER (ORDER BY COUNT(*) DESC) as percentil
    FROM shopping
    GROUP BY customerid
),
category_counts AS (
    SELECT 
        s.product_category,
        CASE WHEN us.percentil <= 0.1 THEN 'Top 10% (Activos)' ELSE 'Resto (Fantasmas)' END AS tipo_usuario,
        COUNT(*) as cantidad_compras
    FROM shopping s
    JOIN user_segments us ON s.customerid = us.customerid
    GROUP BY s.product_category, tipo_usuario
)
SELECT * FROM category_counts
ORDER BY tipo_usuario, cantidad_compras DESC;

select product_category,count(*) from shopping group by product_category;

#QUANTITY OF PRODUCTS PURCHASED BY THE TOP USERS VS THE REST
with users_quantity as (
	select customerid,count(*) as total from shopping group by customerid 
),percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.quantity from users_quantity as u join shopping as s on u.customerid=s.customerid
    group by u.customerid,u.total,s.quantity
)
select case when percentile <=0.1 then 'Top 10' else 'Resto' end as categoria, sum(quantity) as amount from percentage group by categoria;

#AVERAGE PRICE OF THE PURCHASED PRODUCTS BY THE USERS TOP 10 VS THE REST
with users_price as (
	select customerid,count(*) as total from shopping group by customerid
),percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.avg_price from users_price as u join shopping as s
    on s.customerid=u.customerid group by u.customerid,u.total,s.avg_price
)
select case when percentile <= 0.1 then 'Top 10' else 'Rest' end as category,round(avg(avg_price),2) as price from percentage group by category;

#TOP 10 USERS THAT USED MORE COUPONS
with users_coupon as (
	select customerid,percent_rank() over(order by count(*) desc) as percentile from shopping group by customerid
)
select s.coupon_status,case when u.percentile <= 0.1 then 'Top 10' else 'Resto' end as categoria,count(*) total from shopping as s join users_coupon as u 
on s.customerid=u.customerid group by s.coupon_status,categoria;

#ARE THE TOP 10 USERS MORE OR LESS DISCOUNT THAN THE REST?
with users_discount as (
	select customerid,percent_rank() over(order by count(*) desc) as percentile from shopping group by customerid
)
select case when u.percentile <= 0.1 then 'Top 10' else 'Resto' end as Categoria, round(avg(s.discount_pct),2) as descuento from users_discount as u 
join shopping as s on u.customerid=s.customerid group by Categoria;

#DISTRIBUTION OF MEN AND WOMEN BY LOCATION
with sex_location as (
	select location, sum(case when gender='M' then 1 else 0 end) as Male, sum(case when gender='F' then 1 else 0 end) as Female, count(*) as Total from shopping group by location
    order by total desc
)
select * from sex_location;

#WHICH SEX WERE MORE ASSOCIATED TO THE PLATFORM
with sex_count as (
	select gender,round(avg(tenure_months),2) as tenure_months from shopping group by gender
)
select * from sex_count;

#DISTRIBUTION OF SEXES BY MONTH
with sex_months as (
	select month, sum(case when gender='M' then 1 else 0 end) as Male,sum(case when gender='F' then 1 else 0 end) as Female,count(*) as total from shopping group by month order by total desc
)
select * from sex_months;

#WHAT PRODUCTS DO MEN AND WOMEN PREFER?
with sex_products as (
	select product_category,sum(case when gender='M' then 1 else 0 end) as Male,sum(case when gender='F' then 1 else 0 end) as Female, count(*) as total
    from shopping group by product_category order by total desc
)
select * from sex_products;

#PRICE OF THE PURCHASED PRODUCTS BY EACH SEX
with sex_price as (
	select gender,round(avg(avg_price),2) as price from shopping group by gender
)
select * from sex_price;

select coupon_status,count(*) from shopping group by coupon_status;

#QUANTITY OF PRODUCTS THAT PURCHASED EACH SEX
with sex_quantity as (
	select gender,sum(quantity) as sum_quantity, round(avg(quantity),2) as avg_quantity from shopping group by gender
)
select * from sex_quantity;

#WHICH SEX USES MORE COUPONS?
with sex_coupons as (
	select gender,sum(case when coupon_status='Used' then 1 else 0 end) as Used,sum(case when coupon_status='Not Used' then 1 else 0 end) as 'Not Used',
    sum(case when coupon_status='Clicked' then 1 else 0 end) as Clicked from shopping group by gender
)
select * from sex_coupons;

select gender,coupon_status,count(*) as total from shopping group by gender,coupon_status;

#WHICH SEX WAS MORE DISCOUNT?
with sex_discount as (
	select gender,round(avg(discount_pct),2) as avg_discount from shopping group by gender
)
select * from sex_discount;

#WHICH LOCATION HAD MORE USERS WITH MORE ASSOCIATED TIME IN THE PLATFORM
with location_tenure as (
	select location,round(avg(tenure_months),2) as avg_tenure from shopping group by location
)
select * from location_tenure;

#WHICH LOCATION HAD MORE ACTIVITY EACH MONTH
with location_month as (
	select location,month,count(*) total from shopping group by location,month
)
select * from location_month;

#WHICH LOCATION HAD MORE USERS THAT USED MORE COUPONS
with location_coupon as (
	select location,coupon_status,count(*) as total from shopping group by location,coupon_status
)
select * from location_coupon;

#DIFERENT TYPES OF PURCHASED PRODUCTS BY THE USERS OF EACH LOCATION
with location_products as (
	select location,product_category,count(*) as total from shopping group by location,product_category
)
select * from location_products;

#QUANTITY OF PURCHASED PRODUCTS BY EACH LOCATION
with location_quantity as (
	select location,sum(quantity) as sum_quantity,round(avg(quantity),2) as avg_quantity from shopping group by location
)
select * from location_quantity;

#AVERAGE PRICE OF PRODUCTS PURCHASED BY USERS
with location_price as (
	select location,round(avg(avg_price),2) avg_price from shopping group by location
)
select * from location_price;

#WHICH LOCATION HAD MORE AVERAGE DISCOUNT
with location_discount as (
	select location,round(avg(discount_pct),2) as avg_discount from shopping group by location
)
select * from location_discount order by avg_discount desc;

with location_compare as (
	select location,count(*) as total_purcharses,sum(quantity) as quantity,round(avg(quantity),2) as avg_quantity,round(avg(avg_price),2) as avg_price,
    round(avg(discount_pct),2) as discount,sum(case when coupon_status='Used' then 1 else 0 end) as 'Coupon used',sum(case when coupon_status='Clicked' then 1 else 0 end) as 'Coupon clicked',
    sum(case when coupon_status='Not Used' then 1 else 0 end) as 'Coupon not used' from shopping group by location
)
select * from location_compare;

#QUANTITY VS PRICE
with location_pe as (
	select location, round(sum((quantity * avg_price)),2) as income from shopping group by location
)
select * from location_pe order by income desc;

#DID THE BUYERS WITH MORE TIME ON THE PLATFORM BUY MORE IN A MONTH ESPECIALLY?
with tenure_month as (
	select month, round(avg(tenure_months),2) as tenure_months,count(*) as total from shopping group by month
)
select * from tenure_month order by tenure_months desc;

#DID THE BUYERS WITH MORE TIME ON THE PLATFORM PREFER ONE KIND OF PRODUCT?
with tenure_product as (
	select product_category, round(avg(tenure_months),2) as tenure_months, count(*) as total from shopping group by product_category
)
select * from tenure_product order by tenure_months desc;

#DID SHOPPERS WHO SPENT MORE TIME ON THE PLATFORM BUY MORE OF ONE TYPE OF PRODUCT?
with tenure_quantity as(
	select case 
		when tenure_months<=12 then 'No more than a year'
        when tenure_months>12 and tenure_months<=24 then 'Between 1 and 2 years'
        when tenure_months>24 and tenure_months<=36 then 'Between 2 and 3 years'
        else '3+ years'
        end as user_time, sum(quantity) as 'Sum',round(avg(quantity),2) quantity_avg from shopping group by user_time
)

select * from tenure_quantity;

#DID THE SHOPPERS WHO SPENT MORE TIME ON THE PLATFORM HAD MORE OR LESS DISCOUNT
with tenure_discount as(
	select case 
		when tenure_months<=12 then 'No more than a year'
        when tenure_months>12 and tenure_months<=24 then 'Between 1 and 2 years'
        when tenure_months>24 and tenure_months<=36 then 'Between 2 and 3 years'
        else '3+ years'
        end as user_time, round(avg(discount_pct),2) as discount_avg from shopping group by user_time
)
select * from tenure_discount;

#WHICH PRODUCT CATEGORIES BOUGHT WITH MORE QUANTITY?
with product_quantity as(
	select product_category, sum(quantity) as total_quantity,round(avg(quantity),2) as quantity_avg,
    round(avg(avg_price),2) as avg_price from shopping group by product_category
)
select * from product_quantity order by quantity_avg desc;

#WHICH CATEGORY OF PRODUCT HAS A HIGHER PRICE?
with product_price as(
	select product_category, round(avg(avg_price),2) as avg_price from shopping group by product_category
)
select * from product_price order by avg_price desc;

#WHICH CATEGORY WAS MORE BOUGHT BY MONTH?
with product_month as(
	select product_category,month,count(*) as total from shopping group by product_category,month
)
select * from product_month order by month,total desc;

#IN WHICH CATEGORY WERE THE MOST COUPONS USED?
select coupon_status,count(*) from shopping group by coupon_status;
with product_coupon as(
	select product_category as category,sum(case when coupon_status='Used' then 1 else 0 end) as Used,
    sum(case when coupon_status='Not Used' then 1 else 0 end) as 'Not used',sum(case when coupon_status='Clicked' then 1 else 0 end) as 'Clicked'
    from shopping group by product_category
)
select * from product_coupon;

#WHICH CATEGORY HAD MORE DISCOUNT?
with product_discount as(
	select product_category, round(avg(discount_pct),2) as avg_discount,round(avg(avg_price),2) as avg_price,
    round(avg(quantity),2) as avg_quantity from shopping group by product_category
)
select * from product_discount order by avg_discount desc;

#WAS THE USE OF COUPONS WAS DUE TO THE QUANTITY OF PRODUCTS PURCHASED?
with quantity_coupon as (
	select coupon_status,round(avg(quantity),2) as avg_quantity,sum(quantity) as total_quantity from shopping group by coupon_status
)
select * from quantity_coupon;

#DID THE QUANTITY OF PRODUCTS INFLUENCE THE DISCOUNT?
select max(quantity),min(quantity),avg(quantity) from shopping;
with quantity_discount as(
	select case
		when quantity<10 then 'Less than 10'
        when quantity between 10 and 20 then 'Between 10 and 20'
        when quantity between 20 and 50 then 'Between 20 and 50'
        when quantity between 50 and 100 then 'Betwen 50 and 100'
        else'+100'
        end as quantities, round(avg(discount_pct),2) as avg_discount from shopping group by quantities
)
select * from quantity_discount order by avg_discount desc;

#WERE THE COUPONS USED IN A HIGHER PRICE?
with price_coupon as(
	select coupon_status, round(avg(avg_price),2) as avg_prices from shopping group by coupon_status
)
select * from price_coupon;

#WERE THE PRICES RISES DEPEND OF THE MONTH?
with price_month as(
	select month,round(avg(avg_price),2) as avg_prices from shopping group by month 
)
select * from price_month; 

#DISCOUNT APPLIED IN AVERAGE PRICE OF THE PRODUCTS
with price_discount as(
	select case
		when avg_price between 0 and 20 then 'Products less than 20' 
        when avg_price between 20 and 50 then 'Products between 20 and 50'
        else 'Products over 50'
        end as prices, round(avg(discount_pct),2) as avg_discount from shopping group by prices
)
select * from price_discount;

#AVERAGE DISCOUNT BY EACH MONTH
with discount_month as(
	select month,round(avg(discount_pct),2) as avg_discount from shopping group by month
)
select * from discount_month order by avg_discount desc;