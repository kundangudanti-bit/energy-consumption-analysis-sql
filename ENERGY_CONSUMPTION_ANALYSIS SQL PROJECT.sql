CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE 
    );
    
    -- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


DESC COUNTRY;
DESC emission_3;
desc population;
desc production;
desc gdp_3;
desc consumption;



SELECT * FROM COUNTRY;
SELECT * FROM EMISSION_3;
SELECT * FROM population LIMIT 5;
SELECT * FROM production LIMIT 20;
SELECT * FROM gdp_3 LIMIT 5;
SELECT * FROM  consumption; 


SELECT MIN(year) AS start_year,
       MAX(year) AS end_year
FROM emission_3;

SELECT COUNT(DISTINCT Country) AS total_countries
FROM country;

-- What is the total emission per country for the most recent year available?
SELECT country,sum(emission) as total_emission,year
from emission_3
where year=(select max(year) from emission_3)
group by country,year;


-- What are the top 5 countries by GDP in the most recent year?
select country,Value as gdp
from gdp_3
where year =(select max(year) from gdp_3)
order by Value desc
limit 5;

-- Compare energy production and consumption by country and year 
 SELECT
p.country,p.year,sum(p.production) as total_production,
SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c
ON p.country = c.country
GROUP BY p.country,p.year;
    
    -- Which energy types contribute most to emissions across all countries?
select 
energy_type,sum(emission) as total_emission
from emission_3
group by energy_type
order by total_emission DESC;

-- Trend Analysis Over Time
-- How have global emissions changed year over year?
select year,sum(emission) as total_global_emission
from emission_3
group by year
order by total_global_emission;


-- What is the trend in GDP for each country over the given years?
select
year,country,Value as gdp
from gdp_3
order by country,year desc;

-- How has population growth affected total emissions in each country?
select 
p.countries,p.year,p.Value as population,sum(e.emission) as total_emission
from population p
inner join EMISSION_3 e
on p.countries=e.country
and p.year=e.year
group by p.countries,p.year,p.Value
order by p.countries,p.year;


-- Has energy consumption increased or decreased over the years for major economies?
SELECT country,year,
SUM(consumption) AS total_consumption
FROM consumption
WHERE country IN ('United States','China','India','Germany','Japan')
GROUP BY country,year
ORDER BY country,year;



-- What is the average yearly change in emissions per capita for each country? 
SELECT country,year,avg(per_capita_emission) as avg_yearly_change
FROM emission_3
GROUP BY country,year;



-- Ratio & Per Capita Analysis
-- What is the emission-to-GDP ratio for each country by year?
select e.country,e.year,
sum(emission) / g.Value as emission_to_gdp_ratio
from emission_3 e
inner join gdp_3 g
on e.country = g.Country
AND e.year = g.year
GROUP BY
e.country,e.year,g.Value
ORDER BY e.country,e.year;

-- What is the energy consumption per capita for each country over the last decade?
SELECT c.country,c.year,
       SUM(c.consumption)/p.Value AS consumption_per_capita
FROM consumption c
INNER JOIN population p
ON c.country=p.countries
AND c.year=p.year
GROUP BY c.country,c.year,p.Value
ORDER BY c.country,c.year;


-- How does energy production per capita vary across countries
SELECT pr.country,pr.year,
pr.production/p.Value AS production_per_capita
FROM production pr
INNER JOIN population p
ON pr.country=p.countries
AND pr.year=p.year
GROUP BY pr.country,pr.year,pr.production,p.Value
ORDER BY pr.country,pr.year;

-- Which countries have the highest energy consumption relative to GDP?
SELECT c.country,
SUM(c.consumption)/AVG(g.Value) AS consumption_to_gdp
FROM consumption c
INNER JOIN gdp_3 g
ON c.country=g.Country
AND c.year=g.year
GROUP BY c.country
ORDER BY consumption_to_gdp DESC;

-- What is the correlation between GDP growth and energy production growth?
SELECT g.Country,g.year,
g.Value AS GDP,
SUM(p.production) AS total_production
FROM gdp_3 g
INNER JOIN production p
ON g.Country=p.country
AND g.year=p.year
GROUP BY g.Country,g.year,g.Value
ORDER BY g.Country,g.year;

-- Global Comparisons
-- What are the top 10 countries by population and how do their emissions compare?
select p.countries,p.Value as population,
sum(e.emission) as total_emission
from population p
inner join emission_3 e
ON p.countries = e.country
AND p.year = e.year
WHERE p.year = (SELECT MAX(year) FROM emission_3)
GROUP BY p.countries,p.Value
ORDER BY p.Value DESC
LIMIT 10;

-- Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT country,
MAX(per_capita_emission) - MIN(per_capita_emission) AS reduction_in_per_capita_emission
FROM emission_3
GROUP BY country
ORDER BY reduction_in_per_capita_emission DESC;

-- What is the global share (%) of emissions by country?
SELECT country,SUM(emission) * 100 /
(SELECT SUM(emission) FROM emission_3) AS global_emission_share_pct
FROM emission_3
GROUP BY country
ORDER BY global_emission_share_pct DESC;

-- What is the global average GDP, emission, and population by year?
select g.year,
avg(g.Value)as avg_gdp,avg(e.emission) as avg_emission,avg(p.Value) as avg_population
from gdp_3 g
inner join emission_3 e
on g.year=e.year
and g.Country=e.country
inner join population p
on g.year=p.year
and g.Country=p.countries
group by g.year
order by g.year;
















    

