use PortfolioProject
--Select * 
--From PortfolioProject.dbo.covidvaccination
--order by 3,4

Select *
From PortfolioProject.dbo.coviddeaths
Where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.coviddeaths
order by 1,2


-- looking at the total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.coviddeaths
Where location like '%India%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.coviddeaths
--Where location like '%India%'
order by 1,2

-- Lokking at countries wiht highest Infection Rate compare to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject.dbo.coviddeaths
--Where location like '%India%'
GROUP BY location, population
order by PercentagePopulationInfected desc


-- CONTINENTS

-- Continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.coviddeaths
--Where location like '%India%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


-- Global Count

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.coviddeaths
--Where location like '%India%'
where continent is not null
order by 1,2

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.coviddeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(BIGINT, vac.new_vaccinations)) OVER (Partition  by dea.location, dea.date) as RollingpeopleVaccinated --, (RollingpeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(BIGINT, vac.new_vaccinations)) OVER (Partition  by dea.location, dea.date) as RollingpeopleVaccinated --, (RollingpeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(BIGINT, vac.new_vaccinations)) OVER (Partition  by dea.location, dea.date) as RollingpeopleVaccinated --, (RollingpeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Create View to store data for visualization
use PortfolioProject
Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(BIGINT, vac.new_vaccinations)) OVER (Partition  by dea.location, dea.date) as RollingpeopleVaccinated --, (RollingpeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinatedView