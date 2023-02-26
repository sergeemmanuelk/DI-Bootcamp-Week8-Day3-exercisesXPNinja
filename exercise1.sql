--Retrieve all films with a rating of G or PG, which are are not currently rented (they have been returned/have never been borrowed).
SELECT DISTINCT(inv.film_id), film.*
FROM film f
INNER JOIN inventory inv ON inv.film_id = f.film_id
WHERE f.rating='G' OR f.rating = 'PG'
AND f.film_id NOT IN (SELECT r.inventory_id FROM rental r);

--Create a new table which will represent a waiting list for children’s movies. This will allow a child to add their name to the list until the DVD is available (has been returned). Once the child takes the DVD, their name should be removed from the waiting list (ideally using triggers, but we have not learned about them yet. Let’s assume that our Python program will manage this). Which table references should be included?
CREATE TABLE waiting_list(
	id SERIAL PRIMARY KEY,
	complete_name VARCHAR NOT NULL,
	inventory_id INTEGER NOT NULL,
	takes BOOLEAN DEFAULT FALSE,
	CONSTRAINT fk_inventory
		FOREIGN KEY(inventory_id)
		REFERENCES inventory(inventory_id)
		ON UPDATE CASCADE 
		ON DELETE RESTRICT
);

CREATE OR REPLACE FUNCTION fn_waiting_list() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS 
'
BEGIN
	IF NEW.takes THEN
		DELETE FROM waiting_list WHERE id = NEW.id; 
	END IF;
   
   RETURN NULL;
END;
'

CREATE TRIGGER tr_waiting_list
   AFTER UPDATE
   ON waiting_list
   FOR EACH ROW
       EXECUTE PROCEDURE fn_waiting_list();

--Retrieve the number of people waiting for each children’s DVD. Test this by adding rows to the table that you created in question 2 above.
INSERT INTO waiting_list(complete_name, inventory_id)
VALUES('Nicolas', 1),
		('Joe', 2),
		('Peter', 3);
		
UPDATE waiting_list
SET takes = TRUE 
WHERE id IN (1, 3);