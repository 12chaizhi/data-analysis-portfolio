# 电商零售订单SQL数据分析报告
## 一、项目背景
本项目基于脱敏电商订单数据集，使用MySQL完成全流程商业数据分析，模拟电商运营分析师工作场景。
分析目标：挖掘用户地域消费特征、订单销售趋势，为平台区域运营、营销活动提供数据支撑。

## 二、数据集介绍
数据源路径：data/零售_order.csv
字段说明：
- user_id：用户编号
- order_id：订单编号
- pay_amount：订单支付金额
- create_time：订单创建时间
- province：用户所在省份

## 三、数据清洗
1. 缺失值校验：数据集无空值
2. 异常订单筛选：剔除支付金额小于0的无效订单
3. 时间格式标准化，方便按月统计

## 四、核心SQL分析内容
### 1. 各省份消费总额排名
统计各省用户总消费金额，定位高潜力区域。
```sql
SELECT province, SUM(pay_amount) total_sales
FROM retail_order
GROUP BY province
ORDER BY total_sales DESC;
