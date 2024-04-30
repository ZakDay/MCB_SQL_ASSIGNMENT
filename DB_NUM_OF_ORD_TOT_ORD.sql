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

