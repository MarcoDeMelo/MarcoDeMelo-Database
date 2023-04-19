USE `sample_company`;
/* QUestion 1
-- 1. Create a procedure "q1Proc" that receives a dollar amount as a decimal,
-- and returns a list of all payments (payments table) that are less than or equal to that cost.
-- The result should display the following columns: Customer name, payment date, amount.
-- (payments, customers)
DROP procedure IF EXISTS `q1Proc`;
DELIMITER $$
CREATE PROCEDURE `q1Proc`(IN dollar_amount DECIMAL(10,2))
BEGIN
  SELECT c.customerName, p.paymentDate, p.amount
  FROM payments p
  JOIN customers c ON p.customerNumber = c.customerNumber
  WHERE p.amount <= dollar_amount
  ORDER BY p.paymentDate DESC;
END$$

DELIMITER ;

CALL q1Proc(5000.00);
*/
/* Question 2
-- 2. Create a procedure "q2Proc" that returns a list of all payments that are higher than the average of all payments.
-- Do not use a subquery to solve this. The result should display the customer name, Cheque number, amount
-- (payments, customers)

DROP procedure IF EXISTS `q2Proc`;
DELIMITER $$
CREATE PROCEDURE `q2Proc`()
BEGIN
  DECLARE avgAmount DECIMAL(10,2);
  
  -- Calculate the average amount of all payments
  SELECT AVG(amount) INTO avgAmount FROM payments;
  
  -- Return the list of payments that are higher than the average
  SELECT c.customerName, p.checkNumber, p.amount
  FROM payments p
  JOIN customers c ON p.customerNumber = c.customerNumber
  WHERE p.amount > avgAmount;
END$$
DELIMITER ;

CALL q2Proc();
*/

/* QUESTION 3
3. Create a function "getShippingSpeed" that receives 2 dates.
-- Return "fast shipping" if the difference is 1 or 2 days.
-- "Average shipping" if the difference is 3 days. "Slow shipping" otherwise.
-- Use this function to get a list of orders, and the shipping speed based on the orderDate and shippedDate.
-- The result should show: Customer name, order number, order date, shipping speed.
-- (orders, customers)
DROP FUNCTION IF EXISTS `getShippingSpeed`;
DELIMITER $$
CREATE FUNCTION `getShippingSpeed`(date1 DATE, date2 DATE)
RETURNS VARCHAR(20)
BEGIN
  DECLARE daysDiff INT;
  SET daysDiff = DATEDIFF(date2, date1);
  
  IF daysDiff BETWEEN 1 AND 2 THEN
    RETURN 'fast shipping';
  ELSEIF daysDiff = 3 THEN
    RETURN 'average shipping';
  ELSE
    RETURN 'slow shipping';
  END IF;
END$$
DELIMITER ;

SELECT c.customerName, o.orderNumber, o.orderDate,
       getShippingSpeed(o.orderDate, o.shippedDate) AS shippingSpeed
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber;
*/ 
/* QUESTION 4
-- 4. Create a function "getCountByName" that returns the number of customers who's customer name matches a string that the function receives.
-- Example, if the function receives "toys" as a param, "land of toys inc" will be counted (as well as others).
-- (customers)

DROP FUNCTION IF EXISTS `getCountByName`;
DELIMITER $$
CREATE FUNCTION getCountByName(nameParam VARCHAR(255))
RETURNS INT
BEGIN
  DECLARE countResult INT;
  SELECT COUNT(*) INTO countResult FROM customers WHERE customerName LIKE CONCAT('%', nameParam, '%');
  RETURN countResult;
END$$
DELIMITER ;

SELECT getCountByName('toys'); */

