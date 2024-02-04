--COVID DEATH DATA CLEANING

--Standardizing Date Format
ALTER TABLE CovidDeaths$
Add Converted_Date Date;

Update 
	CovidDeaths$
SET 
	Converted_Date = CONVERT(Date,date)

--checks if date format is correctly standardized 
Select 
	Converted_Date, CONVERT(Date,date)
From 
	PortfolioProject.dbo.CovidDeaths$

-- Remove duplicates based on all columns
;WITH CTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY continent, location, date ORDER BY (SELECT NULL)) AS RowNum
    FROM 
        PortfolioProject.dbo.CovidDeaths$
)
DELETE FROM CTE WHERE RowNum > 1;

--checks for columns needed for analysis with null values
SELECT 
	continent, location, Converted_Date, population, total_cases, new_cases, total_deaths, new_deaths, reproduction_rate,
	icu_patients, hosp_patients, weekly_icu_admissions, weekly_hosp_admissions, new_tests, total_tests, positive_rate, 
	tests_per_case, total_vaccinations, people_vaccinated, people_fully_vaccinated, new_vaccinations, 
	population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, 
	cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, life_expectancy
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	continent is not  null

-- Replace NULL values with 0 in the columns
UPDATE PortfolioProject.dbo.CovidDeaths$
SET 
    total_cases = COALESCE(total_cases, 0),
    total_deaths = COALESCE(CAST(total_deaths AS FLOAT), 0.0),
	new_deaths = COALESCE(CAST(new_deaths AS FLOAT), 0.0),
	reproduction_rate = COALESCE(CAST(reproduction_rate AS FLOAT), 0.0),
	icu_patients = COALESCE(CAST(icu_patients AS FLOAT), 0.0),
	hosp_patients = COALESCE(CAST(hosp_patients AS FLOAT), 0.0),
	weekly_icu_admissions = COALESCE(CAST(weekly_icu_admissions AS FLOAT), 0.0),
	weekly_hosp_admissions = COALESCE(CAST(weekly_hosp_admissions AS FLOAT), 0.0),
	new_tests = COALESCE(CAST(new_tests AS FLOAT), 0.0),
	total_tests = COALESCE(CAST(total_tests AS FLOAT), 0.0),
	positive_rate = COALESCE(CAST(positive_rate AS FLOAT), 0.0),
	tests_per_case = COALESCE(CAST(tests_per_case AS FLOAT), 0.0),
	total_vaccinations = COALESCE(CAST(total_vaccinations AS FLOAT), 0.0),
	people_vaccinated = COALESCE(CAST(people_vaccinated AS FLOAT), 0.0),
	people_fully_vaccinated = COALESCE(CAST(people_fully_vaccinated AS FLOAT), 0.0),
	new_vaccinations = COALESCE(CAST(new_vaccinations AS FLOAT), 0.0),
	extreme_poverty = COALESCE(CAST(extreme_poverty AS FLOAT), 0.0),
	female_smokers = COALESCE(CAST(female_smokers AS FLOAT), 0.0),
	male_smokers = COALESCE(CAST(male_smokers AS FLOAT), 0);

--Remove leading and trailing spaces from the 'location' and 'continent' column
UPDATE PortfolioProject..CovidDeaths$
SET location = LTRIM(RTRIM(location));
UPDATE PortfolioProject..CovidDeaths$
SET continent = LTRIM(RTRIM(continent));

--checking data quality by viewing the total count of numeric and non-numeric rows
SELECT 
    'total_cases' AS ColumnName,
    COUNT(*) AS TotalRows,
    COUNT(CASE WHEN ISNUMERIC(total_cases) = 1 THEN 1 ELSE NULL END) AS NumericRows,
    COUNT(CASE WHEN ISNUMERIC(total_cases) = 0 THEN 1 ELSE NULL END) AS NonNumericRows
FROM PortfolioProject.dbo.CovidDeaths$
UNION
SELECT 
    'total_deaths' AS ColumnName,
    COUNT(*) AS TotalRows,
    COUNT(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN 1 ELSE NULL END) AS NumericRows,
    COUNT(CASE WHEN ISNUMERIC(total_deaths) = 0 THEN 1 ELSE NULL END) AS NonNumericRows
FROM PortfolioProject.dbo.CovidDeaths$

--Cleaning Covid Vaccination Data
SELECT *
FROM PortfolioProject.dbo.CovidVaccinations$

