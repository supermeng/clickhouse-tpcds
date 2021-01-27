-- currently (version before 21.1.2.15), multiple statement in one
-- single query is not supported, so we should execute each query
-- one by one
create database tpcdsch;

DROP TABLE IF EXISTS tpcdsch.catalog_sales
CREATE TABLE tpcdsch.catalog_sales
(
`cs_sold_date_sk` Int32,
`cs_sold_time_sk` Int32,
`cs_ship_date_sk` Int32,
`cs_bill_customer_sk` Int32,
`cs_bill_cdemo_sk` Int32,
`cs_bill_hdemo_sk` Int32,
`cs_bill_addr_sk` Int32,
`cs_ship_customer_sk` Int32,
`cs_ship_cdemo_sk` Int32,
`cs_ship_hdemo_sk` Int32,
`cs_ship_addr_sk` Int32,
`cs_call_center_sk` Int32,
`cs_catalog_page_sk` Int32,
`cs_ship_mode_sk` Int32,
`cs_warehouse_sk` Int32,
`cs_item_sk` Int32,
`cs_promo_sk` Int32,
`cs_order_number` Int32,
`cs_quantity` Int32,
`cs_wholesale_cost` Float,
`cs_list_price` Float,
`cs_sales_price` Float,
`cs_ext_discount_amt` Float,
`cs_ext_sales_price` Float,
`cs_ext_wholesale_cost` Float,
`cs_ext_list_price` Float,
`cs_ext_tax` Float,
`cs_coupon_amt` Float,
`cs_ext_ship_cost` Float,
`cs_net_paid` Float,
`cs_net_paid_inc_tax` Float,
`cs_net_paid_inc_ship` Float,
`cs_net_paid_inc_ship_tax` Float,
`cs_net_profit` Float
)
ENGINE = MergeTree
PARTITION BY cs_sold_date_sk
ORDER BY cs_sold_time_sk
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.call_center
CREATE TABLE tpcdsch.call_center
(
`cc_call_center_sk` Int32,
`cc_call_center_id` String,
`cc_rec_start_date` Date,
`cc_rec_end_date` Date,
`cc_closed_date_sk` Int32,
`cc_open_date_sk` Int32,
`cc_name` String,
`cc_class` String,
`cc_employees` Int32,
`cc_sq_ft` Int32,
`cc_hours` String,
`cc_manager` String,
`cc_mkt_id` Int32,
`cc_mkt_class` String,
`cc_mkt_desc` String,
`cc_market_manager` String,
`cc_division` Int32,
`cc_division_name` String,
`cc_company` Int32,
`cc_company_name` String,
`cc_street_number` String,
`cc_street_name` String,
`cc_street_type` String,
`cc_suite_number` String,
`cc_city` String,
`cc_county` String,
`cc_state` String,
`cc_zip` String,
`cc_country` String,
`cc_gmt_offset` Float,
`cc_tax_percentage` Float
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(cc_rec_start_date)
ORDER BY cc_call_center_sk
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.date_dim
CREATE TABLE tpcdsch.date_dim
(
d_date_sk Int32,
d_date_id String,
d_date Date,
d_month_seq Int32,
d_week_seq Int32,
d_quarter_seg Int32,
d_year Int32,
d_dow Int32,
d_moy Int32,
d_dom Int32,
d_qoy Int32,
d_fy_year Int32,
d_fy_quarter_seq Int32,
d_fy_week_seq Int32,
d_day_name String,
d_quarter_name String,
d_holiday String,
d_weekend String,
d_following_holiday String,
d_first_dom Int32,
d_last_dom Int32,
d_same_day_1y Int32,
d_same_day_1q Int32,
d_current_day String,
d_current_week String,
d_current_month String,
d_current_quarter String,
d_current_year String
)
ENGINE = MergeTree()
PARTITION BY (d_year)
ORDER BY (d_date_id)
SETTINGS index_granularity = 8192;

DROP TABLE IF EXISTS tpcdsch.household_demographics
CREATE TABLE tpcdsch.household_demographics
(
`hd_demo_sk` Int32,
`hd_income_band_sk` Int32,
`hd_buy_potential` String,
`hd_dep_count` Int32,
`hd_vehicle_count` Int32
)
ENGINE = MergeTree()
PARTITION BY tuple()
ORDER BY tuple()
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.item
CREATE TABLE tpcdsch.item
(
`i_item_sk` Int32,
`i_item_id` String,
`i_rec_start_date` Date,
`i_rec_end_date` Date,
`i_item_desc` String,
`i_current_price` Float,
`i_wholesale_cost` Float,
`i_brand_id` Int32,
`i_brand` String,
`i_class_id` Int32,
`i_class` String,
`i_category_id` Int32,
`i_category` String,
`i_manufact_id` Int32,
`i_manufact` String,
`i_size` String,
`i_formulation` String,
`i_color` String,
`i_units` String,
`i_container` String,
`i_manager_id` Int32,
`i_product_name` String
)
ENGINE = MergeTree()
PARTITION BY (i_category)
ORDER BY (i_item_id)
SETTINGS index_granularity = 8192;

DROP TABLE IF EXISTS tpcdsch.store
CREATE TABLE tpcdsch.store (
s_store_sk Int32 ,
s_store_id String,
s_rec_start_date date,
s_rec_end_date date,
s_closed_date_sk Int32,
s_store_name String,
s_number_employees Int32,
s_floor_space Int32,
s_hours String,
s_manager String,
s_market_id Int32,
s_geography_class String,
s_market_desc String,
s_market_manager String,
s_division_id Int32,
s_division_name String,
s_company_id Int32,
s_company_name String,
s_street_number String,
s_street_name String,
s_street_type String,
s_suite_number String,
s_city String,
s_county String,
s_state String,
s_zip String,
s_country String,
s_gmt_offset Float,
s_tax_percentage Float
)
ENGINE = MergeTree()
PARTITION BY tuple()
ORDER BY tuple()
SETTINGS index_granularity = 8192;

DROP TABLE IF EXISTS tpcdsch.customer
CREATE TABLE tpcdsch.customer
(
`c_customer_sk` Int32,
`c_customer_id` String,
`c_current_cdemo_sk` Int32,
`c_current_hdemo_sk` Int32,
`c_current_addr_sk` Int32,
`c_first_shipto_date_sk` Int32,
`c_first_sales_date_sk` Int32,
`c_salutation` String,
`c_first_name` String,
`c_last_name` String,
`c_preferred_cust_flag` String,
`c_birth_day` Int32,
`c_birth_month` Int32,
`c_birth_year` Int32,
`c_birth_country` String,
`c_login` String,
`c_email_address` String,
`c_last_review_date` Int32
)
ENGINE = MergeTree()
PARTITION BY c_birth_country
ORDER BY c_first_sales_date_sk
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.store_sales
CREATE TABLE tpcdsch.store_sales (
ss_sold_date_sk Int32,
ss_sold_time_sk Int32,
ss_item_sk Int32,
ss_customer_sk Int32,
ss_cdemo_sk Int32,
ss_hdemo_sk Int32,
ss_addr_sk Int32,
ss_store_sk Int32,
ss_promo_sk Int32,
ss_ticket_number Int32 ,
ss_quantity Int32,
ss_wholesale_cost Float,
ss_list_price Float,
ss_sales_price Float,
ss_ext_discount_amt Float,
ss_ext_sales_price Float,
ss_ext_wholesale_cost Float,
ss_ext_list_price Float,
ss_ext_tax Float,
ss_coupon_amt Float,
ss_net_paid Float,
ss_net_paid_inc_tax Float,
ss_net_profit Float
)
ENGINE = MergeTree()
PARTITION BY (ss_store_sk)
ORDER BY (ss_sold_date_sk)
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.web_sales
CREATE TABLE tpcdsch.web_sales (
ws_sold_date_sk Int32,
ws_sold_time_sk Int32,
ws_ship_date_sk Int32,
ws_item_sk Int32 ,
ws_bill_customer_sk Int32,
ws_bill_cdemo_sk Int32,
ws_bill_hdemo_sk Int32,
ws_bill_addr_sk Int32,
ws_ship_customer_sk Int32,
ws_ship_cdemo_sk Int32,
ws_ship_hdemo_sk Int32,
ws_ship_addr_sk Int32,
ws_web_page_sk Int32,
ws_web_site_sk Int32,
ws_ship_mode_sk Int32,
ws_warehouse_sk Int32,
ws_promo_sk Int32,
ws_order_number Int32 ,
ws_quantity Int32,
ws_wholesale_cost Float,
ws_list_price Float,
ws_sales_price Float,
ws_ext_discount_amt Float,
ws_ext_sales_price Float,
ws_ext_wholesale_cost Float,
ws_ext_list_price Float,
ws_ext_tax Float,
ws_coupon_amt Float,
ws_ext_ship_cost Float,
ws_net_paid Float,
ws_net_paid_inc_tax Float,
ws_net_paid_inc_ship Float,
ws_net_paid_inc_ship_tax Float,
ws_net_profit Float
)
ENGINE = MergeTree()
PARTITION BY (ws_warehouse_sk)
ORDER BY (ws_sold_date_sk)
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.customer_demographics
CREATE TABLE tpcdsch.customer_demographics
(
`cd_demo_sk` Int32,
`cd_gender` String,
`cd_marital_status` String,
`cd_education_status` String,
`cd_purchase_estimate` Int32,
`cd_credit_rating` String,
`cd_dep_count` Int32,
`cd_dep_employed_count` Int32,
`cd_dep_college_count` Int32
)
ENGINE = MergeTree()
PARTITION BY cd_credit_rating
ORDER BY cd_demo_sk
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.promotion;
CREATE TABLE tpcdsch.promotion
(
`p_promo_sk` Int32,
`p_promo_id` String,
`p_start_date_sk` Int32,
`p_end_date_sk` Int32,
`p_item_sk` Int32,
`p_cost`  Float,
`p_response_target` Int32,
`p_promo_name` String,
`p_channel_dmail` String,
`p_channel_email` String,
`p_channel_catalog` String,
`p_channel_tv` String,
`p_channel_radio` String,
`p_channel_press` String,
`p_channel_event` String,
`p_channel_demo` String,
`p_channel_details` String,
`p_purpose` String,
`p_discount_active` String
)
ENGINE = MergeTree()
PARTITION BY tuple()
ORDER BY p_promo_sk
SETTINGS index_granularity = 8192;

DROP TABLE IF EXISTS tpcdsch.customer_address;
CREATE TABLE tpcdsch.customer_address
(
`ca_address_sk` Int32,
`ca_address_id` String,
`ca_street_number` String,
`ca_street_name` String,
`ca_street_type` String,
`ca_suite_number` String,
`ca_city` String,
`ca_county` String,
`ca_state` String,
`ca_zip` String,
`ca_country` String,
`ca_gmt_offset` Float,
`ca_location_type` String
)
ENGINE = MergeTree()
PARTITION BY tuple()
ORDER BY ca_street_number
SETTINGS index_granularity = 8192;

DROP TABLE IF EXISTS tpcdsch.catalog_returns
create table tpcdsch.catalog_returns
(
cr_returned_date_sk Int32,
cr_returned_time_sk Int32,
cr_item_sk Int32,
cr_ship_date_sk Int32,
cr_refunded_customer_sk   Int32,
cr_refunded_cdemo_sk  Int32,
cr_refunded_hdemo_sk  Int32,
cr_refunded_addr_sk   Int32,
cr_returning_customer_sk  Int32,
cr_returning_cdemo_sk Int32,
cr_returning_hdemo_sk Int32,
cr_returning_addr_sk  Int32,
cr_call_center_sk Int32,
cr_catalog_page_sk Int32,
cr_ship_mode_sk   Int32,
cr_warehouse_sk   Int32,
cr_reason_sk  Int32,
cr_order_number   Int32,
cr_return_quantity Float,
cr_return_amount  Float,
cr_return_tax Float,
cr_return_amt_inc_tax Float,
cr_fee  Float,
cr_return_ship_cost   Float,
cr_refunded_cash  Float,
cr_reversed_charge Float,
cr_store_credit   Float,
cr_net_loss   Float
)
ENGINE = MergeTree()
PARTITION BY cr_returned_date_sk
ORDER BY cr_item_sk
SETTINGS index_granularity = 8192;

DROP TABLE IF EXISTS tpcdsch.warehouse
CREATE TABLE tpcdsch.warehouse
(
    `w_warehouse_sk` Int32,
    `w_warehouse_id` String,
    `w_warehouse_name` String,
    `w_warehouse_sq_ft` Int32,
    `w_street_number` String,
    `w_street_name` String,
    `w_street_type` String,
    `w_suite_number` String,
    `w_city` String,
    `w_county` String,
    `w_state` String,
    `w_zip` String,
    `w_country` String,
    `w_gmt_offset` Float
)
ENGINE = MergeTree()
PARTITION BY tuple()
ORDER BY tuple()
SETTINGS index_granularity = 8192

DROP TABLE IF EXISTS tpcdsch.time_dim
CREATE TABLE tpcdsch.time_dim
(
    `t_time_sk` Int32,
    `t_time_id` String,
    `t_time` Int32,
    `t_hour` Int32,
    `t_minute` Int32,
    `t_second` Int32,
    `t_am_pm` String,
    `t_shift` String,
    `t_sub_shift` String,
    `t_meal_time` String
)
ENGINE = MergeTree()
PARTITION BY (t_hour)
ORDER BY (t_time_id)
SETTINGS index_granularity = 8192

drop table IF EXISTS tpcdsch.store_returns
create table tpcdsch.store_returns
(
    sr_returned_date_sk       Int32,
    sr_return_time_sk         Int32,
    sr_item_sk                Int32,
    sr_customer_sk            Int32,
    sr_cdemo_sk               Int32,
    sr_hdemo_sk               Int32,
    sr_addr_sk                Int32,
    sr_store_sk               Int32,
    sr_reason_sk              Int32,
    sr_ticket_number          Int32,
    sr_return_quantity        Int32,
    sr_return_amt             Float,
    sr_return_tax             Float,
    sr_return_amt_inc_tax     Float,
    sr_fee                    Float,
    sr_return_ship_cost       Float,
    sr_refunded_cash          Float,
    sr_reversed_charge        Float,
    sr_store_credit           Float,
    sr_net_loss               Float
)
ENGINE = MergeTree()
PARTITION BY (sr_returned_date_sk)
ORDER BY (sr_item_sk)
SETTINGS index_granularity = 8192

-- distributed table

create database tpcds_dist

create table tpcds_dist.catalog_sales as tpcdsch.catalog_sales
ENGINE = Distributed(local_test, tpcdsch, catalog_sales, cs_item_sk)

CREATE TABLE tpcds_dist.store_sales AS tpcdsch.store_sales
ENGINE = Distributed(local_test, tpcdsch, store_sales, ss_item_sk)

create table tpcds_dist.customer_demographics as tpcdsch.customer_demographics
ENGINE = Distributed(local_test, tpcdsch, customer_demographics, cd_demo_sk)

create table tpcds_dist.date_dim as tpcdsch.date_dim
ENGINE = Distributed(local_test, tpcdsch, date_dim, d_date_sk)

create table tpcds_dist.promotion as tpcdsch.promotion
ENGINE = Distributed(local_test, tpcdsch, promotion, p_promo_sk)

create table tpcds_dist.item as tpcdsch.item
ENGINE = Distributed(local_test, tpcdsch, item, i_item_sk)

create table tpcds_dist.web_sales as tpcdsch.web_sales
ENGINE = Distributed(local_test, tpcdsch, web_sales, ws_item_sk)

create table tpcds_dist.customer as tpcdsch.customer
ENGINE = Distributed(local_test, tpcdsch, customer, c_customer_sk)

create table tpcds_dist.store as tpcdsch.store
ENGINE = Distributed(local_test, tpcdsch, store, s_store_sk)

create table tpcds_dist.household_demographics as tpcdsch.household_demographics
ENGINE = Distributed(local_test, tpcdsch, household_demographics, hd_demo_sk)

create table tpcds_dist.customer_address as tpcdsch.customer_address
ENGINE = Distributed(local_test, tpcdsch, customer_address, ca_address_sk)

create table tpcds_dist.store_returns as tpcdsch.store_returns
ENGINE = Distributed(local_test, tpcdsch, store_returns, sr_item_sk)