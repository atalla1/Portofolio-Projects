

Select *
From PortofolioProjectAnnualDeath..CovidDeaths$

--Looking at total cases vs death
--covid percentage per population
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null
Order by 1,2

--Looking at countries with highest infection rate
Select Location, Population, max(total_cases) as highest_infected, max((total_cases/population))*100 as PercentageInfectedPopulation
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null
Group by Location, Population
Order by PercentageInfectedPopulation desc

--Looking at countries with highest death count per population
Select Location, Population, max(cast(total_deaths as int)) as HighestDeaths, max((total_deaths/population))*100 as PercentageDeathPopulation
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null
Group by Location, Population
Order by HighestDeaths desc

--BY CONTINENT

--Looking at total cases vs death
--covid percentage per population
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is null
Order by 1,2

--Looking at continent with highest infection rate
Select continent, max(total_cases) as HighestInfected
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null 
Group by continent
Order by HighestInfected desc

--Looking at continent with highest death count per population
Select continent, max(cast(total_deaths as int)) as HighestDeaths
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null
Group by continent
Order by HighestDeaths desc

--Looking at global death percentage
Select date,  SUM(New_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as PercentageDeath
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null
group by date
order by 1,2

--Looking at death percentage 
Select SUM(New_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as PercentageDeath
From PortofolioProjectAnnualDeath..CovidDeaths$
Where continent is not null
order by 1,2


--vaccination

--Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortofolioProjectAnnualDeath..CovidDeaths$ dea
Join PortofolioProjectAnnualDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Looking at global daily vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VacDaily
From PortofolioProjectAnnualDeath..CovidDeaths$ dea
Join PortofolioProjectAnnualDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


With VacPop (continent, location, date, population, new_vaccinations, VacDaily)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VacDaily
From PortofolioProjectAnnualDeath..CovidDeaths$ dea
Join PortofolioProjectAnnualDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (VacDaily/population)*100 as PercentageVac
from VacPop

--Temp Table

Drop Table if exists #PercentagePopulationVac
Create Table #PercentagePopulationVac
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccinations numeric, 
VacDaily numeric
)
Insert into #PercentagePopulationVac 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VacDaily
From PortofolioProjectAnnualDeath..CovidDeaths$ dea
Join PortofolioProjectAnnualDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (VacDaily/population)*100 as PercentageVac
from #PercentagePopulationVac

--create view

Create view PercentagePopulationVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as VacDaily
From PortofolioProjectAnnualDeath..CovidDeaths$ dea
Join PortofolioProjectAnnualDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentagePopulationVac