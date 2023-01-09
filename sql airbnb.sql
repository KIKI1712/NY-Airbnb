-- CREATE DATABASE airbnb_ny;

USE airbnb_ny;

SHOW TABLES;

SELECT * FROM airbnb_last_review;
SELECT * FROM airbnb_price;
SELECT * FROM airbnb_room_type;

CREATE VIEW airbnb_last_review_upd AS
(SELECT *, RIGHT(last_review, 4) AS last_review_year 
FROM airbnb_last_review);

CREATE VIEW airbnb_price_upd AS
(SELECT listing_id, CAST(SUBSTRING_INDEX(price, ' ', 1) AS SIGNED INTEGER) AS price, nbhood_full
FROM airbnb_price);

SELECT * FROM airbnb_last_review_upd;
SELECT * FROM airbnb_price_upd;

DESC airbnb_price_upd;
SELECT * FROM airbnb_price_upd;

-- some insight
-- Average price by neighborhood
SELECT ROUND(AVG(price),2) AS avg_price, nbhood_full
FROM airbnb_price_upd
GROUP BY nbhood_full
ORDER BY avg_price DESC;

-- Avg and max price by ngbh and room type
SELECT ROUND(AVG(price),2) AS avg_price, max(price) AS max_price, min(price) AS min_price, nbhood_full, room_type
FROM airbnb_price_upd AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
GROUP BY 4,5
ORDER BY max_price DESC;

-- avg, min, max price by room_type
SELECT ROUND(AVG(price),2) AS avg_price, max(price) AS max_price, min(price) AS min_price, room_type
FROM airbnb_price_upd AS ap
JOIN airbnb_room_type AS art ON art.listing_id = ap.listing_id
GROUP BY room_type;

-- average, min, and max room price by room type and hood
WITH merged AS(
SELECT ROUND(AVG(price),2) AS avg_price, max(price)  AS max_price, min(price)  AS min_price, room_type, nbhood_full
FROM airbnb_price_upd AS apd
JOIN airbnb_room_type AS art ON art.listing_id = apd.listing_id
JOIN airbnb_last_review_upd AS alr ON alr.listing_id = apd.listing_id
GROUP BY room_type, nbhood_full)

SELECT *, CASE
WHEN avg_price <= 69 THEN 'Budget'
WHEN avg_price <= 175 THEN 'Average'
WHEN avg_price <= 350 THEN 'Expensive'
ELSE 'Extravagant'
END AS room_description
FROM merged;

-- avg price per hood and number of apartments
SELECT ROUND(avg(price),2) AS avg_price, count(*) AS 'number of rooms', SUBSTRING_INDEX(nbhood_full, ",",1) AS hood
FROM airbnb_price_upd AS apd
JOIN airbnb_room_type AS art ON art.listing_id = apd.listing_id
JOIN airbnb_last_review_upd AS alr ON alr.listing_id = apd.listing_id
GROUP BY hood
order by avg_price desc;

-- most common room type per hood, min and max price
SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS hood, room_type, count(*) AS 'number of rooms', min(price) as min_price, max(price) AS max_price
FROM airbnb_price_upd AS apd
JOIN airbnb_room_type AS art ON art.listing_id = apd.listing_id
JOIN airbnb_last_review_upd AS alr ON alr.listing_id = apd.listing_id
GROUP BY hood, room_type
order by 1,3;

-- When are the rooms mostly booked in general (since the data is only for 2019 it was enough to extract only month name)
SELECT SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review , count(*) AS no_reviews
FROM airbnb_last_review
GROUP BY month_of_last_review
ORDER BY no_reviews DESC;
#we can see that spring and summer times are mostly booked


-- number of reviews indicating when are the rooms in different hood mostly booked (same thing for month extraction applies)
SELECT SUBSTRING_INDEX(nbhood_full, ",",1) AS hood, SUBSTRING_INDEX(last_review, " ", 1) AS month_of_last_review,
room_type, count(*) AS no_reviews
FROM airbnb_last_review AS alw
JOIN airbnb_price AS ap
ON ap.listing_id = alw.listing_id
JOIN airbnb_room_type AS art
ON art.listing_id = alw.listing_id
GROUP BY 2, 1, 3
ORDER BY 1 DESC,4 DESC,2,3;