--SELECT * FROM PortfolioProject..CovidDeaths

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like 'India'
order by 1,2

--Looking at total cases vs population

SELECT Location, date, Population, total_cases,(total_cases/Population)*100 AS CovidPositivePercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like 'India'
order by 1,2

--Looking at countries wth highest Infection Rate compared to Population

SELECT Location,Population, MAX(total_cases) AS HighestInfection,MAX(total_cases/Population)*100 AS CovidPositivePercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like 'India'
GROUP BY Location, Population
order by CovidPositivePercentage desc

--Showing Countries with highest death count per population

SELECT Location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like 'India'
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--By continent
--Showing continent with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like 'India'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like 'India'
WHERE continent is NOT NULL
GROUP BY date
order by 1,2


--Looking at Total_populations vs vaccinations
--USE CTE
WITH PopvsVac (Continent,Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--GROUP BY dea.continent
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


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
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--GROUP BY dea.continent
--order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualization

--DROP Table if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--GROUP BY dea.continent
--order by 2,3

SELECT * 
FROM PercentPopulationVaccinated
