-- =============================================================================================
-- Assignment 2: Predict hotel cancellations
-- Name:
--
-- How to use this file
--   * Run ONE block at a time: select its lines with the mouse, then click Run.
--   * Where you see ___ (three underscores), replace it with the right word or number first.
--     BigQuery gives an error if a ___ is still there (the error says: Unrecognized name: ___).
--   * Text after -- is a comment. BigQuery does not run it. Read the comments: they explain the code.
--   * A CREATE MODEL can take 1 to 3 minutes. Wait until it finishes before you run the next block.
--   * Keep every query you run in this file, and hand it in.
-- =============================================================================================


-- =============================================================================================
-- Block 0. The three groups (run once, as it is)
-- =============================================================================================
-- A view is a saved query: it does not copy the data, it just remembers the SELECT.
-- ROW_NUMBER() numbers the bookings 1, 2, 3 ... in booking_id order (D10).
-- MOD(number, 5) is the remainder after dividing by 5, so it is always 0, 1, 2, 3 or 4.
-- Remainder 3 -> validation, remainder 4 -> test, all others -> train.
-- Because booking_id never changes, every booking stays in the same group every time (D14).
CREATE OR REPLACE VIEW ml.hotel_groups AS
SELECT
  *,
  CASE MOD(ROW_NUMBER() OVER (ORDER BY booking_id), 5)
    WHEN 3 THEN 'validation'
    WHEN 4 THEN 'test'
    ELSE 'train'
  END AS split
FROM ml.hotel_bookings;

-- Check: you should see test 23,878 · train 71,634 · validation 23,878
SELECT split, COUNT(*) AS bookings
FROM ml.hotel_groups
GROUP BY split
ORDER BY split;


-- =============================================================================================
-- Part 1. Understand the data with SQL
-- =============================================================================================

-- 1.1 How many bookings are there? (one row per hotel)
SELECT
  hotel,
  COUNT(*) AS bookings,
  MIN(arrival_date_year) AS first_year,
  MAX(___) AS last_year                 -- ___ : the same column as in MIN
FROM ml.hotel_bookings
GROUP BY ___;                           -- ___ : the column you want one row for

-- 1.2 How many bookings are cancelled?
-- is_canceled is 1 (cancelled) or 0 (the guest came), so:
--   SUM(is_canceled) = the number of cancelled bookings
--   AVG(is_canceled) = the share of cancelled bookings (0.37 means 37%)
-- First, both hotels together (one row):
SELECT
  COUNT(*) AS bookings,
  SUM(is_canceled) AS cancelled,
  ROUND(AVG(is_canceled) * 100, 1) AS cancel_pct
FROM ml.hotel_bookings;

-- Then, one row for each hotel: copy the query above, add the hotel column to SELECT,
-- and add GROUP BY hotel before the ; at the end.
-- your query


-- 1.3 Does a deposit stop people from cancelling?
SELECT
  deposit_type,
  COUNT(*) AS bookings,
  ROUND(AVG(___) * 100, 1) AS cancel_pct    -- ___ : the column that says if a booking was cancelled
FROM ml.hotel_bookings
GROUP BY ___
ORDER BY bookings DESC;

-- 1.4 Do people who book early cancel more?
-- CASE checks the conditions from top to bottom and stops at the first one that is true (D04).
-- The numbers at the start of each band ('1: ', '2: ' ...) make ORDER BY sort the bands in the right order.
SELECT
  CASE
    WHEN lead_time <= 7   THEN '1: 0-7 days'
    WHEN lead_time <= 30  THEN '2: 8-30 days'
    WHEN lead_time <= ___ THEN '3: 31-90 days'      -- ___ : the last day of this band
    WHEN lead_time <= 180 THEN '4: 91-180 days'
    WHEN lead_time <= ___ THEN '5: 181-365 days'    -- ___ : the last day of this band
    ELSE '6: over a year'
  END AS lead_band,
  COUNT(*) AS bookings,
  ROUND(AVG(is_canceled) * 100, 1) AS cancel_pct
FROM ml.hotel_bookings
GROUP BY lead_band
ORDER BY lead_band;

