/* LEVEL 1: Easy */
/* Q1: Who is the senior most employee based on job title? */

Select * From employee
Order By levels Desc
Limit 1;

/* Q2: Which countries have the most Invoices? */

Select Count(*) as MostInvoices, billing_country From invoice
Group By billing_country 
Order By MostInvoices Desc;

/* Q3: What are top 3 values of total invoice? */

Select total,billing_country from invoice
Order By Total Desc
Limit 3;

/* Q4: Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

Select SUM(total) as invoice_total, billing_city, billing_country
From invoice
Group By billing_city, billing_country
Order By invoice_total Desc
Limit 1;

/* Q5: Who is the best customer?
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

Select c.customer_id, c.first_name, c.last_name, SUM(total) as TotalSpent From customer as c
Join invoice as i ON 
c.customer_id = i.customer_id 
group by c.customer_id
order by TotalSpent Desc
	Limit 1;

/* LEVEL 2: Moderate */
/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/* Method 1 */
Select Distinct email as Email, first_name as FirstName, last_name as LastName, genre.name as Genre from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email asc;

/* Method 2 */

Select Distinct email as Email, first_name, last_name
From customer as c
Join invoice as i on c.customer_id = i.customer_id
Join invoice_line as iline on iline.invoice_id = i.invoice_id
Where track_id IN
	(Select track_id from track
	 Join genre on track.genre_id = genre.genre_id
	 Where genre.name = 'Rock')
Order By Email Asc;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

Select artist.artist_id, artist.name, Count(artist.artist_id) as Max_Rock_Songs From artist
Join Album on artist.artist_id = album.artist_id
Join Track on track.album_id = album.album_id
Join Genre on track.genre_id = genre.genre_id
Where genre.name = 'Rock'
Group By artist.artist_id
Order by Max_Rock_Songs Desc
Limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT artist.name, track.name, milliseconds
FROM track join album on track.album_id = album.album_id
Join artist on artist.artist_id = album.artist_id
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */ 

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;