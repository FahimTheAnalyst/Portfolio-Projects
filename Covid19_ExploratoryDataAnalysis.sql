/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

Select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- LOOKING AT DATA TO START WITH
Select Location, population, date, new_cases, total_cases,  total_deaths
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,3

--TOTAL CASES vs TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF U CONTRACT COVID IN YOUR COUNTRY
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 'Death Rate'
from PortfolioProject..CovidDeaths
where location = 'India'
and continent is not null
order by 2 desc

--TOTAL CASES vs POPULATION
--SHOWS THE PERCENTAGE OF THE POPULATION THAT GOT INFECTED WITH COVID IN YOUR COUNTRY	
select location,date,population,total_cases,((total_cases/population)*100) as 'Infection Rate'
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 2 desc

--SHOWS COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
select Location,MAX(CAST(date as date)) as 'Latest Recorded Date',Population,MAX(total_cases) as 'Total Infections Count' ,(MAX(total_cases)/population)*100 as 'Infection Rate'
from PortfolioProject..CovidDeaths
group by location,population
order by 5 desc

--SHOWS COUNTRIES WITH HIGHEST DEATH RATE COMPARED TO POPULATION
select Location,MAX(CAST(date as date)) as 'Latest Recorded Date',Population,MAX(total_cases) as 'Total Infections Count',MAX(CAST(total_deaths as int)) as 'Total Deaths Count',(MAX(CAST(total_deaths as float))/MAX(total_cases))*100 as 'Death Rate'
from PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by 6 desc;

--DEATHS IN EACH COUNTRY PER DAY
Select continent,location,cast(date as date) date,population,new_deaths,total_deaths,SUM(CONVERT(bigint,new_deaths)) OVER (partition by location order by date) as CumulativeDeaths
from PortfolioProject..CovidDeaths 
where continent is not null
order by 2,3

--AVERAGE DEATHS IN EACH COUNTRY PER DAY 
Select location,MAX(CAST(date as date)) as 'Latest Recorded Date',population,AVG(new_deaths) as 'Average Deaths Per Day'
from PortfolioProject..CovidDeaths 
where continent is not null
group by location,population
order by 4 desc

--BREAKING THINGS DOWN BY CONTINENT
--SHOWS CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
select Continent,MAX(CAST(date as date)) as 'Latest Recorded Date',population,SUM(CAST(new_deaths as int)) as 'Total Deaths Count'
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent,population
order by 4 desc
	
--GLOBAL NUMBERS
Select continent,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by 1,2

--TOTAL POPULATION VS VACCINATIONS
Select dea.continent,dea.location,cast(dea.date as date) date,dea.population,vac.new_vaccinations,vac.total_vaccinations 
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on vac.location=dea.location
	and vac.date=dea.date
where dea.continent is not null
order by 2,3

--USING CTE TO PERFORM CALCULATION 
--SHOWS PERCENTAGE OF POPULATION VACCINATED PER CONTINENT
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

--USING TEMP TABLE
--SHOWS PERCENTAGE OF POPULATION VACCINATED PER COUNTRY
Drop Table if exists #PercentPopulationVaccinated2
Create Table #PercentPopulationVaccinated2
(
Continent nvarchar(255),
Country nvarchar(255),
Date date,
Population numeric,
Total_Vaccinations bigint
)
Insert into #PercentPopulationVaccinated2
Select dea.continent,dea.location,MAX(CAST(dea.date as date))as LatestRecordedDate,dea.population,MAX(CONVERT(bigint,vac.total_vaccinations)) as Total_Vaccinations
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.population
Select *,(Total_Vaccinations/Population)*100 as 'Percentage of Population Vaccinated'
From #PercentPopulationVaccinated2
order by 6 desc;

--SHOWS VACCINATIONS PER DAY
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
Cumulative_Vaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,cast(dea.date as date) date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as Cumulative_Vaccinations
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
Select *,(Cumulative_Vaccinations/Population)*100 as 'Percentage of Population Vaccinated'
From #PercentPopulationVaccinated
order by 2,3 


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,MAX(CAST(dea.date as date))as LatestRecordedDate,dea.population,MAX(CONVERT(bigint,vac.total_vaccinations)) as Total_Vaccinations
from PortfolioProject..CovidDeaths dea	
join PortfolioProject..CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.population
 
Select * 
From PercentPopulationVaccinated