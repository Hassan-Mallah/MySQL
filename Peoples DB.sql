/* 4.1 
Спроектировать базу данных – peoples
• Создать таблицы:
- Люди (обязательные поля: имя, фамилия, отчество)
- Контакты (обязательное поле: номер телефона)
- Адреса
- Личный транспорт
*/
CREATE DATABASE `Peoples` /*!40100 DEFAULT CHARACTER SET utf8 */;

CREATE TABLE `Peoples`.`People` (`id` INT NOT NULL AUTO_INCREMENT, `Name` VARCHAR(45) NOT NULL, `FamilyName` VARCHAR(45) NOT NULL, `MiddleName` VARCHAR(45) NOT NULL, `DateOfBirth` DATE NULL, PRIMARY KEY (`id`));

CREATE TABLE `Peoples`.`Contacts` (`id` INT NOT NULL AUTO_INCREMENT, `Telephone_Number` VARCHAR(20) NOT NULL, `People_id` INT NOT NULL, PRIMARY KEY (`id`), CONSTRAINT `fk_People` FOREIGN KEY (`People_id`) REFERENCES `Peoples`.`People` (`id`) ON DELETE cascade ON UPDATE cascade);

CREATE TABLE `Peoples`.`Contacts` (`id` INT NOT NULL AUTO_INCREMENT, `Telephone_Number` VARCHAR(20) NOT NULL, PRIMARY KEY (`id`));

CREATE TABLE `Peoples`.`Addresses` (`id` INT NOT NULL AUTO_INCREMENT, `Address` VARCHAR(100) NOT NULL, PRIMARY KEY (`id`));

CREATE TABLE `Peoples`.`Private_Transport` (`id` INT NOT NULL AUTO_INCREMENT, `Model` VARCHAR(45) NOT NULL, `People_id` INT NOT NULL, PRIMARY KEY (`id`), CONSTRAINT `fk_Private_Transport` FOREIGN KEY (`People_id`) REFERENCES `Peoples`.`People` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION);



/* 4.2.1
Используя приложение [1] создать функцию для случайной генерации комбинации: фамилия, имя, отчество
*/

CREATE DEFINER=`root`@`localhost` FUNCTION `Random_Name`() RETURNS varchar(40)
BEGIN

DECLARE g int; # Gender
DECLARE f VARCHAR(40); # First Name
DECLARE m VARCHAR(40); # Middle Name
DECLARE l VARCHAR(40); # Last Name

DECLARE i varchar(40);
DECLARE j VARCHAR(40);

set g = (select ceil(rand() * 2));
set f = (SELECT firstname FROM names_f where gender = g	ORDER BY RAND()	limit 1);
set m = (SELECT middlename FROM names_m	where gender = g ORDER BY RAND() limit 1);
set l = (SELECT lastname from names_l where id >= (select ceil(RAND() * ( SELECT MAX(id) FROM  names_l))) and gender = g limit 1); # This method is faster for bigger tables

RETURN concat(l, ' ', f, ' ', m);
END

/* 4.2.2
Создать функцию для случайной генерации даты рождения: от 1 года до 80 лет
*/

CREATE DEFINER=`root`@`localhost` FUNCTION `Random_Birth_Dates`() RETURNS varchar(40)
BEGIN
RETURN (select date_format(now() - INTERVAL ceil(RAND() * 29200) day, '%Y-%m-%d'));
END

/* 4.2.3
Создать процедуру на заполнение таблиц используя внутри процедуры функции выше
*/

CREATE DEFINER=`root`@`localhost` PROCEDURE `Fill_Table`()
BEGIN
DECLARE n VARCHAR(80); # Name
DECLARE LastName  VARCHAR(80);
DECLARE FirstName  VARCHAR(80);
DECLARE MiddleName  VARCHAR(80);
DECLARE DateOfBirth date;

set n = (select Random_Name());
set FirstName =  substring_index(SUBSTRING_INDEX(n, ' ', 2), ' ', -1);
set LastName =  SUBSTRING_INDEX(n, ' ', 1);
set MiddleName = SUBSTRING_INDEX(n, ' ', -1);
set DateOfBirth = (select Random_Birth_Dates());

INSERT INTO `Peoples`.`People` (`Name`, `FamilyName`, `MiddleName`, `DateOfBirth`) VALUES (FirstName, LastName, MiddleName, DateOfBirth);
END

/* 4.2.4
Заполнить таблицу "Люди" процедурой (100 человек)
*/

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertRecords`(c int)
BEGIN
	declare p1 int(4);
    set p1 = 0;
    label1: LOOP
    IF p1 < c THEN
		call Fill_Table();
        SET p1 = p1 + 1;
        ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
END

/* 4.2.5
Реализовать связи "многие ко многим" между таблицами: "Люди" — "Личный транспорт" и "Люди" — "Адреса".
*/

CREATE TABLE `Peoples`.`Poeple_Address` (`People_id` INT NOT NULL, `Address_id` INT NOT NULL,
  CONSTRAINT `Address_fk` FOREIGN KEY (`Address_id`) REFERENCES `Peoples`.`Addresses` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `People_fk` FOREIGN KEY (`People_id`) REFERENCES `Peoples`.`People` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE);
    
CREATE TABLE `Peoples`.`People_Transport` (`People_id` INT NOT NULL, `Transport_id` INT NOT NULL,
  CONSTRAINT `Transport_fk` FOREIGN KEY (`Transport_id`) REFERENCES `Peoples`.`Private_Transport` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `People_fk` FOREIGN KEY (`People_id`) REFERENCES `Peoples`.`People` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE);

/* 4.2.6
Написать запрос на вывод людей, номеров телефона (иных контактов), адреса проживания, наличие автомобиля (если нет, то вывести "Отсутствует" если есть — вывести какой)
*/

select Name, Address, coalesce(Model, 'Отсутствует') 'Car', Contacts.Telephone_Number
from People 
left join People_Transport on People.id = People_Transport.People_id
left join Private_Transport on Private_Transport.id = People_Transport.Transport_id
join Poeple_Address on Poeple_Address.People_id = People.id
join Addresses on  Poeple_Address.Address_id = Addresses.id
join Contacts on People.id = Contacts.People_id;

/*
Написать запрос на вывод всех людей у которых есть личный транспорт
*/

select People.id, Name, Model
from People
join People_Transport on People.id = People_Transport.People_id
join Private_Transport on Private_Transport.id = People_Transport.Transport_id;
