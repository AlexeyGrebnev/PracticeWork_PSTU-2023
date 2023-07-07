CREATE OR REPLACE FUNCTION public.log_updete_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
	begin
		
		if (select 1 from log where (bore_id = new.bore_id) and (date_prod = current_date))then 
update public.log set production = production + new.production where bore_id = new.bore_id;
		
		else
INSERT INTO log (bore_id,  production) select  bore_id, production from bore where bore_id = new.bore_id;
update public.log set date_prod = now(); 
		
end if;
RETURN NULL;
	END;

$function$
;
