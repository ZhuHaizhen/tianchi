/*
本笔记为阿里云天池龙珠计划SQL训练营的学习内容，链接为：https://tianchi.aliyun.com/specials/promotion/aicampsql
 */

/*
视图是基于真实表的一张虚拟表，视图中保存的是SELECT语句，使用视图时会执行SELECT语句并创建一张临时表
视图不仅可以基于真实的表，也可以在视图的基础上继续创建视图。但应尽量避免，多重视图会降低SQL的性能
 */
create view productsum (product_type, cnt_product)
as
select product_type, count(*)
from product
group by product_type
/* 视图和表一样，数据行是没有顺序的。
MySQL允许使用order by语句，但若从特定视图进行选择，而该视图使用了order by语句，则视图定义中的order by会被忽略 */
order by product_type;

CREATE TABLE shop_product
(
    shop_id CHAR(4) NOT NULL,
    shop_name VARCHAR(200) NOT NULL,
    product_id CHAR(4) NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (shop_id, product_id)
);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000A', '东京', '0001', 30);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000A', '东京', '0002', 50);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000A', '东京', '0003', 15);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0002', 30);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0003', 120);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0004', 20);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0006', 10);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0007', 40);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0003', 20);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0004', 50);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0006', 90);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0007', 70);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity)
VALUES ('000D', '福冈', '0001', 100);

create view view_shop_product(product_type, sale_price, shop_name)
as
select product_type, sale_price, shop_name
from product,
     shop_product
where product.product_id = shop_product.product_id;

select sale_price, shop_name
from view_shop_product
where product_type = '衣服';

alter view productsum
    as select product_type, sale_price
       from product
       where regist_date > '2009-09-11';

/*
对一个视图来说，包含以下结构中的任意一种都不可以被更新：
* 聚合函数
* DISTINCT关键字
* GROUP BY子句
* HAVING子句
* UNION或UNION ALL运算符
* FROM子句中包含多个表
**更新视图时，原表中的数据也会被更新。不推荐，在创建视图时应尽量使用限制不允许通过视图修改表**
 */
update productsum
set sale_price = '5000'
where productsum.product_type = '办公用品';

drop view productsum;

/* 嵌套子查询 */
select product_type, cnt_product
from (select *
      from (
               select product_type, count(*) as cnt_product
               from product
               group by product_type
           ) as productsum
      where cnt_product = 4) as productsum2;

/* 标量子查询：要求执行的SQL语句只能返回一个值 */
select product_id, product_name, sale_price
from product
where sale_price > (select avg(sale_price) from product);

select product_id,
       product_name,
       sale_price,
       (select avg(sale_price) from product) as avg_price
from product;

/* 关联子查询 */
select product_type, product_name, sale_price
from product as p1
where sale_price > (select avg(sale_price)
                    from product as p2
                    where p1.product_type = p2.product_type
                    group by product_type);

select product_type, product_name, sale_price
from product as p1
where sale_price > (select avg(sale_price)
                    from product as p2
                    where p1.product_type = p2.product_type
                    group by product_type);

/* 练习一 */
create view ViewPractice5_1 as
select product_name, sale_price, regist_date
from product
where sale_price >= 1000
  and regist_date = '2009-09-20';
select *
from ViewPractice5_1;

insert into ViewPractice5_1
values ('刀子', 300, '2009-11-02');
/*更新视图时也会同时更新原表，由于其它字段没有设置默认值，仅插入视图中的三个字段的值会报错 */

select product_id,
       product_name,
       product_type,
       sale_price,
       (select avg(sale_price) from product) as sale_price_all
from product;

create view AvgPriceType as
select product_id, product_name, p1.product_type, sale_price, avg_sale_price
from product as p1,
     (select product_type, avg(sale_price) as avg_sale_price from product group by product_type) as p2
where p1.product_type = p2.product_type;

/* 算数函数 */
CREATE TABLE samplemath
(
    m float(10, 3),
    n INT,
    p INT
);

START TRANSACTION; -- 开始事务
INSERT INTO samplemath(m, n, p)
VALUES (500, 0, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (-180, 0, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (NULL, NULL, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (NULL, 7, 3);
INSERT INTO samplemath(m, n, p)
VALUES (NULL, 5, 2);
INSERT INTO samplemath(m, n, p)
VALUES (NULL, 4, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (8, NULL, 3);
INSERT INTO samplemath(m, n, p)
VALUES (2.27, 1, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (5.555, 2, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (NULL, 1, NULL);
INSERT INTO samplemath(m, n, p)
VALUES (8.76, NULL, NULL);
COMMIT; -- 提交事务

SELECT *
FROM samplemath;

select m, abs(m) as abs_col, n, p, mod(n, p) as mod_col, round(m, 1) as round_col
from samplemath;

/* 字符串函数 */
CREATE TABLE samplestr
(
    str1 VARCHAR(40),
    str2 VARCHAR(40),
    str3 VARCHAR(40)
);

START TRANSACTION;
INSERT INTO samplestr (str1, str2, str3)
VALUES ('opx', 'rt', NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES ('abc', 'def', NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES ('太阳', '月亮', '火星');
INSERT INTO samplestr (str1, str2, str3)
VALUES ('aaa', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES (NULL, 'xyz', NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES ('@!#$%', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES ('ABC', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES ('aBC', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3)
VALUES ('abc哈哈', 'abc', 'ABC');
INSERT INTO samplestr (str1, str2, str3)
VALUES ('abcdefabc', 'abc', 'ABC');
INSERT INTO samplestr (str1, str2, str3)
VALUES ('micmic', 'i', 'I');
COMMIT;

SELECT *
FROM samplestr;

select str1,
       str2,
       str3,
       concat(str1, str2, str3) as str_concat,
       length(str1) as str_len,
       lower(str1) as str_low,
    /* replace(对象字符串，要替换的字符串， 替换成什么字符串) */
       replace(str1, str2, str3) as str_rep,
    /* substring(对象字符串 from 截取的起始位置 for 截取的字符数)，从最左侧可是索引，索引起始值为1 */
       substring(str1 from 3 for 2) as str_sub
from samplestr;

/* 将原始字符串按照指定分隔符分割后，取第n个分隔符之前或之后的子字符串，支持正向和反向索引 */
select substring_index('www.mysql.com', '.', 2);
select substring_index('www.mysql.com', '.', -2);
/* 二次拆分获取第n个元素 */
select substring_index(substring_index('www.mysql.com', '.', 2), '.', -1);

/* 日期函数 */
select current_date;
select current_time;
select current_timestamp;

select current_timestamp as now,
       extract(year from current_timestamp) as year,
       extract(month from current_timestamp) as month,
       extract(day from current_timestamp) as day,
       extract(hour from current_timestamp) as hour,
       extract(minute from current_timestamp) as minute,
       extract(second from current_timestamp) as second;

/* 转换函数 */
select cast('0001' as signed integer) as int_col;

select cast('2009-12-14' as date) as date_col;
/* coalesce是SQL特有的函数，返回可变参数中从左侧开始第一个不是NULL的值 */
select coalesce(null, 11) as col_1,
       coalesce(null, 'hello world', null) as col_2,
       coalesce(null, null, '2020-11-01') as col_3;

/*
谓词：
* LIKE
* BETWEEN
* IS NULL，IS NOT NULL
* IN
* EXISTS
*/

CREATE TABLE samplelike
(
    strcol VARCHAR(6) NOT NULL,
    PRIMARY KEY (strcol)
);

START TRANSACTION; -- 开始事务
INSERT INTO samplelike (strcol)
VALUES ('abcddd');
INSERT INTO samplelike (strcol)
VALUES ('dddabc');
INSERT INTO samplelike (strcol)
VALUES ('abdddc');
INSERT INTO samplelike (strcol)
VALUES ('abcdd');
INSERT INTO samplelike (strcol)
VALUES ('ddabc');
INSERT INTO samplelike (strcol)
VALUES ('abddc');
COMMIT; -- 提交事务

SELECT *
FROM samplelike;

select *
from samplelike
where strcol like 'ddd%';

select *
from samplelike
where strcol like '%ddd%';

select *
from samplelike
where strcol like 'abc__';

select product_name, sale_price
from product
where sale_price between 100 and 1000; /* [100, 1000] */

select product_name, sale_price
from product
where sale_price > 100
  and sale_price < 1000; /* (100, 1000) */

select product_name, purchase_price
from product
where purchase_price is null;

select product_name, purchase_price
from product
where purchase_price is not null;

select product_name, purchase_price
from product
where purchase_price in (320, 500, 5000);
/* IN 和 NOT IN 无法取出NULL */
select product_name, purchase_price
from product
where purchase_price not in (320, 500, 5000);

/* 使用子查询作为IN谓词的参数 */
CREATE TABLE shopproduct
(
    shop_id CHAR(4) NOT NULL,
    shop_name VARCHAR(200) NOT NULL,
    product_id CHAR(4) NOT NULL,
    quantity INTEGER NOT NULL,
    PRIMARY KEY (shop_id, product_id) -- 指定主键
);

START TRANSACTION; -- 开始事务
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000A', '东京', '0001', 30);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000A', '东京', '0002', 50);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000A', '东京', '0003', 15);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0002', 30);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0003', 120);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0004', 20);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0006', 10);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000B', '名古屋', '0007', 40);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0003', 20);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0004', 50);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0006', 90);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000C', '大阪', '0007', 70);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity)
VALUES ('000D', '福冈', '0001', 100);
COMMIT; -- 提交事务

SELECT *
FROM shopproduct;

select product_name, sale_price
from product
where product_id in (
    select product_id
    from shopproduct
    where shop_id = '000C'
);

/* EXIST谓词：判断是否存在满足某种条件的记录 */
select product_name, sale_price
from product as p
where exists(
              select *
              from shopproduct as sp
              where sp.shop_id = '000C'
                and sp.product_id = p.product_id
          );

select product_name, sale_price
from product as p
where not exists(
        select *
        from shopproduct as sp
        where sp.shop_id = '000A'
          and sp.product_id = p.product_id
    );

/* CASE WHEN */
select product_name,
       case
           when product_type = '衣服' then concat('A: ', product_type)
           when product_type = '办公用品' then concat('B: ', product_type)
           when product_type = '厨房用具' then concat('C: ', product_type)
           else null
           end as abc_product_type
from product;

select sum(case when product_type = '衣服' then sale_price else 0 end) as sum_price_clothes,
       sum(case when product_type = '厨房用具' then sale_price else 0 end) as sum_price_kitcen,
       sum(case when product_type = '办公用品' then sale_price else 0 end) as sum_price_office
from product;

/* 练习二 */
/* 运算或者函数中含有 NULL 时，结果全都会变为NULL */

select product_name, purchase_price
from product
where purchase_price not in (500, 2800, 5000);

select product_name, purchase_price
from product /* 返回结果为空 */
where purchase_price not in (500, 2800, 5000, null);

select sum(case when sale_price <= 1000 then 1 else 0 end) as low_price,
       sum(case when sale_price >= 1001 and sale_price <= 3000 then 1 else 0 end) as mid_price,
       sum(case when sale_price >= 3001 then 1 else 0 end) as high_price
from product;