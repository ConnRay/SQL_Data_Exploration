-- Verify Relevent columns Exist
SELECT 
    Continent, Location, date, total_cases, new_cases, total_deaths, population
FROM 
    sqldataexplorationcovid.covid.covid_deaths
ORDER BY 
    1,2


-- Total Cases Vs. Total Deaths for United States

SELECT
    Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
FROM 
    sqldataexplorationcovid.covid.covid_deaths
WHERE 
    Location = "United States"
ORDER BY 
    1,2

-- Total Cases Vs. population for the unitied states

SELECT
    Location, date, total_cases, population, (total_cases/population)*100 as contraction_percent
FROM 
    sqldataexplorationcovid.covid.covid_deaths
WHERE 
    Location = "United States"
ORDER BY 
    1,2

-- Output Country by Highest infection rate

SELECT
    Location, MAX(total_cases) as max_infection, population, max((total_cases/population)*100) as contraction_percent
FROM 
    sqldataexplorationcovid.covid.covid_deaths 
GROUP BY 
    population, Location
ORDER BY 
    contraction_percent DESC

-- Output Countries with highest total death percentages compared to population

SELECT
    Location, MAX(total_cases) as max_infection, Max(total_deaths) as max_deaths, population, max((total_cases/population)*100) as contraction_percent, max((total_deaths/population)* 100) as death_percent
FROM 
    sqldataexplorationcovid.covid.covid_deaths 
GROUP BY 
    population, Location
ORDER BY 
    death_percent DESC

-- Look at the Global Data

-- Global Death Percentage
SELECT
    date, SUM(new_cases) as world_total_cases, SUM(cast(new_deaths as int)) as world_total_deaths, (sum(cast(new_deaths as int))/ SUM(new_cases))*100 as world_death_percent
FROM 
    sqldataexplorationcovid.covid.covid_deaths
WHERE 
    continent is not null 
GROUP BY 
    date
ORDER BY    
    date 

-- Introduce vaccination data
Select *
FROM
    sqldataexplorationcovid.covid.covid_deaths as deaths JOIN sqldataexplorationcovid.covid.covid_vaccinations as vaxs
    ON deaths.location = vaxs.location and deaths.date = vaxs.date

-- Total vaccinations vs country population

WITH PopVsVax
AS
(
SELECT 
    deaths.continent, deaths.Location, deaths.date, deaths.population, vaxs.new_vaccinations, SUM(vaxs.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.Location, deaths.date) AS total_vax
FROM
    sqldataexplorationcovid.covid.covid_deaths as deaths JOIN sqldataexplorationcovid.covid.covid_vaccinations as vaxs
    ON deaths.location = vaxs.location and deaths.date = vaxs.date
WHERE 
    deaths.continent is not null
)
SELECT *, (total_vax/population)*100 as vax_percent
FROM 
    PopVsVax 
ORDER BY 
    2,3
