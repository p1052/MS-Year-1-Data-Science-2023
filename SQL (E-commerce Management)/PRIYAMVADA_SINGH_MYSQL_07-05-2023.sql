use orders;

describe carton;
select * from carton;
describe address;
select * from address;
describe online_customer;
select * from online_customer;

describe order_header;
select * from order_header;
describe order_items;
select * from order_items;

describe product;
select * from product;
describe product_class;
select * from product_class;
describe shipper;
select * from shipper;

/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email, customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.

select
  CUSTOMER_ID,
  CONCAT_WS(' ', CASE WHEN CUSTOMER_GENDER = 'F' THEN 'Ms' ELSE 'Mr' END, UPPER(CUSTOMER_FNAME), UPPER(CUSTOMER_LNAME)) as CUSTOMER_FULL_NAME,
  YEAR(CUSTOMER_CREATION_DATE) as CUSTOMER_CREATION_YEAR,
  CUSTOMER_EMAIL,
  (SELECT 
     CASE
       WHEN CUSTOMER_CREATION_YEAR < 2005 THEN 'CATEGORY A'
       WHEN CUSTOMER_CREATION_YEAR >=2005 and CUSTOMER_CREATION_YEAR < 2011 THEN 'CATEGORY B'
       WHEN CUSTOMER_CREATION_YEAR >= 2011 THEN 'CATEGORY C'
     END
   ) as CUSTOMER_CATEGORY
from online_customer;


/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/

describe product;
select * from product;
describe order_items;
select * from order_items;

## Answer 2.

select 
    p.PRODUCT_ID,
    p.PRODUCT_DESC,
	p.PRODUCT_QUANTITY_AVAIL, 
	p.PRODUCT_PRICE,
	p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE as INVENTORY_VALUES,
	(SELECT
     CASE
		WHEN p.PRODUCT_PRICE <= 10000 THEN p.PRODUCT_PRICE*0.9
		WHEN p.PRODUCT_PRICE > 10000 and p.PRODUCT_PRICE < 20000 THEN p.PRODUCT_PRICE*0.85
        WHEN p.PRODUCT_PRICE > 20000 THEN p.PRODUCT_PRICE*0.8
     END) as NEW_PRICE
from
    PRODUCT p
	LEFT JOIN
    ORDER_ITEMS i
    on p.PRODUCT_ID = i.PRODUCT_ID
where i.PRODUCT_ID is NULL
order by INVENTORY_VALUES;

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

describe product_class;
select * from product_class;
describe product;
select * from product;

## Answer 3.

select
    c.PRODUCT_CLASS_DESC,
    p.PRODUCT_CLASS_CODE,
    COUNT(p.PRODUCT_ID) as PRODUCT_ID_COUNT,
    SUM(p.PRODUCT_QUANTITY_AVAIL * p.PRODUCT_PRICE) as INVENTORY_VALUE
from product p
	JOIN
    product_class c
    on p.PRODUCT_CLASS_CODE = c.PRODUCT_CLASS_CODE
group by 
    p.PRODUCT_CLASS_CODE,
    c.PRODUCT_CLASS_DESC
having
	INVENTORY_VALUE > 100000
order by INVENTORY_VALUE desc;


/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/

describe online_customer;
select * from online_customer;
describe address;
select * from address;
describe order_header;
select * from order_header; 


## Answer 4.

select
	oc.CUSTOMER_ID,
    CONCAT_WS(' ',oc.CUSTOMER_FNAME,oc.CUSTOMER_LNAME) as CUSTOMER_FULL_NAME, 
	oc.CUSTOMER_EMAIL,
    oc.CUSTOMER_PHONE,
    a.COUNTRY
from 
	online_customer oc LEFT JOIN address a 
    on oc.ADDRESS_ID = a.ADDRESS_ID
where oc.CUSTOMER_ID in (
					SELECT oh.CUSTOMER_ID 
                    from order_header oh
					where oh.ORDER_STATUS = 'Cancelled'
					group by oh.CUSTOMER_ID
					having count(oh.ORDER_ID) = (
													SELECT 
													COUNT(*) from order_header
													where CUSTOMER_ID = oh.CUSTOMER_ID)
													);            


/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */


