use protfolioproject;
select*
from dbo.covid_death
order by 3,4;
 
--modify the data with correct value because location and continent both column  has same name like asia , asia
 update covid_death
 set location = dbo.covid_death.continent
 where continent is not null ;
 --update data modify zeros into null in new cases and new deaths
update covid_death
SET new_cases = NULL
WHERE new_cases = 0
 -- newdeaths
 update covid_death
SET new_deaths = null
WHERE new_deaths = 0


--select location,date, total_cases,total_deaths, population
--from dbo.covid_death 
--order by 1,2 

--looking at total_cases vs total_death as a percentange
--shows likellihood of dying if you contract covid within your country 
select location,date, total_cases , total_deaths ,cast(total_deaths as float)/cast(total_cases as float)*100  as deathpercentage
from dbo.covid_death 
where location like '%states%' 
order by 1,2 ;
 
 --looking at total_cases vs population 
 --shows what percentage of population got covid
select location,date, total_cases , population ,cast(total_cases as float)/cast(population as float)*100  as covid_case_percentage
from dbo.covid_death 
where location like 'india' 
order by 1,2 ;

--looking at country with highest infeaction rate of covid
select location,population,max(cast(total_cases as float)) as higest_infeaction_rate, max(cast(total_cases as float)/cast(population as float))*100  as covid_infeaction_rate
from dbo.covid_death 
group by location,population
order by  covid_infeaction_rate desc;

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount
from dbo.covid_death 
where location <> dbo.covid_death .continent --it will eliminate row which has same name in both continent and location
group by location
order by totaldeathcount desc;

--let's break down by continent
--showing continent with highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from dbo.covid_death 
where location <> dbo.covid_death .continent --it will eliminate row which has same name in both continent and location
group by continent
order by totaldeathcount desc;
 
--GLOBAL NUMBERS OF TOTAL_CASES VS TOTAL_DEATHS VS DEATH_PERCENTAGE

select sum(cast(new_cases as int) ) as total_newcases  , SUM(CAST(new_deaths as int))  as total_deaths,
SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float)) * 100 as death_percentage
from dbo.covid_death 
-- where new_cases is not null  AND new_cases <> 0 
where location <> dbo.covid_death .continent --it will eliminate row which has same name in both continent and location
order by 1,2;


select*
from dbo.CovidVacination;

--lets join data set covidvaccination and covid_deaths
--looking at total_population vs vaccinations
--use cte
with PopulationVsVacci(continent,location,date,population,new_vaccinations,rollingupvaccinateds)
as
(
select death.continent,death.location,death.date,death.population,vacci.new_vaccinations,
sum(cast( vacci.new_vaccinations as float)) over (partition by death.location order by death.location , death.date) AS rollingupvaccinateds
from dbo.covid_death death
join dbo.covidvacination vacci
on death.location = vacci.location and
death.date = vacci.date
)
select*,((rollingupvaccinateds/population)*100 ) as vaccinated_per
from PopulationVsVacci

-- creating temp table looking at peapole got  vaccinated
create table #PopulationVaccinatedPer
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingupvaccinateds numeric,
)
insert into #PopulationVaccinatedPer
select death.continent,death.location,death.date,death.population,vacci.new_vaccinations,
sum(cast( vacci.new_vaccinations as float)) over (partition by death.location order by death.location , death.date) AS rollingupvaccinateds
from dbo.covid_death death
join dbo.covidvacination vacci
on death.location = vacci.location and
death.date = vacci.date

select*,((rollingupvaccinateds/population)*100 ) as vaccinated_per --to calculate percentage of vaccination by population count
from #PopulationVaccinatedPer

--creating view for later visualization
create view PopulationVaccinatedPer as
select death.continent,death.location,death.date,death.population,vacci.new_vaccinations,
sum(cast( vacci.new_vaccinations as float)) over (partition by death.location order by death.location , death.date) AS rollingupvaccinateds
from dbo.covid_death death
join dbo.covidvacination vacci
on death.location = vacci.location and
death.date = vacci.date
--order by 2,3
--creating view of TOTAL_CASES VS TOTAL_DEATHS VS DEATH_PERCENTAGE BY GLOBAL
create view golbaldeathpercentage as
select sum(cast(new_cases as int) ) as total_newcases  , SUM(CAST(new_deaths as int))  as total_deaths,
SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float)) * 100 as death_percentage
from dbo.covid_death 
-- where new_cases is not null  AND new_cases <> 0 
where location <> dbo.covid_death .continent --it will eliminate row which has same name in both continent and location