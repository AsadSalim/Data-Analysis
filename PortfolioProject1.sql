/*
* 25/6/2021

* This is my first SQL data exploration project using the
  Microsoft SQL Management Studio. 

* The dataset used in this project is "The global data on confirmed COVID-19 deaths"



*/




SELECT *
FROM PortfolioProject..CovidDeaths


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

-- HERE WE SELECT THE DATA WE'RE GOING TO USE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


-- LOOKING AT TOTAL CASES VS POPULATION
 SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE date = '2021-05-24 00:00:00.000'
ORDER BY 1, 2

-- Looking at countries with heighest infection rate compared to population

SELECT location, population, MAX(total_cases) AS TotalCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY TotalCount DESC

-- Let's look at how many people actually died

SELECT location, population, MAX(total_cases) AS TotalCases, MAX((total_deaths/population))*100 AS TotalDeathsRatio
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY TotalDeathsRatio

-- THIS SHOWS TOTAL DEATHS
-- IN THIS CASE total_deaths is of nvarchar(255) type and we need to convert it into int

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- ANOTHER WAY TO MAKE THE ABOVE QUERY
SELECT location, MAX(CAST(total_deaths AS INT)) AS 'TOTAL DEATHS'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 'TOTAL DEATHS' DESC

CREATE VIEW TotalDeaths AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS 'TOTAL DEATHS'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location



-- GLOBAL NUMBERS
SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercetage
FROM PortfolioProject..CovidDeaths
WHERE location = 'World'
ORDER BY date

-- ANOTHER WAY TO MAKE THE ABOVE QUERY
SELECT date, SUM(total_cases) AS TotalCases, SUM(CAST(total_deaths AS int)) AS TotalDeaths, 
(SUM(CAST(total_deaths AS int))/SUM(total_cases))*100 AS DeathPercetage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

-- Total numbers
SELECT SUM(total_cases) AS TotalCases, SUM(CAST(total_deaths AS int)) AS TotalDeaths, 
(SUM(CAST(total_deaths AS int))/SUM(total_cases))*100 AS DeathPercetage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date

-- Creating a view for it
Create View TotalCases as
SELECT SUM(total_cases) AS TotalCases, SUM(CAST(total_deaths AS int)) AS TotalDeaths, 
(SUM(CAST(total_deaths AS int))/SUM(total_cases))*100 AS DeathPercetage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY date



-- Now let's analyze the second table
SELECT *
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
	 AND DEA.date = VAC.date

-- Looking at total population vs vaccination
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingVaccinations
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
	 AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3

-- For further calculations using the RollingVaccinations We need to use either CTEs or Temp tables
-- 1 - We use the CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingVaccinations
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
	 AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT*, (RollingVaccinations/population)*100
FROM PopvsVac

-- 2 - Temp tables
DROP TABLE IF EXISTS #PercentVaccinatedPopulation
Create Table #PercentVaccinatedPopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingVaccinations numeric
)


insert into #PercentVaccinatedPopulation

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingVaccinations
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
	 AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT*, (rollingVaccinations/population)*100
FROM #PercentVaccinatedPopulation

-- Creating view to stored data for later visualizations
Create View PercentVaccinatedPopulation as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) RollingVaccinations
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
     ON DEA.location = VAC.location
	 AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL







-- For visualization we use the following queries
--  1.

Select SUM(new_cases) as total_casses, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

--  2.

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--  3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


--  4.

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc