

/* 
-- Connect to the class server for this exercise.
-- IS-HAY09.iSchool.UW.EDU
-- UNIVERSITY database

The following 5 questions are based on material introduced in Module 6. The last 2 questions are similar in that each involve creating a stored procedure that calls other stored procedures (aka 'nested' procedures). There are four expectations when following best-practices:
1) the outer (aka 'calling') stored procedure will call each nested stored procedure to retrieve every foreign key value
2) the FK value that is retrieved via nested stored procedure will be placed into a variable before being used in any transaction
3) all input parameters of both the calling and nested procedures are to use 'name' values of foreign keys as opposed to hard-coding actual foreign key ID values
4) Assume identity() is enabled on all tables to auto-increment each primary key value
*/

/*
Q1  Write the SQL code to find the 3 staff who have worked at UW the longest under the following conditions. 
HINTS: 
1) Account for NULL values in EndDate for people still actively employed (they do not have an EndDate) by using ISNULL() function
2) Considering using DateDiff() with DAY in first position with the results divided by 365.25 to obtain decimal values in the result
3) Change the resulting value from 6 decimal places to 2 using CAST()
4) Consider only those staff that has a position of the following: 'Facilities Assistant', 'Academic Support Officer', 'Academic Compliance Director',
'Academic Tutor','Landscape Engineer', 'Grant Writer', 'Researcher'
*/

SELECT top 3 S.StaffID, S.StaffFName, S.StaffLName, CAST(DateDiff(Day, BeginDate, ISNULL(EndDate, GetDate()))  AS DECIMAL(18,2)) /365.25 AS Employed_Year
FROM tblSTAFF S
	JOIN tblSTAFF_POSITION SP ON S.StaffID = SP.StaffID
    JOIN tblPOSITION P ON SP.PositionID = P.PositionID 
WHERE P.PositionName IN ('Facilities Assistant', 'Academic Support Officer', 'Academic Compliance Director',
'Academic Tutor','Landscape Engineer', 'Grant Writer', 'Researcher')
ORDER BY Employed_Year DESC


/*
Q2 Write the SQL code to find the top 3 Departments ordered by the most dollars received from RegistrationFees with the following conditions:
1) classes are '300-level' (Hint: CourseNumber begins with a '3') 
2) only measure fees from students that have the number '5' in the third position of their areacode
3) only measure fees that are associated with a registration date between March 3, 1997 and September 23, 2012
*/

SELECT TOP 3 D.DeptID, D.DeptName, SUM(CLT.RegistrationFee) AS RegistrationFee
FROM tblDEPARTMENT D
 JOIN tblCOURSE CO ON CO.DeptID = D.DeptID
 JOIN tblCLASS C ON C.CourseID = CO.CourseID
 JOIN tblCLASS_LIST CLT ON CLT.ClassID = C.ClassID
 JOIN tblSTUDENT S ON S.StudentID = CLT.StudentID
WHERE CO.CourseNumber LIKE '3%'
AND CLT.RegistrationDate BETWEEN 'March 3, 1997' AND 'September 23, 2012'
AND SUBSTRING(S.StudentAreaCode, 3, 1) = 5
GROUP BY D.DeptID, D.DeptName
ORDER BY RegistrationFee DESC


/*
Q3 Write the SQL code to label every student into one of the following based on their birthdate and return a count of how many are under each label (HINT: this will be easiest if you use a CASE statement):
1) if they were born before January 1, 1925, label them as 'Greatest Generation'  
2) if they were born between 1925 and 1945, label them as 'Silent Generation'
3) if they were born between 1946 and 1964, label them as 'Baby Boomers'
4) if they were born between 1965 and 1976, label them as 'Generation X'
5) if they were born between 1977 and 1995, label them as 'Millenials'
6) Else 'Generation ZZZZZZZ'
*/

