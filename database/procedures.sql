DROP PROCEDURE IF EXISTS user_login;
DELIMITER $$
CREATE PROCEDURE `user_login`(IN i_username VARCHAR(50), IN i_password VARCHAR(50))
BEGIN
  DROP TABLE IF EXISTS UserLogin;
    CREATE TABLE UserLogin
    SELECT User.username, User.status, C.isCustomer, A.isAdmin, M.isManager
    FROM User, (SELECT COUNT(*) AS isCustomer FROM Customer WHERE username = i_username) AS C,
    (SELECT COUNT(*) AS isAdmin FROM admin WHERE username = i_username) AS A,
    (SELECT COUNT(*) AS isManager FROM Manager WHERE username = i_username) AS M
  WHERE (username = i_username) AND (password = MD5(i_password));
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS user_register;
DELIMITER $$
CREATE PROCEDURE `user_register`(
    IN i_username VARCHAR(50),
    IN i_password VARCHAR(50),
    IN i_firstname VARCHAR(50),
    IN i_lastname VARCHAR(50)
)
BEGIN
    INSERT IGNORE INTO user (username, password, firstname, lastname)
            VALUES (i_username, MD5(i_password), i_firstname, i_lastname);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS customer_only_register;
DELIMITER $$
CREATE PROCEDURE `customer_only_register`(
    IN i_username VARCHAR(50),
    IN i_password VARCHAR(50),
    IN i_firstname VARCHAR(50),
    IN i_lastname VARCHAR(50)
)
BEGIN
  INSERT IGNORE INTO user (username, password, firstname, lastname)
        VALUES (i_username, MD5(i_password), i_firstname, i_lastname);
  INSERT IGNORE INTO customer (username)
        VALUES (i_username);

END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS customer_add_creditcard;
DELIMITER $$
CREATE PROCEDURE `customer_add_creditcard`(
    IN i_username VARCHAR(50),
    IN i_creditCardNum CHAR(16)
)
BEGIN
  IF 5 > (SELECT COUNT(*)
        FROM customercreditcard
        WHERE username = i_username
    ) THEN
  INSERT IGNORE INTO CustomerCreditCard (username, creditCardNum)
        VALUES(i_username, i_creditCardNum);
    END IF;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS manager_only_register;
DELIMITER $$
CREATE PROCEDURE `manager_only_register`(
    IN i_username VARCHAR(50),
    IN i_password VARCHAR(50),
    IN i_firstname VARCHAR(50),
    IN i_lastname VARCHAR(50),
    IN i_comName VARCHAR(50),
    IN i_empStreet VARCHAR(50),
    IN i_empCity VARCHAR(50),
    IN i_empState CHAR(2),
    IN i_empZipcode CHAR(5)
)
BEGIN
  INSERT IGNORE INTO user (username, password, firstname, lastname)
        VALUES (i_username, MD5(i_password), i_firstname, i_lastname);
  INSERT IGNORE INTO employee (username)
        VALUES (i_username);
  INSERT IGNORE INTO manager (username, comName, manStreet, manCity, manState, manZipcode)
        VALUES (i_username, i_comName, i_empStreet, i_empCity, i_empState, i_empZipcode);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS manager_customer_register;
DELIMITER $$
CREATE PROCEDURE `manager_customer_register`(
    IN i_username VARCHAR(50),
    IN i_password VARCHAR(50),
    IN i_firstname VARCHAR(50),
    IN i_lastname VARCHAR(50),
    IN i_comName VARCHAR(50),
    IN i_empStreet VARCHAR(50),
    IN i_empCity VARCHAR(50),
    IN i_empState CHAR(2),
    IN i_empZipcode CHAR(5)
)
BEGIN
  INSERT IGNORE INTO user (username, password, firstname, lastname)
        VALUES (i_username, MD5(i_password), i_firstname, i_lastname);
  INSERT IGNORE INTO employee (username)
        VALUES (i_username);
  INSERT IGNORE INTO customer (username)
        VALUES (i_username);
  INSERT IGNORE INTO manager (username, comName, manStreet, manCity, manState, manZipcode)
        VALUES (i_username, i_comName, i_empStreet, i_empCity, i_empState, i_empZipcode);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS manager_customer_add_creditcard;
DELIMITER $$
CREATE PROCEDURE `manager_customer_add_creditcard`(
    IN i_username VARCHAR(50),
    IN i_creditCardNum CHAR(16)
)
BEGIN
  INSERT IGNORE INTO CustomerCreditCard (username, creditCardNum)
        VALUES(i_username, i_creditCardNum);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_approve_user;