-- 1.5 Can we trust the prices?  (two queries, two screenshots)
-- Query 1: price checks. COUNTIF(condition) counts the rows where the condition is true.
SELECT
  MIN(adr) AS lowest_price,
  MAX(adr) AS highest_price,
  ROUND(AVG(adr), 2) AS average_price,
  COUNTIF(adr < 0) AS below_zero,
  COUNTIF(adr = 0) AS exactly_zero,
  COUNTIF(adr > 1000) AS over_1000,
  COUNTIF(adults = 0) AS no_adults,
  COUNTIF(stays_in_weekend_nights + stays_in_week_nights = 0) AS zero_nights
FROM ml.hotel_bookings;

-- Query 2: the average price for each month, one column for each hotel.
-- Only bookings where the guest came (is_canceled = 0) and the price is real.
-- IF(condition, value, NULL) keeps the price only for one hotel; AVG skips the NULLs.
SELECT
  arrival_date_month,
  ROUND(AVG(IF(hotel = 'Resort Hotel', adr, NULL)), 1) AS resort_price,
  ROUND(AVG(IF(hotel = 'City Hotel', adr, NULL)), 1) AS city_price
FROM ml.hotel_bookings
WHERE is_canceled = 0 AND adr > 0 AND adr < 1000
GROUP BY arrival_date_month
ORDER BY resort_price DESC;


-- =============================================================================================
-- Block 2. Evidence for question 2.2 (run as they are, three screenshots)
-- =============================================================================================
-- Query 1: reservation_status against is_canceled. Look at which statuses have is_canceled = 1.
SELECT reservation_status, is_canceled, COUNT(*) AS bookings
FROM ml.hotel_bookings
GROUP BY reservation_status, is_canceled
ORDER BY reservation_status;

-- Query 2: guests who asked for a parking space, against guests who did not.
-- (required_car_parking_spaces > 0) is TRUE or FALSE, so it makes two groups.
SELECT
  required_car_parking_spaces > 0 AS asked_for_parking,
  COUNT(*) AS bookings,
  ROUND(AVG(is_canceled) * 100, 1) AS cancel_pct
FROM ml.hotel_bookings
GROUP BY asked_for_parking;

-- Query 3: guests who got the room type they booked, against guests who got a different one.
SELECT
  reserved_room_type = assigned_room_type AS got_the_room_booked,
  COUNT(*) AS bookings,
  ROUND(AVG(is_canceled) * 100, 1) AS cancel_pct
FROM ml.hotel_bookings
GROUP BY got_the_room_booked;


-- =============================================================================================
-- Part 3.1 Cancellations (classification)
-- =============================================================================================

-- Block 3.1a. The consultant's model: EVERY column.
-- SELECT * EXCEPT (...) means "all columns except these". We drop booking_id (just a number),
-- split (our group name) and reservation_status_date (a date, kept out to keep it simple).
-- data_split_method = 'NO_SPLIT' means: train on all the rows I give you. We already chose the train rows.
CREATE OR REPLACE MODEL ml.cancel_everything
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['is_canceled'], data_split_method = 'NO_SPLIT') AS
SELECT * EXCEPT (booking_id, split, reservation_status_date)
FROM ml.hotel_groups
WHERE split = 'train';

-- Check the consultant's model on the validation rows. Write down the accuracy.
SELECT *
FROM ML.EVALUATE(MODEL ml.cancel_everything,
  (SELECT * FROM ml.hotel_groups WHERE split = 'validation'));


-- Block 3.1b. Your model: only columns the hotel knows on the day of booking.
-- (Compare this list with your answers to 2.2.)
-- arrival_date_year is not here either: next month's bookings will have a new year the model has never seen.
-- agent and company are not here: they are ID numbers, and agent 240 is not "more" than agent 9.
CREATE OR REPLACE MODEL ml.cancel_honest
OPTIONS (model_type = 'LOGISTIC_REG', input_label_cols = ['is_canceled'], data_split_method = 'NO_SPLIT') AS
SELECT
  is_canceled,                                               -- the label: what the model learns to predict
  hotel, lead_time, arrival_date_month,                      -- where, how early, which month
  stays_in_weekend_nights, stays_in_week_nights,             -- how long
  adults, children, babies, meal,                            -- who, and the meal package
  market_segment, distribution_channel, customer_type,       -- who sold the booking, and the kind of customer
  is_repeated_guest, previous_cancellations, previous_bookings_not_canceled,   -- the guest's history
  reserved_room_type, deposit_type, adr                      -- the room booked, the deposit, the price
FROM ml.hotel_groups
WHERE split = 'train';

