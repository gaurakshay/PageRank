-- Delete directory that will be used to store new ranks if they already exist:
rmf newranks;

-- Load twitter rank file.
rank_details = LOAD 'HW4-old_twitter_account_rank.csv' USING PigStorage(',') AS (id:int, rank:double);

-- Load association file to find who follows who.
assoc_details = LOAD 'HW4-follows_account.csv' USING PigStorage(',') AS (follower:int, subject:int);

-- Group the assoc file to find out the sinks.
group_all = GROUP assoc_details ALL;

-- Get the distinct followers.
followers = FOREACH group_all {
    dis_follower = DISTINCT assoc_details.follower;
    GENERATE dis_follower AS fol;
    };
followers = FOREACH followers GENERATE FLATTEN (fol.follower) AS follower;

-- Get the distinct subjects;
subjects = FOREACH group_all {
    dis_subject = DISTINCT assoc_details.subject;
    GENERATE dis_subject AS sub;
    };
subjects = FOREACH subjects GENERATE FLATTEN (sub.subject) AS subject;

-- Every subject should be a follower of somebody. If the subject is not a follower then it is a sink.
not_sinks = JOIN followers BY follower FULL, subjects BY subject;
not_sinks = FILTER not_sinks BY follower is not null;
not_sinks = FOREACH not_sinks GENERATE follower as t_id;

-- Filter out the subjects that are sinks so that the counts of the subjects for any follower omits them (we are eliminating sinks).
assoc_details_foll = JOIN assoc_details BY subject, not_sinks BY t_id;
assoc_details_foll = FOREACH assoc_details_foll GENERATE assoc_details::follower as follower, assoc_details::subject  as subject;

-- Group the subjects for each follower to count the number of subjects for each twitter id.
group_by_follower = GROUP assoc_details_foll BY follower;

-- Find total outlinks (subjects) of each follower and eliminate those followers who are sinks (this should not be necessary, but just making sure.)
subject_count = FOREACH group_by_follower GENERATE group AS follower, COUNT(assoc_details_foll.subject) as sub_count;
subject_count = JOIN subject_count BY follower, not_sinks BY t_id;
subject_count = FOREACH subject_count GENERATE subject_count::follower, subject_count::sub_count;

-- Use the group created in preceeding step to count the number of ids present.
n = DISTINCT not_sinks;
n = GROUP n ALL;
n = FOREACH n GENERATE COUNT(n.t_id) as total_count;
-- Total number of ids (207)

-- Generate the constant to be added to each rank that will be calculated (pre_add).
pre_add = FOREACH n GENERATE (1.0-0.85)/(double)total_count AS constnt;

-- JOIN the count of subjects with the old rank for each twitter id
follower_rank_subject = JOIN subject_count BY follower, rank_details BY id;

-- Create the ratio of rank vs number of subjects for each twitter id.
follower_ratio = FOREACH follower_rank_subject GENERATE subject_count::follower AS follower, rank_details::rank/subject_count::sub_count AS ratio;

-- Join each follower and it ratio generated in the preceeding step with the subject-follower pairs in the follows_account file.
join_followers_ratio = JOIN assoc_details BY follower, follower_ratio BY follower;

-- Filter out the subjects that are sinks.
join_followers_ratio = JOIN join_followers_ratio BY assoc_details::subject, not_sinks BY t_id;
join_followers_ratio = FOREACH join_followers_ratio GENERATE join_followers_ratio::assoc_details::subject AS subject, join_followers_ratio::assoc_details::follower as follower, join_followers_ratio::follower_ratio::ratio as ratio;

-- Group by subjects so that we can sum all the ratios.
group_subjects = GROUP join_followers_ratio BY subject;

-- Generate the sum of the ratios of all the followers of an account (tot_ratio).
post_add = FOREACH group_subjects GENERATE group AS subject, SUM(join_followers_ratio.ratio) AS tot_ratio;

-- Calculate final account by adding the pre_add to tot_ratio
final_rank = FOREACH post_add GENERATE subject, pre_add.constnt + (0.85*tot_ratio);
--DUMP final_rank;

-- Store the data on a file (directory = newranks).
STORE final_rank INTO 'newranks' USING PigStorage(',');

-- Remove the old account rank file using shell command rm.
sh rm HW4-old_twitter_account_rank.csv;

-- Move the newly generated file in the "newranks" directory and save it with the name provided.
sh mv ./newranks/p* ./HW4-old_twitter_account_rank.csv;

-- Delete the directory generated while storing the ranks for a cleaner output.
rmf newranks;
