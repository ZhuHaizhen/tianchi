/*
本笔记为阿里云天池龙珠计划SQL训练营的学习内容，链接为：https://tianchi.aliyun.com/specials/promotion/aicampsql
*/
use shop;

/*
1: 请使用A股上市公司季度营收预测数据集《Income Statement.xls》和《Company Operating.xlsx》和《Market Data.xlsx》，以Market Data为主表，将三张表中的TICKER_SYMBOL为600383和600048的信息合并在一起。只需要显示以下字段。
表名 	            字段名
Income Statement 	TICKER_SYMBOL
Income Statement 	END_DATE
Income Statement 	T_REVENUE
Income Statement 	T_COGS
Income Statement 	N_INCOME
Market Data 	    TICKER_SYMBOL
Market Data 	    END_DATE_
Market Data 	    CLOSE_PRICE
Company Operating 	TICKER_SYMBOL
Company Operating 	INDIC_NAME_EN
Company Operating 	END_DATE
Company Operating 	VALUE
 */
select ist.TICKER_SYMBOL,
       ist.END_DATE,
       ist.T_REVENUE,
       ist.T_COGS,
       ist.N_INCOME,
       md.CLOSE_PRICE,
       co.INDIC_NAME_EN,
       co.VALUE
from `income statement` as `ist`
     left join `market data` as `md`
     on ist.TICKER_SYMBOL = md.TICKER_SYMBOL and ist.END_DATE = md.END_DATE
     left join `company operating` `co`
     on ist.END_DATE = co.END_DATE and ist.TICKER_SYMBOL = co.TICKER_SYMBOL
where ist.TICKER_SYMBOL in ('600383', '600048');

/*
2: 请使用 Wine Quality Data 数据集《winequality-red.csv》，找出 pH=3.03的所有红葡萄酒，然后，对其 citric acid 进行中式排名（相同排名的下一个名次应该是下一个连续的整数值。换句话说，名次之间不应该有“间隔”）
 */
select *,
       dense_rank() over (order by `citric acid`) as ds_rank
from `winequality-red`
where pH = 3.03;

/*
3: 使用Coupon Usage Data for O2O中的数据集《ccf_offline_stage1_test_revised.csv》，试分别找出在2016年7月期间，发放优惠券总金额最多和发放优惠券张数最多的商家。
这里只考虑满减的金额，不考虑打几折的优惠券。
 */
select Merchant_id, sum(substring_index(Discount_rate,':',-1)) as amount
from ccf_offline_stage1_test_revised
where Date_received between '2016-07-01' and '2016-07-31'
group by Merchant_id
order by amount desc
limit 1;

select Merchant_id, count(Coupon_id) as cnt
from ccf_offline_stage1_test_revised
where Date_received between '2016-07-01' and '2016-07-31'
group by Merchant_id
order by cnt desc
limit 1;

/*
4: 请使用A股上市公司季度营收预测中的数据集《Macro&Industry.xlsx》中的sheet-INDIC_DATA，请计算全社会用电量:第一产业:当月值在2015年用电最高峰是发生在哪月？并且相比去年同期增长/减少了多少个百分比？
 */
select mon, DATA_VALUE, (DATA_VALUE-value_14)/value_14 as YoY
from (select month(PERIOD_DATE) as mon, DATA_VALUE
from `macro industry`
where year(PERIOD_DATE) = '2015' and
      name_cn = 'Total Electricity Consumption: Primary Industry' and
      FREQUENCY_CD = 'M') as t1
inner join (
select month(PERIOD_DATE) as mon_14, DATA_VALUE as value_14
from `macro industry`
where year(PERIOD_DATE) = '2014' and
      name_cn = 'Total Electricity Consumption: Primary Industry' and
      FREQUENCY_CD = 'M'
) as t2 on t1.mon=t2.mon_14
group by mon
order by DATA_VALUE desc
limit 1;

/*
5: 使用Coupon Usage Data for O2O中的数据集《ccf_online_stage1_train.csv》，试统计在2016年6月期间，线上总体优惠券弃用率为多少？并找出优惠券弃用率最高的商家。
弃用率 = 被领券但未使用的优惠券张数 / 总的被领取优惠券张数
 */
select sum(case when Date is null and Coupon_id is not null then 1 else 0 end)/count(Coupon_id) as total
from ccf_online_stage1_train
where Date_received between '2016-06-01' and '2016-06-30';

