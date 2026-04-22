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

#USUARIOS CON MAS ACTIVIDAD ERAN HOMBRES O MUJERES
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
 

#LOCALIDAD DE LOS USUARIOS CON MAS ACTIVIDAD
with user_location as (
	select customerid,location,count(*) as amount from shopping group by customerid,location order by amount desc limit 50
)
select * from user_location;

#USUARIOS DE DIFERENTE LOCALIDAD 10% MAS ACTIVOS DEL DATASET 
with localidad as(
	select customerid, count(*) as total from shopping group by customerid
), percentage as (
	select l.customerid,percent_rank() over(order by l.total desc) as percentile,s.location from localidad as l join 
    shopping as s on l.customerid=s.customerid group by l.customerid,l.total,s.location
)
select location,sum(case when percentile <= 0.1 then 1 else 0 end) as 'Top 10', sum(case when percentile > 0.1 then 1 else 0 end) as 'Resto'
from percentage group by location;


#TIEMPO DE SUSCRIPCION POR PARTE DE LOS USUARIOS CON MAS ATIVIDAD Y MENOS ACTIVIDAD
#LOS USUARIOS QUE MAS COMPRARON TENIAN MAS TIEMPO EN LA PLATAFORMA?
with user_time as (
	select customerid,tenure_months,count(*) as amount from shopping group by customerid,tenure_months
)
select 'Average_high' as category,round(avg(tenure_months),2) as Average from (select tenure_months 
from user_time order by amount desc limit 50) as table_high union all
select 'Average_low', round(avg(tenure_months),2) from (select tenure_months from user_time order by amount asc limit 50) as table_low;

#PROMEDIO DEL TOP 10 Y RESTO DE USUARIOS MAS ACTIVOS
with users_time as(
	select customerid,count(*) as total from shopping group by customerid
), percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.tenure_months from users_time as u join shopping as s on u.customerid=s.customerid 
    group by u.customerid,s.tenure_months,u.total
)
select case when percentile <= 0.1 then 'Top 10' else 'Resto' end as Users, round(avg(tenure_months),2) from percentage group by Users; 


#USUARIOS CON MAS COMPRAS CADA MES
with user_month as (
	select customerid,sum(if(month(transaction_date)=1,1,0)) as January,sum(if(month(transaction_date)=2,1,0)) as February,sum(if(month(transaction_date)=3,1,0)) as March,
    sum(if(month(transaction_date)=4,1,0)) as April, sum(if(month(transaction_date)=5,1,0)) as May,sum(if(month(transaction_date)=6,1,0)) as June,
    sum(if(month(transaction_date)=7,1,0)) as July,sum(if(month(transaction_date)=8,1,0)) as August,sum(if(month(transaction_date)=9,1,0)) as September,
    sum(if(month(transaction_date)=10,1,0)) as October,sum(if(month(transaction_date)=11,1,0)) as November,sum(if(month(transaction_date)=12,1,0)) as December,
    count(*) as total from shopping group by customerid
)
select * from user_month order by total desc limit 50;

#USUARIOS TOP 10 Y EL RESTO CON MAS COMPRAS
with users_month as (
	select customerid,count(*) as total from shopping group by customerid
), percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,month(s.transaction_date) as months from users_month as u join shopping as s on u.customerid=s.customerid
    group by u.customerid,u.total,months
)
select months,sum(case when percentile <= 0.1 then 1 else 0 end) as 'Top 10', sum(case when percentile > 0.1 then 1 else 0 end) as 'Resto' from percentage group by months;


#COMPRAS DE LOS USUARIOS TOP 5% VS EL RESTO 
with users_month as(
	select customerid,count(*) as total_activity,percent_rank() over (order by count(*) desc) as percentile from shopping group by customerid
)
select case 
	when percentile <= 0.05 then 'Top 5%'
    else 'Resto'
 end as segment,round(avg(total_activity),2) as avg_activity,count(*) as num_users from users_month group by segment; #188 compras anuales
 
 
#DISTRIBUCION DE TIPO DE PRODUCTOS POR USUARIO 
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
        CASE WHEN us.percentil <= 0.05 THEN 'Top 5% (Activos)' ELSE 'Resto (Fantasmas)' END AS tipo_usuario,
        COUNT(*) as cantidad_compras
    FROM shopping s
    JOIN user_segments us ON s.customerid = us.customerid
    GROUP BY s.product_category, tipo_usuario
)
SELECT * FROM category_counts
ORDER BY tipo_usuario, cantidad_compras DESC;

select product_category,count(*) from shopping group by product_category;

#CANTIDAD DE PRODUCTOS DE COMPRA DE CADA USUARIO
with users_quantity as (
	select customerid,count(*) as total from shopping group by customerid 
),percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.quantity from users_quantity as u join shopping as s on u.customerid=s.customerid
    group by u.customerid,u.total,s.quantity
)
select case when percentile <=0.1 then 'Top 10' else 'Resto' end as categoria, sum(quantity) as amount from percentage group by categoria;

