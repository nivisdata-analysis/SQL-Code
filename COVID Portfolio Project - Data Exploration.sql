/*
Covid 19 Data Exploration 

Skills used: JOINs, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Total cases vs Total deaths
-- Shows Likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE location LIKE '%ndia'
AND continent is not NULL
ORDER BY 1,2

-- Total cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, population , total_cases,  (total_cases/population)*100 AS InfectedCasesPercentage
FROM Portfolio_Project..CovidDeaths
-- WHERE location LIKE '%ndia'
WHERE continent is not NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population , MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
-- WHERE location LIKE '%ndia'
WHERE continent is not NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with the Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCounts
FROM Portfolio_Project..CovidDeaths
WHERE continent iS not NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC

-- GLOBAL NUMBERS

SELECT	SUM(new_cases) as total_cases, 
		SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not NULL
-- GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
    On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
    On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100, 2) AS PercentRollingPeopleVaccinated
FROM PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
    On dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent is not NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- CREATING VIEWS to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
    On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3

SELECT *
From PercentPopulationVaccinated