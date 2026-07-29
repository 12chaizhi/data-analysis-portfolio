-- 电商用户订单数据分析
-- 数据集：脱敏电商订单表 user_order
-- 字段：user_id, order_id, pay_amount, create_time, province

-- 1. 月度用户留存率计算
WITH user_first AS (
    SELECT user_id, DATE_FORMAT(MIN(create_time), '%Y-%m') first_month
    FROM user_order
    GROUP BY user_id
),
user_month AS (
    SELECT DISTINCT user_id, DATE_FORMAT(create_time, '%Y-%m') order_month
    FROM user_order
)
SELECT
    first_month,
    COUNT(DISTINCT user_id) new_user,
    SUM(IF(order_month = DATE_ADD(DATE_FORMAT(STR_TO_DATE(CONCAT(first_month,'-01'),'%Y-%m-%d'),INTERVAL 1 MONTH),'%Y-%m'),1,0)) retention_1m
FROM user_first f
LEFT JOIN user_month m ON f.user_id = m.user_id
GROUP BY first_month;

-- 2. RFM用户分层模型
WITH rfm_data AS (
    SELECT
        user_id,
        DATEDIFF('2026-07-29', MAX(create_time)) R,
        COUNT(DISTINCT order_id) F,
        SUM(pay_amount) M
    FROM user_order
    GROUP BY user_id
),
rfm_score AS (
    SELECT
        user_id,
        NTILE(5) OVER(ORDER BY R ASC) R_score,
        NTILE(5) OVER(ORDER BY F ASC) F_score,
        NTILE(5) OVER(ORDER BY M ASC) M_score
    FROM rfm_data
)
SELECT
    user_id,
    CONCAT(R_score,F_score,M_score) rfm_tag,
    CASE
        WHEN R_score >=4 AND F_score >=4 AND M_score >=4 THEN '高价值核心用户'
        WHEN R_score <=2 AND F_score >=3 AND M_score >=3 THEN '沉睡高消费用户'
        WHEN R_score >=3 AND F_score <=2 THEN '低频高客单用户'
        ELSE '普通流失用户'
    END user_type
FROM rfm_score;

-- 3. 转化漏斗：浏览-加购-下单-支付
SELECT
    stage,
    user_cnt,
    LAG(user_cnt) OVER(ORDER BY stage_sort) prev_cnt,
    ROUND(user_cnt / LAG(user_cnt) OVER(ORDER BY stage_sort),3) convert_rate
FROM (
    SELECT '浏览' stage,1 stage_sort,COUNT(DISTINCT user_id) user_cnt FROM view_log
    UNION ALL
    SELECT '加购' stage,2 stage_sort,COUNT(DISTINCT user_id) user_cnt FROM cart_log
    UNION ALL
    SELECT '下单' stage,3 stage_sort,COUNT(DISTINCT user_id) user_cnt FROM order_log
    UNION ALL
    SELECT '支付' stage,4 stage_sort,COUNT(DISTINCT user_id) user_cnt FROM pay_log
) t;
