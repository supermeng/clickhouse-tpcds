1.
-- using in
select i_item_id,
 avg(cs_quantity) agg1,
 avg(cs_list_price) agg2,
 avg(cs_coupon_amt) agg3,
 avg(cs_sales_price) agg4,
 sum(cs_sales_price) sum5
from tpcds_dist.catalog_sales
join tpcdsch.item on cs_item_sk = i_item_sk
where cs_bill_cdemo_sk in
(
    select cd_demo_sk from tpcdsch.customer_demographics where cd_marital_status = 'D' and
     cd_education_status = 'Advanced Degree'
)
and cs_sold_date_sk in
(
    select d_date_sk from tpcdsch.date_dim where d_year = 1998
)
and cs_promo_sk in
(
    select p_promo_sk from tpcdsch.promotion where p_channel_email = 'N' or p_channel_event = 'N'
)
group by i_item_id
order by i_item_id
limit 10;

2.
-- using in
select i_brand_id brand_id, i_brand brand,
  sum(ss_ext_sales_price) ext_price
from tpcds_dist.store_sales
join tpcdsch.item on ss_item_sk = i_item_sk
where ss_sold_date_sk in (select d_date_sk from tpcdsch.date_dim where d_moy=11 and d_year=2002)
and i_manager_id=25
group by i_brand, i_brand_id
order by ext_price desc, i_brand_id
limit 10;

3. -- do not support multiple distributed local join without primary key
4. -- for one to one join we using customer_address as left table
select avg(ss_quantity)
     ,avg(ss_ext_sales_price)
     ,avg(ss_ext_wholesale_cost)
     ,sum(ss_ext_wholesale_cost)
from tpcds_dist.customer_address
 join (select ss_addr_sk, ss_quantity, ss_ext_sales_price, ss_ext_wholesale_cost, ss_ext_wholesale_cost, ss_net_profit
   from tpcdsch.store_sales
   join tpcdsch.store on s_store_sk = ss_store_sk
   join tpcdsch.customer_demographics on cd_demo_sk = ss_cdemo_sk
   join tpcdsch.household_demographics on ss_hdemo_sk=hd_demo_sk
   join (select * from tpcdsch.date_dim where d_year = 2001) t on ss_sold_date_sk = d_date_sk
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
   ))) t on ss_addr_sk = ca_address_sk
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
   ,cnt from tpcds_dist.customer
   join (select ss_ticket_number
    ,ss_customer_sk
    ,count(*) cnt
    from tpcdsch.store_sales
    join tpcdsch.date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
    join tpcdsch.store on store_sales.ss_store_sk = store.s_store_sk
    join tpcdsch.household_demographics on store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    where date_dim.d_dom between 1 and 2
    and (household_demographics.hd_buy_potential = '>10000' or
         household_demographics.hd_buy_potential = '5001-10000')
    and household_demographics.hd_vehicle_count > 0
    and case when household_demographics.hd_vehicle_count > 0 then
             household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count else null end > 1
    and date_dim.d_year in (1999,1999+1,1999+2)
    and store.s_county in ('Williamson County','Williamson County','Williamson County','Williamson County')
    group by ss_ticket_number,ss_customer_sk) dj on ss_customer_sk = c_customer_sk
where cnt between 1 and 5
order by cnt desc, ss_ticket_number asc limit 10;

-- using in
select c_last_name
   ,c_first_name
   ,c_salutation
   ,c_preferred_cust_flag
   ,ss_ticket_number
   ,cnt
   from tpcds_dist.customer join (select ss_ticket_number
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
      group by ss_ticket_number,ss_customer_sk) dj on ss_customer_sk = c_customer_sk
where cnt between 1 and 5
order by cnt desc, ss_ticket_number asc
limit 10;

6.
select
 c_last_name,c_first_name,substr(s_city,1,30),ss_ticket_number,amt,profit
 from tpcds_dist.customer join
 (select ss_ticket_number
      ,ss_customer_sk
      ,store.s_city as s_city
      ,sum(ss_coupon_amt) amt
      ,sum(ss_net_profit) profit
    from tpcdsch.store_sales
    join tpcdsch.date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
    join tpcdsch.store on store_sales.ss_store_sk = store.s_store_sk
    join tpcdsch.household_demographics on store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    where (household_demographics.hd_dep_count = 1 or household_demographics.hd_vehicle_count > -1)
    and date_dim.d_dow = 1
    and date_dim.d_year in (2000,2000+1,2000+2)
    and store.s_number_employees between 200 and 295
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk, store.s_city ) ms on ss_customer_sk = c_customer_sk
order by substr(s_city,1,30), profit
limit 10
;

