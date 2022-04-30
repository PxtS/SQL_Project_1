-- EXPLORATORY ANALYSIS OF GLOBAL COVID-19 DATASET (RECORDS UPTO 7th APRIL 2022) ON MYSQL:-
-- FILE LINK - https://ourworldindata.org/covid-deaths
-- ----------------------------------------------------------------------------------------------------------------------------------


-- STEP 1 - CREATING DATABASE ON MYSQL SERVER TO UPLOAD DATASET:-
CREATE DATABASE Covid_Analysis_Portfolio;
USE Covid_Analysis_Portfolio;
SHOW Tables;
-- ----------------------------------------------------------------------------------------------------------------------------------


-- STEP 2 - DIVIDE THE DATASET (.csv) INTO TWO SEPARATE DATASETS TO SHOWCASE SPECIFIC SQL COMMANDS:
-- IMPORTING 2 PROXY files (.csv) of the respective datasets on the database to create tables with appropriate columns and datatypes
-- The tables are:-
-- (i) c_deaths_april22  &  (ii) c_vaccinations_april22 
-- ----------------------------------------------------------------------------------------------------------------------------------


-- STEP 3 -- EMPTYING ALL ENTRIES FROM THE 2 PROXY TABLES TO PREPARE THEM FOR DATA IMPORT VIA LOCAL INFILE:-
Select * from c_deaths_april22;
Delete from c_deaths_april22 WHERE iso_code = 'CYP';
Select * from c_vaccinations_april22 WHERE Location = 'India' and date like '%-11-2021' ORDER BY DATE;
Delete from c_vaccinations_april22 WHERE iso_code = 'AUS';

-- Data import process via local infile:-
SET global local_infile= 1;
SHOW VARIABLES like 'local_infile';

load data local infile 'C:/Users/prate/Documents/STUDIES/Life/SQL/SQL Portfolio Project/covid_deaths_April_2022.csv'
	into table c_deaths_april22
fields terminated by ','
ignore 1 rows;
Select Count(*) from c_deaths_april22;
select * from c_deaths_april22 WHERE DATE like '%-04-2022' order by DATE DESC;

load data local infile 'C:/Users/prate/Documents/STUDIES/Life/SQL/SQL Portfolio Project/covid_vaccinations_April_2022.csv'
	into table c_vaccinations_april22
fields terminated by ','
ignore 1 rows;
select count(*) from c_vaccinations_april22;
select * from c_vaccinations_april22 WHERE DATE like '%-04-2022' order by DATE DESC;
-- --------------------------------------------------------------------------------------------------------------------------------


-- STEP 4 -- EXPLORATION OF DATA:-

SELECT * FROM c_deaths_april22 WHERE Continent = '';
Select Distinct(continent) from c_deaths_april22;
Select Count(Distinct(location)) from c_deaths_april22;
Select Distinct(location) from c_deaths_april22;


-- 4(a) - Total Cases vs Total Deaths of Countries:-
Select Location as Country, 
	   Continent, 
       max(total_cases) as Cases_Total, 
       max(total_deaths) as Deaths_Total, 
       max(total_deaths)/max(total_cases) * 100 as Death_rate
From c_deaths_april22 
WHERE Continent <> '' 
group by Location ORDER BY Cases_Total DESC;


-- 4(b) - Total cases vs population of countries:-
Select Location as Country, 
	   Continent, 
	   max(Total_cases) as Cases_Total, 
	   Population, 
	   max(total_cases)/Population * 100 as Population_Infected_Percentage
from c_deaths_april22
Where continent <> ''
GROUP BY Location
ORDER BY Cases_Total DESC; 


-- 4(c) - Positivity rate in countries with regards to no. of tests:-
Select cd.Location as Country, 
       cd.Continent, 
       max(cd.total_cases) as Cases_Total, 
       max(cv.Total_tests) as Tests_Total, 
       max(cd.Total_cases)/max(cv.Total_tests) * 100 as Positivity_Rate
From c_deaths_april22 as cd
JOIN c_vaccinations_april22 as cv 
       on cd.location = cv.location 
	   and cv.date = cd.date
Where cd.continent <> ''
group by cd.location
order by Cases_total DESC;
 

-- 4(d) - Continent breakup of cases:-
-- Death percentage in each continent:
Select Location as Continent_Name, 
	   Max(Total_Cases) as Cases_Total, 
	   Max(Total_Deaths) as Deaths_Total, 
	   max(total_deaths)/max(Total_cases) * 100 as Death_Rate
From c_deaths_april22
Where Continent = '' and Location IN ('Asia', 'North America', 'South America', 'Europe', 'Africa', 'Oceania', 'Antarctica') 
Group by Continent_Name
Order by Cases_Total DESC;


-- 4(e) - Daily Statistics of worldwide no. of cases and deaths and the respective death percentage:-
Select Date,
	   Sum(new_Cases) as Daily_Cases,
       Sum(new_deaths) as Daily_Deaths,
       sum(new_deaths)/sum(new_cases)*100 as Death_percentage
From c_deaths_april22
where continent <> '' 
Group by Date;


-- 4(f) - Global cases vs deaths and death percentage over time broken up by date:-
Select Date,
       Total_Cases,
       Total_Deaths,
	   Total_deaths/Total_Cases * 100 as Death_Percentage
FROM c_deaths_april22
where continent <> ''
Group by date;


-- 4(g) - CALCULATION - Total cases vs total deaths and death percentage as of latest date:-
SELECT sum(new_cases) as No_of_Cases,
       sum(new_deaths) as No_of_Deaths,
       sum(new_deaths)/sum(new_cases)*100 as Death_Percentage
From c_deaths_april22
Where Continent <> '';


-- 4(h) - Percentage of population vaccinated in each country:-
Select cd.location, 
	   cd.population, 
       max(cv.people_fully_vaccinated), 
       max(cv.people_fully_vaccinated)/cd.population*100 as Percentage_Population_Vaccinated 
FROM c_deaths_april22 as cd
JOIN c_vaccinations_april22 as cv on cd.location = cv.location and cv.date = cd.date
where cd.continent <> ''
Group by cd.location
ORDER BY max(cd.Total_cases) DESC;