SELECT (CASE
	WHEN S.StudentBirth < 'January 1, 1925'
	THEN 'Greatest Generation'
	WHEN S.StudentBirth BETWEEN '1925' AND '1945'
	THEN 'Silent Generation'
	WHEN S.StudentBirth BETWEEN '1946' AND '1964'
	THEN 'Baby Boomers'
	WHEN S.StudentBirth BETWEEN '1965' AND '1976'
	THEN 'Generation X'
	WHEN S.StudentBirth BETWEEN '1977' AND '1995'
	THEN 'Millenials'
	ELSE 'Generation ZZZZZZZ'
	END) AS Student_Label, COUNT(*) AS NumofPeople
FROM tblSTUDENT S
GROUP BY (CASE
	WHEN S.StudentBirth < 'January 1, 1925'
	THEN 'Greatest Generation'
	WHEN S.StudentBirth BETWEEN '1925' AND '1945'
	THEN 'Silent Generation'
	WHEN S.StudentBirth BETWEEN '1946' AND '1964'
	THEN 'Baby Boomers'
	WHEN S.StudentBirth BETWEEN '1965' AND '1976'
	THEN 'Generation X'
	WHEN S.StudentBirth BETWEEN '1977' AND '1995'
	THEN 'Millenials'
	ELSE 'Generation ZZZZZZZ'
	END)
ORDER BY NumofPeople DESC

/*
Q4 Write the SQL to create a stored procedure to INSERT and new row into tblSTAFF_POSITION that calls three nested stored procedures (one for each FK). You will need to write the SQL code to create the nested stored procedures as well. Include an explicit transaction as well as error-handling if any variable ends-up NULL (either RAISERROR or THROW).

HINT: Use @Fname, @Lname, and @Birthdate as parameters to retrieve StaffID; use @DeptName to retrieve DeptID, and @PosName to obtain PositionID. There will be 2 additional parameters that pass values straight through to the INSERT statement, including @BeginDate and @EndDate (which may be NULL).
*/

GO
CREATE PROCEDURE GET_STUFFID
@Fname varchar(60),
@Lname varchar(60),
@Birthdate Date,
@S_ID INT OUTPUT
AS
SET @S_ID = (SELECT  S.StaffID
                FROM tblSTAFF S
                WHERE S.StaffFName = @Fname
                AND S.StaffLName = @Lname 
                AND S.StaffBirth = @Birthdate)
GO

CREATE PROCEDURE GET_DEPTID
@DeptName varchar(50),
@Dep_ID INT OUTPUT
AS
SET @dep_ID = (SELECT  D.DeptID
               FROM tblDEPARTMENT D
               WHERE D.DeptName = @DeptName)
GO

CREATE PROCEDURE GET_POSID
@PosName varchar(50),
@PO_ID INT OUTPUT
AS
SET @PO_ID = (SELECT  PO.PositionID
               FROM tblPOSITION PO
               WHERE PO.PositionName = @PosName)
GO

CREATE PROCEDURE INSERT_NEWSTUFF
@Fname varchar(60),
@Lname varchar(60),
@Birthdate Date,
@DeptName varchar(50),
@PosName varchar(50),
@BeginDate Date
AS

DECLARE @StaffID INT, @DEPID INT, @PosID INT

EXEC GET_STUFFID
@Fname = @Fname,
@Lname = @Lname,
@Birthdate = @Birthdate,
@S_ID = @StaffID OUTPUT

IF @StaffID IS NULL
	BEGIN
		PRINT '@StaffID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@StaffID cannot be NULL; Operation Terminating', 1;
	END

EXEC GET_DEPTID
@DeptName = @DeptName,
@Dep_ID = @DEPID OUTPUT

IF @DEPID IS NULL
	BEGIN
		PRINT '@DEPID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@DEPID cannot be NULL; Operation Terminating', 1;
	END


EXEC GET_POSID
@PosName = @PosName,
@PO_ID = @PosID OUTPUT

IF @PosID IS NULL
	BEGIN
		PRINT '@PosID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@PosID cannot be NULL; Operation Terminating', 1;
	END

