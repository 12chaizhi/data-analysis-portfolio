-- 电商订单数据分析SQL
-- 1. 各省份销售额统计
SELECT province, SUM(pay_amount) total_sales
FROM retail_order
GROUP BY province
ORDER BY total_sales DESC;

-- 2. 按月统计销售额、订单量
SELECT DATE_FORMAT(create_time,'%Y-%m') month,
COUNT(DISTINCT order_id) order_count,
SUM(pay_amount) sales
FROM retail_order
GROUP BY month
ORDER BY month;

-- 3. 计算平均客单价
SELECT SUM(pay_amount)/COUNT(DISTINCT order_id) avg_price
FROM retail_order;
