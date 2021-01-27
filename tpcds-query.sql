use tpcdsch;

1.
select i_item_id,
    avg(cs_quantity) agg1,
    avg(cs_list_price) agg2,
    avg(cs_coupon_amt) agg3,
    avg(cs_sales_price) agg4,
    sum(cs_sales_price) sum5
from catalog_sales
join customer_demographics on cs_bill_cdemo_sk = cd_demo_sk
join date_dim on cs_sold_date_sk = d_date_sk
join item on cs_item_sk = i_item_sk
join promotion on cs_promo_sk = p_promo_sk
where cd_marital_status = 'D' and
   cd_education_status = 'Advanced Degree' and
   (p_channel_email = 'N' or p_channel_event = 'N') and
   d_year = 1998
group by i_item_id
order by i_item_id
limit 10;

-- substitute join with in
select i_item_id,
    avg(cs_quantity) agg1,
    avg(cs_list_price) agg2,
    avg(cs_coupon_amt) agg3,
    avg(cs_sales_price) agg4,
    sum(cs_sales_price) sum5
from catalog_sales
join item on cs_item_sk = i_item_sk
where cs_bill_cdemo_sk in
(
    select cd_demo_sk from customer_demographics where cd_marital_status = 'D'
        and cd_education_status = 'Advanced Degree'
)
and cs_sold_date_sk in
(
    select d_date_sk from date_dim where d_year = 1998
)
and cs_promo_sk in
(
    select p_promo_sk from promotion where p_channel_email = 'N' or p_channel_event = 'N'
)
group by i_item_id
order by i_item_id
limit 10;

2.
select i_brand_id brand_id, i_brand brand,
    sum(ss_ext_sales_price) ext_price
from store_sales
join item on ss_item_sk = i_item_sk
join date_dim on d_date_sk = ss_sold_date_sk
where i_manager_id=25
    and d_moy=11
    and d_year=2002
group by i_brand, i_brand_id
order by ext_price desc, i_brand_id
limit 10;

-- substitute join with in
select i_brand_id brand_id, i_brand brand,
  sum(ss_ext_sales_price) ext_price
from store_sales
join item on ss_item_sk = i_item_sk
where ss_sold_date_sk in (select d_date_sk from date_dim where d_moy=11 and d_year=2002)
and i_manager_id=25
group by i_brand, i_brand_id
order by ext_price desc, i_brand_id
limit 10;

3.
select channel, col_name, d_year, d_qoy, i_category, count(*) sales_cnt, sum(ext_sales_price) sales_amt from (
    select 'store' as channel, 'ss_promo_sk' col_name, d_year, d_qoy, i_category, ss_ext_sales_price ext_sales_price
     from store_sales
     join item on ss_item_sk=i_item_sk
     join date_dim on ss_sold_date_sk=d_date_sk
     where ss_promo_sk is null
    union all
    select 'web' as channel, 'ws_ship_customer_sk' col_name, d_year, d_qoy, i_category, ws_ext_sales_price ext_sales_price
     from web_sales
     join item on ws_item_sk=i_item_sk
     join date_dim on ws_sold_date_sk=d_date_sk
     where ws_ship_customer_sk is null
    union all
    select 'catalog' as channel, 'cs_bill_hdemo_sk' col_name, d_year, d_qoy, i_category, cs_ext_sales_price ext_sales_price
     from catalog_sales
     join item on cs_item_sk=i_item_sk
     join date_dim on cs_sold_date_sk=d_date_sk
     where cs_bill_hdemo_sk is null ) foo
group by channel, col_name, d_year, d_qoy, i_category
order by channel, col_name, d_year, d_qoy, i_category
limit 10;

4.
select avg(ss_quantity)
     ,avg(ss_ext_sales_price)
     ,avg(ss_ext_wholesale_cost)
     ,sum(ss_ext_wholesale_cost)
