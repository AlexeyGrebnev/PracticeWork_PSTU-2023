CREATE TABLE public.bore (
	"name" text NULL,
	production int4 NULL,
	field_id int4 NULL,
	bore_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	CONSTRAINT bore_pk PRIMARY KEY (bore_id)
);

-- Table Triggers

create trigger update_trigger after
insert
    or
update
    on
    public.bore for each row execute procedure log_updete_trigger();


-- public.bore foreign keys

ALTER TABLE public.bore ADD CONSTRAINT bore_fk FOREIGN KEY (field_id) REFERENCES public.field(field_id) ON DELETE CASCADE ON UPDATE CASCADE;