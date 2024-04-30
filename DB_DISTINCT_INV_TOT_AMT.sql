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
