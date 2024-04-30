SQL Assignment
To create and normalize the database schema based on the information provided in the scenario, we need to follow best practices for naming conventions and ensure data normalization. The description indicates a need for extracting and organizing data related to Purchase Orders, Invoices, and Payments from a raw table named XXBCM_ORDER_MGT. Below is an example of how the schema could be designed and normalized.
Tools Used:
1.	Oracle SQL Developer
2.	Notepad++
Proposed Database Schema
1.	XXBCM_ORDER_MGT
•	ORDER_REF 			
•	ORDER_DATE 			
•	SUPPLIER_NAME 		
•	SUPP_CONTACT_NAME 	
•	SUPP_ADDRESS 		
•	SUPP_CONTACT_NUMBER 
•	SUPP_EMAIL 			
•	ORDER_TOTAL_AMOUNT 	
•	ORDER_DESCRIPTION 	
•	ORDER_STATUS 		
•	ORDER_LINE_AMOUNT 	
•	INVOICE_REFERENCE 	
•	INVOICE_DATE 		
•	INVOICE_STATUS 		
•	INVOICE_HOLD_REASON 
•	INVOICE_AMOUNT 		
•	INVOICE_DESCRIPTION 
2.	XXBCM_SUPPLIER_TBL
•	SUPPLIER_NAME 	
•	FIRST_NAME
•	LAST_NAME
•	SUPP_ADDRESS 	
•	TEL_NUMBER
•	MOBILE_NUMBER
•	SUPP_EMAIL_ADD 


	
3.	XXBCM_ORDER_TBL
•	ORDER_ID
•	ORDER_REF 		
•	SUPPLIER_NAME		
•	ORDER_DATE 		
•	ORDER_TOTAL_AMOUNT
•	ORDER_DESCRIPTION
•	ORDER_STATUS	
•	ORDER_LINE_AMOUNT
4.	XXBCM_INVOICE_TBL
•	INVOICE_ID
•	INVOICE_REFERENCE 	
•	ORDER_REF		
•	INVOICE_DATE	
•	INVOICE_STATUS		
•	INVOICE_HOLD_REASON
•	INVOICE_AMOUNT	
•	INVOICE_DESCRIPTION
Normalization
•	1st Normal Form (1NF): Each table has a primary key, and all attributes contain only atomic values.
•	2nd Normal Form (2NF): All attributes in the table depend solely on the primary key.
•	3rd Normal Form (3NF): All fields can only depend on the primary key and not on other fields.












SQL to Create Tables
-- TABLE NORMALISATION

  CREATE TABLE XXBCM_ORDER_MGT 
   (    
    ORDER_REF           VARCHAR2(2000), 
    ORDER_DATE          VARCHAR2(2000), 
    SUPPLIER_NAME       VARCHAR2(2000), 
    SUPP_CONTACT_NAME   VARCHAR2(2000), 
    SUPP_ADDRESS        VARCHAR2(2000), 
    SUPP_CONTACT_NUMBER VARCHAR2(2000), 
    SUPP_EMAIL          VARCHAR2(2000), 
    ORDER_TOTAL_AMOUNT  VARCHAR2(2000), 
    ORDER_DESCRIPTION   VARCHAR2(2000), 
    ORDER_STATUS        VARCHAR2(2000), 
    ORDER_LINE_AMOUNT   VARCHAR2(2000), 
    INVOICE_REFERENCE   VARCHAR2(2000), 
    INVOICE_DATE        VARCHAR2(2000), 
    INVOICE_STATUS      VARCHAR2(2000), 
    INVOICE_HOLD_REASON VARCHAR2(2000), 
    INVOICE_AMOUNT      VARCHAR2(2000), 
    INVOICE_DESCRIPTION VARCHAR2(2000)
   ) ;
    
    CREATE TABLE XXBCM_SUPPLIER_TBL
   (
    SUPPLIER_NAME       VARCHAR2(1000) NOT NULL, 
    FIRST_NAME  VARCHAR2(500)  NOT NULL,
    LAST_NAME   VARCHAR2(500)  NOT NULL,    
    SUPP_ADDRESS        VARCHAR2(2000),
    TEL_NUMBER VARCHAR2(8),
    MOBILE_NUMBER VARCHAR2(8),  
    SUPP_EMAIL_ADD          VARCHAR2(200),
    CONSTRAINT XXBCM_SUPPLIER_PK PRIMARY KEY (SUPPLIER_NAME)
    ) ;
    

