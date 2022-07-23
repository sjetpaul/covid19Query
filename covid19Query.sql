-- Tables
select *
from Covid19..CovidDeaths$
order by 1,2

select *
from Covid19..CovidVaccination$

-- Showing cases, deaths based on location population

select location, date, population,total_cases, total_deaths 
from Covid19..CovidDeaths$

-- Location based Total cases and deaths

select location, sum(total_cases) as TotalCases, sum(convert(float,total_deaths)) as TotalDeaths
from Covid19..CovidDeaths$
where continent is not null
group by location
order by 1

-- Continent total cases and total deaths

select location, sum(total_cases) as TotalCases, sum(cast(total_deaths as float)) as TotalDeaths
from Covid19..CovidDeaths$
where continent is null 
group by location
order by TotalDeaths desc

select continent, sum(total_cases) as TotalCases, sum(cast(total_deaths as float)) as TotalDeaths
from Covid19..CovidDeaths$ 
group by continent
order by TotalDeaths desc

-- Total Percent of Population got covid of India

select location,date,population,total_cases,(total_cases/population)*100 as CasesPercentage
from Covid19..CovidDeaths$
where location like '%india%'
order by 2

-- Total Cases and Total Deaths growing rate over the time in India

select location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathRate
from Covid19..CovidDeaths$
where location like '%india%'
order by 2

-- Contries Highest Infection rate Compared to population

select location, population, max(total_cases) as Highestinfection, max((cast(total_cases as int)/population)*100) as HighestInfectionRate
from Covid19..CovidDeaths$
where continent is not null
group by location, population
order by HighestInfectionRate desc

-- Country Highest death count of population

select location, population, max(cast(total_deaths as INT)) as HighestDeaths, max((cast(total_deaths as INT)/population)*100) as HighestDeathRate
from Covid19..CovidDeaths$
where continent is not null
group by location, population
order by HighestDeathRate DESC

-- Global Infection Rate over the Time

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as InfectionRate
from Covid19..CovidDeaths$
where continent is not null
group by date
order by 1

-- Joining two Table
select * 
from Covid19..CovidDeaths$ dea
join Covid19..CovidVaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date

-- Total Population vs Vaccination over all Locations
select dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.date) as VaccinationsDone
from Covid19..CovidDeaths$ dea
join Covid19..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2

select dea.location, dea.date, dea.population
,max(vac.total_vaccinations) as VaccinationsDone
from Covid19..CovidDeaths$ dea
join Covid19..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2

-- Percentage of Vaccination of Total Population
---- Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated(
location nvarchar(255),
date datetime,
population numeric,
VaccinationsDone numeric
)

insert into #PercentPopulationVaccinated
select dea.location, dea.date, dea.population
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.date) as VaccinationsDone
from Covid19..CovidDeaths$ dea
join Covid19..CovidVaccination$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *,(VaccinationsDone/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated
order by 1,2

---- Using CTE
with PopuVsVacci(location, date, population, VaccinationsDone) as
(
select dea.location, dea.date, dea.population
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.date) as VaccinationsDone
from Covid19..CovidDeaths$ dea
join Covid19..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *,(VaccinationsDone/population)*100 as PercentVaccinated
from PopuVsVacci
order by 1,2

---- Createing View 
create view percentPopulation as
select dea.location, dea.date, dea.population
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.date) as VaccinationsDone
from Covid19..CovidDeaths$ dea
join Covid19..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *,(VaccinationsDone/population)*100 as PercentVaccinated
from percentPopulation
order by 1,2