DELIMITER $$
CREATE PROCEDURE `admin_approve_user`(IN i_username VARCHAR(50))
BEGIN
    UPDATE user
    SET status = 'Approved'
    WHERE username = i_username
        AND (status = 'Pending' OR status = 'Declined');
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_decline_user;
DELIMITER $$
CREATE PROCEDURE `admin_decline_user`(IN i_username VARCHAR(50))
BEGIN
  UPDATE user
  SET status = 'Declined'
  WHERE username = i_username
        AND status = 'Pending';
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_filter_user;
DELIMITER $$
CREATE PROCEDURE `admin_filter_user`(
    IN i_username VARCHAR(50),
    IN i_status VARCHAR(50),
    IN i_sortBy VARCHAR(50),
    IN i_sortDirection VARCHAR(50)
)
BEGIN
  DROP TABLE IF EXISTS AdFilterUser;
    CREATE TABLE AdFilterUser
    WITH ccCount AS (
        SELECT username,
            COUNT(creditCardNum) AS "count"
        FROM customercreditcard
        GROUP BY username
    )
    SELECT u.username,
        COALESCE(cc.count, 0) AS creditCardCount,
        CASE
            WHEN (u.username IN (SELECT username FROM Customer)) AND (u.username IN (SELECT username FROM admin)) THEN "CustomerAdmin"
            WHEN (u.username IN (SELECT username FROM Customer)) AND (u.username IN (SELECT username FROM Manager)) THEN "CustomerManager"
            WHEN u.username IN (SELECT username FROM Customer) THEN "Customer"
            WHEN u.username IN (SELECT username FROM admin) THEN "Admin"
            WHEN u.username IN (SELECT username FROM Manager) THEN "Manager"
            ELSE "User"
      END AS userType,
        u.status
    FROM user u
    LEFT JOIN ccCount cc
        ON cc.username = u.username
    WHERE (i_username='' OR i_username = u.username)
        AND (i_status="ALL" OR i_status='' OR i_status = u.status)
    ORDER BY
    (CASE
    WHEN i_sortBy="username" AND i_sortDirection="ASC" THEN u.username
        WHEN i_sortBy="creditCardCount" AND i_sortDirection="ASC" THEN creditCardCount
        WHEN i_sortBy="userType" AND i_sortDirection="ASC" THEN userType
        WHEN i_sortBy="status" AND i_sortDirection="ASC" THEN status
    END) ASC,
    (CASE
    WHEN i_sortBy="username" THEN u.username
        WHEN i_sortBy="creditCardCount" THEN creditCardCount
        WHEN i_sortBy="userType" THEN userType
        WHEN i_sortBy="status" THEN status
        ELSE u.username
    END) DESC;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_filter_company;
DELIMITER $$
CREATE PROCEDURE `admin_filter_company`(
    IN i_comName VARCHAR(50),
    IN i_minCity INT(5),
    IN i_maxCity INT(5),
    IN i_minTheater INT(5),
    IN i_maxTheater INT(5),
    IN i_minEmployee INT(7),
    IN i_maxEmployee INT(7),
    IN i_sortBy VARCHAR(50),
    IN i_sortDirection VARCHAR(50)
)
BEGIN
  DROP TABLE IF EXISTS AdFilterCom;
    CREATE TABLE AdFilterCom
    WITH cc AS (
        SELECT comName,
            COUNT(DISTINCT(thCity)) AS numCityCover
        FROM theater
        GROUP BY comName
    ), tc AS (
        SELECT comName,
            COUNT(thName) AS numTheater
        FROM theater
        GROUP BY comName
    ), ec AS (
        SELECT comName,
            COUNT(username) AS numEmployee
        FROM manager
        GROUP BY comName
    )
    SELECT c.comName,
        COALESCE(cc.numCityCover, 0) as numCityCover,
        COALESCE(tc.numTheater, 0) as numTheater,
        COALESCE(ec.numEmployee, 0) as numEmployee
    FROM company c
    LEFT JOIN cc
        ON cc.comName = c.comName
    LEFT JOIN tc
        ON tc.comName = c.comName
    LEFT JOIN ec
        ON ec.comName = c.comName
    WHERE (i_comName = "ALL" OR i_comName = "" OR c.comName = i_comName)
      AND (i_minCity IS NULL OR COALESCE(cc.numCityCover, 0) >= i_minCity)
        AND (i_maxCity IS NULL OR COALESCE(cc.numCityCover, 0) <= i_maxCity)
        AND (i_minTheater IS NULL OR COALESCE(tc.numTheater, 0) >= i_minTheater)
        AND (i_maxTheater IS NULL OR COALESCE(tc.numTheater, 0) <= i_maxTheater)
        AND (i_minEmployee IS NULL OR COALESCE(ec.numEmployee, 0) >= i_minEmployee)
        AND (i_maxEmployee IS NULL OR COALESCE(ec.numEmployee, 0) <= i_maxEmployee)
    ORDER BY
    (CASE
    WHEN i_sortBy="comName" AND i_sortDirection="ASC" THEN c.comName
        WHEN i_sortBy="numCityCover" AND i_sortDirection="ASC" THEN numCityCover
        WHEN i_sortBy="numTheater" AND i_sortDirection="ASC" THEN numTheater
        WHEN i_sortBy="numEmployee" AND i_sortDirection="ASC" THEN numEmployee
    END) ASC,
    (CASE
    WHEN i_sortBy="comName" AND i_sortDirection != "ASC" THEN c.comName
        WHEN i_sortBy="numCityCover" AND i_sortDirection != "ASC" THEN numCityCover
        WHEN i_sortBy="numTheater" AND i_sortDirection != "ASC" THEN numTheater
        WHEN i_sortBy="numEmployee" AND i_sortDirection != "ASC" THEN numEmployee
    END) DESC,
    (CASE
    WHEN i_sortDirection != "ASC" AND i_sortDirection != "DESC" THEN c.comName
    END) DESC;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_create_theater;