CREATE TABLE XXBCM_ORDER_TBL
   (
    ORDER_ID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    ORDER_REF           VARCHAR2(15) NOT NULL, 
    SUPPLIER_NAME       VARCHAR2(1000) NOT NULL,
    ORDER_DATE          DATE,
    ORDER_TOTAL_AMOUNT  NUMERIC(15,2), 
    ORDER_DESCRIPTION   VARCHAR2(2000), 
    ORDER_STATUS        VARCHAR2(15), 
    ORDER_LINE_AMOUNT   NUMERIC(15,2),
    CONSTRAINT XXBCM_ORDER_PK PRIMARY KEY (ORDER_ID, ORDER_REF),
    CONSTRAINT XXBCM_SUPPLIER_FK FOREIGN KEY (SUPPLIER_NAME) REFERENCES XXBCM_SUPPLIER_TBL (SUPPLIER_NAME)
    ) ;
    
    
    CREATE TABLE XXBCM_INVOICE_TBL
   (
    INVOICE_ID INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    INVOICE_REFERENCE   VARCHAR2(2000) NOT NULL, 
    ORDER_REF           VARCHAR2(15) NOT NULL,
    INVOICE_DATE        DATE, 
    INVOICE_STATUS      VARCHAR2(15), 
    INVOICE_HOLD_REASON VARCHAR2(200), 
    INVOICE_AMOUNT      NUMERIC(15,2), 
    INVOICE_DESCRIPTION VARCHAR2(2000),
    CONSTRAINT XXBCM_INVOICE_ORD_PK PRIMARY KEY (INVOICE_ID,INVOICE_REFERENCE,ORDER_REF)

    ) ;

Migration – SQL Procedure

CREATE OR REPLACE PACKAGE PR_TABLE_DATA AS
  PROCEDURE INSERT_DATA;
END PR_TABLE_DATA;
/