-- Your model on the validation rows: write down accuracy, precision and recall.
-- The default threshold is 0.5: probability 0.5 or more counts as "will cancel".
SELECT *
FROM ML.EVALUATE(MODEL ml.cancel_honest,
  (SELECT * FROM ml.hotel_groups WHERE split = 'validation'));


-- Block 3.1c. Three checks
-- Check 1: how often is the simple guess "nobody cancels" right? It is right for every booking with is_canceled = 0.
SELECT ROUND(COUNTIF(is_canceled = 0) / COUNT(*) * 100, 1) AS nobody_cancels_right_pct
FROM ml.hotel_groups
WHERE split = 'validation';

-- Check 2: which bookings is the model very sure WILL CANCEL (probability 0.9 or more)?
-- The result has one row for each deposit type: add the rows together for the total.
-- ML.PREDICT gives, for each booking, a list of two probabilities: one for label 0 and one for label 1.
-- The small SELECT ... FROM UNNEST(...) WHERE label = 1 takes out the probability of "will cancel".
WITH scored AS (
  SELECT
    booking_id, deposit_type, is_canceled,
    (SELECT prob FROM UNNEST(predicted_is_canceled_probs) WHERE label = 1) AS p_cancel
  FROM ML.PREDICT(MODEL ml.cancel_honest,
    (SELECT * FROM ml.hotel_groups WHERE split = 'validation'))
)
SELECT deposit_type, COUNT(*) AS very_sure_bookings
FROM scored
WHERE p_cancel >= 0.9                   -- only the bookings with a probability of 0.9 or more
GROUP BY deposit_type
ORDER BY very_sure_bookings DESC;

-- Check 3: No Deposit bookings only. First the model, then the simple guess, on the same rows.
SELECT *
FROM ML.EVALUATE(MODEL ml.cancel_honest,
  (SELECT * FROM ml.hotel_groups WHERE split = 'validation' AND deposit_type = 'No Deposit'));

SELECT ROUND(COUNTIF(is_canceled = 0) / COUNT(*) * 100, 1) AS nobody_cancels_right_pct
FROM ml.hotel_groups
WHERE split = 'validation' AND deposit_type = 'No Deposit';


-- Block 3.1d. What does each threshold cost the hotel? (run as it is)
-- UNNEST([0.3, 0.4, ...]) makes a small list of thresholds; CROSS JOIN repeats every booking for every threshold.
-- guests_with_no_room: the model said "will cancel" (p_cancel >= threshold) but the guest came  -> €200 each
-- empty_rooms:         the model said "will come"   (p_cancel <  threshold) but the guest cancelled -> €100 each
WITH scored AS (
  SELECT
    is_canceled,
    (SELECT prob FROM UNNEST(predicted_is_canceled_probs) WHERE label = 1) AS p_cancel
  FROM ML.PREDICT(MODEL ml.cancel_honest,
    (SELECT * FROM ml.hotel_groups WHERE split = 'validation'))
)
SELECT
  threshold,
  ROUND(COUNTIF((p_cancel >= threshold) = (is_canceled = 1)) / COUNT(*), 3) AS accuracy,
  COUNTIF(p_cancel >= threshold AND is_canceled = 0) AS guests_with_no_room,
  COUNTIF(p_cancel < threshold AND is_canceled = 1) AS empty_rooms,
  COUNTIF(p_cancel >= threshold AND is_canceled = 0) * 200
    + COUNTIF(p_cancel < threshold AND is_canceled = 1) * 100 AS cost_eur
FROM scored
CROSS JOIN UNNEST([0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]) AS threshold
GROUP BY threshold
ORDER BY threshold;


-- Block 3.1e. The test, ONE time only. Write your chosen threshold in place of ___:
-- a number from 0.3 to 0.9, the one with the lowest cost in Block 3.1d.
SELECT *
FROM ML.EVALUATE(MODEL ml.cancel_honest,
  (SELECT * FROM ml.hotel_groups WHERE split = 'test'),
  STRUCT(___ AS threshold));


-- =============================================================================================
-- Part 3.2 Prices (regression)
-- =============================================================================================

-- Block 3.2a. The price model. The label is adr (price per night).
-- WHERE adr > 0 AND adr < 1000 leaves out free rooms, the negative price and the 5,400 price (see 1.5).
CREATE OR REPLACE MODEL ml.price_clean
OPTIONS (model_type = 'LINEAR_REG', input_label_cols = ['adr'], data_split_method = 'NO_SPLIT') AS
SELECT
  adr,
  hotel, arrival_date_month, reserved_room_type,
  adults, children, babies, meal,
  market_segment, distribution_channel, customer_type,
  lead_time, stays_in_weekend_nights, stays_in_week_nights,
  is_repeated_guest, total_of_special_requests
