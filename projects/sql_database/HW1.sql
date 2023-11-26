-- CREATE DB
-- ร้านอาหารตามสั่ง
-- 1. dim_menu
-- 2. dim_category
-- 3. fact_order
-- 4. fact_order_detail (bridge table)

-- CLEAR DB
DROP TABLE dim_menu ;
DROP TABLE dim_category ;
DROP TABLE fact_order ;
DROP TABLE fact_order_detail ;
DROP VIEW order_detail_review ;
DROP VIEW order_revenue ;
DROP VIEW top_menu ;

-- CREATE TABLE 
CREATE TABLE IF NOT EXISTS dim_menu (
menu_id INT,
menu_name varchar,
menu_price real,
cat_id INT
) ;

CREATE TABLE IF NOT EXISTS dim_category (
cat_id INT,
cat_name varchar,
cat_detail varchar
) ;

CREATE TABLE IF NOT EXISTS fact_order (
order_id INT,
order_date date) ;

CREATE TABLE IF NOT EXISTS fact_order_detail (
order_id INT,
menu_id INT,
qty INT
) ;

.table

-- INSERT DATA
-- 1. dim_menu
INSERT INTO dim_menu values 
(1, "ข้าวไข่เจียว", 40, 1) ,
(2, "ข้าวผัดกระเพราไข่ดาว", 50, 1) ,
(3, "ข้าวหมูกระเทียมไข่ดาว", 50, 1) ,
(4, "ข้าวผัด", 40, 1) ,
(5, "ชาดำเย็น", 15, 2) ,
(6, "น้ำเก็กฮวย", 15, 2) ;

-- 2. dim_category
INSERT INTO dim_category values
(1, "Food", "All Food"),
(2, "Drink", "All Drink") ;

-- 3. fact_order
INSERT INTO fact_order values
  (1, "2023-10-15"),
  (2, "2023-10-15"),
  (3, "2023-10-16"),
  (4, "2023-10-16"),
  (5, "2023-10-17"),
  (6, "2023-10-18"),
  (7, "2023-10-18"),
  (8, "2023-10-19"),
  (9, "2023-10-20"),
  (10, "2023-10-20"),
  (11, "2023-10-21") ;

-- 4. fact_order_detail
INSERT INTO fact_order_detail values
(1, 1, 1),
(2, 1, 1),
(2, 2, 3),
(2, 3, 1),
(2, 5, 2),
(3, 4, 1),
(3, 2, 1),
(3, 5, 2),
(4, 1, 1),
(4, 6, 2),
(5, 3, 2),
(5, 6, 2),
(6, 2, 3),
(6, 6, 2),
(7, 3, 1),
(7, 6, 1),
(8, 2, 1),
(8, 5, 1),
(9, 1, 2),
(9, 5, 2),
(10, 1, 1),
(10, 2, 1),
(10, 6, 1),
(11, 2, 2),
(11, 3, 1),
(11, 5, 1),
(11, 6, 2) ; 

-- CHECK 
.mode box
SELECT * FROM dim_menu ;
SELECT * FROM dim_category ;
SELECT * FROM fact_order ;
SELECT * FROM fact_order_detail ; 

-- Query Data
.mode box
  
-- Q1. ภาพรวมของ order ทั้งหมด ว่ามีการสั่งอะไรบ้าง มูลค่าเท่าไหร่ สั่งวันไหนบ้าง
-- JOIN + VIEW 
CREATE VIEW order_detail_review AS
SELECT
  t1.order_id,
  t1.order_date,
  t3.menu_name,
  t4.cat_name,
  t2.qty,
  t3.menu_price,
  t2.qty * t3.menu_price AS total_price
FROM fact_order AS t1
JOIN fact_order_detail AS t2
ON t1.order_id = t2.order_id
JOIN dim_menu t3
ON t2.menu_id = t3.menu_id
JOIN dim_category AS t4
ON t3.cat_id = t4.cat_id ; 

SELECT * FROM order_detail_review ; 

-- Q2.สรุป revenue ของแต่ละ order 
-- Aggregate + VIEW
CREATE VIEW order_revenue AS
  SELECT 
    order_id,
    order_date,
    SUM(total_price) AS revenue
  FROM order_detail_review
  GROUP BY 1 ; 

SELECT * FROM order_revenue ; 

-- Q3. แสดงรายการที่ขายดี
-- Aggregate + VIEW
CREATE VIEW top_menu AS
  SELECT 
    menu_name ,
    cat_name ,	
    COUNT(menu_name) AS Qty
  FROM order_detail_review 
  GROUP BY 1
  ORDER BY 3 
  DESC; 

SELECT * FROM top_menu ; 

-- Q4. สรุปยอดขายในแต่ละ category (จากการเก็บข้อมูล 7 วัน)
SELECT 
  cat_name,
  SUM(total_price) AS total_revenue_THB
FROM order_detail_review 
GROUP BY 1
ORDER BY 2
DESC ; 

-- Q5. เมนูไหนที่คนสั่งบ่อยที่สุด
-- SubQuery
SELECT 
  menu_name ,
  Qty
FROM (
  SELECT 
    menu_name , 
    cat_name ,	
  COUNT(menu_name) AS Qty
  FROM order_detail_review 
  GROUP BY 1
  ORDER BY 2 DESC 
)
LIMIT 2 ; 

-- Q6. เมนูไหนที่คนสั่งบ่อยที่สุด
-- WITH
WITH sub1 AS
  (SELECT 
    menu_name ,
    cat_name ,	
    COUNT(menu_name) AS Qty
  FROM order_detail_review 
  GROUP BY 1
  ORDER BY 3 DESC)

SELECT 
  sub1.menu_name ,
  sub1.Qty
FROM sub1
LIMIT 2 ; 


-- Note
-- พบว่าคนนิยมสั่งสองรายการคือ ข้าวผัดกระเพราไข่ดาว , น้ำเก็กฮวย
-- ดังนั้นครั้งต่อไปจะต้องเตรียมวัตถุดิบและส่วนประกอบสำหรับสองรายการนี้เพิ่มขึ้น 
