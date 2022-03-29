
/*
1) Write the SQL to determine the top three StudentPermStates with the highest average grade earned for 300-level course from 
the college of 'Arts and Sciences' over the last 15 years?
*/

SELECT TOP 3 S.StudentPermState, AVG(CLT.Grade) AS AVG_GRADE
FROM tblSTUDENT S
	JOIN tblCLASS_LIST CLT ON CLT.StudentID = S.StudentID
	JOIN tblCLASS CS ON CS.ClassID = CLT.ClassID
	JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
	JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
	JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
WHERE COL.CollegeName = 'Arts and Sciences'
AND CR.CourseNumber LIKE '3%'
AND [YEAR] > YEAR(GETDATE()) -15
GROUP BY S.StudentPermState
ORDER BY AVG_GRADE DESC

/*
2) Write the SQL to determine which students have completed at least 15 credits of classes each from the colleges of Medicine, 
Information School, and Arts and Sciences since 2009 
that also completed more than 3 classes held in buildings on Stevens Way 
in classrooms of type 'large lecture hall'. 
*/

SELECT A.StudentID,A.StudentFname, A.StudentLname
FROM
(SELECT S.StudentID,S.StudentFname, S.StudentLname, SUM(Credits) AS CredCompleted
FROM tblSTUDENT S
	JOIN tblCLASS_LIST CLT ON CLT.StudentID = S.StudentID
	JOIN tblCLASS CS ON CS.ClassID = CLT.ClassID
	JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
	JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
	JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
	JOIN tblCLASSROOM CM ON CM.ClassroomID = CS.ClassroomID
	JOIN tblBUILDING B ON B.BuildingID = CM.BuildingID
	JOIN tblLOCATION L ON L.LocationID = B.LocationID
WHERE COL.CollegeName IN ('Medicine', 'Information School', 'Arts and Sciences')
AND CS.[YEAR] > '2009'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname
HAVING SUM(Credits) >= 15
)A ,

(SELECT S.StudentID,S.StudentFname, S.StudentLname, COUNT(CR.CourseName) AS NUM_COUNT
FROM tblSTUDENT S
	JOIN tblCLASS_LIST CLT ON CLT.StudentID = S.StudentID
    JOIN tblCLASS CS ON CS.ClassID = CLT.ClassID
	JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
    JOIN tblCLASSROOM CM ON CM.ClassroomID = CS.ClassroomID
    JOIN tblCLASSROOM_TYPE CT ON CT.ClassroomTypeID = CM.ClassroomTypeID
    JOIN tblBUILDING B ON B.BuildingID = CM.BuildingID
    JOIN tblLOCATION L ON L.LocationID = B.LocationID
WHERE CT.ClassroomTypeName = 'Large Lecture Hall'
AND L.LocationName = 'Stevens Way'
GROUP BY S.StudentID, S.StudentFname, S.StudentLname
HAVING COUNT(CR.CourseName) > 3
)B
WHERE A.StudentID = B.StudentID
GROUP BY A.StudentID,A.StudentFname, A.StudentLname


/*
3) Write the SQL to determine the buildings that have held more than 10 classes from the Mathematics department since 1997 that have also
that have also held fewer than 20 classes from the Anthropology department since 2016.
*/

SELECT A.BuildingID, A.BuildingName
FROM
(SELECT B.BuildingID, B.BuildingName, COUNT(CR.CourseName) AS NUM_COUNT
FROM tblBUILDING B
 JOIN tblCLASSROOM CM ON CM.BuildingID = B.BuildingID
 JOIN tblCLASS CS ON CS.ClassroomID = CM.ClassroomID
 JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
 JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
 JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
WHERE D.DeptName = 'Mathematics'
AND CS.[YEAR] > 1997
GROUP BY B.BuildingID, B.BuildingName
HAVING COUNT(CR.CourseName) > 10) A,

(SELECT B.BuildingID, B.BuildingName, COUNT(CR.CourseName) AS NUM_COUNT
FROM tblBUILDING B
 JOIN tblCLASSROOM CM ON CM.BuildingID = B.BuildingID
 JOIN tblCLASS CS ON CS.ClassroomID = CM.ClassroomID
 JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
 JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
 JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
WHERE D.DeptName = 'Anthropology'
AND CS.[YEAR] > 2016
GROUP BY B.BuildingID, B.BuildingName
HAVING COUNT(CR.CourseName) < 20) B
WHERE A.BuildingID = B.BuildingID
GROUP BY A.BuildingID, A.BuildingName


/*
4) Write the SQL to determine which location on campus has held the classes 
that generated the most combined money in registration fees for
 the colleges of 'Engineering', 'Nursing', 'Pharmacy', and 'Public Affairs (Evans School)'.
*/ 

SELECT TOP 1 L.LocationID, L.LocationName ,SUM(CLT.RegistrationFee) AS RegistrationFee
FROM tblLOCATION L 
	JOIN tblBUILDING B ON B.LocationID = L.LocationID
	JOIN tblCLASSROOM CM ON CM.BuildingID = B.BuildingID
	JOIN tblCLASS CS ON CS.ClassroomID = CM.ClassroomID
	JOIN tblCLASS_LIST CLT ON CLT.ClassID = CS.ClassID
	JOIN tblCOURSE CR ON CR.CourseID = CS.CourseID
	JOIN tblDEPARTMENT D ON D.DeptID = CR.DeptID
	JOIN tblCOLLEGE COL ON COL.CollegeID = D.CollegeID
WHERE COL.CollegeName IN ('Engineering', 'Nursing', 'Pharmacy', 'Public Affairs (Evans School)')
GROUP BY L.LocationID, L.LocationName
ORDER BY RegistrationFee DESC