describe SHIPPER;
select * from SHIPPER; 
describe ONLINE_CUSTOMER; 
select * from ONLINE_CUSTOMER; 
describe ADDRESS;
select * from ADDRESS; 
describe ORDER_HEADER;
select * from ORDER_HEADER;

## Answer 5.

select 
	s.SHIPPER_NAME, 
    a.CITY, 
    COUNT(oc.CUSTOMER_ID) as NUMBER_OF_CUSTOMERS, 
    COUNT(oh.ORDER_ID) as NUMBER_OF_CONSIGNMENTS
from 
	order_header oh 
    join
    online_customer oc
    on oh.CUSTOMER_ID = oc.CUSTOMER_ID
    join
    address a
    on a.ADDRESS_ID = oc.ADDRESS_ID
    join
    shipper s
    on oh.SHIPPER_ID = s.SHIPPER_ID
group by s.SHIPPER_NAME, 
    a.CITY, s.SHIPPER_NAME
having s.SHIPPER_NAME = 'DHL';

/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

describe product;
select * from product; 
describe product_class;
select * from product_class;
describe order_items;
select * from order_items;

## Answer 6.

select
	p.PRODUCT_ID,
    p.PRODUCT_DESC,
    SUM(p.PRODUCT_QUANTITY_AVAIL) as PRODUCT_AVAILABLE, 
    SUM(oi.PRODUCT_QUANTITY) as PRODUCT_SOLD,
	(SELECT CASE 
		WHEN pc.PRODUCT_CLASS_DESC in ('Electronics','Computer') THEN
			CASE 
                WHEN SUM(oi.PRODUCT_QUANTITY) is null THEN 'No Sales in past, give discount to reduce inventory'
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) < 0.1*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Low inventory, need to add inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) < 0.5*(SUM(oi.PRODUCT_QUANTITY)) and SUM(p.PRODUCT_QUANTITY_AVAIL) > 0.1*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Medium inventory, need to add some inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) >= 0.5*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Sufficient inventory'
			END
		WHEN pc.PRODUCT_CLASS_DESC in ('Mobiles','Watches') THEN
			CASE
				WHEN SUM(oi.PRODUCT_QUANTITY) is null THEN 'No Sales in past, give discount to reduce inventory'
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) < 0.2*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Low inventory, need to add inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) < 0.6*(SUM(oi.PRODUCT_QUANTITY)) and SUM(p.PRODUCT_QUANTITY_AVAIL) > 0.2*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Medium inventory, need to add some inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) >= 0.6*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Sufficient inventory'
			END
		WHEN pc.PRODUCT_CLASS_DESC NOT in ('Electronics','Computer','Mobiles','Watches') THEN
			CASE 
				WHEN SUM(oi.PRODUCT_QUANTITY) is null THEN 'No Sales in past, give discount to reduce inventory'
                WHEN SUM(oi.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) < 0.3*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Low inventory, need to add inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) < 0.7*(SUM(oi.PRODUCT_QUANTITY)) and SUM(p.PRODUCT_QUANTITY_AVAIL) > 0.3*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Medium inventory, need to add some inventory'
				WHEN SUM(p.PRODUCT_QUANTITY_AVAIL) >= 0.7*(SUM(oi.PRODUCT_QUANTITY)) THEN 'Sufficient inventory'
			END
	END) as INVENTORY_TYPE
from product p
left join 
order_items oi
on p.PRODUCT_ID = oi.PRODUCT_ID
left join
product_class pc
on pc.PRODUCT_CLASS_CODE = p.PRODUCT_CLASS_CODE
group by p.PRODUCT_ID, p.PRODUCT_DESC, pc.PRODUCT_CLASS_DESC
order by p.PRODUCT_ID;


/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10.
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */
 
describe carton; 
select * from carton;
describe order_items;
select * from order_items;
describe product;
select * from product;

## Answer 7.

select
	oi.ORDER_ID,
    SUM(oi.PRODUCT_QUANTITY*p.LEN*p.WIDTH*p.HEIGHT) as ORDER_VOLUME
from 
	order_items oi
	JOIN
	product p
	on oi.PRODUCT_ID = p.PRODUCT_ID
group by oi.ORDER_ID
having 
	ORDER_VOLUME <= 600*300*100
order by 
	ORDER_VOLUME desc limit 1;

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

