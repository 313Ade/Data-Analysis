
-- ORDERS
SELECT * FROM mintclassics.orders;
select
 -- count(distinct(o.orderNumber)) PendingOrders,
 distinct(o.orderNumber) pendingOrders, 
 w.warehouseName, od.quantityOrdered, od.productCode, p.productName, status
-- count(*) PendingOrders
from orders o

join orderdetails od
on o.orderNumber = od.orderNumber
join products p
on p.productCode = od.productCode
right join warehouses w
on w.warehouseCode = p.warehouseCode

where status NOT LIKE 'SHIPPED'
and status not like 'CANCELLED'
and status not like 'RESOLVED'
and status not like 'DISPUTED'
and status not like 'ON HOLD'

-- group by 2

order by 2
;
select
 -- count(distinct(o.orderNumber)) PendingOrders,
 -- distinct(o.orderNumber) pendingOrders, 
 w.warehouseName, od.quantityOrdered
 -- count(od.quantityOrdered)
-- count(*) PendingOrders
from orders o

join orderdetails od
on o.orderNumber = od.orderNumber
join products p
on p.productCode = od.productCode
right join warehouses w
on w.warehouseCode = p.warehouseCode

where status NOT LIKE 'SHIPPED'
and status not like 'CANCELLED'
and status not like 'RESOLVED'
and status not like 'DISPUTED'
and status not like 'on hold';

-- WAREHOUSE ANALYSIS --
SELECT sum(od.quantityOrdered) QuantityOrdered, warehouseName, sum(quantityOrdered * priceEach) Revenue,

(sum(quantityOrdered * priceEach)/sum(od.quantityOrdered)) AvgRevenue

FROM mintclassics.warehouses w


join products p
on p.warehouseCode = w.warehouseCode
join orderdetails od
on od.productCode = p.productCode
join orders o 
on o.orderNumber = od.orderNumber

where status = 'Shipped'
group by 2	
order by 3 desc; -- PRODUCT PERFORMANCE

 select count(*) from (select productName, w.warehouseCode from warehouses w
join products p
on p.warehouseCode = w.warehouseCode
order by 1) ss; -- subquery gets the products and their respective warehouses. outerquery gets the count of all the entries

-- ORDERS ANALYSIS --
select COUNT(*) ordersPlaced, month(orderDate) month, year(orderdate) year
FROM 
 mintclassics.orders o
        JOIN orderdetails od ON od.orderNumber = o.orderNumber
        GROUP BY 2,3
        ORDER BY 1 DESC
       LIMIT 5; -- ORDERS PLACED PER MONTH

select sum(quantityordered), productName, productLine, quantityInStock, (quantityInStock-sum(quantityordered)) as diff, priceEach, warehouseName
from 
 mintclassics.orders o
        JOIN orderdetails od ON od.orderNumber = o.orderNumber
        JOIN products p ON p.productCode = od.productCode
        join warehouses w ON w.warehouseCode = p.warehouseCode
where status = 'shipped'
group by productName
ORDER BY quantityInStock desc; -- quanity ordered, quantity in stock and difference

SELECT *
-- sum(quantityOrdered),
-- month(shippeddate) month, year(shippeddate) year

FROM mintclassics.orders o
join orderdetails od 
on od.orderNumber = o.orderNumber
join products p
on p.productCode = od.productCode

where status = 'shipped'
-- and shippedDate > '2004-01-01'
-- group by month(shippeddate), year(shippedDate)
order by quantityOrdered desc
-- limit 5;
;
SELECT
    MONTH(shippedDate) AS shipment_month,
    YEAR(shippedDate) AS shipment_year,
    PRODUCTNAME,
    MAX(sumOrdered) AS max_sum_ordered
FROM (
    SELECT 
        shippedDate,
        quantityOrdered,
        productName,
        productLine,
        priceEach,
        SUM(quantityOrdered) OVER (PARTITION BY MONTH(shippedDate)) AS sumOrdered
    FROM
        mintclassics.orders o
        JOIN orderdetails od ON od.orderNumber = o.orderNumber
        JOIN products p ON p.productCode = od.productCode
    WHERE
        status = 'shipped'
) AS subquery
GROUP BY
    shipment_month
ORDER BY 4 DESC; -- not necessary (SUBQUERIES IN ACTION, THOUGH)

SELECT productName, od.priceEach, sum(quantityOrdered) quantityOrderedTotal, (priceEach*sum(quantityOrdered)) Revenue, quantityInStock, warehouseName
FROM 
products p
JOIN orderdetails od ON od.productCode = p.productCode
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN warehouses w on w.warehouseCode = p.warehouseCode
where status not like 'cancelled'
and status not like 'disputed'
GROUP BY productName
ORDER BY Revenue DESC; -- TOP REVENUE PRODUCTS

