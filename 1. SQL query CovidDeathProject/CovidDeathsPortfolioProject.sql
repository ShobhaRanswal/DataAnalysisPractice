select * 
from CovidVaccinations
order by 3,4

select * 
from CovidDeaths
where continent is not null
order by 3,4


select location , date ,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Total Cases vs Total Deaths
--shows likelihood of   dying if you contract covid in  your country
select location , date ,total_cases,total_deaths,(
total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%India%'
and continent is not null
order by 1,2


--total cases vs population
--shows what % of populations had got covid 
select location , date,population ,total_cases,(
total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%India%'
order by 1,2


-- looking at countries with highest popultion rate compared to population
select location ,population ,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%India%'
Group by location,population
order by PercentPopulationInfected desc

-- showing the countries  with  the highest death count per population

select  location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by  location
order by TotalDeathCount desc


-- by contient 
select  location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
Group by  location
order by TotalDeathCount desc

select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by  continent
order by TotalDeathCount desc


-- showing continent with highest deathcounts per populations

select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is  not null
Group by continent
order by TotalDeathCount desc



-- global numbers
select  date ,sum(new_cases)as total_cases ,sum(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from CovidDeaths
--where location like '%India%'
 where continent is not null
 group by date
order by 1,2


select sum(new_cases)as total_cases ,sum(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from CovidDeaths
--where location like '%India%'
 where continent is not null
 --group by date
order by 1,2


--looking at total population vs vaccinations

select *
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


select dea.continent ,dea.location ,
dea.date, dea.population,vac.new_vaccinations
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent ,dea.location ,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int , vac.new_vaccinations)) OVER(Partition by dea.location)
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



select dea.continent ,dea.location ,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int , vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (Continent,Location ,Date ,Population ,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent ,dea.location ,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int , vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population) *100
from PopvsVac

--TEMP Table 
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime ,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent ,dea.location ,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int , vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
From  #PercentPopulationVaccinated





--Creating view to store data 

create view PercentPopulationVaccinated as 
select dea.continent ,dea.location ,dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int , vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated