/*
本笔记为阿里云天池龙珠计划SQL训练营的学习内容，链接为：https://tianchi.aliyun.com/specials/promotion/aicampsql
*/
use shop;

/*
窗口函数也叫OLAP (Online Analytical Processing)函数
 */
select product_name,
       product_type,
       sale_price,
       rank() over (partition by product_type
           order by sale_price) as ranking
from product;

/*
专用窗口函数：
RANK()：英式排序，即排序时，如果存在并列的情况，则跳过之后的位次
DENSE_RANK()：中式排序，即排序时，即使存在并列的情况，也不跳过之后的位次
ROW_NUMBER()：赋予唯一的连续位次
 */
select product_name,
       product_type,
       sale_price,
       rank() over (order by sale_price) as ranking,
       dense_rank() over (order by sale_price) as dense_ranking,
       row_number() over (order by sale_price) as row_num
from product;

/*
在窗口函数上使用聚合函数
 */
select product_id,
       product_name,
       sale_price,
       sum(sale_price) over (order by product_id) as current_sum,
       avg(sale_price) over (order by product_id) as current_avg
from product;

/*
应用窗口函数计算移动平均：
PRESEDING：将框架指定为“截止到之前n行”，加上自身行
FOLLOWING：将框架指定为“截止到之后n行”，加上自身行
BETWEEN 1 PRECEDING AND 1 FOLLOWING：将框架指定为“之前1行”+自身含+“之后1行”
 */
select product_id,
       product_name,
       sale_price,
       avg(sale_price) over (order by product_id rows 2 preceding) as moving_avg,
       avg(sale_price) over (order by product_id rows between 1 preceding and 1 following) as moving_avg
from product;

/*
ROLLUP：计算各分组的合计
 */
select product_type,regist_date,sum(sale_price) as sum_price
from product
group by product_type, regist_date with rollup;

/*
练习1
 */
select product_id,
       product_name,
       sale_price,
       max(sale_price) over (order by product_id) as current_max_price
from product;

/*
练习2：继续使用product表，计算出按照登记日期（regist_date）升序进行排列的各日期的销售单价（sale_price）的总额
 */
select product_id,
       product_name,
       regist_date,
       sale_price,
       sum(sale_price) over (order by regist_date) as sum_sale
from product;
