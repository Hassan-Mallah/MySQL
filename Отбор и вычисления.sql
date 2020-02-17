/* Есть две таблицы.
Таблица счетов – accounts с полями:
• counterparty_id – идентификатор счета (поле id)
• name – название счета
• active – признак активности
Таблица проводок – transaction с полями:
• trans_id – идентификатор проводки (поле id)
• transDate – дата проведения проводки
• rev_id – идентификатор получателя
• snd_id – идентификатор отправителя
• asset_id – идентификатор актива(рубли, доллары, акции лукойла, акции
газпрома и т.д.)
• quantity – количество передаваемого актива

 3.2.1
Отобрать активные счета по которым есть проводки как минимум по двум разным активам.
Выводимые поля: counterparty_id, name, cnt(количество уникальных активов по которым есть проводки)
*/
select id, name, count(distinct(asset_id)) cnt
from (
	select rev_id id, asset_id from transaction
	union all
	select snd_id, asset_id from transaction) t
left join accounts
	on id = counterparty_id
where id in (
	select counterparty_id from accounts
	where active = 1
)
group by id
having count(distinct(asset_id)) > 1;

/* 3.2.2
Посчитать суммарное число актива, образовавшееся на активных счетах, в результате проведенных проводок.
Выводимые поля: counterparty_id, name, asset_id, quantity
*/

select rev_id id, name, asset_id, sum(quantity) quantity
from transaction
left join accounts
	on rev_id = counterparty_id
where rev_id in (
	select counterparty_id from accounts
	where active = 1
)
group by rev_id, asset_id;

/* 3.2.3
Посчитать средний дневной оборот по всем счетам по всем проводкам считая, что asset_id во всех проводках одинаковый.
Выводимые поля: counterparty_id, name, oborot
*/

select rev_id id, name, avg(quantity) DailyAverage from transaction
left join accounts
	on rev_id = counterparty_id
group by rev_id;

/* 3.2.4
Посчитать средний месячный оборот по всем счетам по всем проводкам считая, что asset_id во всех проводках одинаковый. 
Выводимые поля: counterparty_id, name, oborot
*/
select rev_id id, name, sum(quantity)/count(distinct(date_format(transDate, '%Y-%m'))) MonthlyAvg from transaction
left join accounts
	on rev_id = counterparty_id
group by date_format(transDate, '%Y-%m'), rev_id;
