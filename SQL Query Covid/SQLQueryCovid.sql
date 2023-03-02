
Select * from CovidDeaths
where continent is not null
order by 3,4;

Select * from CovidVaccinations
where continent is not null
order by 3,4;


Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2;


-- Total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
where continent is not null
order by 1,2;


-- Total cases vs total deaths in USA
--likelihood of dying if you contract covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2;

-- Total cases vs total deaths in Bangladesh
--likelihood of dying if you contract covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
where continent is not null and location= 'bangladesh'
order by 1,2;

-- Total cases vs Total population
--likelihood of getting covid
Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
where location= 'Bangladesh'
order by 2;


-- Countries with highest infection rate compared with popution
Select location, population, max(total_cases) as HighestInectionCount, max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths
group by location, population
order by InfectedPercentage desc;

-- Top 10 Countries with highest infection rate compared with popution
Select top(10) location, population, max(total_cases) as HighestInectionCount, max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage desc;


-- Countries with highest death count compared with popution
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc;


-- Continent with highest death count compared with popution
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc;


-- Global data order by date
Select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1;

-- Total Population vs new Vaccination
Select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(Partition by cd.location order by cd.location, cd.date) as RollingTotalVaccination
--, (RollingTotalVaccination/cd.population)*100 
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location=cv.location
	and cd.date= cv.date
where cd.continent is not null
order by 2,3;



--Use CTE
with PopvsVac(Continent, Location, Date, Population, New_Vaccination,RollingTotalVaccination)
as
(
Select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(Partition by cd.location order by cd.location, cd.date) as RollingTotalVaccination
--, (RollingTotalVaccination/cd.population)*100 
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location=cv.location
	and cd.date= cv.date
where cd.continent is not null
--order by 2,3
)
Select *,(RollingTotalVaccination/population)*100 as RollingPercent
from PopvsVac
--where location='bangladesh'


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingTotalVaccination numeric
)


Insert into #PercentPopulationVaccinated
Select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(Partition by cd.location order by cd.location, cd.date) as RollingTotalVaccination
--, (RollingTotalVaccination/cd.population)*100 
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location=cv.location
	and cd.date= cv.date
--where cd.continent is not null
--order by 2,3

Select *, (RollingTotalVaccination/population)*100 as RollingPercent
from #PercentPopulationVaccinated





-- Create view for later visualization
Create View PercentPopulationVaccinated as
Select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(Partition by cd.location order by cd.location, cd.date) as RollingTotalVaccination
--, (RollingTotalVaccination/cd.population)*100 
from CovidDeaths cd
join CovidVaccinations cv
	on cd.location=cv.location
	and cd.date= cv.date
where cd.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated



--Create view total Global data
Create View TotalCovidCases as
Select sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
--order by 1

Select * from TotalCovidCases;



--Create view Global data by date
Create View TotalCovidCasesbyDate as
Select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date


Select * from TotalCovidCasesbyDate;


-- Create view for every continents death counts 

--Select location, sum(cast(new_deaths as INT)) as TotalDeathCount
--from CovidDeaths
--where continent is null
--and location not in ('World', 'European Union', 'International')
--group by location
--order by 1


Create View DeathCountbyContinent as
Select Continent, sum(cast(new_deaths as INT)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
--order by 1

Select * from DeathCountbyContinent;



-- Create View for infection count & percentage by location

Create View InfectionSummary as 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedPercentage
From CovidDeaths
Group by Location, Population
--order by InfectedPercentage desc

Select * from InfectionSummary
order by InfectedPercentage desc;


-- Create View for infection count & percentage by location and date

Create View InfectionSummarybyDate as
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedPercentage
From CovidDeaths
Group by Location, Population, date
--order by InfectedPercentage desc

Select * from InfectionSummarybyDate
order by InfectedPercentage desc;



-- Create View for Bangladesh

Create View BDSummary as 
Select location, date, total_cases, total_deaths, (total_cases/population)*100 as InfectedPercentage, 
(total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
where continent is not null and location= 'bangladesh'
--order by 1,2;


--Select Location, date, total_vaccinations
--from CovidVaccinations
--where location like '%state%'




-- Create View for total cases and deaths worldwide

Create View WorldData as 
Select location, date, total_cases, total_deaths
from CovidDeaths
where location = 'World'
--order by 1,2,3

Select * from WorldData