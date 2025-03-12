ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';
DROP TABLE detalle;
DROP TABLE producto;
DROP TABLE orden;
DROP TABLE clientes;
DROP TABLE proveedor;

CREATE TABLE clientes ( 
	COD_CLI NUMBER(5) NOT NULL CONSTRAINT clientes_pk PRIMARY KEY, 
	NOMBRE VARCHAR2(30) NOT NULL, 
	CIUDAD VARCHAR2(20) );

CREATE TABLE proveedor ( 
	COD_PROV NUMBER(5) NOT NULL CONSTRAINT proveedor_pk PRIMARY KEY, 
	NOMBRE VARCHAR2(30) NOT NULL, 
	CIUDAD VARCHAR2(20) );

CREATE TABLE producto ( 
	COD_PROD NUMBER(5) NOT NULL CONSTRAINT producto_pk PRIMARY KEY, 
	NOMBRE VARCHAR2(30) NOT NULL CONSTRAINT producto_uk UNIQUE, 
	PRECIO NUMBER(8), 
	COD_PROV CONSTRAINT prod_to_prov_fk REFERENCES proveedor );
	
CREATE TABLE orden ( 
	NUM_ORDEN NUMBER(8) NOT NULL CONSTRAINT orden_pk PRIMARY KEY, 
	COD_CLI CONSTRAINT orden_to_clientes_fk REFERENCES clientes, 
	FECHA_ORDEN DATE NOT NULL, 
	FECHA_ENTREGA DATE );
	
CREATE TABLE detalle ( 
	NUM_ORDEN CONSTRAINT detalle_to_orden REFERENCES orden, 
	COD_PROD CONSTRAINT detalle_to_prod REFERENCES producto, 
	CANTIDAD NUMBER(8) NOT NULL, 
	CONSTRAINT detalle_pk PRIMARY KEY (NUM_ORDEN,COD_PROD) 
	);
	
INSERT INTO clientes VALUES (1000,'PEREZ','MONTEVIDEO');
INSERT INTO clientes VALUES (1001,'GARCIA','SALTO');
INSERT INTO clientes VALUES (1002,'ABELLA','PANDO');
INSERT INTO clientes VALUES (1003,'SORIA','ROCHA');
INSERT INTO clientes VALUES (1004,'ABELLA','SALTO');
INSERT INTO clientes VALUES (1005,'RUIZ','ROCHA');
INSERT INTO clientes VALUES (1006,'MORENO','SALTO');
INSERT INTO clientes VALUES (1007,'REYES','MONTEVIDEO');
INSERT INTO clientes VALUES (1008,'AGUILAR','ROCHA');
INSERT INTO clientes VALUES (1009,'DELGADO','SALTO');
INSERT INTO clientes VALUES (1010,'ABELLA','MONTEVIDEO');
INSERT INTO clientes VALUES (1011,'ESPINOLA','MONTEVIDEO');
INSERT INTO clientes VALUES (1012,'PEREZ','MINAS');

INSERT INTO proveedor VALUES (2000,'APOLO','MONTEVIDEO');
INSERT INTO proveedor VALUES (2001,'DITEL','MONTEVIDEO');
INSERT INTO proveedor VALUES (2002,'LA CATEDRAL','PANDO');

INSERT INTO producto VALUES (110,'PINCEL',150,2000);
INSERT INTO producto VALUES (120,'ESMALTE 10L',550,2000);
INSERT INTO producto VALUES (130,'ESMALTE 25L',900,2000);
INSERT INTO producto VALUES (140,'RODILLO',210,2001);
INSERT INTO producto VALUES (150,'ESPATULA',120,2002);
INSERT INTO producto VALUES (160,'DESTORNILLADOR',200,2002);

INSERT INTO orden VALUES (5000,1000,'30/03/2017','01/04/2017');
INSERT INTO orden VALUES (5001,1000,'01/04/2017','01/04/2017');
INSERT INTO orden VALUES (5002,1001,'02/04/2017','03/04/2017');
INSERT INTO orden VALUES (5003,1001,'02/04/2017','03/04/2017');
INSERT INTO orden VALUES (5004,1002,'19/04/2017','20/04/2017');
INSERT INTO orden VALUES (5005,1003,'20/04/2017','21/04/2017');
INSERT INTO orden VALUES (5006,1004,'20/04/2017','21/04/2017');
INSERT INTO orden VALUES (5007,1005,'05/05/2017',NULL);
INSERT INTO orden VALUES (5008,1006,'08/05/2017',NULL);

INSERT INTO detalle VALUES (5000,110,1);
INSERT INTO detalle VALUES (5000,130,2);
INSERT INTO detalle VALUES (5001,110,3);
INSERT INTO detalle VALUES (5001,120,4);
INSERT INTO detalle VALUES (5001,130,2);
INSERT INTO detalle VALUES (5002,140,2);
INSERT INTO detalle VALUES (5002,150,3);
INSERT INTO detalle VALUES (5002,160,3);
INSERT INTO detalle VALUES (5003,130,1);
INSERT INTO detalle VALUES (5004,140,5);
INSERT INTO detalle VALUES (5004,160,6);
INSERT INTO detalle VALUES (5005,120,3);
INSERT INTO detalle VALUES (5005,130,3);
INSERT INTO detalle VALUES (5006,140,2);
INSERT INTO detalle VALUES (5006,150,5);
INSERT INTO detalle VALUES (5007,110,4);
INSERT INTO detalle VALUES (5007,130,1);
INSERT INTO detalle VALUES (5008,110,2);
INSERT INTO detalle VALUES (5008,120,3);
INSERT INTO detalle VALUES (5008,130,4);
INSERT INTO detalle VALUES (5008,140,5);

