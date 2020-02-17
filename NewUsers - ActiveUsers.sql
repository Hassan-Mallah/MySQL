/*
Есть таблица событий, в которой собирается вся активность пользователя в продукте. Колонки:
- user_id
- event_timestamp
- event_name
-------------------
Requested 4 4 columns: 
- Year and month of user appearance in the system
- Number of new users (coming this month)
- The number of users who returned to the second calendar month after registration
- Return probability

Expected output:
https://drive.google.com/file/d/1sx8MaX6oFYirTXaN5-yq9IkozvuYv8K3/view
*/

select 
    distinct(date_format(E1.event_timestamp, '%Y-%m')) 'Month',
    B.NewUsers,
    C.MAU,
    concat(round(100 * C.MAU /B.NewUsers), '%') AS `Return Probability`
from Event E1
left join (
	select event_timestamp, count(user_id) NewUsers from Event E2
	where
		E2.event_timestamp = 
		(
			select min(E3.event_timestamp) from Event E3 where E2.user_id = E3.user_id
		)
		group by E2.event_timestamp
) B
on E1.event_timestamp = B.event_timestamp
left join (
	select event_timestamp, count(E4.user_id) 'MAU' 
	from 
		Event E4 
	where 
		date_format(date_sub(E4.event_timestamp, interval 1 month), '%Y-%m') = (
		select date_format(min(E3.event_timestamp), '%Y-%m') from Event E3 where E3.user_id = E4.user_id
	)
	group by E4.event_timestamp
) C
on E1.event_timestamp = C.event_timestamp
order by Month;