describe ONLINE_CUSTOMER;
describe ORDER_HEADER;
select * from order_header;
describe ORDER_ITEMS; 
describe PRODUCT;
describe ADDRESS;

## Answer 8.

select 
	oc.CUSTOMER_ID, 
    CONCAT_WS(' ',oc.CUSTOMER_FNAME,oc.CUSTOMER_LNAME) as CUSTOMER_FULL_NAME, 
    SUM(oi.PRODUCT_QUANTITY) as TOTAL_PRODUCT_QUANTITY,
    SUM((oi.PRODUCT_QUANTITY*p.PRODUCT_PRICE)) as TOTAL_VALUE
from
	online_customer oc
    JOIN
    order_header oh
    on oh.CUSTOMER_ID = oc.CUSTOMER_ID
    JOIN
    order_items oi
    on oi.ORDER_ID = oh.ORDER_ID
    JOIN
	product p
    on p.PRODUCT_ID = oi.PRODUCT_ID
where
	oh.PAYMENT_MODE = 'Cash' and
	oc.CUSTOMER_LNAME like 'G%'
group by oc.CUSTOMER_ID;
	

/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products, 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

describe ORDER_ITEMS; 
select * from order_items;
describe PRODUCT;
select * from product;
describe ORDER_HEADER; 
select * from order_header;
describe ONLINE_CUSTOMER;
select * from online_customer; 
describe ADDRESS;


## Answer 9.

/* NOTE TO THE MENTOR: The question only asked to display product_id, product_desc, and total_quantity but I've also displayed 
order_id and city just to cross check my output manually. */

select
	p.PRODUCT_ID,
	p.PRODUCT_DESC,
    oi.ORDER_ID,
    a.CITY,
    SUM(oi.PRODUCT_QUANTITY) as TOTAL_PRODUCT_QUANTITY
from
	product p
    JOIN order_items oi
    on p.PRODUCT_ID = oi.PRODUCT_ID
    JOIN order_header oh
    on oh.ORDER_ID = oi.ORDER_ID
    JOIN online_customer oc
    on oc.CUSTOMER_ID = oh.CUSTOMER_ID
    JOIN address a
    on a.ADDRESS_ID = oc.ADDRESS_ID
where
	p.PRODUCT_ID <> 201 and
    a.CITY NOT in ('Bangalore','New Delhi') and
	oi.ORDER_ID in (
				SELECT oi.ORDER_ID
                from order_items oi
				JOIN order_header oh
				on oh.ORDER_ID = oi.ORDER_ID
				JOIN online_customer oc
				on oc.CUSTOMER_ID = oh.CUSTOMER_ID
				JOIN address a
				on a.ADDRESS_ID = oc.ADDRESS_ID
			where 
				oi.PRODUCT_ID != 201 and
				a.CITY NOT in ('Bangalore','New Delhi')) and
                oi.ORDER_ID in (
								SELECT oi.ORDER_ID
								from order_items oi
								where PRODUCT_ID = 201
							)
group by
	p.PRODUCT_ID, 
	p.PRODUCT_DESC,
	oi.ORDER_ID,
    a.CITY
order by
	TOTAL_PRODUCT_QUANTITY desc;


/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

use orders;
describe ORDER_ITEMS; 
select * from order_items;
describe ORDER_HEADER; 
select * from order_header;
describe ONLINE_CUSTOMER;
select * from online_customer; 
describe ADDRESS;

## Answer 10.

select 
	oi.ORDER_ID, 
    oc.CUSTOMER_ID,
	CONCAT_WS(' ',oc.CUSTOMER_FNAME,oc.CUSTOMER_LNAME) as CUSTOMER_FULL_NAME,
    SUM(oi.PRODUCT_QUANTITY) as TOTAL_PRODUCT_QUANTITY
from
	order_items oi
    JOIN order_header oh
    on oi.ORDER_ID = oh.ORDER_ID
    JOIN online_customer oc
    on oc.CUSTOMER_ID = oh.CUSTOMER_ID
    JOIN address a
    on a.ADDRESS_ID = oc.ADDRESS_ID
where
	(oi.ORDER_ID % 2) = 0 and
	a.PINCODE not like '5%' and
    oh.ORDER_STATUS = 'Shipped'
group by 
	oi.ORDER_ID, 
    oc.CUSTOMER_ID
order by
	oi.ORDER_ID;