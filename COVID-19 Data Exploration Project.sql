SELECT * 
FROM ProtifolioProjects..CovidDeath
ORDER BY 3,4

--SELECT * 
--FROM ProtifolioProjects..CovidVacinations
--ORDER BY 3,4

--Select the data i am going to be using
SELECT location,date,total_cases,new_cases, total_deaths,population
FROM ProtifolioProjects..CovidDeath
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (CONVERT(decimal, total_deaths) / CONVERT(decimal, total_cases)) * 100 as DeathPercentage
FROM ProtifolioProjects..CovidDeath
where location like '%states%'
ORDER BY 1,2

-- Looking at the total cases vs popilation
-- show what percentage of popoulation got covid
SELECT location,date,total_cases,population, (CONVERT(decimal, total_cases) / CONVERT(decimal, population)) * 100 as PercentagePopulation
FROM ProtifolioProjects..CovidDeath
where location like '%states%'
ORDER BY 1,2

-- Looking at countries with the highest infection rate compare to population
SELECT location,population, Max(total_cases)as HighestInfectionCount,MAX((CONVERT(decimal, total_cases) / CONVERT(decimal, population))) * 100 as PercentagePopIlationInfected
FROM ProtifolioProjects..CovidDeath
--where location like '%states%'
group by location,population
ORDER BY PercentagePopIlationInfected desc


-- showing the countries with hidhest death count per population

SELECT location,population, Max(Cast(total_deaths as int)) as TotalDeathCount
FROM ProtifolioProjects..CovidDeath
--where location like '%states%'
where continent is not null 
group by location,population
ORDER BY TotalDeathCount desc

--let's break things down by continet
SELECT continent, Max(Cast(total_deaths as int)) as TotalDeathCount
FROM ProtifolioProjects..CovidDeath
--where location like '%states%'
where continent is not null 
group by continent
ORDER BY TotalDeathCount desc


--showing contintents with the highest death count per population

SELECT continent, Max(Cast(total_deaths as int)) as TotalDeathCount
FROM ProtifolioProjects..CovidDeath
--where location like '%states%'
where continent is not null 
group by continent
ORDER BY TotalDeathCount desc


--Global numbers
SELECT date,sum(cast(total_cases as int )) as total_cases,sum(Cast(total_deaths as int))as total_deaths,Sum(CONVERT(decimal, total_deaths) / CONVERT(decimal, total_cases)) * 100 as DeathPercentage
FROM ProtifolioProjects..CovidDeath
where continent is not null 
group by date
ORDER BY 1,2
 --total cases total number across the world

SELECT sum(CONVERT(decimal, total_cases)) as total_cases,sum(CONVERT(decimal, total_deaths))as total_deaths,Sum(CONVERT(decimal, total_deaths) / CONVERT(decimal, total_cases)) * 100 as DeathPercentage
FROM ProtifolioProjects..CovidDeath
where continent is not null 
ORDER BY 1,2


-- Looking at total population vs vaccinations
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations

FROM ProtifolioProjects..CovidDeath dea
Join ProtifolioProjects..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (decimal, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location) as RollingPeopleVaccinated

FROM ProtifolioProjects..CovidDeath dea
Join ProtifolioProjects..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3


--use CTE

with popvsVac(continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (decimal, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location) as RollingPeopleVaccinated

FROM ProtifolioProjects..CovidDeath dea
Join ProtifolioProjects..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/Population)*100
FROM popvsVac


-- temp table
Drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationVaccinated

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (decimal, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated

FROM ProtifolioProjects..CovidDeath dea
Join ProtifolioProjects..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2,3
select * , (RollingPeopleVaccinated/Population)*100
FROM #percentPopulationVaccinated


--Crating view to store data for later visualization

Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert (decimal, vac.new_vaccinations)) over (partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated

FROM ProtifolioProjects..CovidDeath dea
Join ProtifolioProjects..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * From 
PercentagePopulationVaccinated