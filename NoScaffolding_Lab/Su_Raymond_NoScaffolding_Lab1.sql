/*
1) Write the SQL query to determine the departments that held fewer than 230 classes in buildings on Stevens Way 
between 2011 and 2016 that also generated more than $16.5 million from registration fees in the 1990's that also 
had more than 400 distinct (!!) students complete a 400-level course in the 1980's
*/

SELECT A.DeptID, A.DeptName, A.NumOfClass
FROM (SELECT D.DeptID, D.DeptName, COUNT(ClassID) AS NumOfClass
FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CS ON CS.CourseID = CR.CourseID
	JOIN tblCLASSROOM CM ON CM.ClassroomID = CS.ClassroomID
	JOIN tblBUILDING B ON B.BuildingID = CM.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
WHERE L.LocationName = 'Stevens Way'
AND CS.[YEAR] BETWEEN '2011' AND '2016'
GROUP BY D.DeptID, D.DeptName
HAVING COUNT(ClassID) < 230) A,

(SELECT D.DeptID, D.DeptName, SUM(RegistrationFee) AS RegistrationFee
FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CS ON CS.CourseID = CR.CourseID
	JOIN tblCLASS_LIST CLT ON CLT.ClassID = CS.ClassID
WHERE CS.[YEAR] LIKE '199%'
GROUP BY D.DeptID, D.DeptName
HAVING SUM(RegistrationFee) > 16500000) B,

(SELECT D.DeptID, D.DeptName, COUNT(DISTINCT S.StudentID) AS NumOfStudent
FROM tblDEPARTMENT D 
	JOIN tblCOURSE CR ON CR.DeptID = D.DeptID
	JOIN tblCLASS CS ON CS.CourseID = CR.CourseID
	JOIN tblCLASS_LIST CLT ON CLT.ClassID = CS.ClassID
	JOIN tblSTUDENT S ON S.StudentID = CLT.StudentID
WHERE CR.CourseNumber LIKE '4%'
AND CS.[YEAR] LIKE '198%'
GROUP BY D.DeptID, D.DeptName
HAVING COUNT(DISTINCT S.StudentID) >400) C
WHERE A.DeptID = B.DeptID
AND B.DeptID = C.DeptID
ORDER BY A.DeptName

/*
2) Which students with the special need of 'Anxiety' have completed more than 13 credits of 300-level 
Information School classes with a grade less than 3.1 in the last 3 years?
*/

SELECT S.StudentID ,S.StudentFname, S.StudentLname, SUM(CR.Credits) AS TotalCredsISchool
FROM tblSTUDENT S 
	JOIN tblSTUDENT_SPECIAL_NEED SSN ON SSN.StudentID = S.StudentID
	JOIN tblSPECIAL_NEED SN ON SN.SpecialNeedID = SSN.SpecialNeedID
	JOIN tblCLASS_LIST CLT ON CLT.StudentID = S.StudentID
	JOIN tblCLASS CS ON CS.ClassID = CLT.ClassID
	JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
	JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
	JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
WHERE SN.SpecialNeedName = 'Anxiety'
AND COL.CollegeName = 'Information School'
AND CR.CourseNumber LIKE '3%'
AND CLT.Grade < 3.1
AND CS.[YEAR] >= '2018'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname
HAVING SUM(CR.Credits) > 13

/*
3) Write the SQL to determine the top 10 states by number of students who have completed both 15 credits of Arts and Science courses
as well as between 5 and 18 credits of Medicine since 2003.
*/

SELECT TOP 10 A.StudentPermState, COUNT(*) AS NumOfPeople
FROM
(SELECT S.StudentPermState, S.StudentID, SUM(Credits) AS CredCompleted15
from tblSTUDENT S
	JOIN tblCLASS_LIST CLT  ON CLT.StudentID = S.StudentID
    JOIN tblCLASS CLS ON CLS.ClassID = CLT.ClassID
	JOIN tblCOURSE CR ON  CLS.CourseID = CR.CourseID
	JOIN tblDEPARTMENT DP ON DP.DeptID = CR.DeptID
    JOIN tblCOLLEGE COL ON COL.CollegeID = DP.CollegeID
    WHERE COL.CollegeName = 'Arts and Sciences'
    AND CLS.[YEAR] >= '2003'
    Group by  S.StudentPermState,S.StudentID,  S.StudentFname, S.StudentLname
    HAVING SUM(Credits) = 15
) A, 
(SELECT S.StudentPermState, S.StudentID, SUM(Credits) AS CredCompleted5_18
from tblSTUDENT S
	JOIN tblCLASS_LIST CLT  ON CLT.StudentID = S.StudentID
    JOIN tblCLASS CLS ON CLS.ClassID = CLT.ClassID
	JOIN tblCOURSE CR ON  CLS.CourseID = CR.CourseID
	JOIN tblDEPARTMENT DP ON DP.DeptID = CR.DeptID
    JOIN tblCOLLEGE COL ON COL.CollegeID = DP.CollegeID
    WHERE COL.CollegeName = 'Medicine' 
    AND CLS.[YEAR] >= '2003'
    Group by  S.StudentPermState, S.StudentID, S.StudentFname, S.StudentLname
    HAVING SUM(Credits) BETWEEN 5 and 18
) B 
Where A.StudentID = B.StudentID
GROUP BY A.StudentPermState
ORDER BY NumOfPeople DESC

/*
4) Write the SQL to determine the students who are currently assigned a dormroom type 'Triple' on West Campus 
who have paid more than $2,000 in registration fees in the past four years?
*/


SELECT S.StudentID ,S.StudentFname, S.StudentLname,CLT.RegistrationDate, SUM(CLT.RegistrationFee) AS RegistrationFee
FROM tblSTUDENT S
	JOIN tblCLASS_LIST CLT  ON CLT.StudentID = S.StudentID
	JOIN tblCLASS CS ON CS.ClassID = CLT.ClassID
	JOIN tblSTUDENT_DORMROOM SD ON SD.StudentID = CLT.StudentID
	JOIN tblDORMROOM D ON D.DormRoomID = SD.DormRoomID
	JOIN tblDORMROOM_TYPE DT ON DT.DormRoomTypeID = D.DormRoomTypeID
	JOIN tblBUILDING B ON B.BuildingID = D.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
WHERE L.LocationName = 'West Campus'
AND DT.DormRoomTypeName = 'Triple'
AND CLT.RegistrationDate >= DATEADD(Year, -4, GETDATE())
GROUP BY S.StudentID ,S.StudentFname, S.StudentLname, CLT.RegistrationDate
HAVING SUM(CLT.RegistrationFee) > 2000
