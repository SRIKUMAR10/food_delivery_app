-- ═════════════════════════════════════════════════════════════════════════════
-- FOOD DELIVERY ENTERPRISE DATA LAKEHOUSE & BIGQUERY STAR SCHEMA (PHASE 3)
-- Database: food_delivery_dw (Google Cloud BigQuery, Location: asia-south1)
-- ═════════════════════════════════════════════════════════════════════════════

-- 1. CREATE DATASET
CREATE SCHEMA IF NOT EXISTS `food_delivery_dw`
OPTIONS (
  location = 'asia-south1',
  description = 'Enterprise Data Warehouse for Food Delivery App (Buyer, Seller, Rider, CRM & Financial Analytics)'
);

-- ═════════════════════════════════════════════════════════════════════════════
-- 2. DIMENSION TABLES (SCD TYPE 1 / 2 DIMENSIONAL MODELING)
-- ═════════════════════════════════════════════════════════════════════════════

-- A. Dim_Buyers (Customer Profile & Identity)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Dim_Buyers` (
  buyer_key STRING NOT NULL,           -- UID from Firebase Auth / buyer_user/{uid}
  full_name STRING,
  email STRING,
  phone_number STRING,
  account_created_at TIMESTAMP,
  registration_platform STRING,        -- Android, iOS, Web
  default_city STRING,
  default_pincode STRING,
  is_active BOOL,
  updated_at TIMESTAMP
)
CLUSTER BY default_city, buyer_key;

-- B. Dim_Sellers (Merchant & Restaurant Catalog Master)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Dim_Sellers` (
  seller_key STRING NOT NULL,          -- UID from sellers/{uid}
  store_name STRING,
  owner_name STRING,
  contact_phone STRING,
  contact_email STRING,
  category STRING,                     -- Restaurant, Bakery, Cafe, Grocery
  cuisine_types ARRAY<STRING>,
  address_street STRING,
  city STRING,
  geo_latitude FLOAT64,
  geo_longitude FLOAT64,
  commission_percentage FLOAT64,
  rating_score FLOAT64,
  is_store_open BOOL,
  onboarded_at TIMESTAMP,
  updated_at TIMESTAMP
)
CLUSTER BY city, category, seller_key;

-- C. Dim_DeliveryPartners (Rider Fleet Master)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Dim_DeliveryPartners` (
  rider_key STRING NOT NULL,           -- UID from delivery_partners/{uid}
  rider_name STRING,
  phone_number STRING,
  vehicle_type STRING,                 -- Bike, EV Scooter, Bicycle
  vehicle_number STRING,
  driving_license STRING,
  kyc_status STRING,                   -- Verified, Pending, Rejected
  rating_score FLOAT64,
  is_online BOOL,
  is_active BOOL,
  onboarded_at TIMESTAMP,
  updated_at TIMESTAMP
)
CLUSTER BY vehicle_type, kyc_status, rider_key;

-- D. Dim_Products (Menu Items Catalog)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Dim_Products` (
  product_key STRING NOT NULL,         -- ID from products/{productId}
  seller_key STRING NOT NULL,
  product_name STRING,
  category_name STRING,
  base_price FLOAT64,
  discount_price FLOAT64,
  is_veg BOOL,
  is_available BOOL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
CLUSTER BY seller_key, category_name;

-- ═════════════════════════════════════════════════════════════════════════════
-- 3. FACT TABLES (PARTITIONED BY DATE & CLUSTERED FOR MAXIMUM QUERY SPEED)
-- ═════════════════════════════════════════════════════════════════════════════

-- A. Fact_Orders (Grain: 1 row per order transaction)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Fact_Orders` (
  order_id STRING NOT NULL,
  buyer_key STRING NOT NULL,
  seller_key STRING NOT NULL,
  rider_key STRING,
  order_status STRING,                 -- Placed, Confirmed, Preparing, ReadyForPickup, OutForDelivery, Delivered, Cancelled
  payment_method STRING,               -- UPI, Razorpay, Card, COD, Wallet
  payment_status STRING,               -- Success, Pending, Failed, Refunded
  item_count INT64,
  subtotal_amount FLOAT64,
  tax_amount FLOAT64,
  delivery_fee FLOAT64,
  platform_fee FLOAT64,
  discount_amount FLOAT64,
  seller_payout_amount FLOAT64,
  rider_earnings_amount FLOAT64,
  total_order_amount FLOAT64,
  order_placed_at TIMESTAMP,
  order_delivered_at TIMESTAMP,
  fulfillment_duration_minutes FLOAT64,
  order_date DATE
)
PARTITION BY order_date
CLUSTER BY seller_key, buyer_key, order_status;

-- B. Fact_FinancialLedger (Double-Entry Financial Accounting & Payouts)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Fact_FinancialLedger` (
  ledger_id STRING NOT NULL,
  reference_id STRING NOT NULL,        -- order_id or payout_request_id
  transaction_type STRING,             -- order_payment, seller_payout, rider_incentive, platform_commission, refund
  party_type STRING,                   -- Buyer, Seller, DeliveryPartner, Platform
  party_key STRING NOT NULL,
  gross_amount FLOAT64,
  fee_deducted FLOAT64,
  net_amount FLOAT64,
  payment_gateway_ref STRING,          -- UTR / Razorpay payment ID
  status STRING,                       -- Completed, Pending, Failed, Reversed
  transaction_timestamp TIMESTAMP,
  transaction_date DATE
)
PARTITION BY transaction_date
CLUSTER BY party_key, transaction_type, status;

-- C. Fact_DeliveryTracking (Fleet Performance & SLA Metrics)
CREATE TABLE IF NOT EXISTS `food_delivery_dw.Fact_DeliveryTracking` (
  delivery_id STRING NOT NULL,
  order_id STRING NOT NULL,
  rider_key STRING NOT NULL,
  seller_key STRING NOT NULL,
  buyer_key STRING NOT NULL,
  assigned_at TIMESTAMP,
  accepted_at TIMESTAMP,
  arrived_at_store_at TIMESTAMP,
  picked_up_at TIMESTAMP,
  delivered_at TIMESTAMP,
  pickup_delay_minutes FLOAT64,
  transit_duration_minutes FLOAT64,
  total_trip_duration_minutes FLOAT64,
  travel_distance_km FLOAT64,
  sla_breached BOOL,
  delivery_date DATE
)
PARTITION BY delivery_date
CLUSTER BY rider_key, seller_key;

-- ═════════════════════════════════════════════════════════════════════════════
-- 4. ANALYTICAL CRM & BUSINESS INTELLIGENCE VIEWS (CRM & EXECUTIVE COCKPIT)
-- ═════════════════════════════════════════════════════════════════════════════

-- ── VIEW 1: Customer 360 CRM & RFM Segmentation ─────────────────────────────
CREATE OR REPLACE VIEW `food_delivery_dw.vw_customer_360` AS
WITH BuyerAggregations AS (
  SELECT
    o.buyer_key,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_order_amount) AS lifetime_spend,
    AVG(o.total_order_amount) AS average_order_value,
    MAX(o.order_placed_at) AS last_order_timestamp,
    DATE_DIFF(CURRENT_DATE(), DATE(MAX(o.order_placed_at)), DAY) AS recency_days,
    COUNTIF(o.order_status = 'Cancelled') AS cancelled_orders
  FROM `food_delivery_dw.Fact_Orders` o
  GROUP BY o.buyer_key
)
SELECT
  b.buyer_key,
  b.full_name,
  b.email,
  b.phone_number,
  b.default_city,
  COALESCE(a.total_orders, 0) AS total_orders,
  COALESCE(a.lifetime_spend, 0.0) AS lifetime_spend,
  COALESCE(a.average_order_value, 0.0) AS average_order_value,
  a.recency_days,
  -- RFM Customer Segment Categorization
  CASE
    WHEN a.total_orders >= 15 AND a.recency_days <= 14 THEN 'VIP_Loyal'
    WHEN a.total_orders >= 5 AND a.recency_days <= 30 THEN 'Active_Regular'
    WHEN a.total_orders >= 1 AND a.recency_days <= 60 THEN 'At_Risk_Churn'
    WHEN a.recency_days > 60 THEN 'Dormant_Churned'
    ELSE 'New_Customer'
  END AS crm_segment