from (select ss_addr_sk, ss_quantity, ss_ext_sales_price, ss_ext_wholesale_cost, ss_ext_wholesale_cost, ss_net_profit
   from store_sales
   join store on s_store_sk = ss_store_sk
   join customer_demographics on cd_demo_sk = ss_cdemo_sk
   join household_demographics on ss_hdemo_sk=hd_demo_sk
   join (select * from date_dim where d_year = 2001) t on ss_sold_date_sk = d_date_sk
where ((cd_marital_status = 'U'
and cd_education_status = 'Secondary'
and ss_sales_price between 100.00 and 150.00
and hd_dep_count = 3
   )or
   (cd_marital_status = 'S'
and cd_education_status = 'Advanced Degree'
and ss_sales_price between 50.00 and 100.00
and hd_dep_count = 1
   ) or
   (cd_marital_status = 'M'
and cd_education_status = 'College'
and ss_sales_price between 150.00 and 200.00
and hd_dep_count = 1
   ))) t
join customer_address on ss_addr_sk = ca_address_sk
where ((ca_country = 'United States'
and ca_state in ('AK', 'TX', 'WV')
and ss_net_profit between 100 and 200
   ) or
   (ca_country = 'United States'
and ca_state in ('MT', 'NC', 'IN')
and ss_net_profit between 150 and 300
   ) or
   (ca_country = 'United States'
and ca_state in ('MI', 'MO', 'KY')
and ss_net_profit between 50 and 250
   ))
 limit 10;

5.
select c_last_name
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales
      join date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
      join store on store_sales.ss_store_sk = store.s_store_sk
      join household_demographics on store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    where date_dim.d_dom between 1 and 2
    and (household_demographics.hd_buy_potential = '>10000' or
         household_demographics.hd_buy_potential = '5001-10000')
    and household_demographics.hd_vehicle_count > 0
    and case when household_demographics.hd_vehicle_count > 0 then
             household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count else null end > 1
    and date_dim.d_year in (1999,1999+1,1999+2)
    and store.s_county in ('Williamson County','Williamson County','Williamson County','Williamson County')
    group by ss_ticket_number,ss_customer_sk) dj
    join customer on ss_customer_sk = c_customer_sk
    where cnt between 1 and 5
    order by cnt desc, ss_ticket_number asc limit 10;

-- substitute join with in
select c_last_name
   ,c_first_name
   ,c_salutation
   ,c_preferred_cust_flag
   ,ss_ticket_number
   ,cnt from (select ss_ticket_number
    ,ss_customer_sk
    ,count(*) cnt
from tpcdsch.store_sales
  where ss_sold_date_sk in (select d_date_sk from tpcdsch.date_dim where d_dom between 1 and 2 and d_year in (1999,1999+1,1999+2))
  and ss_store_sk in (select s_store_sk from tpcdsch.store where store.s_county in ('Williamson County','Williamson County','Williamson County','Williamson County'))
  and ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where (household_demographics.hd_buy_potential = '>10000' or
       household_demographics.hd_buy_potential = '5001-10000')
  and household_demographics.hd_vehicle_count > 0
  and case when household_demographics.hd_vehicle_count > 0 then
           household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count else null end > 1)
  group by ss_ticket_number,ss_customer_sk) dj
  join tpcdsch.customer on ss_customer_sk = c_customer_sk
where cnt between 1 and 5
order by cnt desc, ss_ticket_number asc
limit 10;

6.
select
  c_last_name,c_first_name,substr(s_city,1,30),ss_ticket_number,amt,profit
  from
   (select * from
   (select ss_ticket_number
          ,ss_customer_sk
          ,store.s_city as s_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales
    join date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
    join store on store_sales.ss_store_sk = store.s_store_sk
    join household_demographics on store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    where (household_demographics.hd_dep_count = 1 or household_demographics.hd_vehicle_count > -1)
    and date_dim.d_dow = 1
    and date_dim.d_year in (2000,2000+1,2000+2)
    and store.s_number_employees between 200 and 295
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk, store.s_city) t
    join customer on ss_customer_sk = c_customer_sk) t2
 order by substr(s_city,1,30), profit
 limit 10
