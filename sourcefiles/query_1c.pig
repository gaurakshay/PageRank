--Use as:
--pig -x local -param tweets=1 -f query_1c.pig
-- Load twitter accounts file.
A = LOAD 'HW4-twitter_account.csv' USING PigStorage(',') as (id:int, email1:chararray, ph:chararray, loc:chararray, tweets:int);
-- Filter the twitter accounts with tweets greater than tweets passed as parameters.
B = FILTER A BY tweets>$tweets;
-- Load stackoverflow file.
C = LOAD 'HW4-stack_overflow_account.csv' USING PigStorage(',') AS (email2:chararray, rep:int, que:int);
-- Join filtered twitter accounts file with the stack overflow file using email.
D = JOIN B BY email1, C BY email2;
-- Group D for calculating average.
E = GROUP D ALL;
-- Find the average of the reputation.
F = FOREACH E GENERATE $tweets,AVG(D.rep);
-- Dump the output.
DUMP F;
