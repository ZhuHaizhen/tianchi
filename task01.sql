/*
本笔记为阿里云天池龙珠计划SQL训练营的学习内容，链接为：https://tianchi.aliyun.com/specials/promotion/aicampsql
 */

/*
SQL语句分为以下三类：
1. DDL(Data Definition Language，数据定义语言)用来创建或删除存储数据用的数据库及数据库中的表等。包含以下几种指令：
    * CREATE: 创建数据库和表等对象
    * DROP: 删除数据库和表等对象
    * ALTER: 修改数据库和表等对象的结构
2. DML(Data Manipulation Language，数据库操纵语言)用来查询或变更表中的记录。包含以下几种指令：
    * SELECT: 查询表中的数据
    * INSERT: 向表中插入新数据
    * UPDATE: 更新表中的数据
    * DELETE: 删除表中的数据
3. DCL(Data Control Language，数据控制语言)用来确认或取消对数据库中的数据进行的变更，还可以对RDBMS的用户权限进行设定。包含以下几种指令：
    * COMMIT: 对数据库中的数据进行的变更
    * ROLLBACK: 取消对数据库中的数据进行的变更
    * GRANT: 赋予用户操作权限
    * ROVOKE: 取消用户的操作权限
 */

create database shop;
use shop;
create table product
(
    product_id     char(4)      not null,
    product_name   varchar(100) not null,
    product_type   varchar(32)  not null,
    sale_price     integer,
    purchase_price integer,
    regist_date    date,
    primary key (product_id)
);

drop table product;
alter table product
    add column product_name_pinyin varchar(100);
alter table product
    drop column product_name_pinyin;
truncate table product; /* 清除数据，速度快 */
update product
set regist_date = '2009-10-10'; /* 会修改所有行 */
update product
set sale_price = sale_price * 10
    where product_type = '厨房用具';
update product
set regist_date = NULL /* NULL清空 */
    where product_id = '0008';
update product
set sale_price = sale_price * 10, /* 同时更新多列 */
    purchase_price = purchase_price / 2
    where product_type = '厨房用具';

create table productins
(
    product_id     char(4)      not null,
    product_name   varchar(100) not null,
    product_type   varchar(32)  not null,
    sale_price     integer default 0,
    purchase_price integer,
    regist_date    date,
    primary key (product_id)
);
insert into productins (product_id, product_name, product_type, sale_price, purchase_price, regist_date)
    values ('0005', '高压锅', '厨房用具', 6800, 5000, '2019-01-15');
insert into productins /* 一次插入多行 */
    values ('0001', 'T恤衫', '衣服', 1000, 500, '2009-09-20'),
           ('0002', '打孔器', '办公用品', 500, 320, '2009-09-11'),
           ('0003', '运动T恤', '衣服', 4000, 2800, NULL),
           ('0004', '菜刀', '厨房用具', 3000, 2800, '2009-09-20'),
           ('0005', '高压锅', '厨房用具', 6800, 5000, '2009-01-15'),
           ('0006', '叉子', '厨房用具', 500, NULL, '2009-09-20'),
           ('0007', '擦菜板', '厨房用具', 880, 790, '2008-04-28'),
           ('0008', '圆珠笔', '办公用品', 100, NULL, '2009-11-11');
insert into product
select *
    from productins;

/* 练习 */
create table Addressbook (
    regist_no integer not null primary key,
    name varchar(128) not null,
    address varchar(256) not null,
    tel_no char(10),
    mail_address char(20)
);

alter table Addressbook add column postal_code char(8) not null;

drop table Addressbook;

/* 删除后的表无法恢复 */