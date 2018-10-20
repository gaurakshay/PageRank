-- Load twitter accounts.
A = LOAD 'HW4-twitter_account.csv' USING PigStorage(',') AS (id:int, email:chararray, ph:chararray, loc:chararray, tweets:int);
-- Group the twitter accounts by location.
B = GROUP A BY loc;
-- Count the number of A in each group.
C = FOREACH B GENERATE group, COUNT(A);
-- Dump the variable for the output.
DUMP C;
