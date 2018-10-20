--Use as:
--pig -x local -param code=717 -f query_1a.pig
-- Load twitter accounts.
A = LOAD 'HW4-twitter_account.csv' USING PigStorage(',') AS (id:int, email:chararray, ph:chararray, loc:chararray, tweets:int);
-- Group the twitter accounts by the first three digits of the phone number.
B = GROUP A BY SUBSTRING(ph,0,3);
-- Selection step. Filter the groups with the parameter passed.
C = FILTER B BY group=='$code';
-- Projection step, select only the group and the email. 
D = FOREACH C GENERATE group, A.email;
-- Dump the variable for the output.
DUMP D;