;

-- substitute join with in
select
c_last_name,c_first_name,substr(s_city,1,30),ss_ticket_number,amt,profit
from (select ss_ticket_number
      ,ss_customer_sk
      ,store.s_city as s_city
      ,sum(ss_coupon_amt) amt
      ,sum(ss_net_profit) profit
    from tpcdsch.store_sales
    join tpcdsch.store on ss_store_sk = s_store_sk
    where ss_sold_date_sk in (select d_date_sk from tpcdsch.date_dim where d_dow = 1 and d_year in (2000,2000+1,2000+2))
    and ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where hd_dep_count = 1 or hd_vehicle_count > -1)
    and s_number_employees between 200 and 295
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk, store.s_city ) ms
    join customer on ss_customer_sk = c_customer_sk
order by substr(s_city,1,30), profit
limit 10
;

7.
select sum (ss_quantity)
from (select ss_addr_sk, ss_net_profit,ss_quantity
  from tpcdsch.store_sales
  join tpcdsch.store on s_store_sk = ss_store_sk
  join tpcdsch.customer_demographics on cd_demo_sk = ss_cdemo_sk
  join tpcdsch.customer_address on ss_addr_sk = ca_address_sk
  join tpcdsch.date_dim on ss_sold_date_sk = d_date_sk
  where d_year = 2000
  and
  ((
    cd_marital_status = 'S'
    and
    cd_education_status = 'Advanced Degree'
    and
    ss_sales_price between 100.00 and 150.00
    )
  or
   (cd_marital_status = 'D'
    and
    cd_education_status = '4 yr Degree'
    and
    ss_sales_price between 50.00 and 100.00
   )
  or
  (cd_marital_status = 'U'
    and
    cd_education_status = 'Secondary'
    and
    ss_sales_price between 150.00 and 200.00
  ))) t
join customer_address on ss_addr_sk = ca_address_sk
where
(
 (
 ca_country = 'United States'
 and
 ca_state in ('MN', 'TN', 'IL')
 and ss_net_profit between 0 and 2000
 )
or
 (
 ca_country = 'United States'
 and
 ca_state in ('TX', 'OR', 'ID')
 and ss_net_profit between 150 and 3000
 )
or
 (
 ca_country = 'United States'
 and
 ca_state in ('MI', 'AL', 'RI')
 and ss_net_profit between 50 and 25000
 )
)
;

8.
select i_item_id,
      avg(cs_quantity) agg1,
      avg(cs_list_price) agg2,
      avg(cs_coupon_amt) agg3,
      avg(cs_sales_price) agg4
from catalog_sales
join customer_demographics on cs_bill_cdemo_sk = cd_demo_sk
join date_dim on cs_sold_date_sk = d_date_sk
join item on cs_item_sk = i_item_sk
join promotion on cs_promo_sk = p_promo_sk
where cd_marital_status = 'D' and
     cd_education_status = 'Advanced Degree' and
     (p_channel_email = 'N' or p_channel_event = 'N') and
     d_year = 1998
group by i_item_id
order by i_item_id
limit 10
;

-- using in
select i_item_id,
     avg(cs_quantity) agg1,
     avg(cs_list_price) agg2,
     avg(cs_coupon_amt) agg3,
     avg(cs_sales_price) agg4
from catalog_sales
join item on cs_item_sk = i_item_sk
where cs_bill_cdemo_sk in (select cd_demo_sk from tpcdsch.customer_demographics where cd_marital_status = 'D' and cd_education_status = 'Advanced Degree')
    and cs_sold_date_sk in (select d_date_sk from tpcdsch.date_dim where d_year = 1998)
    and cs_promo_sk in (select p_promo_sk from tpcdsch.promotion where p_channel_email = 'N' or p_channel_event = 'N')
