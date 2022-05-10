--Take a look of the whole data
select*
from WorldCovidDataMay2022..CovidDeaths$
order by 1,2

select location, date, new_vaccinations
from WorldCovidDataMay2022..CovidVaccinations$
where location like 'Indonesia' and continent is not null
order by 1,2

--Total cases VS Total Deaths
--This number gonna tell you the likelihood of dying because of covid in each country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
--group by location
order by total_cases desc

--Total cases VS Population
--Shows the percentage of Covid cases compared to population

select location, date, total_cases, population, (total_cases/population)*100 as CovidPatientPercentages, (total_deaths/total_cases)*100 as DeathPercentages
from WorldCovidDataMay2022..CovidDeaths$
--group by location
order by CovidPatientPercentages desc

--Shows the highest number of Covid cases compared to population

select location, population, MAX(total_cases) HighestCaseCount, MAX((total_cases/population))*100 as CovidPatientPercentages
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
group by location, population
order by CovidPatientPercentages desc


--Shows countries with highest deaths compared to population

select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount, MAX((total_deaths/population)*100) as DeathRate
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- TOTAL GLOBAL NUMBERS

select SUM(new_cases) as world_cases, SUM(cast(new_deaths as int)) as world_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentages
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null 
--AND DeathPercentages >1.0
--group by date
order by 1,2

--Looking at Total Population VS Vaccinations
--Using CTE (Common Table Expression)
with PopvsVac (continent, location, date, population, new_vaccination, people_vaccinated)
AS
(
--create view people_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as people_vaccinated
from WorldCovidDataMay2022..CovidDeaths$ dea
Join WorldCovidDataMay2022..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)
Select*, (people_vaccinated/population)*100 as vaccinated_rate
From PopvsVac
where location like '%united state%'


--Temp Table
Drop Table if exists #people_vaccinated_rate
Create Table #people_vaccinated_rate
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
people_vaccinated numeric
)

Insert into #people_vaccinated_rate
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as people_vaccinated
from WorldCovidDataMay2022..CovidDeaths$ dea
Join WorldCovidDataMay2022..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3 

Select*, (people_vaccinated/population)*100 as vaccinated_rate
From #people_vaccinated_rate
where location like '%united state%'

--Create views to store data for later use.

USE [WorldCovidDataMay2022]
go
Create View people_vacccinated_rates AS
with PopvsVac (continent, location, date, population, new_vaccination, people_vaccinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
order by dea.location, dea.date) as people_vaccinated
from WorldCovidDataMay2022..CovidDeaths$ dea
Join WorldCovidDataMay2022..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)
Select*, (people_vaccinated/population)*100 as vaccinated_rate
From PopvsVac