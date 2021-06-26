--SELECT *
--From Elias_Project.dbo.CovidDeaths
--Where continent is not null
--Order by 3,4
 

Select location, date, total_cases, new_cases, total_deaths, population
From Elias_Project.dbo.CovidDeaths
Order by 1,2 


-- Total Cases vs. Total Deaths
-- Showing likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Elias_Project.dbo.CovidDeaths
WHERE location like '%states%'
Order by 1,2 


--Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases,(total_cases/population)*100 as CasePercentage
From Elias_Project.dbo.CovidDeaths
--WHERE location like '%states%'
Order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Elias_Project.dbo.CovidDeaths
--WHERE location like '%states%'
Group By location, population
Order by PercentPopulationInfected DESC 


--Let's Break This Down By Continent 

-- Showing  continents with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Elias_Project.dbo.CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount DESC

-- Showing Countries with Highest Death Count per Population 
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Elias_Project.dbo.CovidDeaths
Where continent is not null
Group By location
Order by TotalDeathCount DESC


-- Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From Elias_Project.dbo.CovidDeaths
Where continent is not null
Group By date
order by 1,2

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From Elias_Project.dbo.CovidDeaths
Where continent is not null
order by 1,2



SELECT *
From Elias_Project.dbo.CovidVaccination
Order by 3,4



--Looking aat Total Population vs. Vaccination

update Elias_Project.dbo.CovidVaccination set new_vaccinations = replace(replace(new_vaccinations,'.',''),',','')
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Elias_Project.dbo.CovidDeaths dea
Join Elias_Project.dbo.CovidVaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Elias_Project.dbo.CovidDeaths dea
Join Elias_Project.dbo.CovidVaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac





-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Elias_Project.dbo.CovidDeaths dea
Join Elias_Project.dbo.CovidVaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(convert(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From Elias_Project.dbo.CovidDeaths dea
Join Elias_Project.dbo.CovidVaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null