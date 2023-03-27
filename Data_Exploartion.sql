/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
select * from 
ProtfolioProject ..CovidDeaths$
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

select location,date,total_cases, new_cases,total_deaths,population
from ProtfolioProject..CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
--  Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
from ProtfolioProject..CovidDeaths$
Where location like 'India'
and continent is not null
order by 1,2

---Total Cases VS Population
---Shows what percentage of population infected with Covid

select location,date,total_cases,population,round((total_cases/population)*100,2) as  PercentPopulationInfected
from ProtfolioProject..CovidDeaths$
Where location like 'India'
order by 1,2

--Countries with HIghesgt Infection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as  PercentPopulationInfected
from ProtfolioProject..CovidDeaths$
--Where location like 'India'
Group by location,population
order by PercentPopulationInfected desc

--Countries Highest Death Count per Population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking things down by continent

--showing continents with the highest death count per population

select   continent ,max(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths$
where continent is  not null
group by    continent
order by TotalDeathCount desc 

---GLOBAL NUMBERS

select sum(new_cases),sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int)) /sum(new_cases)*100 as DeathPercentage--,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage
from ProtfolioProject..CovidDeaths$
where continent is  not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

---Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Contitnent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated


--Creating view to store data for later visualization

create view PercentPopulationVaccinated1 as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths$ dea
Join ProtfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated1