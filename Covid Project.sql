Select *
From Covid..CovidDeaths
Where continent is not null
order by 3,4

-- Select *
-- From Covid..CovidVaccinations
-- order by 3,4

-- Select data that we are going to be using
Select Location, Date, total_cases, new_cases, total_deaths, population
From Covid..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, CAST(total_deaths AS DECIMAL)/total_cases*100 as DeathPercentage
From Covid..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, Date, population, total_cases, CAST(total_cases AS DECIMAL)/population*100 as PercentPopulationInfected
From Covid..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount , MAX(CAST(total_cases AS DECIMAL)/population)*100 as PercentPopulationInfected
From Covid..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From Covid..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

Select continent, MAX(total_deaths) as TotalDeathCount
From Covid..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(new_cases)*100 as DeathPercentage
From Covid..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
order by 1,2

-- Looking at Total Populations vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
    on dea.location =vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null
order by 2,3


-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
    on dea.location =vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null
--ORDER by 2,3
)
Select *, (cast(RollingPeopleVaccinated as decimal)/Population)*100
From PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated 
Create TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
    on dea.location =vac.location
    and dea.date = vac.date 
--WHERE dea.continent is not null
--ORDER by 2,3

Select *, (cast(RollingPeopleVaccinated as decimal)/Population)*100
From #PercentPopulationVaccinated

GO

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
    on dea.location =vac.location
    and dea.date = vac.date 
WHERE dea.continent is not null
--ORDER by 2,3

Select *
FROM PercentPopulationVaccinated