DELIMITER $$
CREATE PROCEDURE `admin_create_theater`(
    IN i_thName VARCHAR(50),
    IN i_comName VARCHAR(50),
    IN i_thStreet VARCHAR(50),
    IN i_thCity VARCHAR(50),
    IN i_thState CHAR(2),
    IN i_thZipcode CHAR(5),
    IN i_capacity INT(11),
    IN i_managerUsername VARCHAR(50)
)
BEGIN
    IF CONCAT(i_managerUsername, i_comName) IN (
        SELECT CONCAT(username, comName)
        FROM manager
    ) THEN
      INSERT IGNORE INTO theater (thName, comName, thStreet, thCity, thState, thZipcode, capacity, manUsername)
            VALUES (i_thName, i_comName, i_thStreet, i_thCity, i_thState, i_thZipcode, i_capacity, i_managerUsername);
    END IF;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_view_comDetail_emp;
DELIMITER $$
CREATE PROCEDURE `admin_view_comDetail_emp` (
    IN i_comName VARCHAR(50)
)
BEGIN
    DROP TABLE IF EXISTS AdComDetailEmp;
    CREATE TABLE AdComDetailEmp
    SELECT u.firstname AS "empFirstname",
        u.lastname AS "empLastname"
    FROM user u
    INNER JOIN manager m
        ON m.username = u.username
    WHERE m.comName = i_comName;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_view_comDetail_th;
DELIMITER $$
CREATE PROCEDURE `admin_view_comDetail_th` (
    IN i_comName VARCHAR(50)
)
BEGIN
    DROP TABLE IF EXISTS AdComDetailTh;
    CREATE TABLE AdComDetailTh
    SELECT t.thName,
    t.manUsername as "thManagerUsername",
    t.thCity,
    t.thState,
    t.capacity AS "thCapacity"
    FROM theater t
    WHERE t.comName = i_comName;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS admin_create_mov;
DELIMITER $$
CREATE PROCEDURE `admin_create_mov`(
    IN i_movName VARCHAR(50),
    IN i_movDuration CHAR(11),
    IN i_movReleaseDate DATE
)
BEGIN
  INSERT IGNORE INTO movie (movName, duration, movReleaseDate)
        VALUES (i_movName, i_movDuration, i_movReleaseDate);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS manager_filter_th;
