SELECT *
FROM CovidDeaths
Where continent is not null 
ORDER BY 3,4

-- SELECT *
-- FROM CovidVaccination
-- ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
FROM CovidDeaths
Where location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CAST(total_cases as float)/CAST(population as float))*100 as Infected
FROM CovidDeaths
Where location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((CAST(total_cases as float)/CAST(population as float)))*100 as PercentofPopulationInfected
FROM CovidDeaths
--Where location like '%states%'
GROUP BY Location, population
ORDER BY PercentofPopulationInfected DESC

-- Showing Coutries with the highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like '%states%'
Where continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeath
--Where location like '%states%'
Where continent is not null 
GROUP BY [continent]
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(CAST(new_cases as float)) as total_cases, SUM(CAST(new_deaths as float)) as total_deaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 as DeathPercentage
FROM CovidDeaths
--Where location like '%states%'
WHERE continent is not NULL
--GROUP BY [date]
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.LOCATION order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeath dea 
Join CovidVaccination vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition By dea.LOCATION order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeath dea 
Join CovidVaccination vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (CAST(RollingPeopleVaccinated as float)/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated NUMERIC
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition By dea.LOCATION order by dea.location, 
    dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeath dea 
Join CovidVaccination vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (CAST(RollingPeopleVaccinated as float)/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition By dea.LOCATION order by dea.location, 
    dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeath dea 
Join CovidVaccination vac
    ON dea.location = vac.[location]
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

SELECT *
From PercentPopulationVaccinated