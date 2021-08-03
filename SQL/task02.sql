/*
本笔记为阿里云天池龙珠计划SQL训练营的学习内容，链接为：https://tianchi.aliyun.com/specials/promotion/aicampsql
 */

show databases;
use shop;
show tables;

select product_name, product_type
    from product
    where product_type = '衣服';

select product_id as id, product_name as name, purchase_price as '进货单价'
    from product;

select distinct product_type
    from product;

select product_name, product_type
    from product
    where sale_price = 500;

select product_name, purchase_price
    from product
    where purchase_price is null;

select product_name, purchase_price
    from product
    where purchase_price is not null;

select product_name, product_type, sale_price
    from product
    where not sale_price >= 1000;

select product_name, product_type, regist_date
    from product /* and运算符优先于or运算符，要想先执行or运算，应该使用括号 */
    where product_type = '办公用品'
      and (regist_date = '2009-09-11' or regist_date = '2009-09-20');

/* 练习一 */
select product_name, regist_date
    from product
    where regist_date > '2009-04-28';

select *
    from product
    where purchase_price = NULL; /* 输出为空，应该用 IS NULL */

select *
    from product
    where purchase_price <> NULL; /* 输出为空，应该用 IS NOT NULL */

select *
    from product
    where product_name > NULL; /* 输出为空 */

select product_name, sale_price, purchase_price
    from product
    where sale_price - purchase_price >= 500;

select product_name, sale_price, purchase_price
    from product
    where sale_price >= purchase_price + 500;

select product_name, product_type, sale_price * 0.9 - purchase_price as profit
    from product
    where sale_price * 0.9 - purchase_price >= 100;

select count(*)
    from product; /* 统计全部数据的行数，包含NULL */

select count(purchase_price)
    from product; /* 统计不包含NULL的行数 */

select sum(sale_price), sum(purchase_price)
    from product;

select avg(sale_price), avg(purchase_price)
    from product;

select max(regist_date), min(regist_date)
    from product; /* max和min也可用于非数值型数据 */

select count(distinct product_type)
    from product;

select product_type, count(*)
    from product
    group by product_type;

select purchase_price, count(*)
    from product /* NULL会被当成单独的一组进行统计 */
    group by purchase_price;

select product_type, count(*)
    from product
    group by product_type
    having count(*) = 2;

select product_id, product_name, sale_price, purchase_price
    from product
    order by sale_price desc, sale_price;

select product_id, product_name, sale_price, purchase_price
    from product /* 用于排序的列中含有NULL时， NULL会在开头或末尾进行汇总 */
    order by purchase_price;

/* 练习二 */
/*
无法对product_name非数值型变量求和
group by子句应该写作where子句之后
 */

select product_type, sum(sale_price) as sum, sum(purchase_price) as sum
    from product
    group by product_type
    having sum(sale_price) > sum(purchase_price) * 1.5;

/* regist_date desc, sale_price */