--1. Take a look of the whole data. This would help us get to know the data.
select*
from WorldCovidDataMay2022..CovidDeaths$
order by 1,2


select*
from WorldCovidDataMay2022..CovidVaccinations$
order by 1,2

--2. Total cases VS Total Deaths per Country
--This number gonna tell you the likelihood of dying because of covid in each country.

select continent, location, SUM(new_cases) as total_case, SUM(CONVERT(bigint, new_deaths)) as total_death, 
(SUM(CONVERT(bigint, new_deaths))/SUM(new_cases))*100 as death_percentages
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
Group by continent, location
order by total_case desc, total_death desc

--3.Total Deaths per Continent
--This number gonna tell you the total of people died because of covid in each Continent.

select continent, SUM(CONVERT(bigint, new_deaths)) as TotalDeathCount, SUM(new_cases) as TotalCases,
(SUM(CONVERT(bigint, new_deaths))/SUM(new_cases))*100 as DeathPercentages
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null 
group by continent
order by  2 desc


--4. Total cases VS Population per Country
--Shows the percentages of Covid cases compared to population in each country

select continent, location, population, SUM(new_cases) as total_case, (SUM(new_cases)/population)*100 as CovidPatientPercentages 
--(total_deaths/total_cases)*100 as DeathPercentages
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
group by continent, location, population
order by 1

--5. Highest Infection Count in each Country
--Shows the percentages of Infection Rate in each Country
select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PercentPopulationInfected
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
group by location, population
order by 4 desc
 
 --date
select location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases)/population)*100 AS PercentPopulationInfected
from WorldCovidDataMay2022..CovidDeaths$
where continent is not null
group by location, population, date
order by 4 desc

--. GLOBAL Number
--.1 Global Number of Death Count and Cases

Select SUM(DISTINCT population) AS TotalPopulation, SUM(new_cases) as TotalCases, SUM(CONVERT(bigint, new_deaths)) as TotalDeaths, 
(SUM(CONVERT(bigint, new_deaths))/SUM(new_cases))*100 as TotalDeathPercentages, SUM(new_cases)/SUM(DISTINCT population) AS TotalRateCases
From WorldCovidDataMay2022..CovidDeaths$
where continent is not null


--.1 Global Number of Population and Vaccines
select SUM(DISTINCT dea.population) AS TotalPopulation, SUM(CONVERT(bigint, vac.new_vaccinations))/2 AS TotalVaccinationNumbers,
SUM(CONVERT(bigint, vac.new_vaccinations))/2/SUM(DISTINCT dea.population)*100 AS GlobalVaccinationRate
from WorldCovidDataMay2022..CovidVaccinations$ vac
join WorldCovidDataMay2022..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--. Looking at Total Population VS Vaccinations
--.1 Using CTE (Common Table Expression)
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
)
Select*, (people_vaccinated/population)*100 as vaccinated_rate
From PopvsVac


--7.2 Using Temp Table
Drop Table if exists #people_vaccinated_rate --This line will allow you to make changes after temp table created
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

Select*, (people_vaccinated/population)*100 as vaccinated_rate
From #people_vaccinated_rate

--. Create views to store data for later use.

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

