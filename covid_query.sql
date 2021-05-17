--covid_vaccination table creation


create table covid_vaccination(iso_code varchar(25),continent varchar(25),location varchar(50),date date,new_tests varchar(25),total_tests varchar(25),total_tests_per_thousand varchar(25),
new_tests_per_thousand varchar(25),new_tests_smoothed varchar(25),new_tests_smoothed_per_thousand varchar(25),positive_rate varchar(25),
tests_per_case varchar(25),tests_units varchar(25),total_vaccinations varchar(25),people_vaccinated varchar(25),people_fully_vaccinated varchar(25),
new_vaccinations varchar(25),new_vaccinations_smoothed varchar(25),total_vaccinations_per_hundred varchar(25),
people_vaccinated_per_hundred varchar(25),people_fully_vaccinated_per_hundred varchar(25),
new_vaccinations_smoothed_per_million varchar(25),stringency_index double precision,population bigint,
median_age double precision,aged_65_older double precision,aged_70_older double precision,gdp_per_capita double precision,extreme_poverty varchar(25),
cardiovasc_death_rate double precision,diabetes_prevalence double precision,female_smokers varchar(25),male_smokers varchar(25),
handwashing_facilities double precision,hospital_beds_per_thousand double precision,
life_expectancy double precision,human_development_index varchar(25));

copy covid_vaccination from'E:\alex\covid_vacination.csv' delimiter ',' csv header;

--covid_death table creation


create table covid_death(iso_code varchar(50),continent varchar(50),location varchar(50),date date,population bigint,total_cases int,
new_cases int,new_cases_smoothed varchar(50),total_deaths int,new_deaths varchar(50),
new_deaths_smoothed varchar(50),total_cases_per_million varchar(50),new_cases_per_million varchar(50),
new_cases_smoothed_per_million varchar(50),total_deaths_per_million varchar(50),new_deaths_per_million varchar(50),
new_deaths_smoothed_per_million varchar(50),reproduction_rate varchar(50),icu_patients varchar(50),
icu_patients_per_million varchar(50),hosp_patients varchar(50),hosp_patients_per_million varchar(50),weekly_icu_admissions varchar(50),
weekly_icu_admissions_per_million varchar(50),weekly_hosp_admissions varchar(50),weekly_hosp_admissions_per_million varchar(50));

copy covid_death from'E:\alex\covid_deaths.csv' delimiter ',' csv header;

select * from covid_death order by 3,4;

select * from covid_vaccination order by 3,4;

--select data that we are going to be using


select location,date,total_cases,new_cases,total_deaths,population from covid_death  order by 1,2;


--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country


select location,date,total_cases,total_deaths,(total_deaths::numeric/total_cases::numeric)*100 as death_percentage 
from covid_death where location = 'India' and total_deaths is not null and continent is not null order by 1,2;


--looking at the total cases vs population
--shows whta percentage of population got covid


select location,date,population,total_cases,(total_cases::numeric/population::numeric)*100 as population_infect_percentage
from covid_death where continent is not null and location = 'India' order by 1,2;


--looking at countries with highest infection rate compared to population


select location,population,max(total_cases)as highest_infection_count,max(total_cases::numeric/population::numeric)*100 as population_infect_percentage
from covid_death 
where total_cases/population is not null
group by location,population order by 4 desc;

--showing countries with highest death count per population

select location,max(total_deaths)as totaldeathcount from covid_death
where continent is not null and total_deaths is not null
group by location 
order by totaldeathcount desc;

--let's break things down by continent
--showing continents with the highest death count per population

select continent,max(total_deaths) as totaldeathcount from covid_death 
where continent is not null group by continent order by totaldeathcount desc;

--global
select sum(population)as total_population,sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(new_deaths::numeric)/sum(new_cases::numeric)*100 as death_percentage 
from covid_death where continent is not null /*group by date*/ order by 1,2;

--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations::int) over (partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from covid_death as dea join covid_vaccination as vac on dea.location=vac.location 
and dea.date=vac.date where dea.continent is not null order by 2,3;

--use cte
with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations::int) over (partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from covid_death as dea join covid_vaccination as vac on dea.location=vac.location 
and dea.date=vac.date where dea.continent is not null --order by 2,3
)
select *,(rollingpeoplevaccinated::numeric/population::numeric)*100 as vaccinepercentage from popvsvac;

--temp table

create table percentpeoplevaccinated
(continent varchar(50),location varchar(50),date date,population bigint,new_vaccinations varchar(50),
rollingpeoplevaccinated bigint);


Insert into percentpeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations::int) over (partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from covid_death as dea join covid_vaccination as vac on dea.location=vac.location 
and dea.date=vac.date where dea.continent is not null; --order by 2,3

select *,(rollingpeoplevaccinated::numeric/population::numeric)*100 as vaccinepercentage from percentpeoplevaccinated;

--create view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations::int) over (partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from covid_death as dea join covid_vaccination as vac on dea.location=vac.location 
and dea.date=vac.date where dea.continent is not null; --order by 2,3;

select * from percentpopulationvaccinated;





















































