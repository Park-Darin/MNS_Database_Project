--*****PLEASE ENTER YOUR DETAILS BELOW*****
--T3-mns-json.sql

--Student ID: Park Darin 
--Student Name: 33577161
--Unit Code: FIT2094
--Applied Class No: 01

/* Comments for your marker:




*/

/*3(a)*/
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT TO GENERATE 
-- THE COLLECTION OF JSON DOCUMENTS HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT JSON_OBJECT ('_id' VALUE a.appt_no,
                    'datetime' VALUE to_char(a.appt_datetime,'dd/mm/yyyy hh24:mi'),
                    'provider_code' VALUE p.provider_code,
                    'provider_name' VALUE p.provider_title || '. ' || p.provider_fname || ' ' || p.provider_lname,
                    'item_totalcost' VALUE sum(ai.as_item_quantity * i.item_stdcost),
                    'no_of_items' VALUE count(ai.item_id),
                    'items' VALUE JSON_ARRAYAGG (
                    JSON_OBJECT('id' VALUE ai.item_id,
                                'desc' VALUE i.item_desc,
                                'standardcost' VALUE i.item_stdcost,
                                'quantity' VALUE ai.as_item_quantity)
                            )FORMAT JSON)
            || ',' 
            FROM mns.appointment a
            JOIN mns.provider p on a.provider_code = p.provider_code
            LEFT JOIN mns.apptservice_item ai on a.appt_no = ai.appt_no
            JOIN mns.item i on ai.item_id = i.item_id
            WHERE ai.item_id IS NOT NULL
            GROUP BY a.appt_no, appt_datetime, p.provider_code, provider_title, provider_fname, provider_lname
            ORDER BY a.appt_no;

