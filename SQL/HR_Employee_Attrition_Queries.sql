
select * from Employee_Attrition


-- Q1. How many employees are there in the organization?
SELECT COUNT(*) AS Total_Employees
FROM Employee_Attrition



-- Q2. How many employees stayed and how many left the organization?
SELECT
    CASE
        WHEN Attrition = 1 THEN 'Left'
        WHEN Attrition = 0 THEN 'Stayed'
    END AS Employee_Status,
    COUNT(*) AS Total_Employees
FROM Employee_Attrition
GROUP BY Attrition



-- Q3. What is the overall employee attrition rate?
SELECT  ROUND( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee_Attrition), 2 ) AS Attrition_Rate_Percentage
FROM Employee_Attrition
WHERE Attrition = 1



-- Q4. How many employees work in each department?
SELECT  Department , COUNT(*) AS Total_Employees
FROM Employee_Attrition
GROUP BY Department



-- Q5. What is the gender distribution of employees?
SELECT  Gender , COUNT(*) AS Total_Employees
FROM Employee_Attrition
GROUP BY Gender



-- Q6. What is the average monthly income of employees?
SELECT  ROUND(AVG(MonthlyIncome), 2) AS Average_Monthly_Income
FROM Employee_Attrition



-- Q7. Which department has the highest employee attrition rate?
SELECT TOP 1 Department ,
             COUNT(*) AS Employees_Left,
	         ROUND( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee_Attrition
	         WHERE Department = e.Department), 2) 
	         AS Attrition_Rate
FROM Employee_Attrition e
WHERE Attrition = 1
GROUP BY Department
ORDER BY Attrition_Rate DESC



-- Q8. Which job roles experience the highest employee attrition?
SELECT TOP 1 JobRole ,
             COUNT(*) AS Employees_Left,
	         ROUND( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee_Attrition
	         WHERE JobRole = e.JobRole), 2) 
	         AS Attrition_Rate
FROM Employee_Attrition e
WHERE Attrition = 1
GROUP BY JobRole
ORDER BY Attrition_Rate DESC



-- Q9. Does working overtime increase employee attrition?
SELECT OverTime ,
       COUNT(*) AS Employees_Left,
	   ROUND( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee_Attrition
	   WHERE OverTime = e.OverTime), 2) 
	   AS Attrition_Rate
FROM Employee_Attrition e
WHERE Attrition = 1
GROUP BY OverTime
ORDER BY Attrition_Rate DESC



-- Q10. Does monthly income differ between employees who stayed and left?
SELECT Attrition , AVG( MonthlyIncome ) AS Average_Monthly_Income
FROM Employee_Attrition
GROUP BY Attrition



-- Q11. Which age groups experience the highest employee attrition?
WITH AgeGroups AS
(
    SELECT *,
        CASE
            WHEN Age BETWEEN 18 AND 25 THEN '18-25'
            WHEN Age BETWEEN 26 AND 35 THEN '26-35'
            WHEN Age BETWEEN 36 AND 45 THEN '36-45'
            WHEN Age BETWEEN 46 AND 55 THEN '46-55'
            ELSE '56+'
        END AS Age_Group
    FROM Employee_Attrition
)

SELECT
    Age_Group , COUNT(*) AS Employees_Left,
    ROUND( COUNT(*) * 100.0 / ( SELECT COUNT(*) FROM AgeGroups AS a2
    WHERE a2.Age_Group = a1.Age_Group ), 2) 
	AS Attrition_Rate
FROM AgeGroups a1
WHERE Attrition = 1
GROUP BY Age_Group
ORDER BY Attrition_Rate DESC



-- Q12. Does job satisfaction influence employee attrition?
SELECT JobSatisfaction ,
       COUNT(*) AS Employees_Left,
	   ROUND( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee_Attrition
	   WHERE JobSatisfaction = e.JobSatisfaction), 2) 
	   AS Attrition_Rate
FROM Employee_Attrition e
WHERE Attrition = 1
GROUP BY JobSatisfaction
ORDER BY Attrition_Rate DESC



-- Q13. Rank employees by monthly income within each department.
SELECT Department , JobRole , Age , MonthlyIncome ,
       RANK() OVER ( PARTITION BY Department ORDER BY MonthlyIncome DESC ) AS Income_Rank
FROM Employee_Attrition



-- Q14. Find the Top 3 highest-paid employees in each department.
SELECT * 
FROM (
       SELECT Department , JobRole , Age , MonthlyIncome ,
       RANK() OVER ( PARTITION BY Department ORDER BY MonthlyIncome DESC ) AS Income_Rank
	   FROM Employee_Attrition
	 ) as x
WHERE Income_Rank <= 3
ORDER BY Department , Income_Rank



-- Q15. Which employees earn more than their department's average salary?
SELECT *
FROM
(
    SELECT Department , JobRole , Age , MonthlyIncome ,
    AVG(MonthlyIncome) OVER (PARTITION BY Department) AS Avg_Department_Salary
    FROM Employee_Attrition
) AS x
WHERE MonthlyIncome > Avg_Department_Salary



-- Q16. Calculate the average monthly income for each job level.
SELECT JobLevel , AVG(MonthlyIncome) AS Avg_JobLevel
FROM Employee_Attrition
GROUP BY JobLevel
ORDER BY JobLevel


-- Q17. Which departments have an attrition rate above the company average?
WITH DepartmentAttrition AS
(
    SELECT Department , ROUND ( COUNT(*) * 100.0 / 
	( SELECT COUNT(*) FROM Employee_Attrition WHERE Department = e.Department ), 2 ) AS Attrition_Rate
    FROM Employee_Attrition e
    WHERE Attrition = 1
    GROUP BY Department
)

SELECT *
FROM DepartmentAttrition
WHERE Attrition_Rate > (
                         SELECT ROUND ( COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee_Attrition), 2 )
                         FROM Employee_Attrition
                         WHERE Attrition = 1 )
						


-- Q18. Categorize employees into Experience Levels using CASE.
SELECT Department , JobRole , Age , TotalWorkingYears ,
    CASE
        WHEN TotalWorkingYears <= 2 THEN 'Fresher'
        WHEN TotalWorkingYears BETWEEN 3 AND 5 THEN 'Junior'
        WHEN TotalWorkingYears BETWEEN 6 AND 10 THEN 'Mid-Level'
        WHEN TotalWorkingYears BETWEEN 11 AND 20 THEN 'Senior'
        ELSE 'Expert'
    END AS Experience_Level
FROM Employee_Attrition



-- Q19. Find employees with the longest tenure in each department.
SELECT *
FROM
(
    SELECT Department , JobRole , Age , YearsAtCompany ,
    RANK() OVER ( PARTITION BY Department ORDER BY YearsAtCompany DESC ) AS Tenure_Rank
    FROM Employee_Attrition
) AS x
WHERE Tenure_Rank = 1



-- Q20. Create an HR Summary Report showing employee count, attrition rate, and average salary by department.
SELECT Department ,
       COUNT(*) AS Total_Employees ,
       ROUND( SUM(CASE WHEN Attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) , 2 ) AS Attrition_Rate ,
       ROUND(AVG(MonthlyIncome), 2) AS Average_Salary
FROM Employee_Attrition
GROUP BY Department
ORDER BY Department