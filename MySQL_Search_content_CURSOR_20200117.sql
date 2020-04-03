DELIMITER //

create temporary table search_output (
cnt int not null
, tab_name varchar(100) not null
, colu_name varchar(100) not null
) engine=memory;

create procedure UTIL_search_string(in search_string_in varchar(100))
begin 
/* 	Author: Matthias Guenther (matthis@online.ms at 2020.01.17)
	License CC BY (creativecommons.org)
	Desc: 	parse trough all string like columns to find a specific content
		--> fill in the searchstring in line 53
*/
	declare done int default false;
    declare query varchar(4000);
	declare stmt varchar(4000);
	declare cnt_stmt int;
	DECLARE db_cursor CURSOR FOR 
		select	CONCAT(	'insert into search_output (cnt, tab_name, colu_name) '
						,'select count(*) as cnt, '''
						,t.tables_name,''' as tab_name, '''
						,c.columns_name,''' as colu_name  from `',t.tables_name,
						'` where `',c.columns_name,'` like ''%',search_string_in,'%'' having count(*) > 0'
						) as del_sql
		from	columns c 
		join	tables t
		on		c.columns_tables_id = t.tables_id
		where	c.columns_datatype like 'string'
--        and		c.columns_name like '%GC%'
		order by t.tables_name ;
	declare continue handler for not found set done = true;
	OPEN db_cursor;
    read_loop: LOOP
		set done = false ;
		fetch db_cursor into query;
        if done then
			leave read_loop;
		end if;
		if query is not null then 
			-- select query;
			set @sql_stmt = query;
			prepare stmt from @sql_stmt;
			execute stmt;
			deallocate prepare stmt;
		end if;
	end loop;
	close db_cursor;
    select t.*, concat('select * from ',t.tab_name,' where ',t.colu_name, ' like ''%',search_string_in,'%'';') as SEL from search_output t;
end//

call UTIL_search_string('fill_the_search_string_here')//

DELIMITER ;

drop procedure UTIL_search_string;
drop table search_output; 