group by i_item_id
order by i_item_id
limit 10
;

9. -- do not support using parent column in subquery
select distinct(i_product_name)
from item i1
where i_manufact_id between 761 and 761+40
 and (select count(*) as item_cnt
      from item
      where (i_manufact = i1.i_manufact and
      ((i_category = 'Women' and
      (i_color = 'midnight' or i_color = 'gainsboro') and
      (i_units = 'Box' or i_units = 'Carton') and
      (i_size = 'small' or i_size = 'large')
      ) or
      (i_category = 'Women' and
      (i_color = 'magenta' or i_color = 'chocolate') and
      (i_units = 'Lb' or i_units = 'Bunch') and
      (i_size = 'petite' or i_size = 'medium')
      ) or
      (i_category = 'Men' and
      (i_color = 'chartreuse' or i_color = 'chiffon') and
      (i_units = 'Tbl' or i_units = 'Dozen') and
      (i_size = 'economy' or i_size = 'extra large')
      ) or
      (i_category = 'Men' and
      (i_color = 'coral' or i_color = 'pale') and
      (i_units = 'Ton' or i_units = 'Bundle') and
      (i_size = 'small' or i_size = 'large')
      ))) or
     (i_manufact = i1.i_manufact and
      ((i_category = 'Women' and
      (i_color = 'burnished' or i_color = 'plum') and
      (i_units = 'Oz' or i_units = 'Each') and
      (i_size = 'small' or i_size = 'large')
      ) or
      (i_category = 'Women' and
      (i_color = 'misty' or i_color = 'mint') and
      (i_units = 'Ounce' or i_units = 'Tsp') and
      (i_size = 'petite' or i_size = 'medium')
      ) or
      (i_category = 'Men' and
      (i_color = 'dark' or i_color = 'olive') and
      (i_units = 'Dram' or i_units = 'Gross') and
      (i_size = 'economy' or i_size = 'extra large')
      ) or
      (i_category = 'Men' and
      (i_color = 'cornflower' or i_color = 'hot') and
      (i_units = 'Gram' or i_units = 'N/A') and
      (i_size = 'small' or i_size = 'large')
      )))) > 0
order by i_product_name
limit 10
;

10. -- do not support window function in clickhouse
select *
from(
select i_category, i_class, i_brand,
       s_store_name, s_company_name,
       d_moy,
       sum(ss_sales_price) sum_sales,
       avg(sum(ss_sales_price)) over
         (partition by i_category, i_brand, s_store_name, s_company_name)
         avg_monthly_sales
from item, store_sales, date_dim, store
where ss_item_sk = i_item_sk and
      ss_sold_date_sk = d_date_sk and
      ss_store_sk = s_store_sk and
      d_year in (1998) and
        ((i_category in ('Electronics','Men','Books') and
          i_class in ('cameras','shirts','entertainments')
         )
      or (i_category in ('Music','Women','Jewelry') and
          i_class in ('classical','dresses','estate')
        ))
group by i_category, i_class, i_brand,
         s_store_name, s_company_name, d_moy) tmp1
where case when (avg_monthly_sales <> 0) then (abs(sum_sales - avg_monthly_sales) / avg_monthly_sales) else null end > 0.1
order by sum_sales - avg_monthly_sales, s_store_name
limit 10
;

11. -- duplicate with 7

12.
select
 s_store_name,
 i_item_desc,
 sc.revenue,
 i_current_price,
 i_wholesale_cost,
 i_brand
from (select ss_store_sk, ss_item_sk, sum(ss_sales_price) as revenue
 from store_sales
 join date_dim on ss_sold_date_sk = d_date_sk
 where d_month_seq between 1177 and 1177+11
 group by ss_store_sk, ss_item_sk) sc
