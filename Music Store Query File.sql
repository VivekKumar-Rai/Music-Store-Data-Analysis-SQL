/* Q1: Who is the senior most employee based on job title? */

SELECT FIRST_NAME, LAST_NAME FROM EMPLOYEE 
ORDER BY LEVELS DESC LIMIT 1;

/* Q2: Which countries have the most Invoices? */

SELECT BILLING_COUNTRY, COUNT(*) AS TOTAL FROM INVOICE
GROUP BY BILLING_COUNTRY ORDER BY TOTAL DESC LIMIT 1;

/* Q3: What are top 3 values of total invoice? */

SELECT INVOICE_ID, TOTAL FROM INVOICE
ORDER BY TOTAL DESC LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT BILLING_CITY, SUM(TOTAL) AS TOTAL_INVOICE FROM INVOICE
GROUP BY BILLING_CITY ORDER BY TOTAL_INVOICE DESC LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT CU.CUSTOMER_ID, CU.FIRST_NAME, CU.LAST_NAME, SUM(I.TOTAL) AS TOTAL_SPENT 
FROM CUSTOMER CU INNER JOIN INVOICE I
ON I.CUSTOMER_ID=CU.CUSTOMER_ID
GROUP BY CU.CUSTOMER_ID
ORDER BY TOTAL_SPENT DESC LIMIT 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT EMAIL, FIRST_NAME, LAST_NAME, GENRE.NAME AS NAME
FROM CUSTOMER
INNER JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
INNER JOIN INVOICE_LINE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
INNER JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
INNER JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
WHERE GENRE.NAME = 'Rock'
ORDER BY EMAIL;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT ARTIST.NAME, COUNT(TRACK.TRACK_ID) AS TOTAL FROM ARTIST
INNER JOIN ALBUM ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
INNER JOIN TRACK ON TRACK.ALBUM_ID = ALBUM.ALBUM_ID
INNER JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
WHERE GENRE.NAME = 'Rock'
GROUP BY ARTIST.NAME
ORDER BY TOTAL DESC
LIMIT 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track.
Order by the song length with the longest songs listed first. */

SELECT TRACK.NAME, TRACK.MILLISECONDS FROM TRACK
WHERE TRACK.MILLISECONDS >
 	(
	   SELECT AVG(MILLISECONDS) FROM TRACK
    )
ORDER BY TRACK.MILLISECONDS DESC;

/* Q9: Find how much amount spent by each customer each artist?
Write a query to return customer name, artist name and total spent. */ 

WITH ARTIST_LIST AS (
	SELECT ARTIST.ARTIST_ID, ARTIST.NAME, 
	SUM(INVOICE_LINE.UNIT_PRICE*INVOICE_LINE.QUANTITY) AS TOTAL_SALES
	FROM INVOICE_LINE
	JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
	JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
	JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
	GROUP BY 1
	ORDER BY 3 DESC
)
SELECT C.FIRST_NAME, C.LAST_NAME, AL.NAME,
SUM(IL.UNIT_PRICE*IL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID = I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
JOIN ALBUM ALB ON ALB.ALBUM_ID = T.ALBUM_ID
JOIN ARTIST_LIST AL ON AL.ARTIST_ID = ALB.ARTIST_ID
GROUP BY 1,2,3
ORDER BY 4 DESC;

/* Q10: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all genres */

WITH GENRE_PER_COUNTRY AS 
(
	SELECT BILLING_COUNTRY AS COUNTRY, GE.NAME,
	RANK() OVER(PARTITION BY BILLING_COUNTRY ORDER BY COUNT(IL.QUANTITY) DESC) AS RANK_NO
	FROM INVOICE IV
	INNER JOIN INVOICE_LINE IL ON IL.INVOICE_ID = IV.INVOICE_ID
	INNER JOIN TRACK TR ON TR.TRACK_ID = IL.TRACK_ID
	INNER JOIN GENRE GE ON GE.GENRE_ID = TR.GENRE_ID
	GROUP BY 1,2
	ORDER BY 1
)
SELECT COUNTRY, NAME FROM GENRE_PER_COUNTRY WHERE RANK_NO = 1;

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH CUSTOMER_COUNTRY AS
(
	SELECT CU.CUSTOMER_ID, CU.FIRST_NAME, CU.LAST_NAME, IV.BILLING_COUNTRY AS COUNTRY, SUM(IV.TOTAL) AS TOTAL,
	RANK() OVER(PARTITION BY COUNTRY ORDER BY SUM(IV.TOTAL) DESC) AS RANK_NO
	FROM CUSTOMER CU
	INNER JOIN INVOICE IV ON CU.CUSTOMER_ID = IV.CUSTOMER_ID
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME, COUNTRY, TOTAL
FROM CUSTOMER_COUNTRY WHERE RANK_NO = 1;

/*Thank You.*/