FROM `food_delivery_dw.Dim_Buyers` b
LEFT JOIN BuyerAggregations a ON b.buyer_key = a.buyer_key;

-- ── VIEW 2: Merchant Performance & Health Score Cockpit ──────────────────────
CREATE OR REPLACE VIEW `food_delivery_dw.vw_merchant_performance_cockpit` AS
SELECT
  s.seller_key,
  s.store_name,
  s.category,
  s.city,
  COUNT(o.order_id) AS total_orders_received,
  SUM(o.subtotal_amount) AS gross_merchandise_value,
  SUM(o.seller_payout_amount) AS total_merchant_earnings,
  SUM(o.platform_fee) AS platform_commission_earned,
  ROUND(AVG(o.fulfillment_duration_minutes), 1) AS avg_kitchen_preparation_mins,
  ROUND(SAFE_DIVIDE(COUNTIF(o.order_status = 'Cancelled'), COUNT(o.order_id)) * 100, 2) AS cancellation_rate_pct,
  s.rating_score AS merchant_rating
FROM `food_delivery_dw.Dim_Sellers` s
LEFT JOIN `food_delivery_dw.Fact_Orders` o ON s.seller_key = o.seller_key
GROUP BY s.seller_key, s.store_name, s.category, s.city, s.rating_score;

-- ── VIEW 3: Live Fleet Demand & Heatmap Intelligence ─────────────────────────
CREATE OR REPLACE VIEW `food_delivery_dw.vw_fleet_demand_heatmaps` AS
SELECT
  EXTRACT(HOUR FROM o.order_placed_at) AS order_hour_of_day,
  EXTRACT(DAYOFWEEK FROM o.order_placed_at) AS day_of_week,
  s.city,
  ROUND(s.geo_latitude, 2) AS geo_cluster_lat,
  ROUND(s.geo_longitude, 2) AS geo_cluster_lng,
  COUNT(o.order_id) AS order_demand_volume,
  AVG(dt.transit_duration_minutes) AS avg_transit_minutes,
  COUNTIF(dt.sla_breached = TRUE) AS sla_breach_count
FROM `food_delivery_dw.Fact_Orders` o
JOIN `food_delivery_dw.Dim_Sellers` s ON o.seller_key = s.seller_key
LEFT JOIN `food_delivery_dw.Fact_DeliveryTracking` dt ON o.order_id = dt.order_id
WHERE o.order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY order_hour_of_day, day_of_week, s.city, geo_cluster_lat, geo_cluster_lng;
