--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS total_cc
FROM prescriber
INNER JOIN prescription 
USING (npi)
GROUP BY npi
ORDER BY total_cc
LIMIT 1;
-- ASNWER NPI:1255318853 
-- 		Total_CC 11

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_cc
FROM prescription
INNER JOIN prescriber 
USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_cc DESC;


-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description,
FROM prescriber

SELECT specialty_description, SUM(total_claim_count) AS total_cc
FROM prescriber
INNER JOIN prescription
USING (npi)
GROUP BY specialty_description
ORDER BY total_cc
LIMIT 1;

-- b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_cc
FROM prescriber
INNER JOIN prescription
USING (npi)
INNER JOIN drug 
USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description, opioid_drug_flag
ORDER BY total_cc DESC;

-- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
-- d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. a. Which drug (generic_name) had the highest total drug cost?
SELECT *
FROM drug

SELECT total_drug_cost
FROM prescription

SELECT generic_name, SUM(total_drug_cost) AS total_dc
FROM prescription
INNER JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY total_dc DESC
LIMIT 1;
-- ANSWER INSULIN, $104264066.35 

-- b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name, ROUND(total_30_day_fill_count/30,2) AS cost_per_day
FROM prescription
INNER JOIN drug
USING (drug_name)
ORDER BY cost_per_day DESC
LIMIT 1;
-- ANSWER 151.30

--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT *
FROM drug

SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug;	

-- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT SUM(total_drug_cost::MONEY), opioid_drug_flag, antibiotic_drug_flag, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' ELSE 'neither'END
FROM drug
LEFT JOIN prescription
USING (drug_name)
GROUP BY opioid_drug_flag, antibiotic_drug_flag
ORDER BY SUM(total_drug_cost) DESC; 

--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN';
--ANSWER 10

SELECT state
FROM fips_county


-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT *
FROM cbsa

SELECT cbsaname, SUM(population) AS total_population
FROM cbsa
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population 
--ANSWER MAX(Morristown), MIN(Nashville)

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT *
FROM cbsa;
SELECT *
FROM population;

SELECT population, county
FROM population
INNER JOIN fips_county
USING (fipscounty)
WHERE fipscounty NOT IN (SELECT DISTINCT fipscounty
FROM cbsa)
ORDER BY population DESC;

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, SUM(total_claim_count) AS total_claim_count
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_name
HAVING SUM(total_claim_count) > 3000
ORDER BY total_claim_count DESC;


-- b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT *
FROM drug

SELECT drug_name, opioid_drug_flag, SUM(total_claim_count) AS total_cc, CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'other' 
	END AS drug_type
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_name, opioid_drug_flag
HAVING SUM(total_claim_count) > 3000
ORDER BY total_cc DESC;

-- c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, drug_name, opioid_drug_flag, SUM(total_claim_count) AS total_cc, CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	ELSE 'other' 
	END AS drug_type
FROM drug
INNER JOIN prescription
USING (drug_name)
INNER JOIN prescriber
USING (npi)
GROUP BY drug_name, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
HAVING SUM(total_claim_count) > 3000
ORDER BY total_cc DESC;

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
-- a.First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). 
-- **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.