select Merchant_id,
       sum(case when Date is null and Coupon_id is not null then 1 else 0 end)/count(Coupon_id) as abandon_rate
from ccf_online_stage1_train
where Date_received between '2016-06-01' and '2016-06-30'
group by Merchant_id
order by abandon_rate desc
limit 1;

/*
6: 请使用 Wine Quality Data 数据集《winequality-white.csv》，找出 pH=3.63的所有白葡萄酒，然后，对其 residual sugar 量进行英式排名（非连续的排名）
 */
select *,
       rank() over (order by `residual sugar`)
from `winequality-white`
where pH=3.63;

/*
7: 请使用A股上市公司季度营收预测中的数据集《Market Data.xlsx》中的sheet-DATA，
计算截止到2018年底，市值最大的三个行业是哪些？以及这三个行业里市值最大的三个公司是哪些？（每个行业找出前三大的公司，即一共要找出9个）
 */
select TYPE_NAME_EN, TICKER_SYMBOL, no
from (select TYPE_NAME_EN, TICKER_SYMBOL, rank() over (partition by TYPE_NAME_EN order by MARKET_VALUE desc) as no
    from `market data` as t
inner join
(select TYPE_NAME_EN as name_t1, TYPE_NAME_CN
from `market data`
where year(END_DATE) = '2018'
group by TYPE_NAME_EN
order by sum(MARKET_VALUE) desc
limit 3) t1 on t.TYPE_NAME_EN=t1.name_t1) as t2
where no <= 3 ;

/*
8: 使用Coupon Usage Data for O2O中的数据集《ccf_online_stage1_train.csv》和《ccf_offline_stage1_train.csv》，试找出在2016年6月期间，线上线下累计优惠券使用次数最多的顾客。
 */
select User_id, sum(num) as total
from (select User_id, count(Coupon_id) as num
      from ccf_online_stage1_train
      where Coupon_id is not null
        and Date is not null
        and Date between '2016-06-01' and '2016-06-30'
      group by User_id
      union all
      select User_id, count(Coupon_id) as num
      from ccf_offline_stage1_train
      where Coupon_id is not null
        and Date is not null
        and Date between '2016-06-01' and '2016-06-30'
      group by User_id) as t
group by User_id
order by total desc
limit 1;

/*
9: 请使用A股上市公司季度营收预测数据集《Income Statement.xls》中的sheet-General Business和《Company Operating.xlsx》中的sheet-EN。
找出在数据集所有年份中，按季度统计，白云机场旅客吞吐量最高的那一季度对应的净利润是多少？（注意，是单季度对应的净利润，非累计净利润。）
 */
select *
from (select TICKER_SYMBOL,
             concat(year(END_DATE), 'Q', quarter(END_DATE)) as Q
      from `company operating`
      where INDIC_NAME_EN = 'Baiyun Airport:Aircraft take-off and landing times'
      group by Q, TICKER_SYMBOL
      order by sum(VALUE) desc
      limit 1) as t1
     inner join
     (select TICKER_SYMBOL,
             concat(year(END_DATE), 'Q', quarter(END_DATE)) as Q,
             sum(T_PROFIT) as profit
      from `income statement`
      group by Q, TICKER_SYMBOL) as t2
     on t1.TICKER_SYMBOL = t2.TICKER_SYMBOL and
        t1.Q = t2.Q;

/*
10: 使用Coupon Usage Data for O2O中的数据集《ccf_online_stage1_train.csv》和《ccf_offline_stage1_train.csv》，试找出在2016年6月期间，线上线下累计被使用优惠券满减最多的前3名商家。
比如商家A，消费者A在其中使用了一张200减50的，消费者B使用了一张30减1的，那么商家A累计被使用优惠券满减51元。
 */
select Merchant_id, sum(discount) as total
from (select Merchant_id, substring_index(Discount_rate,':',-1) as discount
from ccf_online_stage1_train
where Date between '2016-06-01' and '2016-06-30' and
      Coupon_id is not null and Date is not null
union all
select Merchant_id, substring_index(Discount_rate,':',-1) as discount
from ccf_offline_stage1_train
where Date between '2016-06-01' and '2016-06-30' and
      Coupon_id is not null and Date is not null ) as t
group by Merchant_id
order by total desc
limit 3;