FROM ml.hotel_groups
WHERE split = 'train' AND adr > 0 AND adr < 1000;

-- The price model on the validation rows: write down mean_absolute_error (MAE) and r2_score (R²).
SELECT *
FROM ML.EVALUATE(MODEL ml.price_clean,
  (SELECT * FROM ml.hotel_groups WHERE split = 'validation' AND adr > 0 AND adr < 1000));


-- Block 3.2b. Two simple guesses (run as they are)
-- Guess 1: "every room costs the average price of the training rows".
-- The CTE (WITH ...) works out one number, the average; CROSS JOIN puts it next to every validation row.
-- ABS(actual - guess) is the miss in euros, always positive; AVG of the misses is the MAE.
WITH train AS (
  SELECT AVG(adr) AS avg_price
  FROM ml.hotel_groups
  WHERE split = 'train' AND adr > 0 AND adr < 1000
)
SELECT ROUND(AVG(ABS(v.adr - t.avg_price)), 2) AS mae_average_guess
FROM ml.hotel_groups AS v
CROSS JOIN train AS t
WHERE v.split = 'validation' AND v.adr > 0 AND v.adr < 1000;

-- Guess 2: "every room costs the average price of that hotel in that month".
-- The CTE makes a small table: one average price for each hotel and month (24 rows).
-- JOIN ... USING (hotel, arrival_date_month) gives each validation booking the average for its hotel and month.
WITH rule AS (
  SELECT hotel, arrival_date_month, AVG(adr) AS rule_price
  FROM ml.hotel_groups
  WHERE split = 'train' AND adr > 0 AND adr < 1000
  GROUP BY hotel, arrival_date_month
)
SELECT ROUND(AVG(ABS(v.adr - r.rule_price)), 2) AS mae_hotel_month_guess
FROM ml.hotel_groups AS v
JOIN rule AS r USING (hotel, arrival_date_month)
WHERE v.split = 'validation' AND v.adr > 0 AND v.adr < 1000;


-- Block 3.2c. Where is the price model wrong? The resort in August and in January.
-- ML.PREDICT adds a column predicted_adr to every row. Then we compare the averages.
SELECT
  arrival_date_month,
  COUNT(*) AS bookings,
  ROUND(AVG(adr), 2) AS actual_average_price,
  ROUND(AVG(predicted_adr), 2) AS predicted_average_price
FROM ML.PREDICT(MODEL ml.price_clean,
  (SELECT * FROM ml.hotel_groups WHERE split = 'validation' AND adr > 0 AND adr < 1000))
WHERE hotel = 'Resort Hotel' AND arrival_date_month IN ('August', 'January')
GROUP BY arrival_date_month;


-- =============================================================================================
-- Part 3.3 Guests (clustering)
-- =============================================================================================

-- Block 3.3. Four segments with k-means (D13). Only bookings where the guest came, with a real price.
-- k-means has no label and no right answer to test, so it uses all these bookings, not only the train rows.
-- There is no label: k-means finds groups of similar bookings by itself.
-- standardize_features = TRUE puts all columns on the same scale, so euros do not count more than nights.
-- kmeans_init_method = 'KMEANS++' chooses good starting points.
CREATE OR REPLACE MODEL ml.guests_k4
OPTIONS (model_type = 'KMEANS', num_clusters = 4, kmeans_init_method = 'KMEANS++', standardize_features = TRUE) AS
SELECT
  lead_time,                                                 -- days booked before arrival
  stays_in_weekend_nights + stays_in_week_nights AS nights,  -- length of stay
  adults,
  IFNULL(children, 0) + babies AS kids,                      -- IFNULL: 4 bookings have no children value
  adr,                                                       -- price per night
  total_of_special_requests
FROM ml.hotel_bookings
WHERE is_canceled = 0 AND adr > 0 AND adr < 1000;

