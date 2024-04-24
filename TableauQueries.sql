/*

Queries used for Tableau Vizualization

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- 2. 

Select location,population,SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by location,population
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as TotalInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.

Select Location, Population,date,total_cases,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population,total_cases,date
order by PercentPopulationInfected desc,date desc

-- 5.

With PopvsVac (Continent,Date,Population,TotalVaccinations)
as
(
Select dea.continent,MAX(CAST(dea.date as date))as LatestRecordedDate,SUM(dea.population),MAX(CONVERT(bigint,vac.total_vaccinations)) as TotalVaccinations
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
group by dea.continent
)
Select *,(TotalVaccinations/Population)*100 as 'Percentage of Population Vaccinated'
From PopvsVac
order by 5 desc;
