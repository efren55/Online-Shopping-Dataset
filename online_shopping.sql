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
	when percentile <= 0.1 then 'Top 10%'
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
        CASE WHEN us.percentil <= 0.1 THEN 'Top 10% (Activos)' ELSE 'Resto (Fantasmas)' END AS tipo_usuario,
        COUNT(*) as cantidad_compras
    FROM shopping s
    JOIN user_segments us ON s.customerid = us.customerid
    GROUP BY s.product_category, tipo_usuario
)
SELECT * FROM category_counts
ORDER BY tipo_usuario, cantidad_compras DESC;

select product_category,count(*) from shopping group by product_category;

#CANTIDAD DE PRODUCTOS DE COMPRA DE USUARIOS TOP 10 Y RESTO
with users_quantity as (
	select customerid,count(*) as total from shopping group by customerid 
),percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.quantity from users_quantity as u join shopping as s on u.customerid=s.customerid
    group by u.customerid,u.total,s.quantity
)
select case when percentile <=0.1 then 'Top 10' else 'Resto' end as categoria, sum(quantity) as amount from percentage group by categoria;

#PRECIO PROMEDIO DE LOS DE LOS PRODUCTOS COMPRADOS POR LOS USUARIOS TOP 10 Y EL RESTO
with users_price as (
	select customerid,count(*) as total from shopping group by customerid
),percentage as (
	select u.customerid,percent_rank() over(order by count(*) desc) as percentile,s.avg_price from users_price as u join shopping as s
    on s.customerid=u.customerid group by u.customerid,u.total,s.avg_price
)
select case when percentile <= 0.1 then 'Top 10' else 'Rest' end as category,round(avg(avg_price),2) as price from percentage group by category;

#LOS USUARIOS TOP 10 USABAN MAS CUPONES QUE EL RESTO?
with users_coupon as (
	select customerid,percent_rank() over(order by count(*) desc) as percentile from shopping group by customerid
)
select s.coupon_status,case when u.percentile <= 0.1 then 'Top 10' else 'Resto' end as categoria,count(*) total from shopping as s join users_coupon as u 
on s.customerid=u.customerid group by s.coupon_status,categoria;

#LAS PERSONAS TOP 10 TIENEN MAS O MENOS DESCUENTO QUE EL RESTO?
with users_discount as (
	select customerid,percent_rank() over(order by count(*) desc) as percentile from shopping group by customerid
)
select case when u.percentile <= 0.1 then 'Top 10' else 'Resto' end as Categoria, round(avg(s.discount_pct),2) as descuento from users_discount as u 
join shopping as s on u.customerid=s.customerid group by Categoria;

#DISTRIBUCION DE HOMBRES Y MUJERES POR ESTADO
with sex_location as (
	select location, sum(case when gender='M' then 1 else 0 end) as Male, sum(case when gender='F' then 1 else 0 end) as Female, count(*) as Total from shopping group by location
    order by total desc
)
select * from sex_location;

#QUE SEXO ESTUVO MAS ASOCIADO A LA PLATAFORMA 
with sex_count as (
	select gender,round(avg(tenure_months),2) as tenure_months from shopping group by gender
)
select * from sex_count;

#DISTRIBUCION DE SEXO POR MES
with sex_months as (
	select month, sum(case when gender='M' then 1 else 0 end) as Male,sum(case when gender='F' then 1 else 0 end) as Female,count(*) as total from shopping group by month order by total desc
)
select * from sex_months;

#QUE PRODUCTOS PREFIRIERON HOMBRES Y MUJERES
with sex_products as (
	select product_category,sum(case when gender='M' then 1 else 0 end) as Male,sum(case when gender='F' then 1 else 0 end) as Female, count(*) as total
    from shopping group by product_category order by total desc
)
select * from sex_products;

#PRECIO DE LOS PRODUCTOS COMPRADOS POR CADA SEXO
with sex_price as (
	select gender,round(avg(avg_price),2) as price from shopping group by gender
)
select * from sex_price;

select coupon_status,count(*) from shopping group by coupon_status;

#CANTIDAD DE PRODUCTOS QUE COMPRARON POR CADA SEXO
with sex_quantity as (
	select gender,sum(quantity) as sum_quantity, round(avg(quantity),2) as avg_quantity from shopping group by gender
)
select * from sex_quantity;

#QUE SEXO USO MAS CUPONES
with sex_coupons as (
	select gender,sum(case when coupon_status='Used' then 1 else 0 end) as Used,sum(case when coupon_status='Not Used' then 1 else 0 end) as 'Not Used',
    sum(case when coupon_status='Clicked' then 1 else 0 end) as Clicked from shopping group by gender
)
select * from sex_coupons;

select gender,coupon_status,count(*) as total from shopping group by gender,coupon_status;

#QUE SEXO TUVO MAS DESCUENTOS
with sex_discount as (
	select gender,round(avg(discount_pct),2) as avg_discount from shopping group by gender
)
select * from sex_discount;

#QUE ESTADOS TUVIERON MAS TIEMPO ASOCIADO POR LA PLATAFORMA
with location_tenure as (
	select location,round(avg(tenure_months),2) as avg_tenure from shopping group by location
)
select * from location_tenure;

#QUE ESTADO TUVO MAS ACTIVIDAD CADA MES 
with location_month as (
	select location,month,count(*) total from shopping group by location,month
)
select * from location_month;

#ESTADO QUE USO MAS CUPONES
with location_coupon as (
	select location,coupon_status,count(*) as total from shopping group by location,coupon_status
)
select * from location_coupon;