CREATE OR REPLACE PACKAGE BODY PR_TABLE_DATA AS
  PROCEDURE INSERT_DATA IS
    -- Supplier cursor
    CURSOR C1 IS
      SELECT DISTINCT
             SUPPLIER_NAME,
             REGEXP_SUBSTR(SUPP_CONTACT_NAME, '^[^ ]+') AS FIRST_NAME,
             REGEXP_SUBSTR(SUPP_CONTACT_NAME, ' [^ ]+$') AS LAST_NAME,
             SUPP_ADDRESS,
             REGEXP_SUBSTR(SUPP_CONTACT_NUMBER, '\d{7,}') AS TEL_NUMBER,
             REGEXP_SUBSTR(SUPP_CONTACT_NUMBER, '\d{8,}') AS MOBILE_PHONE,
             SUPP_EMAIL
      FROM XXBCM_ORDER_MGT
      WHERE NOT EXISTS (
          SELECT 1
          FROM XXBCM_SUPPLIER_TBL
          WHERE XXBCM_SUPPLIER_TBL.SUPPLIER_NAME = XXBCM_ORDER_MGT.SUPPLIER_NAME
        )
        AND REGEXP_LIKE(SUPP_CONTACT_NUMBER, '\d{7,}')
        AND REGEXP_LIKE(SUPP_CONTACT_NUMBER, '\d{8,}');

    -- Order cursor
    CURSOR C2 IS
      SELECT DISTINCT
             ORDER_REF,
             SUPPLIER_NAME,
             TO_DATE(ORDER_DATE, 'DD-MON-YYYY') AS ORDER_DATE,
             TO_NUMBER(REPLACE(ORDER_TOTAL_AMOUNT, ',')) AS ORDER_TOTAL_AMOUNT,
             ORDER_DESCRIPTION,
             ORDER_STATUS,
             TO_NUMBER(REPLACE(ORDER_LINE_AMOUNT, ',')) AS ORDER_LINE_AMOUNT
      FROM XXBCM_ORDER_MGT
      WHERE NOT EXISTS (
          SELECT 1
          FROM XXBCM_ORDER_TBL
          WHERE XXBCM_ORDER_TBL.ORDER_REF = XXBCM_ORDER_MGT.ORDER_REF
        )
        AND REGEXP_LIKE(ORDER_TOTAL_AMOUNT, '^\d+$')
        AND REGEXP_LIKE(ORDER_LINE_AMOUNT, '^\d+$');

    -- Invoice cursor
    CURSOR C3 IS
      SELECT
            INVOICE_REFERENCE,
            ORDER_REF,
            TO_DATE(INVOICE_DATE, 'DD-MM-YYYY') AS INVOICE_DATE,
            INVOICE_STATUS,
            INVOICE_HOLD_REASON,
            TO_NUMBER(REPLACE(INVOICE_AMOUNT, ',')) AS INVOICE_AMOUNT,
            INVOICE_DESCRIPTION
      FROM XXBCM_ORDER_MGT
      WHERE NOT EXISTS (
          SELECT 1
          FROM XXBCM_INVOICE_TBL
          WHERE XXBCM_INVOICE_TBL.INVOICE_REFERENCE = XXBCM_ORDER_MGT.INVOICE_REFERENCE
            AND XXBCM_INVOICE_TBL.ORDER_REF = XXBCM_ORDER_MGT.ORDER_REF
        )
        AND INVOICE_REFERENCE IS NOT NULL
        AND REGEXP_LIKE(INVOICE_AMOUNT, '^\d+$');

  BEGIN
    FOR supplier IN C1 LOOP
      INSERT INTO XXBCM_SUPPLIER_TBL (
        SUPPLIER_NAME,
        FIRST_NAME,
        LAST_NAME,
        SUPP_ADDRESS,
        TEL_NUMBER,
        MOBILE_NUMBER,
        SUPP_EMAIL_ADD
      ) VALUES (
        supplier.SUPPLIER_NAME,
        supplier.FIRST_NAME,
        supplier.LAST_NAME,
        supplier.SUPP_ADDRESS,
        supplier.TEL_NUMBER,
        supplier.MOBILE_PHONE,
        supplier.SUPP_EMAIL
      );
    END LOOP;

    FOR order_rec IN C2 LOOP
      INSERT INTO XXBCM_ORDER_TBL (
        ORDER_REF,
        SUPPLIER_NAME,
        ORDER_DATE,
        ORDER_TOTAL_AMOUNT,
        ORDER_DESCRIPTION,
        ORDER_STATUS,
        ORDER_LINE_AMOUNT
      ) VALUES (
        order_rec.ORDER_REF,
        order_rec.SUPPLIER_NAME,
        order_rec.ORDER_DATE,
        order_rec.ORDER_TOTAL_AMOUNT,
        order_rec.ORDER_DESCRIPTION,
        order_rec.ORDER_STATUS,
        order_rec.ORDER_LINE_AMOUNT
      );
    END LOOP;

    FOR invoice IN C3 LOOP
      INSERT INTO XXBCM_INVOICE_TBL (
        INVOICE_REFERENCE,
        ORDER_REF,
        INVOICE_DATE,
        INVOICE_STATUS,
        INVOICE_HOLD_REASON,
        INVOICE_AMOUNT,
        INVOICE_DESCRIPTION
      ) VALUES (
        invoice.INVOICE_REFERENCE,
        invoice.ORDER_REF,
        invoice.INVOICE_DATE,
        invoice.INVOICE_STATUS,
        invoice.INVOICE_HOLD_REASON,
        invoice.INVOICE_AMOUNT,
        invoice.INVOICE_DESCRIPTION
      );
    END LOOP;

    COMMIT;
  END INSERT_DATA;
END PR_TABLE_DATA;

--EXEC PR_TABLE_DATA.INSERT_DATA;

To run migration procedure, execute EXEC PR_TABLE_DATA.INSERT_DATA;



