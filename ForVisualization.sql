--Queries for Covid Visualization

--1. 

SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
ORDER BY 1,2

--2.
--We take these out as they are not included in the above queries and want to stay consistent 
--European Union is part of Europe 

SELECT 
	location,
	SUM(CAST(new_deaths AS int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_death_count DESC

--3.

SELECT
	location,
	population,
	MAX(total_cases) as highest_infection_count,
	MAX((total_cases/population))*100 percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC

--4. 

SELECT
	location,
	population,
	date,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC  