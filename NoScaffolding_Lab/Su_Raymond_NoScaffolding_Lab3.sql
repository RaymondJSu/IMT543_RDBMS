
/*
Q1: Write the SQL to create a stored procedure to UPDATE the BeginDate column in the 
-- STUDENT_DORMROOM table. USE THROW error-handling if variable is NULL.
*/

CREATE PROCEDURE UPDATE_BeginDate
@StudentFName varchar(50),
@StudentLName varchar(50),
@StudentBirth varchar(50),
@DormRoomNumber varchar(50),
@DormRoomTypeName varchar(50),
@BuildingName varchar(50),
@OldBeginDate DATE,
@NewBeginDate DATE
AS DECLARE @SDR_ID INT 
SET @SDR_ID = (SELECT sdr.StudentDormRoomID 
            FROM tblSTUDENT_DORMROOM sdr
                JOIN tblSTUDENT s ON sdr.StudentID = s.StudentID
                JOIN tblDORMROOM d ON sdr.DormRoomID = d.DormRoomID
                JOIN tblBUILDING b ON d.BuildingID = b.BuildingID
                JOIN tblDORMROOM_TYPE dt on d.DormRoomTypeID = dt.DormRoomTypeID
            WHERE sdr.BeginDate = @OldBeginDate
                AND s.StudentFname = @StudentFName
                AND s.StudentLname = @StudentLName
                AND s.StudentBirth = @StudentBirth
                AND d.DormRoomNumber = @DormRoomNumber
                AND dt.DormRoomTypeName = @DormRoomNumber
                AND b.BuildingName = @BuildingName)
IF @SDR_ID IS NULL
    BEGIN 
        PRINT 'NULL value detected in the variable; terminating process';
		THROW 55555, '@SDR_ID cannot be NULL', 1;
    END

UPDATE tblSTUDENT_DORMROOM
SET BeginDate = @NewBeginDate
WHERE StudentDormRoomID = @SDR_ID
GO


/*
Q2: Write the SQL to create a stored procedure to DELETE a row in the STUDENT_DORMROOM table.
-- USE RAISERROR error-handling if any variable is NULL.
*/

CREATE PROCEDURE DELETE_StudnetDormRoom
@StudentFName varchar(50),
@StudentLName varchar(50),
@StudentBirth varchar(50),
@DormRoomNumber varchar(50),
@DormRoomTypeName varchar(50),
@BuildingName varchar(50),
@BeginDate date
AS
DECLARE @DR_ID INT 

SET @DR_ID = (SELECT StudentDormRoomID
            FROM tblSTUDENT_DORMROOM SDR
            JOIN tblSTUDENT S ON S.StudentID = SDR.StudentDormRoomID
            JOIN tblDORMROOM D ON D.DormRoomID = SDR.DormRoomID
            JOIN tblDORMROOM_TYPE DT ON DT.DormRoomTypeID = D.DormRoomTypeID
			JOIN tblBUILDING B ON B.BuildingID = D.BuildingID
            WHERE S.StudentFName = @StudentFName
            AND S.StudentLName = @StudentLName
            AND S.StudentBirth = @StudentBirth
            AND D.DormRoomNumber = @DormRoomNumber
            AND DT.DormRoomTypeName = @DormRoomTypeName
			AND B.BuildingName = @BuildingName
			AND SDR.BeginDate = @BeginDate)
IF @DR_ID IS NULL
	BEGIN
		PRINT 'there is a NULL value in the variable; terminating process';
		RAISERROR ('@DR_ID cannot be NULL; process is terminating', 11,1) -- 11 = 'severity' and 1 = 'state'
		RETURN
	END


DELETE FROM tblSTUDENT_DORMROOM
WHERE StudentID = @DR_ID
GO

/*
Q3: Write the SQL to create a stored procedure to INSERT a row in the DEPARTMENT table.
USE THROW error-handling if variable is NULL.
*/

CREATE PROCEDURE INSERT_Department
@CollegeName varchar(50),
@DeptName varchar(50),
@DeptAbbrev varchar(50),
@DeptDescr varchar(50)
AS
DECLARE @DeptID INT, @COL_ID INT

SET @DeptID = ( 
    SELECT D.DeptID
    FROM tblDEPARTMENT D
    WHERE D.DeptName = @DeptName
    AND D.DeptAbbrev = @DeptAbbrev
    AND D.DeptDescr = @DeptDescr   
)

IF @DeptID IS NULL
    BEGIN
        PRINT 'ERROR: @DeptID cannot be NULL: Process terminated';
        THROW 55555, '@DeptID cannot be NULL', 1;
        RETURN
    END

SET @COL_ID = (SELECT CollegeID
            FROM tblCOLLEGE C
            WHERE C.CollegeName = @CollegeName)

IF @COL_ID IS NULL
	BEGIN
		PRINT 'Variable has come back NULL; check spelling of all parameters';
		THROW 55555, '@COL_ID cannot be NULL; process is terminating', 1;
		RETURN
	END

INSERT INTO tblDEPARTMENT (CollegeID, DeptID, DeptName, DeptAbbrev, DeptDescr)
VALUES(@COL_ID, @DeptID, @DeptName, @DeptAbbrev, @DeptDescR)
GO


/*
Q4: Write the SQL to create a stored procedure to UPDATE the DeptDescr column in the DEPARTMENT table.
Use RAISERROR method of error-handling if variable is NULL
*/

CREATE PROCEDURE UPDATE_DEPARTMENT
@OldDescr varchar(500),  
@NewDescr varchar(500),  
@DeptName varchar(75),  
@DeptAbbrev varchar(8),  
@DeptDescr varchar(500),  
@CollegeName varchar(125),  
@CollegeDescr varchar(500)  
AS  
DECLARE @DID INT  
  
SET @DID = (  
  SELECT DeptID  
  FROM tblDEPARTMENT D  
  JOIN tblCollege C ON D.CollegeID = C.CollegeID  
  WHERE D.DeptDescr = @OldDescr  
  AND D.DeptName = @DeptName  
  AND D.DeptAbbrev = @DeptAbbrev  
  AND D.DeptDescr = @DeptDescr  
  AND C.CollegeName = @CollegeName  
  AND C.CollegeDescr = @CollegeDescr  
)  
  
IF @DID IS NULL  
 BEGIN  
  PRINT 'Variable has come back NULL; check spelling of all parameters'  
  RAISERROR ('@UD_ID cannot be NULL; process is terminating', 11,1)  
  RETURN  
 END  
  
UPDATE tblDEPARTMENT  
SET DeptDescr = @NewDescr  
WHERE DeptID = @DID  

/*
Q5: Write the SQL to create a stored procedure to DELETE a row in the DEPARTMENT table.
*/
GO
CREATE PROCEDURE DELETE_DEPARTMENT
@DeptName varchar(75),
@DeptAbbrev varchar(8),
@DeptDescr varchar(500),
@CollegeName varchar(125)
AS
DECLARE @D_ID INT 

SET @D_ID = (SELECT D.DeptID
            FROM tblDEPARTMENT D 
                JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
				WHERE D.DeptName = @DeptName
				AND COL.CollegeName = @CollegeName)

DELETE FROM tblDEPARTMENT
WHERE DeptID = @D_ID
GO


/*
Q6: Write the SQL query to determine which classes meet following condition.
1) have associate professors that taught a philosophy class in the last 7 years
*/
SELECT C.ClassID, CO.CourseName
FROM tblCLASS C
JOIN tblCOURSE CO ON CO.CourseID = C.CourseID
JOIN tblDEPARTMENT D ON D.DeptID = CO.DeptID
JOIN tblINSTRUCTOR_CLASS IC ON IC.ClassID = C.ClassID
JOIN tblINSTRUCTOR I ON I.InstructorID = IC.InstructorID
JOIN tblINSTRUCTOR_INSTRUCTOR_TYPE IIT ON IIT.InstructorID = I.InstructorID
JOIN tblINSTRUCTOR_TYPE IT ON IT.InstructorTypeID = IIT.InstructorTypeID
WHERE IT.InstructorTypeName = 'Associate Professor'
AND D.DeptName = 'Philosophy'
AND C.YEAR > DATEADD(year, -7, getdate())

--AND DateDiff(Month, IIT.BeginDate, GETDATE()) >= 84
