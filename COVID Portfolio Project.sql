-- Looking at Total Cases vs Total Deaths 
-- Shows the liklihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Totoal Cases Vs Population
-- Shows what percent of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentOfPopInfected
from PortfolioProject..CovidDeaths
where location like '%state%'
order by 1, 2


-- Looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentOfPopInfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
group by location, population
order by PercentOfPopInfected desc

--Breaking things down by continent, this will give us a good look in tableau 
----Showing the continent with the highest deat count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is null
group by location
order by TotalDeathCount desc


-----------------------------
--GLOBAL NUMBERS, have to use aggregate functions
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%state%'
--group by date
where continent is not null
order by 1, 2

-- Looking at total population vs vaccination 
-- USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated-- want the count to start over once it finishes each location 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100  as Percentage
from PopVsVac


-- Creating View to store data later for visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated-- want the count to start over once it finishes each location 
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
