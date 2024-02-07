Select *
from Covidvacinations
order by 3,4
Select *
from CovidDeath
order by 3,4

-- select the data we are going to be using
Select location , date , total_cases, new_cases,total_deaths,population
from CovidDeath
order by 1,2

-- Looking at the total cases vs the total deaths
-- shows the how likely dying in case of having covid in your country
Select location , date , total_cases,total_deaths ,  (cast(total_deaths as float) / cast(total_cases as float))*100 AS DeathRate 
-- we used cast as float as the data type in the sheet wasn't numeric
from CovidDeath
where location like '%states%'
order by 1,2

--Looking at total cases vs the population
Select location , date, total_cases, population , (total_cases/population )*100 as caseRate
from CovidDeath
where location = 'egypt'
order by 1,2

--Looking at Countries with highest infection rate according to population
Select location , population , Max(total_cases)as HighestInfection,  max((total_cases/population ))*100 as PrecentPopulationInfected
from CovidDeath
Group by location, population 
order by PrecentPopulationInfected desc

-- counting countries with highest death count per population
Select location , population , Max(total_deaths)as HighestDeath
from CovidDeath
where continent is not null
Group by location, population 
order by HighestDeath desc

-- counting Continents with highest death count
Select continent , Max(total_deaths)as HighestDeath
from CovidDeath
where continent is not null
Group by continent 
order by HighestDeath desc

-- looking at total population vs vacination
select dea.continent , dea.location, dea.date , vac.new_vaccinations , dea.population , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location,dea.date) as RollingPeopleVacination
--, (RollingPeopleVacination/population)*100
from CovidDeath dea
join Covidvacinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Global Numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as deathPrecentage
from CovidDeath
where continent is not null
order by 1,2

--use cte
with PopvsVac (continent,location,date,population,New_vaccinations,RollingPeopleVacination)
as( 
select dea.continent , dea.location, dea.date , vac.new_vaccinations , dea.population , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location,dea.date) as RollingPeopleVacination
--, (RollingPeopleVacination/population)*100
from CovidDeath dea
join Covidvacinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVacination / population)*100
from PopvsVac

--temp table
Drop table if exists #PrecentPopulationVaccinated
create table #PrecentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVacination numeric,
)
insert into #PrecentPopulationVaccinated
select dea.continent , dea.location, dea.date , vac.new_vaccinations , dea.population , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location,dea.date) as RollingPeopleVacination
--, (RollingPeopleVacination/population)*100
from CovidDeath dea
join Covidvacinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVacination / population)*100
from #PrecentPopulationVaccinated

create view PrecentPopulationVaccinated as
select dea.continent , dea.location, dea.date , vac.new_vaccinations , dea.population , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location 
order by dea.location,dea.date) as RollingPeopleVacination
--, (RollingPeopleVacination/population)*100
from CovidDeath dea
join Covidvacinations vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--select view
select*
from PrecentPopulationVaccinated