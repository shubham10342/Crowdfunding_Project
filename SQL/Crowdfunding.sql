CREATE DATABASE Crowdfunding; 			-- Created Crowdfunding Database

USE Crowdfunding; 						-- Selected Crowdfunding Database

CREATE TABLE Projects (					-- Created Table Projects
Project_ID INT,
Project_Status VARCHAR(50),
Project_Name VARCHAR(500),
country VARCHAR(100),
creator_id INT,
location_id INT,
category_id INT,
created_at DATE,
deadline DATE,
updated_at DATE,
state_changed_at DATE,
successful_at DATE,
launched_at DATE,
usd_pledged DECIMAL,
backers_count INT,
goalamount_usd DECIMAL,
Goal_Range VARCHAR (50),
ProjectDuration INT);

DESCRIBE Projects;

-- Imported project csv file
  
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Projects.csv' 	-- Load data from the specified CSV file (projects) on server
INTO TABLE Projects									-- Insert data into the 'Projects' table	
FIELDS TERMINATED BY ','							-- Fields in the file are separated by commas
ENCLOSED BY '"'										-- Fields may be enclosed in double quotes
LINES TERMINATED BY '\n'							-- Each row ends with a newline character
IGNORE 1 LINES										-- Skip the first line (usually column headers)
(
Project_ID,
Project_Status,
Project_Name,
country,
creator_id,
@location_id,																	
@category_id,
@created_at,
@deadline,
@updated_at,
@state_changed_at,
@successful_at,
@launched_at,
usd_pledged,
backers_count,
goalamount_usd,
Goal_Range,
ProjectDuration
)
SET 
  location_id = NULLIF(@location_id, ''),										-- Used variables to handle null values (If the value is an empty string (''), insert NULL instead.)
  category_id = NULLIF(@category_id, ''),										-- Used variables to handle null values (If the value is an empty string (''), insert NULL instead.)
  created_at = STR_TO_DATE(@created_at, '%d-%m-%Y'),							-- Used variable to handle date conversion into MySQL format
  deadline = STR_TO_DATE(@deadline, '%d-%m-%Y'),								-- Used variable to handle date conversion into MySQl format
  updated_at = STR_TO_DATE(@updated_at, '%d-%m-%Y'),							-- Used variable to handle date conversion into MySQl format
  state_changed_at = STR_TO_DATE(state_changed_at, '%d-%m-%Y'),					-- Used variable to handle date conversion into MySQl format
  successful_at = STR_TO_DATE(@successful_at, '%d-%m-%Y'),						-- Used variable to handle date conversion into MySQl format
  launched_at = STR_TO_DATE(@launched_at, '%d-%m-%Y');							-- Used variable to handle date conversion into MySQl format

-- Created Location Table

Create Table Location(
`Location_Id` INT,
`Location Name` VARCHAR(200),
`Country` VARCHAR(100),
`State` VARCHAR(100),
`Location_type` VARCHAR(200)
);

-- Imported Location Table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crowdfunding/location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Created Category Table

Create Table Category( 
id INT,
`Sub-Category` VARCHAR(200),
parent_id INT,
Ranking INT,
Category VARCHAR(200));

-- Imported Category Table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crowdfunding/Category.csv'
INTO TABLE category
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Created Calendar Table

Create Table Calendar 
(
`Date` Date,
`Year` INT,
Monthno INT,
Monthfullname VARCHAR (25),
`Quarter` VARCHAR(5),
YearMonth VARCHAR (25),
Weekdayno INT,
Weekdayname VARCHAR (25),
FinancialMonth VARCHAR (10),
FinancialQuarter VARCHAR (10),
FinancialYear INT, 
`FM-Sort` INT,
`Date (Year)` INT,
`Date (Quarter)` VARCHAR (25),
`Date (Month Index)` INT,
`Date (Month)` VARCHAR (10)
);

-- Import Calendar Table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crowdfunding/Calendar.csv'
INTO TABLE calendar
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
@`Date`,
`Year`,
Monthno,
Monthfullname,
`Quarter`,
YearMonth,
Weekdayno,
Weekdayname,
FinancialMonth,
FinancialQuarter,
FinancialYear, 
`FM-Sort`,
`Date (Year)`,
`Date (Quarter)`,
`Date (Month Index)`,
`Date (Month)`
)
SET
`Date` = STR_TO_DATE(@`Date`, '%d-%m-%Y')
;

-- created Creator Table

Create Table Creator
(
Creator_id INT,
Creator_name VARCHAR(300),
chosen_currency VARCHAR(25)
);

-- Imported Creator Table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crowdfunding/Creator.csv'
INTO TABLE Creator
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/*.................................................................................................................................................................... */
-- Created Index to optimize the performance of queries
Create Index idx_project_status ON Projects (Project_Status);
Create Index idx_Goal_Range ON Projects (Goal_Range); 
Create Index idx_creator_id ON Projects (creator_id); 
Create Index idx_location_id ON Projects (location_id);
Create Index idx_category_id ON Projects (category_id);  

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- KPI 5: Projects Overview KPI
-- i) Total Number of Projects based on outcome 
CREATE VIEW `Total Number of Projects based on outcome`  AS
Select Project_Status,Count(Project_ID) as Total_Projects
from Projects
Group by Project_Status
Order by Total_Projects Desc;
     
-- ii) Total Number of Projects based on Locations

CREATE VIEW `Total Number of Projects based on Locations`  AS
Select L.Country, Count(P.Project_ID) as Total_Projects
from Projects P
Left Join location L ON P.location_id = L.Location_Id
Group by L.Country
Order by Total_Projects Desc;

-- iii) Total Number of Projects based on  Category

CREATE VIEW `Total Number of Projects based on  Category`  AS
Select C.Category,C.`Sub-Category`, Count(P.Project_ID) as Total_Projects
from Projects P
Left Join Category C ON P.category_id = C.id
Group by C.Category,`Sub-Category`
Order by Total_Projects Desc;

-- iv) Total Number of Projects created by Year , Quarter , Month

-- By Financial Year
CREATE VIEW `Total Number of Projects created by Fin Year`  AS
Select D.FinancialYear, Count(P.Project_ID) as Total_Projects
from Projects P
Left Join Calendar D ON P.created_at = D.`Date`
Group by D.FinancialYear
Order by Total_Projects Desc;

-- By Financial Quarter
CREATE VIEW `Total Number of Projects created by Fin Quarter`  AS
Select D.FinancialQuarter, Count(P.Project_ID) as Total_Projects
from Projects P
Left Join Calendar D ON P.created_at = D.`Date`
Group by D.FinancialQuarter
Order by Total_Projects Desc;

-- By Financial Month
CREATE VIEW `Total Number of Projects created by Fin Month`  AS
Select D.FinancialMonth, Count(P.Project_ID) as Total_Projects
from Projects P
Left Join Calendar D ON P.created_at = D.`Date`
Group by D.FinancialMonth
Order by Total_Projects Desc;

/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- KPI 6.  Successful Projects:
-- i) Amount Raised

CREATE VIEW `Total Amount Raised by Successful Projects`  AS
Select Concat("$", Round(Sum(usd_pledged)/1000000000,2), "B") As Amount_Raised
From Projects
Where Project_Status = "Successful";

-- ii) Number of Backers

CREATE VIEW `Total Number of Backers in successful Projects`  AS
Select Concat(Round(Sum(backers_count)/1000000,2),"M") As Total_Backers
From Projects
Where Project_Status = "Successful";
     
-- iii) Avg Number of Days for successful projects

CREATE VIEW `Avg Number of Days for successful projects`  AS
Select Concat(Round(Avg(ProjectDuration)), " days") as Avg_No_of_Days_for_successful_projects
From Projects
Where Project_Status = "Successful";

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- KPI7 Top Successful Projects
-- i) Based on Number of Backers (Top 10)

CREATE VIEW `Top 10 Successful Projects based on no. of Backers`  AS
Select Project_Name, Sum(backers_count) as Total_Backers
From Projects
Group by Project_Name
Order by Total_Backers DESC
Limit 10;

-- ii) Based on Amount Raised.

CREATE VIEW `Top 10 Successful Projects based on amount raised`  AS
Select Project_Name, Sum(usd_pledged) as Total_Amount_Raised
From Projects
Group by Project_Name
Order by Total_Amount_Raised DESC
Limit 10;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- KPI8. Percentage of Successful Projects

-- i) Percentage of Successful Projects overall

CREATE VIEW `Percentage of Successful Projects overall`  AS
SELECT 
    CONCAT(ROUND((SUM(Project_Status = 'Successful') / COUNT(*)) * 100,
                    2),
            ' %') AS Successful_Projects_Percent
FROM
    Projects;

-- ii) Percentage of Successful Projects  by Category

CREATE VIEW `Percentage of Successful Projects  by Category`  AS
SELECT 
    C.Category,
    CONCAT(ROUND((SUM(P.Project_Status = 'Successful') / COUNT(*)) * 100,
                    2),
            ' %') AS Successful_Projects_Percent
FROM
    Projects P
        JOIN
    Category C ON P.category_id = C.id
GROUP BY C.category
ORDER BY Successful_Projects_Percent DESC;

-- iii) Percentage of Successful Projects by Year , Month etc..

-- By Financial Year

CREATE VIEW `Percentage of Successful Projects by Fin Year`  AS
SELECT 
    D.`FinancialYear`,
    CONCAT(ROUND((SUM(P.Project_Status = 'Successful') / COUNT(*)) * 100,
                    2),
            ' %') AS Successful_Projects_Percent
FROM
    Projects P
        JOIN
    Calendar D ON P.created_at = D.`Date`
GROUP BY D.`FinancialYear`
ORDER BY Successful_Projects_Percent DESC;

-- By Financial Quarter
CREATE VIEW `Percentage of Successful Projects by Fin Quarter`  AS
SELECT 
    D.`FinancialQuarter`,
    CONCAT(ROUND((SUM(P.Project_Status = 'Successful') / COUNT(*)) * 100,
                    2),
            ' %') AS Successful_Projects_Percent
FROM
    Projects P
        JOIN
    Calendar D ON P.created_at = D.`Date`
GROUP BY D.`FinancialQuarter`
ORDER BY Successful_Projects_Percent DESC;

-- By Financial Month

CREATE VIEW `Percentage of Successful Projects by Fin Month`  AS
SELECT 
    D.`FinancialMonth`,
    CONCAT(ROUND((SUM(P.Project_Status = 'Successful') / COUNT(*)) * 100,
                    2),
            ' %') AS Successful_Projects_Percent
FROM
    Projects P
        JOIN
    Calendar D ON P.created_at = D.`Date`
GROUP BY D.`FinancialMonth`
ORDER BY Successful_Projects_Percent DESC;

-- iv) Percentage of Successful projects by Goal Range (decide the range as per your need)

CREATE VIEW `Percentage of Successful projects by Goal Range`  AS
SELECT 
    Goal_Range,
    CONCAT(ROUND((SUM(Project_Status = 'Successful') / COUNT(*)) * 100,
                    2),
            ' %') AS Successful_Projects_Percent
FROM
    Projects
GROUP BY Goal_Range
ORDER BY Successful_Projects_Percent DESC;
