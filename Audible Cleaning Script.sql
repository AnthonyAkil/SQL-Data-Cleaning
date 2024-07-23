--Here we create a temporary dataset as to not perform any modifications to the raw, uncleaned data.
SELECT *
INTO audible_temp
FROM dbo.audible_dataset;


SELECT TOP 100 *
FROM audible_temp;

-- First, remove the prefixes "Writtenby:" and "Narratedby:" in the author and narrator column, respectively.

UPDATE audible_temp
SET author = REPLACE(author,'Writtenby:',''),
	narrator = REPLACE(narrator,'Narratedby:','');


-- Drop all rows that have the value "Not rated yet" in the stars column:

DELETE FROM audible_temp
WHERE stars = 'Not rated yet'

ALTER TABLE audible_temp
ADD avg_rating Nvarchar(3),			-- Limit the precision to 3 since, in the currect dataset, a rating out of 5 can only contain 3 characters at most (i.e. 3.5).
	numbof_ratings Nvarchar(255);


-- We split the stars column into two new columns, the average rating and the number of ratings.		, using the PARSENAME operator after placing a '.' using the REPLACE operator.
-- In the case of the average rating column, note that a rating can be ether three characters (i.e. 3.5) or a single character. Hence, we select the first three characters of the string using the SUBSTRING operator and then removing the excess characters that got selected when there was only a character for the rating. In thise case we used the REMOVE operator to remove ' o'.
-- In the case of the number of ratings column, we first split the string by using the REPLACE and PARSENAME operators so that we only work with the latter part of the stars column. Here we notice that a movie can have a singe 'rating' or more than one 'ratings', which affects how we can return the number of ratings. A CASE WHEN statement can be used to differentiate when there is a single rating or more than one, which
UPDATE audible_temp
SET avg_rating = REPLACE(SUBSTRING(stars, 1, 3), ' o', ''),
    numbof_ratings = CASE 
                         WHEN PARSENAME(REPLACE(stars, 'stars', 'stars.'), 1) = '1 rating' THEN '1'
                         ELSE REPLACE(PARSENAME(REPLACE(stars, 'stars', 'stars.'), 1), ' ratings', '')
                     END;




-- By observing the data we notice non-english names for the audio books, this is something that can be taken into consideration when further cleaning the data
