/*
本笔记为阿里云天池龙珠计划SQL训练营的学习内容，链接为：https://tianchi.aliyun.com/specials/promotion/aicampsql
*/

use shop;
create table product2
(
    product_id char(4) not null,
    product_name varchar(100) not null,
    product_type varchar(32) not null,
    sale_price integer default 0,
    purchase_price integer,
    regist_date date,
    primary key (product_id)
);

insert into product2
values ('0001', 'T恤衫', '衣服', 1000, 500, '2009-09-20'),
       ('0002', '打孔器', '办公用品', 500, 320, '2009-09-11'),
       ('0003', '运动T恤', '衣服', 4000, 2800, NULL),
       ('0009', '手套', '衣服', 800, 500, null),
       ('0010', '水壶', '厨房用具', 2000, 1700, '2009-09-20');

select product_id, product_name
from product
union
/* 会去除重复的记录 */
select product_id, product_name
from product2;

/* 查询毛利率超过 50%或者售价低于 800 的货物 */
select product_id, product_name, product_type, sale_price, purchase_price
from product
where sale_price < 800
union
select product_id, product_name, product_type, sale_price, purchase_price
from product
where sale_price > 1.5 * purchase_price;
/* 不使用UNION */
select product_id, product_name, product_type, sale_price, purchase_price
from product
where sale_price < 800
   or sale_price > 1.5 * purchase_price;

select *
from product
where sale_price / purchase_price < 1.3
union
select *
from product
where sale_price / purchase_price is null;
/* UNION ALL 包含重复行 */
select product_id, product_name
from product
union all
select product_id, product_name
from product2;

select *
from product
where sale_price / purchase_price < 1.5
union all
select *
from product
where sale_price < 1000;

/*
bag是和set类似的一种数学结构，但bag中允许存在重复的元素，set中的元素应该是互异的
对于两个bag，它们的并运算会按照：
1. 该元素是否在至少一个bag里出现过
2. 该元素在各个bag中出现的最大次数
 */

/* 隐式类型转换 */
select product_id, product_name, '1'
from product
union
select product_id, product_name, sale_price
from product2;

/*
MySQL 8.0不支持交运算INTERSECT和差集运算EXCEPT，但借助NOT IN可以实现表的减法
 */

select *
from product
where product_id not in
      (select product_id from product2);
/* 使用NOT谓词进行集合的减法运算, 求出product表中, 售价高于2000,但利润低于30%的商品 */
select *
from product
where sale_price > 2000
  and product_id not in
      (select product_id from product where sale_price / purchase_price > 1.3);

/*
两个集合A,B的对称差指那些仅属于A或仅属于B的元素构成的集合
两个集合的对称差等于A-B并上B-A
 */
select *
from product
where product_id not in
      (select product_id from product2)
union
select *
from product2
where product_id not in
      (select product_id from product);

select sp.shop_id,
       sp.shop_name,
       p.product_name,
       p.product_type,
       p.sale_price,
       sp.quantity
from shopproduct as sp
     inner join
     product as p
     on sp.product_id = p.product_id;
/*
执行顺序：两张表先进行联结，得到了一张新表，然后WHERE子句对这张新表进行筛选，最后SELECT子句筛选出指定的列
另外一种思路：先分别在两个表中用WHERE子句进行筛选，然后把两个子查询联结起来
 */
select sp.shop_id,
       sp.shop_name,
       sp.product_id,
       p.product_name,
       p.product_type,
       p.sale_price,
       sp.quantity
from shopproduct as sp
     inner join
     product as p
     on sp.product_id = p.product_id
where shop_name = '东京'
  and product_type = '衣服';

select sp.shop_id,
       sp.shop_name,
       sp.product_id,
       p.product_name,
       p.product_type,
       p.sale_price,
       sp.quantity
from (
         select *
         from shopproduct
         where shop_name = '东京'
     ) as sp
     inner join
     (
         select *
         from product
         where product_type = '衣服'
     ) as p
     on p.product_id = sp.product_id;

select sp.shop_id,
       sp.shop_name,
       p.product_id,
       p.product_name,
       p.product_type,
       p.purchase_price
from shopproduct as sp
     inner join
     product as p
     on sp.product_id = p.product_id
where p.product_type = '衣服';

select sp.shop_id,
       sp.shop_name,
       sp.product_id,
       sp.quantity,
       p.product_id,
       p.product_name,
       p.product_type,
       p.sale_price
from (
         select *
         from shopproduct
         where shop_name = '东京'
     ) as sp
     inner join
     (
         select *
         from product
         where sale_price < 2000
     ) as p
     on sp.product_id = p.product_id;

/*
一题三解：找出每个商品种类中售价高于该类商品的平均售价的商品
 */

select product_id, product_name, sale_price
from product as p1
where sale_price > (
    select avg(sale_price)
    from product as p2
    where p1.product_type = p2.product_type
    group by p1.product_type
);

select product_type, avg(sale_price) as avg_price
from product
group by product_type;

select p1.product_id, p1.product_name, p1.product_type, p1.sale_price, p2.avg_price
from product as p1
     inner join
     (
         select product_type, avg(sale_price) as avg_price
         from product
         group by product_type
     ) as p2
     on p1.product_type = p2.product_type
where p1.sale_price > p2.avg_price;

/*
自然联结：当两个表进行自然连结时, 会按照两个表中都包含的列名来进行等值内连结, 此时无需使用 ON 来指定连接条件
 */
select *
from product
     natural join shopproduct;

/*
使用自然连结还可以求出两张表或子查询的公共部分
 */
