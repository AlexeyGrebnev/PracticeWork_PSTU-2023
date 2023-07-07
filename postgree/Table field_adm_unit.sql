CREATE TABLE public.field_adm_unit (
	field_id int4 NOT NULL,
	adm_unit_id int4 NOT NULL,
	CONSTRAINT field_adm_unit_pk PRIMARY KEY (field_id, adm_unit_id)
);


-- public.field_adm_unit foreign keys

ALTER TABLE public.field_adm_unit ADD CONSTRAINT administrative_unit_fk FOREIGN KEY (field_id) REFERENCES public.field(field_id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.field_adm_unit ADD CONSTRAINT field_adm_unit_fk FOREIGN KEY (adm_unit_id) REFERENCES public.adm_unit(adm_unit_id) ON DELETE CASCADE ON UPDATE CASCADE;