/* Question 5 
-- 5. Run this snippet on your database
SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE `sample_company`.`employees` CHANGE COLUMN `employeeNumber` `employeeNumber` INT NOT NULL AUTO_INCREMENT;
SET FOREIGN_KEY_CHECKS=1;
*/
-- Question 6
-- 6. Create procedure that includes a transaction that inserts a new manager into the employees table,
-- then inserts 2 employees that report to that manager (reportsTo field in the table).
-- You can make up these 3 persons information as you wish
-- but do not hardcode the IDs for any of these individuals
-- Let SQL auto-generate the manager's ID, and use SQL an SQL function to determine the ID of the manager in subsequent queries
-- No changes should be committed if there are any errors in any of the queries.
-- Your procedure should display a friendly message letting the caller know if the changes were made or not
/*
DROP PROCEDURE IF EXISTS insert_new_manager;
DELIMITER $$
CREATE PROCEDURE insert_new_manager()
BEGIN
  DECLARE message VARCHAR(50);
  DECLARE lastID INT;
  DECLARE manager_office_code INT; 
  DECLARE sqlError int DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  SET sqlError = 0;
  SET manager_office_code = 1;
  START TRANSACTION;
    -- Get the auto-generated ID of the new manager
  -- Insert new manager into employees table
  INSERT INTO employees (lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
  VALUES ('Marco', 'DeMelo','X9123', 'myemail@gmaill.com', manager_office_code, 1056, 'Manager');
  SET lastID =LAST_INSERT_ID();

  -- Insert first employee that reports to the new manager
  INSERT INTO employees (lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
  VALUES ( 'John', 'Adams', 'X0412', 'notMyEmail@gmail.com', manager_office_code, lastID, 'Employee');


  -- Insert second employee that reports to the new manager
  INSERT INTO employees ( lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
   VALUES ('Elizabeth', 'Adams', 'X6122', 'SomeonesEmail@gmail.com', manager_office_code, lastID, 'Employee');



 IF sqlError = 1 THEN
    SET message = "Error with SQL";
    ROLLBACK;
 ELSE 
    SET message = "New Manager and Employees added";
    COMMIT;
END IF;
  select message;
END$$
DELIMITER ;

call insert_new_manager();
SELECT * FROM employees ;
*/
/* Question 7

-- 7. Write a transaction that will update the MSRP of the products in the products table.
-- The transactin should increase the MSRP price of all products
-- by 7% when the difference between MSRP and buyPrice is less than 100$
-- Ensure that no other session can read from this table while the update is running
-- Prevent anyone from reading or writing from the table during the operation

BEGIN;
LOCK TABLES products WRITE;
UPDATE products
SET MSRP = ROUND(buyPrice + (buyPrice * 0.07), 2)
WHERE ABS(MSRP - buyPrice) < 100;
UNLOCK TABLES;
COMMIT;


select MSRP from products;

*/
 -- Question 8
-- 8. Create a procedure that includes a transaction which does the following:
-- get the number of employees from the employees table
-- if the number of employees is below 30, run the fllowing queries
-- every employee should now report to Diane Murphy, the President of the company
-- Reduce the credit limit for customers from the customers table by 25%
-- if there are any errors, no changes should be made to the database
-- return a friendly message to the caller to specify if the changes were mad
/*
DROP PROCEDURE IF EXISTS update_company_info;
DELIMITER $$
CREATE PROCEDURE update_company_info()
BEGIN
  DECLARE numEmployees INT;
  DECLARE bossNum INT;
  DECLARE message VARCHAR(50);
  DECLARE sqlError int DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  SET sqlError = 0;
  START TRANSACTION;
  SELECT employeeNumber FROM employees WHERE jobTitle = 'President' INTO bossNum;
  SELECT COUNT(*) INTO numEmployees FROM employees;
  IF numEmployees < 30 THEN
    UPDATE employees SET reportsTo = bossNum;
    UPDATE customers SET creditLimit = creditLimit * 0.75;
  END IF;
  
   IF sqlError = 1 THEN
  SET message = "Changes were not made due to errors.";
    ROLLBACK;
  ELSE
    SET message = "Changes were made successfully.";
    COMMIT;
  END IF;
  select message;
END$$
DELIMITER ;
CALL update_company_info();
SELECT * FROM employees;
*/
