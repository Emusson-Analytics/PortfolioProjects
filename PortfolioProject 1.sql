/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
order by 1,2



-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS 
Select date,SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_death,SUM(cast (new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null 
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_death,SUM(cast (new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null 
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccination

--SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
--SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) 
--FROM PortfolioProject..CovidDeaths dea
--JOIN PortfolioProject..CovidVaccinations vac
--	ON dea.location = vac.location
--	and dea.date =vac.date
--Where dea.continent is not null
--Order By 2,3

--Alternatively;

SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) 
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
Order By 2,3


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) 
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order By 2,3
)

SELECT *, (RollingPeopleVaccinated/population)* 100
FROM PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) 
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date =vac.date
--Where dea.continent is not null
--Order By 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later Visualization

Create View PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) 
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date =vac.date
Where dea.continent is not null
--Order By 2,3

SELECT *
FROM PercentPopulationVaccinated
