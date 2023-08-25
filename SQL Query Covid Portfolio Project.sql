--SELECT DATA THAT WE ARE GOING TO USE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELY HOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%PAKISTAN%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL POPULATION
--SHOWS WHAT PERCENTAGE OF PEOPLE GOT COVID

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PERCENTAGE_OF_INFECTED_POPULATION
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%PAKISTAN%'
ORDER BY 1,2


SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PERCENTAGE_OF_INFECTED_POPULATION
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%PAKISTAN%'
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionRate,  
MAX((total_cases/population))*100 AS PERCENTAGE_OF_INFECTED_POPULATION
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PERCENTAGE_OF_INFECTED_POPULATION DESC


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount  
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.New_vaccinations, 
SUM(CONVERT(INT,VAC.New_vaccinations)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM PortfolioProject..COVIDVACCINATIONS VAC
JOIN PortfolioProject..CovidDeaths DEA
ON DEA.location=VAC.LOCATION
AND DEA.date=VAC.DATE
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

-- CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


SELECT * FROM PercentPopulationVaccinated