-- using in
select
c_last_name,c_first_name,substr(s_city,1,30),ss_ticket_number,amt,profit
from tpcds_dist.customer join
 (select ss_ticket_number
      ,ss_customer_sk
      ,store.s_city as s_city
      ,sum(ss_coupon_amt) amt
      ,sum(ss_net_profit) profit
  from tpcdsch.store_sales
  join tpcdsch.store on ss_store_sk = s_store_sk
  where ss_sold_date_sk in (select d_date_sk from tpcdsch.date_dim where d_dow = 1 and d_year in (2000,2000+1,2000+2))
  and ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where hd_dep_count = 1 or hd_vehicle_count > -1)
  and s_number_employees between 200 and 295
  group by ss_ticket_number,ss_customer_sk,ss_addr_sk, store.s_city ) ms on ss_customer_sk = c_customer_sk
order by substr(s_city,1,30), profit
limit 10
;

7.
select sum (ss_quantity)
from tpcds_dist.customer_address join (select ss_addr_sk, ss_net_profit,ss_quantity
  from tpcdsch.store_sales
  join tpcdsch.store on s_store_sk = ss_store_sk
  join tpcdsch.customer_demographics on cd_demo_sk = ss_cdemo_sk
  join tpcdsch.customer_address on ss_addr_sk = ca_address_sk
  join tpcdsch.date_dim on ss_sold_date_sk = d_date_sk
  where d_year = 2000
  and
  (( cd_marital_status = 'S'
    and
    cd_education_status = 'Advanced Degree'
    and
    ss_sales_price between 100.00 and 150.00)
  or ( cd_marital_status = 'D'
    and
    cd_education_status = '4 yr Degree'
    and
    ss_sales_price between 50.00 and 100.00)
  or ( cd_marital_status = 'U'
    and
    cd_education_status = 'Secondary'
    and
    ss_sales_price between 150.00 and 200.00)
  )) t on ss_addr_sk = ca_address_sk
where
(( ca_country = 'United States'
 and
 ca_state in ('MN', 'TN', 'IL')
 and ss_net_profit between 0 and 2000 )
or ( ca_country = 'United States'
 and
 ca_state in ('TX', 'OR', 'ID')
 and ss_net_profit between 150 and 3000 )
or ( ca_country = 'United States'
 and
 ca_state in ('MI', 'AL', 'RI')
 and ss_net_profit between 50 and 25000)
)
;

8.
-- using in
select i_item_id,
     avg(cs_quantity) agg1,
     avg(cs_list_price) agg2,
     avg(cs_coupon_amt) agg3,
     avg(cs_sales_price) agg4
from tpcds_dist.catalog_sales
join tpcdsch.item on cs_item_sk = i_item_sk
where cs_bill_cdemo_sk in (select cd_demo_sk from tpcdsch.customer_demographics where cd_marital_status = 'D' and cd_education_status = 'Advanced Degree')
    and cs_sold_date_sk in (select d_date_sk from tpcdsch.date_dim where d_year = 1998)
    and cs_promo_sk in (select p_promo_sk from tpcdsch.promotion where p_channel_email = 'N' or p_channel_event = 'N')
group by i_item_id
order by i_item_id
limit 10
;

12.


13.
-- using in
select  *
from
(select count(*) h8_30_to_9
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 8 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s1,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 9 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s2,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 9 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s3,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 10 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s4,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 10 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s5,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 11 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s6,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 11 and time_dim.t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s7,
(select count(*) h9_to_9_30
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where
  (household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
  (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2) or
  (household_demographics.hd_dep_count = 4 and household_demographics.hd_vehicle_count<=4+2))
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where time_dim.t_hour = 12 and time_dim.t_minute < 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')) s8
;

14.
-- using in
select count(*)
from tpcds_dist.store_sales
where ss_hdemo_sk in (select hd_demo_sk from tpcdsch.household_demographics where hd_dep_count = 5)
and ss_sold_time_sk in (select t_time_sk from tpcdsch.time_dim where t_hour = 8 and t_minute >= 30)
and ss_store_sk in (select s_store_sk from tpcdsch.store where s_store_name = 'ese')
order by count(*);

15.
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
from tpcds_dist.store
join (select ss_store_sk, sr_returned_date_sk, ss_sold_date_sk from tpcdsch.store_sales
 join tpcdsch.store_returns on ss_ticket_number = sr_ticket_number and ss_item_sk = sr_item_sk and ss_customer_sk = sr_customer_sk
 where ss_sold_date_sk in (select d_date_sk from tpcdsch.date_dim)
  and sr_returned_date_sk in (select d_date_sk from tpcdsch.date_dim where d_year = 2000 and d_moy  = 8)
) t on ss_store_sk = s_store_sk
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