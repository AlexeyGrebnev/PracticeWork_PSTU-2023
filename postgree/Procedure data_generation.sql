CREATE OR REPLACE FUNCTION public.data_generation(field_num integer, bore_num integer, adm_unit_num integer, start_date date)
 RETURNS void
 LANGUAGE plpgsql
AS $function$

declare
    field_counter int;
    field_adm_unit_counter int;
   	rand_prod int;
    exit_1 int;
    rand_AU int;
    now_time date;
    v_bore_id int;
   

	begin
		
		TRUNCATE TABLE field RESTART IDENTITY CASCADE;
		TRUNCATE TABLE adm_unit RESTART IDENTITY CASCADE;
		TRUNCATE TABLE bore RESTART IDENTITY CASCADE;
		TRUNCATE TABLE log  RESTART IDENTITY CASCADE;
		

--заполнение field
	LOOP
    INSERT INTO field (name) values ('месторождение');
    EXIT WHEN (SELECT count (1) FROM public.field) >= field_num;
END LOOP;

--заполнение adm_unit
LOOP
    INSERT INTO adm_unit (name) values ('район');
    EXIT WHEN (SELECT count (1) FROM public.adm_unit) >= adm_unit_num;
END LOOP;
	
--заполнение bore
field_counter := 1;
loop
	loop
		rand_prod := floor(random() * 500)::int;
    	INSERT INTO bore (name, production, field_id) values ('скважена', rand_prod, field_counter);
   	 	EXIT WHEN (SELECT count (1) FROM public.bore where field_id = field_counter) >= (random() * (bore_num + 1))::int;
	END LOOP;

	field_counter := field_counter + 1;
EXIT WHEN field_counter >= field_num;
END LOOP;

--заполнение field_adm_unit
field_counter := 1;
loop
	loop
		exit_1 := 0;
		loop
			rand_AU := floor(random() * (adm_unit_num) + 1) ::int;
			if (select 1 from field_adm_unit  where (field_id = field_counter) and (adm_unit_id = rand_AU))then 
    		--rand_AU := floor(random() * (adm_unit_num) + 1) ::int;
    		else
    		exit_1 :=1;
    	 	end if;
    		
			exit when(exit_1 = 1);
		END LOOP;
		
		INSERT INTO field_adm_unit  (field_id, adm_unit_id) values (field_counter , rand_AU);
   	 	EXIT WHEN (SELECT count (1) FROM public.field_adm_unit where field_id = field_counter) >= (random() * (adm_unit_num) + 1)::int;
	END LOOP;

	field_counter := field_counter + 1;
EXIT WHEN field_counter >= field_num;
END LOOP;

--заполнение log
now_time := NOW ()::DATE - 1;
loop 
	v_bore_id :=1;
	loop
		rand_prod := floor(random() * 500)::int;
		INSERT INTO log  (bore_id, production, date_prod) values (v_bore_id, rand_prod, start_date);
		v_bore_id :=v_bore_id + 1;
	exit when(v_bore_id >= (select count(1) from public.bore));
	end loop;


	start_date := start_date + 1;
	exit when(start_date >= now_time);
end loop;

	
	END;
$function$
;