Q4 Listing of distinct invoices and their total amount

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE REPORT_ORDER_SUMMARY IS

    CURSOR order_cursor IS
        SELECT 
            o.ORDER_REF, 
            TO_CHAR(o.ORDER_DATE, 'MON-YYYY') AS ORDER_PERIOD,
            INITCAP(o.SUPPLIER_NAME) AS SUPPLIER_NAME,
            TO_CHAR(o.ORDER_TOTAL_AMOUNT, '99,999,990.00') AS ORDER_TOTAL_AMOUNT,
            o.ORDER_STATUS,
            i.INVOICE_REFERENCE,
            TO_CHAR(i.INVOICE_AMOUNT, '99,999,990.00') AS INVOICE_TOTAL_AMOUNT,
            o.ORDER_DATE
        FROM XXBCM_ORDER_TBL o
        JOIN XXBCM_INVOICE_TBL i ON o.ORDER_REF = i.ORDER_REF
        ORDER BY o.ORDER_DATE DESC;

    v_action VARCHAR2(20);

BEGIN
    DBMS_OUTPUT.PUT_LINE('Order Reference | Order Period | Supplier Name | Order Total Amount | Order Status | Invoice Reference | Invoice Total Amount | Action');
    FOR rec IN order_cursor LOOP
        -- Determining the action based on invoice status
        SELECT CASE 
                   WHEN COUNT(CASE WHEN INVOICE_STATUS = 'Paid' THEN 1 END) = COUNT(*) THEN 'OK'
                   WHEN COUNT(CASE WHEN INVOICE_STATUS = 'Pending' THEN 1 END) > 0 THEN 'To follow up'
                   WHEN COUNT(CASE WHEN INVOICE_STATUS IS NULL OR INVOICE_STATUS = '' THEN 1 END) > 0 THEN 'To verify'
                   ELSE 'Check data'
               END INTO v_action
        FROM XXBCM_INVOICE_TBL
        WHERE ORDER_REF = rec.ORDER_REF;

        DBMS_OUTPUT.PUT_LINE(
            SUBSTR(rec.ORDER_REF, 3) || ' | ' ||
            rec.ORDER_PERIOD || ' | ' ||
            rec.SUPPLIER_NAME || ' | ' ||
            rec.ORDER_TOTAL_AMOUNT || ' | ' ||
            rec.ORDER_STATUS || ' | ' ||
            rec.INVOICE_REFERENCE || ' | ' ||
            rec.INVOICE_TOTAL_AMOUNT || ' | ' ||
            v_action
        );
    END LOOP;

END REPORT_ORDER_SUMMARY;

--EXEC REPORT_ORDER_SUMMARY;

Explanation:
Cursor Definition: The cursor fetches data by joining XXBCM_ORDER_TBL and XXBCM_INVOICE_TBL, ensuring the data is ordered by the most recent order date.
Action Calculation: For each order, it determines the appropriate action based on the status of all related invoices.
Output Formatting: It formats the output as specified, including the action status and monetary values.
Output:

To run the procedure, execute EXEC REPORT_ORDER_SUMMARY;

 








Q5 Listing of the SECOND (2nd) highest Order Total Amount
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE REPORT_SECOND_HIGHEST_ORDER IS
    v_order_ref VARCHAR2(100);
    v_order_date DATE;
    v_supplier_name VARCHAR2(1000);
    v_order_total_amount NUMBER;
    v_order_status VARCHAR2(100);
    v_invoice_references VARCHAR2(4000);