join store on s_store_sk = sc.ss_store_sk
join item on i_item_sk = sc.ss_item_sk
join (select ss_store_sk, avg(revenue) as ave
	from
	    (select  ss_store_sk, ss_item_sk,
		     sum(ss_sales_price) as revenue
		from store_sales
  join date_dim on ss_sold_date_sk = d_date_sk
		where d_month_seq between 1177 and 1177+11
		group by ss_store_sk, ss_item_sk) sa
	group by ss_store_sk) sb on sb.ss_store_sk = sc.ss_store_sk
where sc.revenue <= sb.ave
order by sc.revenue desc
limit 10
;

13.
select  *
from
 (select count(*) h8_30_to_9
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 8
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s1,
 (select count(*) h9_to_9_30
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 9
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s2,
 (select count(*) h9_30_to_10
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 9
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s3,
 (select count(*) h10_to_10_30
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 10
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s4,
 (select count(*) h10_30_to_11
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 10
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s5,
 (select count(*) h11_to_11_30
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 11
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s6,
 (select count(*) h11_30_to_12
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 11
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s7,
 (select count(*) h12_to_12_30
 from store_sales
 join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
 join time_dim on ss_sold_time_sk = time_dim.t_time_sk
 join store on ss_store_sk = s_store_sk
 where time_dim.t_hour = 12
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
          (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
     and store.s_store_name = 'ese') s8
;

-- substitute join with in

select  *
from
(select count(*) h8_30_to_9
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 8 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s1,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 9 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s2,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 9 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s3,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 10 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s4,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 10 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s5,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 11 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s6,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 11 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s7,
(select count(*) h9_to_9_30
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 12 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s8
;

14.
select count(*)
from store_sales
join household_demographics on ss_hdemo_sk = household_demographics.hd_demo_sk
join time_dim on ss_sold_time_sk = time_dim.t_time_sk
join store on ss_store_sk = s_store_sk
where time_dim.t_hour = 8 and time_dim.t_minute >= 30 and household_demographics.hd_dep_count = 5 and
store.s_store_name = 'ese' order by count(*);

-- substitute join with in
select count(*)
from store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where hd_dep_count = 5)
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where t_hour = 8 and t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')
order by count(*);

15.
select
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as a
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as b
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as c
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as d
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as e
from
   store_sales
  join store_returns on ss_ticket_number = sr_ticket_number and ss_item_sk = sr_item_sk and ss_customer_sk = sr_customer_sk
  join store on ss_store_sk = s_store_sk
  join date_dim d1 on ss_sold_date_sk   = d1.d_date_sk
  join date_dim d2 on sr_returned_date_sk   = d2.d_date_sk
where
    d2.d_year = 2000
and d2.d_moy  = 8
group by
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
order by s_store_name
        ,s_company_id
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
limit 10
;

-- using in
select s_store_name
 ,s_company_id
 ,s_street_number
 ,s_street_name
 ,s_street_type
 ,s_suite_number
 ,s_city
 ,s_county
 ,s_state
 ,s_zip
 ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as a
 ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and
               (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as b
 ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and
               (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as c
 ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
               (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as d
 ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as e
from store_sales
join store_returns on ss_ticket_number = sr_ticket_number and ss_item_sk = sr_item_sk and ss_customer_sk = sr_customer_sk
join store on ss_store_sk = s_store_sk
where ss_sold_date_sk in (select d_date_sk from tpcdsch.date_dim)
 and sr_returned_date_sk in (select d_date_sk from tpcdsch.date_dim where d_year = 2000 and d_moy  = 8)
group by
 s_store_name
 ,s_company_id
 ,s_street_number
 ,s_street_name
 ,s_street_type
 ,s_suite_number
 ,s_city
 ,s_county
 ,s_state
 ,s_zip
order by s_store_name
     ,s_company_id
     ,s_street_number
     ,s_street_name
     ,s_street_type
     ,s_suite_number
     ,s_city
     ,s_county
     ,s_state
     ,s_zip
limit 10
;