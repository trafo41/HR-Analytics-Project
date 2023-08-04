create database projects;
use projects;

select * from projects.hr;

alter table hr
change column ï»¿id emp_id varchar(20) null;

describe hr;

select birthdate from hr;

set sql_safe_updates = 0;

update hr
set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    else null
end;

alter table hr
modify column birthdate date;

select age from hr;

alter table hr
modify column hire_date date;

SET sql_mode = 'ALLOW_INVALID_DATES';

update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != ' ';

alter table hr
modify column termdate date;

alter TABLE hr add column age int;

update hr
set age = timestampdiff(Year, birthdate, curdate());

select count(*) from hr where termdate > curdate();

select count(*)
from hr
where termdate = '0000-00-00';


-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count
from hr
where age >= 18
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr
where age >= 18
group by race
order by count desc;

-- 3. What is the age distribution of employees in the company?
select 
	min(age) as youngest,
    max(age) as oldest
from hr
where age > 18;

select floor(age/10)*10 as age_group, count(*) as count
from hr
where age >= 18
group by age_group;

select 
  case 
    when age >= 18 and age <= 25 then '18-25'
    when age >= 26 and age <= 35 then '26-35'
    when age >= 36 and age <= 45 then '36-45'
    when age >= 46 and age <= 55 then '46-55'
    when age >= 56 and age <= 65 then '56-65'
    else '65+' 
  end as age_group, gender, count(*) as count
from hr 
where age >= 18
group by age_group, gender
order by age_group;

-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count
from hr
where age >= 18
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select ROUND(avg(datediff(termdate, hire_date))/365, 1) as avg_length_of_employment
from hr
where termdate <= curdate() and age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count
from hr
where age >= 18
group by department, gender
order by department;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count
from hr
where age >= 18
group by jobtitle
order by jobtitle desc;

-- 8. Which department has the highest turnover rate?
select department, count(*) as total_hired, 
    sum(case when termdate <= curdate() and termdate <> '0000-00-00' then 1 else 0 end) as termination_count, 
    sum(case when termdate = '0000-00-00' then 1 else 0 end) as active_count,
    (sum(case when termdate <= curdate() then 1 else 0 end) / count(*)) as termination_rate
from hr
where age >= 18
group by department
order by termination_rate desc;

-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as count
from hr
where age >= 18
group by location_state
order by count desc;

-- 10. How has the company's employee count changed over time based on hire and term dates?
select 
    hiring_year, 
    hires, 
    terminations, 
    (hires - terminations) as net_change,
    ROUND(((hires - terminations) / hires * 100), 2) as net_change_percent
from (
    select 
        Year(hire_date) as hiring_Year, 
        count(*) as hires, 
        sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations
    from hr
    where age >= 18
    group by year(hire_date)
) subquery
order by hiring_Year asc;
-- ---------------------------OR-----------------------------
select 
    Year(hire_date) as hiring_year, 
    count(*) as hires, 
    sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations, 
    count(*) - sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as net_change,
    ROUND(((count(*) - sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end)) / count(*) * 100),2) as net_change_percent
from hr
where age >= 18
group by year(hire_date)
order by year(hire_date) asc;
    
-- 11. What is the tenure distribution for each department?
select department, ROUND(avg(datediff(curdate(), termdate)/365),0) as avg_tenure
from hr
where termdate <= curdate() and termdate <> '0000-00-00' and age >= 18
group by department;

-- --------------------Insights----------------------
-- There are more male employees
-- White race is the most dominant while Native Hawaiian and American Indian are the least dominant.
-- The youngest employee is 20 Years old and the oldest is 57 Years old
-- 5 age groups were created (18-24, 25-34, 35-44, 45-54, 55-64). A large number of employees were between 25-34 followed by 35-44 while the smallest group was 55-64.
-- A large number of employees work at the headquarters versus remotely.
-- The average length of employment for terminated employees is around 7 Years.
-- The gender distribution across departments is fairly balanced but there are generally more male than female employees.
-- The Marketing department has the highest turnover rate followed by Training. The least turn over rate are in the Research and development, Support and Legal departments.
-- A large number of employees come from the state of Ohio.
-- The net change in employees has increased over the Years.
-- The average tenure for each department is about 8 Years with Legal and Auditing having the highest and Services, Sales and Marketing having the lowest.