#COMPRA DE TIPOS DE PRODUCTOS POR CADA ESTADO
with location_products as (
	select location,product_category,count(*) as total from shopping group by location,product_category
)
select * from location_products;

#CANTIDAD DE PRODUCTOS COMPARDOS POR ESTADOS
with location_quantity as (
	select location,sum(quantity) as sum_quantity,round(avg(quantity),2) as avg_quantity from shopping group by location
)
select * from location_quantity;

#PRECIO PROMEDIO QUE COMPRARON LOS USUARIOS POR ESTADO. 
with location_price as (
	select location,round(avg(avg_price),2) avg_price from shopping group by location
)
select * from location_price;

#QUE ESTADO TUVO MAS DESCUENTO PROMEDIO
with location_discount as (
	select location,round(avg(discount_pct),2) as avg_discount from shopping group by location
)
select * from location_discount order by avg_discount desc;

#DESCUENTO,PROMEDIO PRECIO,QUANTITY,
with location_compare as (
	select location,count(*) as total_purcharses,sum(quantity) as quantity,round(avg(quantity),2) as avg_quantity,round(avg(avg_price),2) as avg_price,
    round(avg(discount_pct),2) as discount,sum(case when coupon_status='Used' then 1 else 0 end) as 'Coupon used',sum(case when coupon_status='Clicked' then 1 else 0 end) as 'Coupon clicked',
    sum(case when coupon_status='Not Used' then 1 else 0 end) as 'Coupon not used' from shopping group by location
)
select * from location_compare;

#CANTIDAD VS PRECIO 
with location_pe as (
	select location, round(sum((quantity * avg_price)),2) as income from shopping group by location
)
select * from location_pe order by income desc;

#LOS COMPRADORES CON MAS TIEMPO ASOCIADO A LA PLATAFORMA COMPRARON MAS EN UN MES ESPECIFICO?
with tenure_month as (
	select month, round(avg(tenure_months),2) as tenure_months,count(*) as total from shopping group by month
)
select * from tenure_month order by tenure_months desc;

#LOS COMPRADORES CON MAS TIEMPO ASOCIADO A LA PLATAFORMA PREFIEREN UN TIPO DE PRODUCTO?
with tenure_product as (
	select product_category, round(avg(tenure_months),2) as tenure_months, count(*) as total from shopping group by product_category
)
select * from tenure_product order by tenure_months desc;

#LOS QUE TIENEN MAS TIEMPO EN LA PLATAFORMA COMPRAN MAS CANTIDAD DE PRODUCTOS?
with tenure_quantity as(
	select case 
		when tenure_months<=12 then 'No more than a year'
        when tenure_months>12 and tenure_months<=24 then 'Between 1 and 2 years'
        when tenure_months>24 and tenure_months<=36 then 'Between 2 and 3 years'
        else '3+ years'
        end as user_time, sum(quantity) as 'Sum',round(avg(quantity),2) quantity_avg from shopping group by user_time
)

select * from tenure_quantity;

#LOS QUE TUVIERON MAS TIEMPO EN LA PLATAFORMA TUVIERON MAS O MENOS DESCUENTO?
with tenure_discount as(
	select case 
		when tenure_months<=12 then 'No more than a year'
        when tenure_months>12 and tenure_months<=24 then 'Between 1 and 2 years'
        when tenure_months>24 and tenure_months<=36 then 'Between 2 and 3 years'
        else '3+ years'
        end as user_time, round(avg(discount_pct),2) as discount_avg from shopping group by user_time
)
select * from tenure_discount;

#QUE CATEGORIA DE PRODUCTOS COMPRARON CON MAS CANTIDAD?
with product_quantity as(
	select product_category, sum(quantity) as total_quantity,round(avg(quantity),2) as quantity_avg,
    round(avg(avg_price),2) as avg_price from shopping group by product_category
)
select * from product_quantity order by quantity_avg desc;

#QUE CATEGORIA DE PRODUCTO TIENE UN PRECIO MAS ALTO?
with product_price as(
	select product_category, round(avg(avg_price),2) as avg_price from shopping group by product_category
)
select * from product_price order by avg_price desc;

#QUE CATEGORIA SE COMPRO MAS POR MES?
with product_month as(
	select product_category,month,count(*) as total from shopping group by product_category,month
)
select * from product_month order by month,total desc;

#EN QUE CATEGORIA MAS DE PRODUCTOS SE USO MAS CUPONES
select coupon_status,count(*) from shopping group by coupon_status;
with product_coupon as(
	select product_category as category,sum(case when coupon_status='Used' then 1 else 0 end) as Used,
    sum(case when coupon_status='Not Used' then 1 else 0 end) as 'Not used',sum(case when coupon_status='Clicked' then 1 else 0 end) as 'Clicked'
    from shopping group by product_category
)
select * from product_coupon;

#QUE CATEGORIA DE PRODUCTO TUVO MAS DESCUENTO?
with product_discount as(
	select product_category, round(avg(discount_pct),2) as avg_discount,round(avg(avg_price),2) as avg_price,
    round(avg(quantity),2) as avg_quantity from shopping group by product_category
)
select * from product_discount order by avg_discount desc;

#EL USO DE CUPONES FUE POR LA CANTIDAD DE PRODUCTOS
with quantity_coupon as (
	select coupon_status,round(avg(quantity),2) as avg_quantity,sum(quantity) as total_quantity from shopping group by coupon_status
)
select * from quantity_coupon;

#LA CANTIDAD DE PRODUCTO INFLUYO EN EL DESCUENTO?
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