BEGIN
    -- Query to find the second highest order total amount
    SELECT o.ORDER_REF, o.ORDER_DATE, UPPER(o.SUPPLIER_NAME) AS SUPPLIER_NAME, 
           o.ORDER_TOTAL_AMOUNT, o.ORDER_STATUS
      INTO v_order_ref, v_order_date, v_supplier_name, v_order_total_amount, v_order_status
      FROM XXBCM_ORDER_TBL o
      WHERE o.ORDER_TOTAL_AMOUNT = (
          SELECT MAX(ORDER_TOTAL_AMOUNT) 
          FROM XXBCM_ORDER_TBL
          WHERE ORDER_TOTAL_AMOUNT < (
              SELECT MAX(ORDER_TOTAL_AMOUNT) FROM XXBCM_ORDER_TBL
          )
      ) AND ROWNUM = 1;  -- Ensuring only one record is fetched

    -- Get all invoice references for the identified order in a pipe-delimited string
    SELECT LISTAGG(i.INVOICE_REFERENCE, '|') WITHIN GROUP (ORDER BY i.INVOICE_REFERENCE)
      INTO v_invoice_references
      FROM XXBCM_INVOICE_TBL i
      WHERE i.ORDER_REF = v_order_ref;

    -- Output the formatted data
    DBMS_OUTPUT.PUT_LINE('Order Reference: ' || SUBSTR(v_order_ref, 3));  -- Removes "PO" prefix
    DBMS_OUTPUT.PUT_LINE('Order Date: ' || TO_CHAR(v_order_date, 'fmMonth DD, YYYY'));
    DBMS_OUTPUT.PUT_LINE('Supplier Name: ' || v_supplier_name);
    DBMS_OUTPUT.PUT_LINE('Order Total Amount: ' || TO_CHAR(v_order_total_amount, '99,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Order Status: ' || v_order_status);
    DBMS_OUTPUT.PUT_LINE('Invoice References: ' || v_invoice_references);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for the second highest order.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END REPORT_SECOND_HIGHEST_ORDER;

--EXEC REPORT_SECOND_HIGHEST_ORDER;


Explanation:
Second Highest Order: The procedure first identifies the second highest ORDER_TOTAL_AMOUNT using a nested SELECT statement that excludes the highest amount.
Invoice References: Using the LISTAGG function, it compiles all related invoice references into a pipe-delimited string.
Data Extraction and Formatting: Fetches all required details for the order and formats them as specified.
Exception Handling: Includes basic error handling for scenarios where no data matches the criteria or other errors occur.
Output:

To run the procedure, execute REPORT_SECOND_HIGHEST_ORDER;
 










Q6 Listing of all suppliers with their respective number of orders and total amount ordered from them between the period of 01 January 2022 and 31 August 2022.

SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE REPORT_SUPPLIER_ORDERS IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Supplier Name | Supplier Contact Name | Contact No. 1 | Contact No. 2 | Total Orders | Order Total Amount');

    FOR rec IN (
        SELECT 
            s.SUPPLIER_NAME,
            s.FIRST_NAME || ' ' || s.LAST_NAME AS CONTACT_NAME,
            REGEXP_REPLACE(s.TEL_NUMBER, '(\d{3})(\d{4})', '\1-\2') AS CONTACT_NO_1,
            REGEXP_REPLACE(s.MOBILE_NUMBER, '(\d{4})(\d{4})', '\1-\2') AS CONTACT_NO_2,
            COUNT(o.ORDER_ID) AS TOTAL_ORDERS,
            TO_CHAR(SUM(o.ORDER_TOTAL_AMOUNT), '99,999,990.00') AS ORDER_TOTAL_AMOUNT
        FROM XXBCM_SUPPLIER_TBL s
        JOIN XXBCM_ORDER_TBL o ON s.SUPPLIER_NAME = o.SUPPLIER_NAME
        WHERE o.ORDER_DATE BETWEEN DATE '2022-01-01' AND DATE '2022-08-31'
        GROUP BY s.SUPPLIER_NAME, s.FIRST_NAME, s.LAST_NAME, s.TEL_NUMBER, s.MOBILE_NUMBER
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.SUPPLIER_NAME || ' | ' ||
            rec.CONTACT_NAME || ' | ' ||
            rec.CONTACT_NO_1 || ' | ' ||
            rec.CONTACT_NO_2 || ' | ' ||
            rec.TOTAL_ORDERS || ' | ' ||
            rec.ORDER_TOTAL_AMOUNT
        );
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for the specified period.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END REPORT_SUPPLIER_ORDERS;


--EXEC REPORT_SUPPLIER_ORDERS;




Explanation:
Data Joining and Filtering: The procedure joins the supplier and order tables, filtering orders based on the specified date range.
Aggregation: It counts the number of orders and sums the total amounts per supplier.
Phone Number Formatting: Uses REGEXP_REPLACE to format contact numbers as specified.
Output Formatting: Constructs a string for each supplier that includes all required details and prints it using DBMS_OUTPUT.PUT_LINE.
Output:
To run the procedure, execute REPORT_SUPPLIER_ORDERS;
 

