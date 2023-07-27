SELECT *
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.covidvax
ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.coviddeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS death_percentage
FROM PortfolioProject.dbo.coviddeaths
WHERE Location = 'Bangladesh'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid 

SELECT Location, date, Population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.coviddeaths
WHERE Location = 'United States'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.coviddeaths
--WHERE Location = 'China'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.coviddeaths
--WHERE Location = 'United States'
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--Breaking things down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.coviddeaths
--WHERE Location = 'United States'
WHERE continent is NULL 
AND location != 'High income'
AND location != 'Upper middle income'
AND location != 'lower middle income'
AND location != 'Low income'
AND location != 'European Union'
GROUP BY location
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths--, 
	--SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--COVID VAX--

--Looking at Total Population vs Vaccinations 

--Use CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvax vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvax vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEWS TO STORE DATA FOR LATER VIZ

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvax vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated