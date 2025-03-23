select * 
from Covid_deaths
order by 3,4 ;

--select * 
--from Covidvaccine
--order by 3,4 ;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_deaths
ORDER BY 1,2;

--Total cases vs Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_deaths
ORDER BY 1,2;

--Likelihood of contracting covid in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Percentage of population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM Covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

--Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_deaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


--Countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



-- By continent
---Continents with highest death count per population

 SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers


SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



--Joining the Covid death and Covid vaccine tables

SELECT * 
FROM Covid_deaths dea
JOIN CovidVaccine2 vac
  ON dea.location = vac.location
  and dea.date = vac.date


-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM Covid_deaths dea
JOIN CovidVaccine2 vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM Covid_deaths dea
JOIN CovidVaccine2 vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;






--USING CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
  
  AS
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM Covid_deaths dea
JOIN CovidVaccine2 vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopvsVac;






