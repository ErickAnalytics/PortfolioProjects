SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select the data that we're gonna use
SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at the total cases versus total deaths
-- Shows the likelihood of dying if you contract COVID in your country
SELECT 
	location,
	date,
	CAST(CONVERT(DECIMAL(15,0),total_cases) AS int) AS  'cases',
	CAST(CONVERT(DECIMAL(15,0),total_deaths)AS int) AS 'deaths',
	CONVERT(DECIMAL(15,6),
	CONVERT(DECIMAL(15,6),total_deaths) / CONVERT(DECIMAL(15,6),total_cases))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at the total cases VS population
-- Shows the percentage of population that got covid
SELECT
	location,
	date,
	FORMAT(CONVERT(DECIMAL(20,0),population), 'N') AS 'populations',
	FORMAT(CONVERT(DECIMAL(20,0),total_cases), 'N') AS  'cases',
	FORMAT(CONVERT(DECIMAL(20,10),
	CONVERT(DECIMAL(20,6),total_cases) / CONVERT(DECIMAL(20,6),population)), 'P') AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%philippines%'
ORDER BY 1,2

--this is a separate one for extra queries
SELECT 
	location,
	date,
	CONVERT(DECIMAL(20,0),population)  AS 'populations',
	CONVERT(DECIMAL(20,0),total_cases) AS  'cases',
	CONVERT(DECIMAL(20,10),
	CONVERT(DECIMAL(20,6),total_cases) / CONVERT(DECIMAL(20,6),population))*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%philippines%'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT 
	location,
	FORMAT(CONVERT(DECIMAL(20,0),population), 'n')  AS 'populations',
	FORMAT(MAX(CONVERT(DECIMAL(20,0),total_cases)), 'n') AS  'highest_infection_count',
	CONVERT(DECIMAL(20,10),
	MAX(CONVERT(DECIMAL(20,6),total_cases)) / CONVERT(DECIMAL(20,6),population))*100 AS percent_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_infected DESC

--Showing countries with highest death count per population
SELECT
	DENSE_RANK () OVER (ORDER BY MAX(CAST(total_deaths AS int)) DESC) AS ranks,
	location,
	MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC	

--breaking it down by continent




--Showing the continents with the highest death counts
SELECT
	continent,
	MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC	


--GLOBAL NUMBERS

SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(CAST(new_deaths AS int))/ NULLIF(SUM(new_cases),0)*100 AS new_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2

SELECT 
	--date,
	SUM(new_cases) AS total_cases,
	SUM(new_deaths) AS total_deaths,
	SUM(CAST(new_deaths AS int))/ NULLIF(SUM(new_cases),0)*100 AS new_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2


--looking at total population vs vaccinations
WITH CTE AS
(
SELECT 
	a.continent,
	a.location,
	a.date,
	a.population,
	b.new_vaccinations,
	SUM(CONVERT(bigint, b.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location, a.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths AS a
JOIN PortfolioProject..CovidVaccinations AS b
ON a.location=b.location
AND a.date=b.date
WHERE a.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT 
	*,
	ROUND((total_vaccinations/population)*100,4) AS vaccination_percentage
FROM CTE



--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
SELECT 
	a.continent,
	a.location,
	a.date,
	a.population,
	b.new_vaccinations,
	SUM(CONVERT(bigint, b.new_vaccinations),0) OVER (Partition by a.location ORDER BY a.location, a.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths AS a
JOIN PortfolioProject..CovidVaccinations AS b
ON a.location=b.location
AND a.date=b.date
--WHERE a.continent IS NOT NULL
--ORDER BY 2,3

SELECT 
	*,
	ROUND((total_vaccinations/population)*100,4) AS vaccination_percentage
FROM #PercentPopulationVaccinated

--altering the table

ALTER TABLE PortfolioProject..CovidVaccinations
ALTER COLUMN new_vaccinations int






--Creating view to store data visualizations 
DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated	AS
SELECT 
	a.continent,
	a.location,
	a.date,
	a.population,
	b.new_vaccinations,
	SUM(CONVERT(numeric(20,0),b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.location, a.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths AS a
JOIN PortfolioProject..CovidVaccinations AS b
ON a.location=b.location
AND a.date=b.date
WHERE a.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