INSERT INTO tblSTAFF_POSITION (StaffID, PositionID, BeginDate, DeptID)
VALUES (@StaffID, @PosID, @BeginDate, @DEPID)
GO

/*
Q5 Write the SQL to create a stored procedure to INSERT and new row into tblCLASS that calls four nested stored procedures (one for each FK). You will need to write the SQL code to create the nested stored procedures as well. Include an explicit transaction as well as error-handling if any variable ends-up NULL (either RAISERROR or THROW).

HINT: Use @Q_Name to obtain QuarterID, @C_Name to obtain CourseID, @C_Room to obtain ClassroomID, and @ScheduleName to retrieve ScheduleID. There will be 2 additional parameters that pass values straight through to the INSERT statement, including @Year and @Section.
*/

CREATE PROCEDURE GETQUARTER
@QuarterName varchar(60),
@Q_ID INT OUTPUT
AS
SET @Q_ID = (SELECT  Q.QuarterID
                FROM  tblQUARTER Q
                WHERE Q.QuarterName = @QuarterName)
GO

CREATE PROCEDURE GETCOURSE
@CourseName varchar(125),
@COUR_ID INT OUTPUT
AS
SET @COUR_ID = (SELECT  CO.CourseID
               FROM  tblCOURSE CO
               WHERE CO.CourseID = @CourseName)
GO

CREATE PROCEDURE GETCLASSROOM
@classroomame varchar(125),
@CLSROOM_ID INT OUTPUT
AS
SET @CLSROOM_ID = (SELECT  CL.ClassroomID
               FROM  tblCLASSROOM CL
               WHERE CL.ClassroomName = @classroomame)
GO

CREATE PROCEDURE GETSCHEDULE
@ScheduleName varchar(50),
@SCH_ID INT OUTPUT
AS
SET @SCH_ID = (SELECT  SC.ScheduleID
               FROM tblSCHEDULE SC
               WHERE SC.ScheduleName = @ScheduleName)
GO

CREATE PROCEDURE INSERT_CLASS
@Q_Name varchar(60),
@C_Name varchar(50),
@C_Room varchar(50),
@ScheduleName varchar(50),
@Year char(4),
@Section char(2)
AS

DECLARE @QuarterID INT, @COUR_ID INT, @CLASS_ID INT, @SCHEDULE_ID INT

EXEC GETQUARTER
@QuarterName = @Q_Name,
@Q_ID = @QuarterID OUTPUT

IF @QuarterID IS NULL
	BEGIN
		PRINT '@QuarterID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@QuarterID cannot be NULL; Operation Terminating', 1;
	END

EXEC GETCOURSE
@CourseName = @C_Name,
@COUR_ID = @COUR_ID OUTPUT

IF @COUR_ID IS NULL
	BEGIN
		PRINT '@COUR_ID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@COUR_ID cannot be NULL; Operation Terminating', 1;
	END

EXEC GETCLASSROOM
@classroomame = @C_Room,
@CLSROOM_ID = @CLASS_ID OUTPUT

IF @CLASS_ID IS NULL
	BEGIN
		PRINT '@CLASS_ID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@CLASS_ID cannot be NULL; Operation Terminating', 1;
	END

EXEC GETSCHEDULE
@ScheduleName = @ScheduleName,
@SCH_ID = @SCHEDULE_ID OUTPUT

IF @SCHEDULE_ID IS NULL
	BEGIN
		PRINT '@SCHEDULE_ID is could be NULL; INSERT operation fails; Check for spelling mistakes';
		THROW 56676, '@SCHEDULE_ID cannot be NULL; Operation Terminating', 1;
	END

BEGIN TRAN T1
INSERT INTO tblCLASS (CourseID, QuarterID, YEAR, ClassroomID, ScheduleID, Section)
VALUES (@COUR_ID, @QuarterID, @Year, @CLASS_ID,@SCHEDULE_ID,@Section)
COMMIT TRAN T1
GO
