--RUN WITH:
--pig -x local -param percentile=95 -f find_ninety_nine_percentile_accounts.pig

-- Load rank file and the twitter account details file.
ranks = LOAD 'HW4-old_twitter_account_rank.csv' USING PigStorage(',') AS (id:int, rank:double);
acc_details = LOAD 'HW4-twitter_account.csv' USING PigStorage(',') AS (id:int, email:chararray, ph:chararray, loc:chararray, tweets:int);

-- Order the rank file by the order of the ranks.
ranks = ORDER ranks BY rank;

-- Assign rank to the rows.
ranks = RANK ranks;

-- Find the total number of ids to calculate the percentile for.
tot_id = GROUP ranks ALL;
tot_id = FOREACH tot_id GENERATE COUNT(ranks.id) as num_id;

-- Calculate the percentile.
percentile = FOREACH tot_id GENERATE FLOOR(((double)$percentile/100.0)*(double)num_id) as rank_filter;

-- Use the percentile to filter the accounts that match the criteria.
k_percentile = FILTER ranks BY rank_ranks >= percentile.rank_filter;

-- Join the filtered ids with the details from the account details file.
details = JOIN k_percentile BY id, acc_details BY id;

-- Remove the extra columns.
details = FOREACH details GENERATE acc_details::id AS id, acc_details::email AS email, k_percentile::rank AS rank;

-- Manipulation to show the result as listed in the requirements.
details = GROUP details ALL;
details = FOREACH details GENERATE details;
DUMP details;
