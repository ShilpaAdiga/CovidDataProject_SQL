select * from CovidDataProject.dbo.covidDeaths order by 3,4;

select * from CovidDataProject.dbo.covidVaccinations order by 3,4;

ALTER TABLE CovidDataProject.dbo.covidDeaths
ALTER COLUMN total_deaths float


-- Total Cases vs Total Deaths
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Countries with AVG Infection Rate compared to Population
SELECT location,  avg(total_cases/population)*100 as PercentPopulationInfected
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count 
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continent with Total Death Count per Population
SELECT continent,sum(new_deaths) as TotalDeathCount 
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null    
GROUP BY continent
ORDER BY totaldeathcount desc;

-- Total Cases vs Total Deaths in whole world in each day
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases), 0))*100 as DeathPercentage
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null
GROUP BY date
order by date


-- Overall Total Cases vs Total Deaths in whole world 
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases), 0))*100 as DeathPercentage
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null


-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDataProject.dbo.covidDeaths dea
JOIN CovidDataProject.dbo.covidVaccinations vac
	ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to check Population vs Vaccination in Percentage
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDataProject.dbo.covidDeaths dea
JOIN CovidDataProject.dbo.covidVaccinations vac
	ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
FROM PopvsVac
ORDER BY 2,3


-- Using Temp table to check Population vs Vaccination in Percentage
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDataProject.dbo.covidDeaths dea
JOIN CovidDataProject.dbo.covidVaccinations vac
	ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
FROM #PercentPeopleVaccinated
ORDER BY 2,3


-- Creating Views
-- Continent with Total Death Count 
CREATE VIEW ContinentDeathCount AS
SELECT continent,sum(new_deaths) as TotalDeathCount 
FROM CovidDataProject.dbo.covidDeaths
WHERE continent is not null    
GROUP BY continent

SELECT * FROM ContinentDeathCount


-- Continent with Total Vaccination
CREATE VIEW ContinentVaccinationCount AS
SELECT continent,sum(CONVERT(bigint,new_vaccinations)) as TotalVaccinations 
FROM CovidDataProject.dbo.covidVaccinations
WHERE continent is not null    
GROUP BY continent


-- Population vs Vaccination
CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	   SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDataProject.dbo.covidDeaths dea
JOIN CovidDataProject.dbo.covidVaccinations vac
	ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null