select *
from product
     natural join product2;
/*
由于运动 T 恤的 regist_date 字段为空，而两个缺失值用等号进行比较的结果不为真，因此不会返回这一行
即：在进行自然联结时，会将指定字段逐个进行等值联结，只返回联结条件为真的行
 */
select *
from (
         select product_id, product_name
         from product
     ) as A
     natural join (
    select product_id, product_name
    from product2
) as B;

select p1.*
from product as p1
     inner join
     product2 as p2
     on p1.product_id = p2.product_id;

select sp.shop_id, sp.shop_name, p.product_id, p.product_name, p.sale_price
from product as p
     left join
     shopproduct as sp
     on sp.product_id = p.product_id
where shop_id is null;
/*
在外联结的过程中产生NULL，影响筛选
 */
select p.product_id, p.product_name, p.sale_price, sp.shop_id, sp.shop_name, sp.quantity
from product as p
     left join
     shop_product as sp
     on p.product_id = sp.product_id
where sp.quantity < 50;
/*
在实际应用中，数据量大且质量未知，我们并不能时刻意识到缺失值等问题的存在
根据SQL查询的执行顺序，可以将筛选条件挪到进行外联结之前执行
 */
select p.product_id, p.product_name, p.sale_price, sp.shop_id, sp.shop_name, sp.quantity
from product as p
     left join
         (select * from shopproduct where quantity < 50) as sp
     on p.product_id = sp.product_id;

/*
MySQL 8.0不支持全外联结，可以通过对左联结和右联结的结果进行UNION实现全外联结
 */

CREATE TABLE Inventoryproduct
(
    inventory_id CHAR(4) NOT NULL,
    product_id CHAR(4) NOT NULL,
    inventory_quantity INTEGER NOT NULL,
    PRIMARY KEY (inventory_id, product_id)
);

START TRANSACTION;
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0001', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0002', 120);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0003', 200);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0004', 3);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0005', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0006', 99);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0007', 999);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0008', 200);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0001', 10);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0002', 25);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0003', 34);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0004', 19);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0005', 99);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0006', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0007', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0008', 18);
COMMIT;

select sp.shop_id, sp.shop_name, p.product_id, p.product_name, p.sale_price, ip.inventory_quantity
from shopproduct as sp
     inner join
     product as p
     on sp.product_id = p.product_id
     inner join
     inventoryproduct as ip
     on sp.product_id = ip.product_id;

select p.product_id, p.product_name, p.sale_price, sp.shop_id, sp.shop_name, ip.inventory_quantity
from product as p
     left join
     shop_product as sp
     on p.product_id = sp.product_id
     left join inventoryproduct as ip
     on sp.product_id = ip.product_id;

/*
非等值联结：比较运算符和谓词运算等逻辑运算都可以放在ON子句作为联结条件
 */
select product_id, product_name, sale_price, count(p2_id) as rank_id
from (
         -- 对每一种商品，找出所有售价不低于它的商品，对这些商品使用COUNT计数，作为售价的排序
         select p1.product_id,
                p1.product_name,
                p1.sale_price,
                p2.product_id as p2_id
         from product as p1
              left join
              product as p2
              on p1.sale_price <= p2.sale_price
     ) as t
group by product_id
order by rank_id;

/*
交叉联结（笛卡尔积）：使用集合A中的每一个元素与集合B中的每一个元素组成一个有序的组合
 */
select sp.shop_id, sp.shop_name, p.product_id, p.sale_price
from shopproduct as sp
     cross join
     product as p;

select sp.shop_id, sp.shop_name, p.product_id, p.sale_price
from shopproduct as sp,
     product as p;

/*
练习1: 找出 product 和 product2 中售价高于 500 的商品的基本信息
 */
select *
from product
where sale_price > 500
union
select *
from product2
where sale_price > 500;

/*
练习2: 借助对称差的实现方式, 求product和product2的交集
 */
select *
from (
         select *
         from product
         union
         select *
         from product2) as t
where product_id not in
      (
          select product_id
          from product
          where product_id not in
                (select product_id from product2)
          union
          select product_id
          from product2
          where product_id not in
                (select product_id from product)
      );

/*
练习3: 每类商品中售价最高的商品都在哪些商店有售?
 */
select sp.shop_id, sp.shop_name, t.product_id, t.product_name, t.product_type, t.max_price
from shopproduct as sp
     inner join
     (select product_id, product_name, product_type, max(sale_price) as max_price
      from product
      group by product_type) as t
     on t.product_id = sp.product_id;

/*
练习4: 分别使用内连结和关联子查询每一类商品中售价最高的商品
 */
select p.product_id, p.product_name, p.product_type, p.sale_price
from product as p
     inner join
     (select product_type, max(sale_price) as max_price
      from product
      group by product_type) as t
     on p.product_type = t.product_type
         and p.sale_price = t.max_price;

select p.product_id, p.product_name, p.product_type, p.sale_price
from product as p
where p.sale_price in (
    select max(sale_price)
    from product as p1
    where p.product_type = p1.product_type
    group by p1.product_type
);

/*
练习5: 用关联子查询实现：在product表中，取出 product_id, produc_name, slae_price, 并按照商品的售价从低到高进行排序、对售价进行累计求和
 */
select product_id,
       product_name,
       sale_price,
       (select sum(sale_price) as cum_sum
        from product as p1
        where p1.sale_price < p.sale_price
           or (p1.sale_price = p.sale_price and p1.product_id <= p.product_id))
from product as p
order by sale_price;