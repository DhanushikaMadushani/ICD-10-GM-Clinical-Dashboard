-- ============================================================================
-- GERMAN INPATIENT FLOW & DIAGNOSIS INTELLIGENCE (DESTATIS)
-- Upstream Verification & KPI Calculation
-- ============================================================================

-- ============================================================================
-- 1. SCHEMA DEFINITION & DATA INGESTION
-- ============================================================================
 drop table if exist hospital_admissions;
 
create table hospital_admissions(
	census_year int,
	department varchar (100),
	icd_code varchar (50),
	diagnosis varchar (255),
	patient_count int,
	demographic_group varchar (100),
	age_group varchar (50),
	age_sort_order int
);


-- ============================================================================
-- 2. CLINICAL KPI VERIFICATION & ANALYTICAL QUERIES
-- ============================================================================

--KPI 1: Total inpatient count

select sum(patient_count) as total_inpatient_count
from hospital_admissions;


--KPI 2: Geritric cases (65+)

select 
    sum(patient_count) as total_inpatient_admissions,
    sum(case 
        when demographic_group ilike '%65%' 
          or demographic_group ilike '%70%' 
          or demographic_group ilike '%75%' 
          or demographic_group ilike '%80%' 
          or demographic_group ilike '%85%' 
          or demographic_group ilike '%90%' 
          or demographic_group ilike '%jahre und mehr%'
        then patient_count 
        else 0 
    end) as geriatric_cases_65_plus
from hospital_admissions;


--KPI 3: Pediatric Cases (<18)

select
	sum (patient_count) as total_inpatient_admissions,
	sum(case
		when demographic_group ilike '%unter 1 Jahr%'
			or demographic_group ilike '%1 bis unter 5%'
			or demographic_group ilike '%5 bis unter 10%'
			or demographic_group ilike '%10 bis unter 15%'
			or demographic_group ilike '%15 bis unter 18%'
		then patient_count
		else 0
	end) as pediatric_cases_under_18
from hospital_admissions;

--KPI 4 & 5: Male and female case ratio

select 
    round(
        100* sum(case when demographic_group ilike '%männlich%' then patient_count else 0 end)::numeric 
        / nullif(sum(patient_count), 0), 
	2) AS male_ratio,

	round(
		100* sum(case when demographic_group ilike '%weiblich%' then patient_count else 0 end) ::numeric
		/ nullif(sum(patient_count),0),
	2) as female_ratio
	
from hospital_admissions;

--KPI 6: Department load share

select 
	department,
	sum(patient_count) as department_admissions,
	round(
		100.0 * sum(patient_count) / sum(sum (patient_count)) over (), 
		2) as department_load_share_pct		
from hospital_admissions
group by department
order by department_admissions desc;


-- KPI 7:Diagnosis rank

with ranked_diagnoses as (
    select 
        icd_code,
        diagnosis,
        sum(patient_count) as total_cases,
        dense_rank() over (order by sum(patient_count) desc) as diagnosis_rank
    from hospital_admissions
    group by icd_code, diagnosis
)
select 
    diagnosis,
	icd_code,
    total_cases,
	diagnosis_rank
from ranked_diagnoses
where diagnosis_rank <= 10
order by diagnosis_rank asc;

--KPI 8: Demographic volumn destribution

select 
	age_group,
	sum(patient_count) as total_cases
from hospital_admissions
group by age_group
order by total_cases desc;
