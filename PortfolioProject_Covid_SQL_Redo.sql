Select *
From PortfolioProject_Covid..CovidDeathsRaw
where continent is not null
order by 3,4

--Select *
--From PortfolioProject_Covid..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_Covid..CovidDeathsRaw
where continent is not null
order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject_Covid..CovidDeathsRaw
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject_Covid..CovidDeathsRaw
--Where location like '%states%'
where continent is not null
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
From PortfolioProject_Covid..CovidDeathsRaw
--Where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject_Covid..CovidDeathsRaw
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject_Covid..CovidDeathsRaw
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject_Covid..CovidDeathsRaw
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..CovidDeathsRaw dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Use CTE	

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..CovidDeathsRaw dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

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
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..CovidDeathsRaw dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_Covid..CovidDeathsRaw dea
Join PortfolioProject_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- Looking at the View created above
Select *
From PercentPopulationVaccinated