--Replacing null values with 0
UPDATE PortfolioProject.dbo.CovidVaccinations$
SET 
    new_vaccinations = COALESCE(CAST(new_vaccinations AS FLOAT), 0.0)

--Standardizing Date Format
ALTER TABLE CovidVaccinations$
Add Date_converted Date;

Update 
	CovidVaccinations$
SET 
	Date_converted = CONVERT(Date,date)


--COVID DATA ANALYSIS
SELECT 
	continent, location, Converted_Date, population, total_cases, new_cases, total_deaths, new_deaths, reproduction_rate,
	icu_patients, hosp_patients, weekly_icu_admissions, weekly_hosp_admissions, new_tests, total_tests, positive_rate, 
	tests_per_case, total_vaccinations, people_vaccinated, people_fully_vaccinated, new_vaccinations, 
	population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, 
	cardiovasc_death_rate, diabetes_prevalence, female_smokers, male_smokers, handwashing_facilities, life_expectancy
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	continent is not  null
ORDER BY
	2,3

--Selects Location, Converted_date, total_cases, new_cases, total_deaths and population
SELECT 
	Location, Converted_Date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject..CovidDeaths$
ORDER BY
	1,2

--Shows the overall total cases and deaths
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_

--country with the highest population(the world's population is approximately 7.8bilion with china taking 1.4b of the world's population)
SELECT 
	location, MAX(Population) AS Max_population
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	continent is not null
GROUP BY 
	Location
ORDER BY 
	Max_population desc

--Country with the highest total cases(china has only 102,494 total cases while US has the highest total cases)
SELECT 
	location, MAX(total_cases) AS Max_totalcases
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	continent is not null
GROUP BY 
	Location
ORDER BY 
	Max_totalcases desc

--which country has the highest total death(china has only 4.845 total deaths while US has the highest total deaths)
SELECT 
	location, MAX(CAST(total_deaths as int)) AS Max_totaldeaths
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	continent is not null
GROUP BY 
	Location
ORDER BY
	Max_totaldeaths desc

--Countries with highest covid case
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%State%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


--Continent with highest covid death per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%State%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- shows the location, max_population, max_totalcases, max_totaldeaths, % survival rate
SELECT 
	location,
	MAX(Population) AS Max_population,
	MAX(total_cases) AS Max_totalcases, 
	MAX(CAST(total_deaths as int)) AS Max_totaldeaths,
	MAX(total_cases) - MAX(CAST(total_deaths AS INT)) AS Max_survival,
	MAX(CAST(total_deaths as int)) / MAX(Population) * 100 AS PercentPopulationInfected,
	MAX(CAST(total_deaths as int)) / MAX(total_cases) * 100 AS DeathPercentage,
	(MAX(total_cases) - MAX(CAST(total_deaths AS INT))) / MAX(total_cases) * 100 AS Max_survival_Rate
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	continent is not null
	and total_cases > 0
GROUP BY 
	Location
ORDER BY
	PercentPopulationInfected desc


--Total Cases Vs Population(PercentPopulationInfected) In United States
SELECT
	Location, Converted_Date, total_cases, Population, total_deaths, (total_cases/Population)*100 as PercentPopulationInfected
FROM
	PortfolioProject..CovidDeaths$
WHERE
	location like '%State%'
ORDER BY
	1,2

--Total Cases Vs Total Deaths (Death Percentage) In United States
SELECT 
	Location, Converted_Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM 
	PortfolioProject..CovidDeaths$
WHERE 
	location like '%States%'
	and total_cases > 0
ORDER BY 
	DeathPercentage desc


-- shows the unique date with the maximum number of cases
SELECT TOP 1
    Converted_Date,
    MAX(total_cases) AS Max_totalcases
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
GROUP BY 
    Converted_Date
ORDER BY
    Max_totalcases DESC

-- Shows the date with the maximum number of deaths
SELECT TOP 1
    Converted_Date,
    MAX(total_deaths) AS Max_totaldeaths
FROM 
    PortfolioProject..CovidDeaths$
WHERE 
    continent IS NOT NULL
GROUP BY 
    Converted_Date
ORDER BY
    Max_totaldeaths DESC;

--Total Population vs Vaccinations
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS One_point_moving_total
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac

--Creating View
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS One_point_moving_total
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated


/*

Queries used for Tableau Project

*/
--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total Death Per Continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Percentage Population Infected by Covid
Select Location, Population,Converted_Date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, Converted_Date
order by PercentPopulationInfected desc

--Percentage Population Infected Per Country
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc