
-- ORDERS
SELECT 
    *
FROM
    mintclassics.orders;
SELECT DISTINCT
    (o.orderNumber) pendingOrders,
    w.warehouseName,
    od.quantityOrdered,
    od.productCode,
    p.productName,
    status
FROM
    orders o
        JOIN
    orderdetails od ON o.orderNumber = od.orderNumber
        JOIN
    products p ON p.productCode = od.productCode
        RIGHT JOIN
    warehouses w ON w.warehouseCode = p.warehouseCode
WHERE
    status NOT LIKE 'SHIPPED'
        AND status NOT LIKE 'CANCELLED'
        AND status NOT LIKE 'RESOLVED'
        AND status NOT LIKE 'DISPUTED'
        AND status NOT LIKE 'ON HOLD'
ORDER BY 2
;
SELECT 
    w.warehouseName, od.quantityOrdered
FROM
    orders o
        JOIN
    orderdetails od ON o.orderNumber = od.orderNumber
        JOIN
    products p ON p.productCode = od.productCode
        RIGHT JOIN
    warehouses w ON w.warehouseCode = p.warehouseCode
WHERE
    status NOT LIKE 'SHIPPED'
        AND status NOT LIKE 'CANCELLED'
        AND status NOT LIKE 'RESOLVED'
        AND status NOT LIKE 'DISPUTED'
        AND status NOT LIKE 'on hold';

-- WAREHOUSE ANALYSIS --
SELECT 
    SUM(od.quantityOrdered) QuantityOrdered,
    warehouseName,
    SUM(quantityOrdered * priceEach) Revenue,
    (SUM(quantityOrdered * priceEach) / SUM(od.quantityOrdered)) AvgRevenue
FROM
    mintclassics.warehouses w
        JOIN
    products p ON p.warehouseCode = w.warehouseCode
        JOIN
    orderdetails od ON od.productCode = p.productCode
        JOIN
    orders o ON o.orderNumber = od.orderNumber
WHERE
    status = 'Shipped'
GROUP BY 2
ORDER BY 3 DESC;-- PRODUCT PERFORMANCE

SELECT 
    COUNT(*)
FROM
    (SELECT 
        productName, w.warehouseCode
    FROM
        warehouses w
    JOIN products p ON p.warehouseCode = w.warehouseCode
    ORDER BY 1) ss;-- subquery gets the products and their respective warehouses. outerquery gets the count of all the entries

SELECT 
    COUNT(*) ordersPlaced,
    MONTH(orderDate) month,
    YEAR(orderdate) year
FROM
    mintclassics.orders o
        JOIN
    orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY 2 , 3
ORDER BY 1 DESC
LIMIT 5;-- ORDERS PLACED PER MONTH

SELECT 
    SUM(quantityordered),
    productName,
    productLine,
    quantityInStock,
    (quantityInStock - SUM(quantityordered)) AS diff,
    priceEach,
    warehouseName
FROM
    mintclassics.orders o
        JOIN
    orderdetails od ON od.orderNumber = o.orderNumber
        JOIN
    products p ON p.productCode = od.productCode
        JOIN
    warehouses w ON w.warehouseCode = p.warehouseCode
WHERE
    status = 'shipped'
GROUP BY productName
ORDER BY quantityInStock DESC;-- quanity ordered, quantity in stock and difference

SELECT 
    *
FROM
    mintclassics.orders o
        JOIN
    orderdetails od ON od.orderNumber = o.orderNumber
        JOIN
    products p ON p.productCode = od.productCode
WHERE
    status = 'shipped'
ORDER BY quantityOrdered DESC
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
ORDER BY 4 DESC;-- not necessary (SUBQUERIES IN ACTION, THOUGH)

SELECT 
    productName,
    od.priceEach,
    SUM(quantityOrdered) quantityOrderedTotal,
    (priceEach * SUM(quantityOrdered)) Revenue,
    quantityInStock,
    warehouseName
FROM
    products p
        JOIN
    orderdetails od ON od.productCode = p.productCode
        JOIN
    orders o ON o.orderNumber = od.orderNumber
        JOIN
    warehouses w ON w.warehouseCode = p.warehouseCode
WHERE
    status NOT LIKE 'cancelled'
        AND status NOT LIKE 'disputed'
GROUP BY productName
ORDER BY Revenue DESC; -- TOP REVENUE PRODUCTS

