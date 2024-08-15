--*****PLEASE ENTER YOUR DETAILS BELOW*****
--T2-mns-select.sql

--Student ID: 33577161
--Student Name: Park Darin
--Unit Code: FIT2094
--Applied Class No: 01

/* Comments for your marker:




*/

/*2(a)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT item_id, item_desc, item_stdcost, item_stock
FROM mns.item
WHERE item_stock >= 50 AND UPPER(item_desc) LIKE '%COMPOSITE%'
ORDER BY item_stock DESC, item_id ASC;


/*2(b)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT 
    p.provider_code,
    CASE
        WHEN p.provider_title IS NOT NULL AND p.provider_fname IS NOT NULL AND p.provider_lname IS NOT NULL THEN
            p.provider_title || '. ' || p.provider_fname || ' ' || p.provider_lname 
        WHEN p.provider_title IS NOT NULL AND p.provider_lname IS NOT NULL THEN
            p.provider_title || '. ' || p.provider_lname 
        WHEN p.provider_title IS NOT NULL AND p.provider_fname IS NOT NULL THEN
            p.provider_title || '. ' || p.provider_fname 
        WHEN p.provider_fname IS NOT NULL AND p.provider_fname IS NOT NULL THEN
            p.provider_fname || ' ' || p.provider_fname 
        WHEN p.provider_title IS NOT NULL THEN
            p.provider_title
        WHEN p.provider_fname IS NOT NULL THEN
            p.provider_fname
        WHEN p.provider_lname IS NOT NULL THEN
            p.provider_lname
        ELSE ''
    END AS provider_name
FROM mns.provider p JOIN mns.specialisation s ON p.spec_id = s.spec_id
WHERE UPPER(s.spec_name) = 'PAEDIATRIC DENTISTRY'
ORDER BY p.provider_lname ASC, p.provider_fname ASC, p.provider_code ASC;


/*2(c)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT service_code, service_desc, lpad(TO_CHAR(service_stdfee, '$9,999.99'), 12, ' ') AS standard_fee
FROM mns.service
WHERE service_stdfee > (SELECT AVG(service_stdfee) FROM mns.service)
ORDER BY service_stdfee DESC, service_code ASC;


/*2(d)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answe

SELECT
    a.appt_no,
    TO_CHAR(a.appt_datetime, 'DD-MM-YYYY HH24:MI:SS') AS appt_datetime,
    a.patient_no,
    CASE
        WHEN p.patient_fname IS NOT NULL AND p.patient_lname IS NOT NULL THEN
            p.patient_fname || ' ' || p.patient_lname
        WHEN p.patient_fname IS NOT NULL THEN
            p.patient_fname
        WHEN p.patient_lname IS NOT NULL THEN
            p.patient_lname
        ELSE ''
    END AS patient_full_name,    
    lpad(TO_CHAR((SUM(asv.apptserv_fee) + SUM(asv.apptserv_itemcost)), '$99,999.99'), 11, ' ') AS total_cost
FROM mns.appointment a
JOIN mns.patient p ON a.patient_no = p.patient_no
LEFT JOIN mns.appt_serv asv ON a.appt_no = asv.appt_no
GROUP BY a.appt_no, a.appt_datetime, a.patient_no, p.patient_fname, p.patient_lname
HAVING (SUM(asv.apptserv_fee) + SUM(asv.apptserv_itemcost)) = (
    SELECT MAX(SUM(asv.apptserv_fee) + SUM(asv.apptserv_itemcost)) 
    FROM mns.appointment a
    LEFT JOIN mns.appt_serv asv ON a.appt_no = asv.appt_no
    GROUP BY a.appt_no
    )
ORDER BY appt_no ASC;


/*2(e)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT s.service_code,
  s.service_desc,
  lpad(TO_CHAR(s.service_stdfee, '$9,999.99'), 12, ' ') AS standard_fee,
  lpad(TO_CHAR((nvl((SELECT AVG(apptserv_fee) FROM mns.appt_serv asv WHERE s.service_code = asv.service_code),0) - s.service_stdfee), 's9,990.99'), 25, ' ') AS standard_fee_differential
FROM mns.service s
GROUP BY s.service_code, s.service_desc, s.service_stdfee
ORDER BY s.service_code;


/*2(f)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT
    p.patient_no,
    CASE
        WHEN p.patient_fname IS NOT NULL AND p.patient_lname IS NOT NULL THEN
            p.patient_fname || ' ' || p.patient_lname
        WHEN p.patient_fname IS NOT NULL THEN
            p.patient_fname
        WHEN p.patient_lname IS NOT NULL THEN
            p.patient_lname
        ELSE ''
    END AS patientname,    
    lpad(TO_CHAR( EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM p.patient_dob), '999'), 10, ' ') AS currentage,
    ( SELECT COUNT(a.appt_no) FROM mns.appointment a WHERE a.patient_no = p.patient_no )AS numappts,
    lpad(to_char(nvl(
    ((SELECT COUNT(a.appt_prior_apptno) FROM mns.appointment a WHERE a.patient_no = p.patient_no AND a.appt_prior_apptno IS NOT NULL)/
    (SELECT COUNT(a.appt_no) FROM mns.appointment a WHERE a.patient_no = p.patient_no ) * 100), 0), '990.9'), 8, ' ') || '%' AS followups
FROM mns.patient p
ORDER BY p.patient_no;


/*2(g)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT
    lpad(p.provider_code, 6, ' ') AS pcode, 
    CASE
        WHEN COUNT(a.appt_no) > 0 THEN lpad(TO_CHAR(COUNT(a.appt_no)), 11, ' ')
        ELSE lpad('-', 11, ' ')
    END AS numberappts,    
    lpad(
        nvl(TO_CHAR((SELECT SUM(nvl(apptserv_fee, 0)) + SUM(nvl(apptserv_itemcost, 0)) 
        FROM (mns.appointment b  LEFT OUTER JOIN mns.appt_serv c ON b.appt_no = c.appt_no) 
        WHERE b.provider_code = p.provider_code AND appt_datetime BETWEEN to_date('10/09/2023 09:00', 'dd/mm/yyyy hh24:mi') AND to_date('14/09/2023 17:00', ' dd/mm/yyyy hh24:mi')), '$9,990.99'),'-'), 10,' ') AS totalfees ,
    lpad(
        nvl(TO_CHAR(SUM((SELECT SUM(as_item_quantity) 
        FROM((mns.appointment x LEFT OUTER JOIN mns.appt_serv y ON x.appt_no = y.appt_no) LEFT OUTER JOIN mns.apptservice_item z ON y.appt_no = z.appt_no AND y.service_code = z.service_code) 
        WHERE y.appt_no = a.appt_no AND appt_datetime BETWEEN to_date('10/09/2023 09:00', 'dd/mm/yyyy hh24:mi') AND to_date('14/09/2023 17:00','dd/mm/yyyy hh24:mi')))),'-'),7,' ') AS noitems
FROM mns.appointment a RIGHT OUTER JOIN mns.provider p ON a.provider_code = p.provider_code AND a.appt_datetime >= to_date('2023-09-10 09:00:00', 'YYYY-MM-DD HH24:MI:SS') AND a.appt_datetime <= to_date('2023-09-14 17:00:00', 'YYYY-MM-DD HH24:MI:SS')
GROUP BY p.provider_code
ORDER BY p.provider_code;