COMMIT;


-- 1) Seleccionar la cantidad de clientes
SELECT COUNT(*) AS cantidad_clientes
FROM clientes;

-- 2) Seleccionar el mayor y el menor precio de los productos
SELECT 
    MAX(precio) AS mayor_precio,
    MIN(precio) AS menor_precio
FROM producto;

-- 3) Seleccionar el promedio de precios de los productos.
SELECT AVG(precio) AS promedio_precio
FROM PRODUCTO;

--4) Seleccionar el número de las órdenes cuando el precio del producto ordenado sea el precio mayor de todos los productos.
SELECT DISTINCT o.num_orden
FROM ORDEN o
JOIN DETALLE d ON o.num_orden = d.num_orden
JOIN PRODUCTO p ON d.cod_prod = p.cod_prod
WHERE p.precio = (SELECT MAX(precio) FROM PRODUCTO);



-- 5) Seleccionar la cantidad de clientes por ciudad.
SELECT ciudad, COUNT(*) AS cantidad_clientes
FROM CLIENTES
GROUP BY ciudad;


-- 6) Seleccionar la cantidad de órdenes por día en el período comprendido entre el 1 y 20 de abril de este año.
SELECT fecha_orden, COUNT(*) AS cantidad_ordenes
FROM ORDEN
WHERE fecha_orden BETWEEN TO_DATE('01/04/2017', 'DD/MM/YYYY') AND TO_DATE('20/04/2017', 'DD/MM/YYYY')
GROUP BY fecha_orden;



-- 7) Seleccionar la cantidad de órdenes que hay por día, con su respectivo importe
-- Para calcular el importe por orden, podemos multiplicar la cantidad de productos por su precio.

SELECT o.fecha_orden, COUNT(*) AS cantidad_ordenes, SUM(d.cantidad * p.precio) AS importe_total
FROM ORDEN o
JOIN DETALLE d ON o.num_orden = d.num_orden
JOIN PRODUCTO p ON d.cod_prod = p.cod_prod
GROUP BY o.fecha_orden;

-- 8) Seleccionar las ciudades en donde hay más de 3 clientes.
SELECT ciudad
FROM CLIENTES
GROUP BY ciudad
HAVING COUNT(*) > 3;


--9 Seleccionar el número de las órdenes en donde se haya pedido más de un producto.

SELECT num_orden
FROM DETALLE
GROUP BY num_orden
HAVING COUNT(*) > 1;

-- 10) Seleccionar el número de las órdenes cuando la cantidad total pedida es superior a 100 y no se pida menos de 30 unidades por producto.
-- Para este requerimiento, necesitamos calcular la cantidad total por orden y asegurarnos de que cada producto pedido tenga al menos 30 unidades.

SELECT num_orden
FROM DETALLE
GROUP BY num_orden
HAVING SUM(cantidad) > 100
   AND MIN(cantidad) >= 30;

-- 11) Seleccionar el número de las órdenes en donde se hayan pedido productos de más de un proveedor.
--Para este requerimiento, necesitamos verificar que en cada orden se hayan solicitado productos de más de un proveedor. 
--Esto se puede lograr mediante el uso de JOIN entre las tablas ORDEN y PRODUCTO.

SELECT d.num_orden
FROM DETALLE d
JOIN PRODUCTO p ON d.cod_prod = p.cod_prod
GROUP BY d.num_orden
HAVING COUNT(DISTINCT p.cod_prov) > 1;

-- 12)   Seleccionar el código de los clientes que han realizado la mayor o la menor cantidad de órdenes.
-- Primero, necesitamos contar las órdenes por cliente y luego seleccionar el cliente con el mayor y menor número de órdenes

SELECT cod_cli
FROM ORDEN
GROUP BY cod_cli
HAVING COUNT(num_orden) = (SELECT MAX(order_count) FROM (SELECT COUNT(num_orden) AS order_count FROM ORDEN GROUP BY cod_cli))
   OR COUNT(num_orden) = (SELECT MIN(order_count) FROM (SELECT COUNT(num_orden) AS order_count FROM ORDEN GROUP BY cod_cli));

-- 13) Seleccionar el nombre de los clientes que han realizado la mayor cantidad de órdenes.
-- Aquí, necesitamos encontrar el cliente con la mayor cantidad de órdenes.

SELECT c.nombre
FROM CLIENTES c
JOIN ORDEN o ON c.cod_cli = o.cod_cli
GROUP BY c.cod_cli, c.nombre
HAVING COUNT(o.num_orden) = (SELECT MAX(order_count) FROM (SELECT COUNT(num_orden) AS order_count FROM ORDEN GROUP BY cod_cli));

