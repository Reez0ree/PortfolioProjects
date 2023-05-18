Select * 
From PortfolioProject..CovidDeaths$
Order by 3, 4


--Select Data that going to be used

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

--Looking at the total cases vs Total Deaths in South africa
--Show % of getting Covid
Select Location, Date, total_cases, total_deaths, (CONVERT(decimal, total_deaths) / CONVERT(decimal, total_cases)) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where Location like '%South Afr%'
Order by 1,2

--Total Cases vs Population
--Show % of what population got Covid in Continent
Select continent, Date, total_cases, population, (CONVERT(decimal, total_deaths) / CONVERT(decimal,population)) * 100 AS PopulationPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by continent desc
--Show % of what population got Covid in South africa
Select Location, Date, total_cases, population, (CONVERT(decimal, total_deaths) / CONVERT(decimal,population)) * 100 AS PopulationPercentage
From PortfolioProject..CovidDeaths$
Where Location like '%South Afr%'
Order by 1,2


--Highest Infection Rate Compared to the population

Select Location,  max(total_cases) as HighestInfectionLocation, population, max(CONVERT(decimal, total_cases) / CONVERT(decimal,population))* 100 AS HIR
From PortfolioProject..CovidDeaths$
--Where Location like '%South Afr%'
GROUP BY Location,population
Order by HIR desc

--Highest deaths per population country
Select Location,  max(cast(total_deaths as int)) as HighestDeathLocation
From PortfolioProject..CovidDeaths$
Where continent is not null
GROUP BY Location
Order by HighestDeathLocation desc

-- Highest death per population per continent

Select location,  max(cast(total_deaths as int)) as HighestDeathLocation
From PortfolioProject..CovidDeaths$
Where continent is null
GROUP BY location
Order by HighestDeathLocation desc

--World Numbers
SELECT  Date,SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths as int)) as total_new_deaths,
  (SUM(CAST(new_deaths as int)) * 100) / NULLIF(SUM(new_cases), 0) as DeathPercent
FROM  PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY Date

---######Vacciantions#####-----
Select * 
From PortfolioProject..CovidVaccinations$



---######Table Join#####-----
Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date


--Total Population Vs Total Vacciations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac(Continent, Location , date, population, new_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations , 
sum(CONVERT(decimal, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
From PopvsVac