DELIMITER $$
CREATE PROCEDURE `manager_filter_th` (
    IN i_manUsername VARCHAR(50),
    IN i_movName VARCHAR(50),
    IN i_minMovDuration INT(11),
    IN i_maxMovDuration INT(11),
    IN i_minMovReleaseDate DATE,
    IN i_maxMovReleaseDate DATE,
    IN i_minMovPlayDate DATE,
    IN i_maxMovPlayDate DATE,
    IN i_includedNotPlay BOOLEAN
)
BEGIN
    DROP TABLE IF EXISTS ManFilterTh;
    IF (COALESCE(i_includedNotPlay, FALSE) = TRUE) THEN
        CREATE TABLE ManFilterTh
        SELECT m.movName AS "movName",
            m.duration AS "movDuration",
            m.movReleaseDate AS "movReleaseDate",
            NULL AS "movPlayDate"
        FROM movie m
        WHERE (i_movName = '' OR m.movName = i_movName)
            AND (i_minMovDuration IS NULL OR m.duration >= i_minMovDuration)
            AND (i_maxMovDuration IS NULL OR m.duration <= i_maxMovDuration)
            AND (i_minMovReleaseDate IS NULL OR m.movReleaseDate >= i_minMovReleaseDate)
            AND (i_maxMovReleaseDate IS NULL OR m.movReleaseDate <= i_maxMovReleaseDate)
            AND CONCAT(m.movName, m.movReleaseDate) NOT IN (
                SELECT CONCAT(m.movName, m.movReleaseDate)
                FROM movie m
                INNER JOIN movieplay mp
                    ON mp.movName = m.movName
                    AND mp.movReleaseDate = m.movReleaseDate
                INNER JOIN theater t
                    ON t.comName = mp.comName
                    AND t.thName = mp.thName
                WHERE (i_manUsername = '' OR t.manUsername = i_manUsername)
            );
    ELSE
        CREATE TABLE ManFilterTh
        SELECT m.movName AS "movName",
            m.duration AS "movDuration",
            m.movReleaseDate AS "movReleaseDate",
            mp.movPlayDate AS "movPlayDate"
        FROM movie m
        LEFT JOIN movieplay mp
            ON mp.movName = m.movName
            AND mp.movReleaseDate = m.movReleaseDate
        LEFT JOIN theater t
            ON t.comName = mp.comName
            AND t.thName = mp.thName
        WHERE (i_manUsername = '' OR t.manUsername = i_manUsername)
            AND (i_movName = '' OR m.movName = i_movName)
            AND (i_minMovDuration IS NULL OR m.duration >= i_minMovDuration)
            AND (i_maxMovDuration IS NULL OR m.duration <= i_maxMovDuration)
            AND (i_minMovReleaseDate IS NULL OR m.movReleaseDate >= i_minMovReleaseDate)
            AND (i_maxMovReleaseDate IS NULL OR m.movReleaseDate <= i_maxMovReleaseDate)
            AND (i_minMovPlayDate IS NULL OR mp.movPlayDate >= i_minMovPlayDate)
            AND (i_maxMovPlayDate IS NULL OR mp.movPlayDate <= i_maxMovPlayDate)
        UNION
        SELECT m.movName AS "movName",
            m.duration AS "movDuration",
            m.movReleaseDate AS "movReleaseDate",
            NULL AS "movPlayDate"
        FROM movie m
        WHERE (i_movName = '' OR m.movName = i_movName)
            AND (i_minMovDuration IS NULL OR m.duration >= i_minMovDuration)
            AND (i_maxMovDuration IS NULL OR m.duration <= i_maxMovDuration)
            AND (i_minMovReleaseDate IS NULL OR m.movReleaseDate >= i_minMovReleaseDate)
            AND (i_maxMovReleaseDate IS NULL OR m.movReleaseDate <= i_maxMovReleaseDate)
            AND CONCAT(m.movName, m.movReleaseDate) NOT IN (
                SELECT CONCAT(m.movName, m.movReleaseDate)
                FROM movie m
                INNER JOIN movieplay mp
                    ON mp.movName = m.movName
                    AND mp.movReleaseDate = m.movReleaseDate
                INNER JOIN theater t
                    ON t.comName = mp.comName
                    AND t.thName = mp.thName
                WHERE (i_manUsername = '' OR t.manUsername = i_manUsername)
            );
    END IF;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS manager_schedule_mov;
DELIMITER $$
CREATE PROCEDURE `manager_schedule_mov`(
    IN i_manUsername VARCHAR(50),
    IN i_movName VARCHAR(50),
    IN i_movReleaseDate DATE,
    IN i_movPlayDate DATE
)
BEGIN
  INSERT IGNORE INTO MoviePlay (movName, movReleaseDate, movPlayDate, thName, comName)
        VALUES(i_movName, i_movReleaseDate, i_movPlayDate, (SELECT thName FROM theater WHERE manUsername=i_manUsername), (SELECT comName FROM theater WHERE manUsername=i_manUsername));
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS customer_filter_mov;
DELIMITER $$
CREATE PROCEDURE `customer_filter_mov` (
    IN i_movName VARCHAR(50),
    IN i_comName VARCHAR(50),
    IN i_city VARCHAR(50),
    IN i_state VARCHAR(3),
    IN i_minMovPlayDate DATE,
    IN i_maxMovPlayDate DATE
)
BEGIN
    DROP TABLE IF EXISTS CosFilterMovie;
    CREATE TABLE CosFilterMovie
    SELECT mp.movName,
        t.thName,
        t.thStreet,
        t.thCity,
        t.thState,
        t.thZipcode,
        t.comName,
        mp.movReleaseDate,
        mp.movPlayDate
    FROM movieplay mp
    INNER JOIN theater t
        ON t.thName = mp.thName
        AND t.comName = mp.comName
    WHERE (i_movName = 'ALL' OR i_movName = '' OR mp.movName = i_movName)
        AND (i_comName = 'ALL' OR i_comName = '' OR t.comName = i_comName)
        AND (i_city = 'ALL' OR i_city = '' OR t.thCity = i_city)
        AND (i_state = 'ALL' OR i_state = '' OR t.thState = i_state)
        AND (i_minMovPlayDate IS NULL OR mp.movPlayDate >= i_minMovPlayDate)
        AND (i_maxMovPlayDate IS NULL OR mp.movPlayDate <= i_maxMovPlayDate);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS customer_view_mov;
DELIMITER $$
CREATE PROCEDURE `customer_view_mov` (
    IN i_creditCardNum CHAR(16),
    IN i_movName VARCHAR(50),
    IN i_movReleaseDate DATE,
    IN i_thName VARCHAR(50),
    IN i_comName VARCHAR(50),
    IN i_movPlayDate DATE
)
BEGIN
    IF 3 > (SELECT COUNT(*)
        FROM customerviewmovie
        WHERE movPlayDate = i_movPlayDate
            AND creditCardNum IN (
                SELECT creditCardNum
                FROM customercreditcard
                WHERE username = (
                    SELECT username
                    FROM customercreditcard
                    WHERE creditCardNum = i_creditCardNum
                )
            )
    ) THEN
        INSERT IGNORE INTO customerviewmovie (movName, movReleaseDate, movPlayDate, thName, comName, creditCardNum)
            VALUES (i_movName, i_movReleaseDate, i_movPlayDate, i_thName, i_comName, i_creditCardNum);
    END IF;
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS customer_view_history;
DELIMITER $$
CREATE PROCEDURE `customer_view_history` (
    IN i_cusUsername VARCHAR(50)
)
BEGIN
    DROP TABLE IF EXISTS CosViewHistory;
    CREATE TABLE CosViewHistory
    SELECT cvm.movName,
        cvm.thName,
        cvm.comName,
        cvm.creditCardNum,
        cvm.movPlayDate
    FROM customerviewmovie cvm
    LEFT JOIN customercreditcard ccc
        ON ccc.creditCardNum = cvm.creditCardNum
    WHERE (i_cusUsername = "" OR i_cusUsername = ccc.username);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS user_filter_th;
DELIMITER $$
CREATE PROCEDURE `user_filter_th`(IN i_thName VARCHAR(50), IN i_comName VARCHAR(50), IN i_city VARCHAR(50), IN i_state VARCHAR(3))
BEGIN
    DROP TABLE IF EXISTS UserFilterTh;
    CREATE TABLE UserFilterTh
  SELECT thName, thStreet, thCity, thState, thZipcode, comName
    FROM Theater
    WHERE
    (thName = i_thName OR i_thName = "ALL" OR i_thName = "") AND
        (comName = i_comName OR i_comName = "ALL" OR i_comName = "") AND
        (thCity = i_city OR i_city = "") AND
        (thState = i_state OR i_state = "ALL" OR i_state = '');
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS user_visit_th;
DELIMITER $$
CREATE PROCEDURE `user_visit_th`(
    IN i_thName VARCHAR(50),
    IN i_comName VARCHAR(50),
    IN i_visitDate DATE,
    IN i_username VARCHAR(50)
)
BEGIN
    INSERT IGNORE INTO UserVisitTheater (thName, comName, visitDate, username)
        VALUES (i_thName, i_comName, i_visitDate, i_username);
END$$
DELIMITER ;



DROP PROCEDURE IF EXISTS user_filter_visitHistory;
DELIMITER $$
CREATE PROCEDURE `user_filter_visitHistory`(IN i_username VARCHAR(50), IN i_minVisitDate DATE, IN i_maxVisitDate DATE)
BEGIN
    DROP TABLE IF EXISTS UserVisitHistory;
    CREATE TABLE UserVisitHistory
  SELECT thName, thStreet, thCity, thState, thZipcode, comName, visitDate
    FROM UserVisitTheater
    NATURAL JOIN
        Theater
  WHERE
    (username = i_username) AND
        (i_minVisitDate IS NULL OR visitDate >= i_minVisitDate) AND
        (i_maxVisitDate IS NULL OR visitDate <= i_maxVisitDate);
END$$
DELIMITER ;
