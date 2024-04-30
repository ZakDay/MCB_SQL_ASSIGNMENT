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