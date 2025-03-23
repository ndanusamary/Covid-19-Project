-- COVID-19 Data Analysis Using SQL

-- Exploring COVID-19 Cases and Deaths

-- Retrieve all records from Covid_deaths table
SELECT * 
FROM Covid_deaths
ORDER BY location, date;



-- Retrieve all records from Covid_vaccine table
 SELECT * 
 FROM Covid_vaccine
 ORDER BY location, date;



-- Key COVID-19 Metrics

-- Total Cases vs Total Deaths with Death Percentage
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM Covid_deaths
ORDER BY location, date;



-- Likelihood of contracting COVID in the United States
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM Covid_deaths
WHERE location LIKE '%United States%'
ORDER BY date;



-- Percentage of population infected in the United States
SELECT location, date, population, total_cases, 
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM Covid_deaths
WHERE location LIKE '%United States%'
ORDER BY date;



-- Countries with the highest infection rate compared to population

SELECT location, population, 
       MAX(total_cases) AS HighestInfectionRate, 
       MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM Covid_deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;



-- Countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Covid_deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- Global COVID-19 Statistics

-- Daily global numbers for total cases, deaths, and death percentage
SELECT date, SUM(new_cases) AS TotalCases, 
       SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
       (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM Covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Overall global total cases, deaths, and death percentage
SELECT SUM(new_cases) AS TotalCases, 
       SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
       (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM Covid_deaths
WHERE continent IS NOT NULL;

-- COVID-19 Vaccination Analysis

-- Joining Covid_deaths and Covid_vaccine tables
SELECT * 
FROM Covid_deaths dea
JOIN Covid_vaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date;

-- Total Population vs. Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covid_deaths dea
JOIN Covid_vaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- Rolling count of vaccinated people per country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Covid_deaths dea
JOIN Covid_vaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- Using CTE to calculate percentage of population vaccinated
WITH PopvsVac AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
  FROM Covid_deaths dea
  JOIN Covid_vaccine vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Using Temporary Table to Store Percentage of Population Vaccinated
DROP TABLE IF EXISTS PercentagePopulationVaccinated;
CREATE TABLE PercentagePopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Covid_deaths dea
JOIN Covid_vaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentagePopulationVaccinated;

-- Creating View for Future Visualizations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Covid_deaths dea
JOIN Covid_vaccine vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