-- The segments in normal units (days, nights, euros), plus who they are (share at the resort, groups, companies).
-- centroid_id is the segment number that ML.PREDICT gives each booking.
SELECT
  centroid_id AS segment,
  COUNT(*) AS bookings,
  ROUND(AVG(lead_time), 0) AS avg_days_booked_before,
  ROUND(AVG(nights), 1) AS avg_nights,
  ROUND(AVG(adults), 1) AS avg_adults,
  ROUND(AVG(kids), 2) AS avg_kids,
  ROUND(AVG(adr), 0) AS avg_price,
  ROUND(AVG(total_of_special_requests), 1) AS avg_requests,
  ROUND(COUNTIF(hotel = 'Resort Hotel') / COUNT(*) * 100, 0) AS pct_resort,
  ROUND(COUNTIF(market_segment = 'Groups') / COUNT(*) * 100, 0) AS pct_groups,
  ROUND(COUNTIF(market_segment = 'Corporate') / COUNT(*) * 100, 0) AS pct_companies,
  ROUND(COUNTIF(arrival_date_month IN ('July', 'August')) / COUNT(*) * 100, 0) AS pct_july_august
FROM ML.PREDICT(MODEL ml.guests_k4,
  (SELECT
     *,
     stays_in_weekend_nights + stays_in_week_nights AS nights,
     IFNULL(children, 0) + babies AS kids
   FROM ml.hotel_bookings
   WHERE is_canceled = 0 AND adr > 0 AND adr < 1000))
GROUP BY segment
ORDER BY bookings DESC;


-- =============================================================================================
-- Bonus blocks (optional)
-- =============================================================================================

-- B1. Test your guess from 1.3: who makes the Non Refund bookings?
-- your query (hint: WHERE deposit_type = 'Non Refund', then GROUP BY market_segment;
--             show COUNT(*), AVG(lead_time) and the share with country = 'PRT')

-- B2. Explain one booking.
-- Step 1: find No Deposit validation bookings that your model says will cancel.
WITH scored AS (
  SELECT
    booking_id, deposit_type,
    (SELECT prob FROM UNNEST(predicted_is_canceled_probs) WHERE label = 1) AS p_cancel
  FROM ML.PREDICT(MODEL ml.cancel_honest,
    (SELECT * FROM ml.hotel_groups WHERE split = 'validation'))
)
SELECT booking_id, ROUND(p_cancel, 3) AS p_cancel
FROM scored
WHERE deposit_type = 'No Deposit' AND p_cancel >= 0.5
ORDER BY p_cancel DESC
LIMIT 10;
-- Step 2: choose one booking_id from that list and write it in place of ___.
-- top_k_features = 5 shows the 5 columns that pushed this prediction the most (D15).
SELECT *
FROM ML.EXPLAIN_PREDICT(MODEL ml.cancel_honest,
  (SELECT * FROM ml.hotel_groups WHERE booking_id = ___),
  STRUCT(5 AS top_k_features));

-- B3. Train the price model on all rows (no WHERE on adr), then find the lowest predicted price.
-- your CREATE OR REPLACE MODEL ml.price_all_rows ... (copy Block 3.2a and remove "AND adr > 0 AND adr < 1000")
-- then:
-- SELECT MIN(predicted_adr) AS lowest_price, COUNTIF(predicted_adr < 0) AS below_zero
-- FROM ML.PREDICT(MODEL ml.price_all_rows, (SELECT * FROM ml.hotel_groups WHERE split = 'validation'));

-- B4. Hidden leaks: copy Block 3.1b as ml.cancel_leaks, add the columns you marked Disagree in 2.2
--     (but NOT reservation_status), then evaluate on the validation rows.
-- your query

-- B5. Fix the month mistake: copy Block 3.2a as ml.price_hotel_month and add this line to the SELECT:
--   CONCAT(hotel, ' ', arrival_date_month) AS hotel_month,
-- To evaluate or predict, add the same column to the rows you give it:
--   (SELECT *, CONCAT(hotel, ' ', arrival_date_month) AS hotel_month FROM ml.hotel_groups WHERE ...)
-- your query

-- B6. Choose k: copy Block 3.3 as ml.guests_k3 (num_clusters = 3) and ml.guests_k5 (num_clusters = 5).
-- ML.EVALUATE on a k-means model needs no rows; it shows davies_bouldin_index (lower = more separate groups).
SELECT * FROM ML.EVALUATE(MODEL ml.guests_k4);
-- your queries for k = 3 and k = 5

-- B7. Nationality: copy Block 3.1b as ml.cancel_country, add country, evaluate on the validation rows.
-- your query
