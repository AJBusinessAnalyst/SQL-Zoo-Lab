USE zoo_lab
-- List 1 row from the animals table:
-- NOTE: end_date means when the animal is no longer at the zoo
-- can be null when animal is still at zoo

SELECT *
FROM zoo_lab.animals
LIMIT 1;

-- List 1 row from the animal_stats table:
-- animals are measured every Monday
-- weight (ok, mass) is given in grams

SELECT *
FROM zoo_lab.animal_stats
LIMIT 1;

-- Part II: Zoo Lab, extremes of the zoo animals
-- Which species has the longest scientific_name?
-- scientific name is in the species table
-- HINT: use length() on a string column to get length of the string

SELECT scientific_name, length(scientific_name) 
FROM species
GROUP BY scientific_name
ORDER BY scientific_name DESC;

-- Which animal has the longest individual_name? Shortest?
-- Each individual animal's given name is stored in the animals table.
-- HINT: there can be such a thing as too short of a name.

SELECT individual_name, length(individual_name)
FROM animals
GROUP BY individual_name
ORDER BY length(individual_name) DESC;

-- Which animal is the most recent addition to the zoo? 
-- start_date is when the animal was added to the zoo.

SELECT start_date, individual_name FROM animals
GROUP BY start_date, individual_name
ORDER BY start_date DESC;


-- What species is this most recent addition to the zoo?

SELECT scientific_name, species.id, animals.species_id, start_date
FROM species
LEFT JOIN animals
ON species.id=animals.species_id
WHERE start_date='2015-07-31';


-- Part III: Zoo Lab, summaries of the zoo animals
-- How many are there of each species?
-- Your answer should report by the common_name of each species, 
-- but it may help to start with counting the number of animals per species_id.  (10pts)

SELECT COUNT(species_id)
FROM animals 
GROUP BY species_id;

SELECT COUNT(animals.id), species.common_name, species.id
FROM animals
JOIN species
ON animals.species_id = species.id
GROUP BY species.common_name, species.id;

-- As of today, what's the average tenancy (length of stay) at the zoo?
-- HINTS:
-- DATEDIFF(date2, date1) returns number of days of date2 - date1
-- IFNULL(exp1, exp2) returns exp2 if exp1 is null
-- CURDATE() returns the current date of the running MySQL session

SELECT AVG(DATEDIFF(IFNULL(end_date, CURDATE()), start_date))
FROM animals;  

-- Using the animal stats table, tell me the average weight for each individual animal, 
-- across all of that animal's weigh-ins

SELECT animal_stats.animal_id, animals.individual_name, species.common_name, 
ROUND(avg(animal_stats.weight*0.0022), 2) as avg_weight
FROM animal_stats
JOIN animals
ON animal_stats.animal_id = animals.id
JOIN species
ON animals.species_id = species.id
GROUP BY animal_stats.animal_id, animals.individual_name, species.common_name;


-- The zoo director is not exactly sure what this would reveal, 
-- but wants you to go for it. 
-- She adds, "oh, and I'm not that great with the metric system. 
-- Can you report weight in pounds?"


-- Measured weights are in animal_stats table.
-- HINT: ROUND(x, d) 
-- rounds the number x to the nearest d decimal points floor(x)
-- rounds DOWN to the nearest integer % 
-- modulo, returns remainder


-- The zoo director says to you, "you know what, maybe grams is better. 
-- Let's use metric from here on!" 
-- "Grams is fine, but I still want species identified by common names."
-- What's the average measured weight per species?
-- Define average weight per species as average of each animal's average (from last question)

SELECT species.common_name, species.id,
ROUND(avg(animal_stats.weight), 2) as avg_wght_grams
FROM animal_stats
JOIN animals
ON animal_stats.animal_id = animals.id
JOIN species
ON animals.species_id = species.id
GROUP BY species.common_name, species.id;

-- Part IV: Zoo Lab, zoo animals with seniority

-- Which animals have been here since December 01, 2014 or earlier?
-- HINT: "been here" implies still here

SELECT start_date, id, individual_name
FROM animals
WHERE start_date >= '2014-12-01';

-- Of the animals who have been here since 11-23-2015,
-- which grew the most, by percentage weight, between 12-01-2014 and 11-23-2015, 
-- a period where we implemented a new feeding schedule.
-- HINTS: use the ids from the last query, assume no gaps in data,
-- use hardcoded earliest and latest dates
-- (last measumerment - 1st measuirment)/first measurment = % 

SELECT start_date, id, individual_name
FROM animals
JOIN animal_stats
WHERE start_date between '2014-12-01' and '2015-11-23';

SELECT animal_id, max(cal_date), min(cal_date), weight
FROM animal_stats
WHERE cal_date between '2014-12-01' and '2015-11-23'
GROUP BY animal_id, weight;

-----------

SELECT ((table2.new_weight - table1.old_weight)/table1.old_weight) * 100 as growth,
 table1.animal_id, animals.individual_name
FROM
(SELECT weight as old_weight, animal_id
FROM animal_stats
WHERE cal_date = '2014-12-01'
GROUP BY animal_id, weight) as table1
JOIN
(SELECT weight as new_weight, animal_id
FROM animal_stats
WHERE cal_date = '2015-11-23'
GROUP BY animal_id, weight) as table2
ON table1.animal_id = table2.animal_id
JOIN animals
ON table1.animal_id = animals.id
ORDER BY growth desc



