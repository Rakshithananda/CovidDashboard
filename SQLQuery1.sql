Select * 
From [Protfolio Project]..[COVIDDeaths]
where continent is not null
order by 3,4


--select data to use
Select location, date,  total_cases, new_cases, total_deaths, population
From [Protfolio Project]..[COVIDDeaths]
order by 1,2

-- total cases vs total deatha
Select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Protfolio Project]..[COVIDDeaths]
where location like '%india%'
order by 1,2

-- total cases vs population

Select location, date, total_cases,population , (total_cases/population)*100 as PercentageGotCovid
From [Protfolio Project]..[COVIDDeaths]
--where location like '%india%'
order by 1,2

--countries with highest infection rate vs population
Select Location,population, max(total_cases) as HighestInfection, max((total_cases/population))*100 as PercentagePopulationInfected
From [Protfolio Project]..[COVIDDeaths]
--where location like '%india%'
Group by location,population
order by 4 desc


-- counttries with the highest death count vs population
Select location,population, MAX(cast(total_deaths as int)) as HighestDeaths
From [Protfolio Project]..[COVIDDeaths]
--where location like '%india%'
where continent is not null
Group by location,population
order by HighestDeaths desc

--BY CONTINENT
--continent with highest death count
Select continent, MAX(cast(total_deaths as int)) as HighestDeaths
From [Protfolio Project]..[COVIDDeaths]
--where location like '%india%'
where continent is not null
Group by continent
order by HighestDeaths desc


 --Global

 Select date, sum(new_cases) as GlobalDailyCases , sum(cast(new_deaths as int)) as GlobalDailyDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathPercentage
From [Protfolio Project]..[COVIDDeaths]
--where location like '%india%'
where continent is not null
group by date
order by date -- removing this gives till date total number


select * 
From [Protfolio Project]..COVIDVacinations
order by 3,4


--join
select * 
From [Protfolio Project]..COVIDDeaths dea
join[Protfolio Project]..COVIDVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
order by 3,4

--total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From [Protfolio Project]..COVIDDeaths dea
join[Protfolio Project]..COVIDVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--total vacinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingCountOfVaccination
From [Protfolio Project]..COVIDDeaths dea
join[Protfolio Project]..COVIDVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use of CTE for population vs vaccination
with PopvsVac(continent, location, date, population, new_vaccinations, RollingCountOfVaccination)
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingCountOfVaccination
From [Protfolio Project]..COVIDDeaths dea
join[Protfolio Project]..COVIDVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)
Select * , (RollingCountOfVaccination/population)*100 as percentageVaccinated
From PopvsVac

--Temp table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountOfVaccination numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingCountOfVaccination
From [Protfolio Project]..COVIDDeaths dea
join[Protfolio Project]..COVIDVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * , (RollingCountOfVaccination/population)*100 as percentageVaccinated
From #PercentPopulationVaccinated

--create view
Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingCountOfVaccination
From [Protfolio Project]..COVIDDeaths dea
join[Protfolio Project]..COVIDVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

