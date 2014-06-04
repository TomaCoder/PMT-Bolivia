/******************************************************************
   bolivia_activity

   select * from bolivia_activity(32036);     
******************************************************************/
CREATE OR REPLACE FUNCTION bolivia_activity(activity_id integer) RETURNS SETOF pmt_json_result_type AS 
$$
DECLARE
  rec record;
  invalid_return_columns text[];
  return_columns text;
  execute_statement text;
  data_message text;
BEGIN
  IF $1 IS NOT NULL THEN	

    -- dynamically build the execute statment	
    execute_statement :=   'SELECT activity_id as "a_id" ' ||
			  -- Sector
			  ',(SELECT array_to_string(array_agg(classification), '','') as "Sector" ' ||
			  'FROM activity_taxonomy at ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON at.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id and taxonomy = ''Sector'') ' ||
			  -- codigo_sisin
			  ', iati_identifier as "Codigo SISIN" ' ||
			  -- nombre_formal
			  ', title as "Nombre Formal" ' ||
			  -- objetivo_especifico
			  ', objective as "Objetivo Especifico" ' ||
			  -- fecha_inicio_estimada y fecha-fin_estimada
			  ', to_char(start_date, ''DD-MM-YYYY'') || '' - '' || to_char(end_date, ''DD-MM-YYYY'') as "Fechas" ' ||
			  -- etapa
			  ',(SELECT array_to_string(array_agg(classification), '','') as "Etapa" ' ||
			  'FROM activity_taxonomy at ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON at.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id AND taxonomy = ''Etapa'') ' ||
			  -- area_influencia
			  ',(SELECT array_to_string(array_agg(classification), '','') as "Area Influencia" ' ||
			  'FROM activity_taxonomy at ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON at.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id AND taxonomy = ''Area Influencia'') ' ||
			  -- entidad_ejecutora
			  ',(SELECT array_to_string(array_agg(o.name), '','') as "Entidad Ejecutora" ' ||
			  'FROM participation p ' ||
			  'JOIN organization o ' ||
			  'ON p.organization_id = o.organization_id ' ||
			  'JOIN participation_taxonomy pt ' ||
			  'ON p.participation_id = pt.participation_id ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON pt.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id AND taxonomy = ''Organisation Role'' AND iati_name = ''Implementing'') ' ||
			  -- depto
			  ',(SELECT array_to_string(array_agg(classification), '','') as "Departamento" ' ||
			  'FROM activity_taxonomy at ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON at.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id AND taxonomy = ''Departamento'') ' ||
			  -- prov
			  -- ',(SELECT array_to_string(array_agg(classification), '','') as "Provincia" ' ||
			  -- 'FROM activity_taxonomy at ' ||
			  -- 'JOIN taxonomy_classifications tc ' ||
			  -- 'ON at.classification_id = tc.classification_id ' ||
			  -- 'WHERE activity_id = a.activity_id AND taxonomy = ''Provincia'') ' ||
			  -- mun
			  ',(SELECT array_to_string(array_agg(classification), '','') as "Municipio" ' ||
			  'FROM activity_taxonomy at ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON at.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id AND taxonomy = ''Municipio'') ' ||
			  -- location
			  -- ',(SELECT count(location_id) as "Número de Ubicaciones" ' ||
			  -- 'FROM location ' ||
			  -- 'WHERE activity_id = a.activity_id) ' ||
			  -- costo_total
			  ',(SELECT cast(coalesce(sum(amount), 0.00) as text) || '' BS'' as "Costo Total" ' ||
			  'FROM financial f ' ||
			  'JOIN financial_taxonomy ft ' ||
			  'ON f.financial_id = ft.financial_id ' ||
			  'JOIN taxonomy_classifications tc ' ||
			  'ON ft.classification_id = tc.classification_id ' ||
			  'WHERE activity_id = a.activity_id AND taxonomy = ''Tipo Presupuesto'' AND classification = ''Costo Total'') ' ||
			  -- fte
			  -- ',(SELECT array_to_string(array_agg(classification), '','') as "FTE" ' ||
			  -- 'FROM activity_taxonomy at ' ||
			  -- 'JOIN taxonomy_classifications tc ' ||
			  -- 'ON at.classification_id = tc.classification_id ' ||
			  -- 'WHERE activity_id = a.activity_id AND taxonomy = ''FTE'') ' ||
			  -- org
			  -- ',(SELECT array_to_string(array_agg(o.name), '','') as "Financiador" ' ||
			  -- 'FROM participation p ' ||
			  -- 'JOIN organization o ' ||
			  -- 'ON p.organization_id = o.organization_id ' ||
			  -- 'JOIN participation_taxonomy pt ' ||
			  -- 'ON p.participation_id = pt.participation_id ' ||
			  -- 'JOIN taxonomy_classifications tc ' ||
			  -- 'ON pt.classification_id = tc.classification_id ' ||
			  -- 'WHERE activity_id = a.activity_id AND taxonomy = ''Organisation Role'' AND iati_name = ''Funding'') ' ||
			  -- convenio
			  -- ',(SELECT array_to_string(array_agg(classification), '','') as "Convenio" ' ||
			  -- 'FROM activity_taxonomy at ' ||
			  -- 'JOIN taxonomy_classifications tc ' ||
			  -- 'ON at.classification_id = tc.classification_id ' ||
			  -- 'WHERE activity_id = a.activity_id AND taxonomy = ''Convenio'') ' ||
			  -- presupuestado
			  -- ',(SELECT cast(coalesce(sum(amount), 0.00) as text) || '' BS'' as "Presupuestado" ' ||
			  -- 'FROM financial f ' ||
			  -- 'JOIN financial_taxonomy ft ' ||
			  -- 'ON f.financial_id = ft.financial_id ' ||
			  -- 'JOIN taxonomy_classifications tc ' ||
			  -- 'ON ft.classification_id = tc.classification_id ' ||
			  -- 'WHERE activity_id = a.activity_id AND taxonomy = ''Tipo Presupuesto'' AND classification = ''Presupuesto'') ' ||
			  -- ejecutado
			  -- ',(SELECT cast(coalesce(sum(amount), 0.00) as text) || '' BS'' as "Ejecutado" ' ||
			  -- 'FROM financial f ' ||
			  -- 'JOIN financial_taxonomy ft ' ||
			  -- 'ON f.financial_id = ft.financial_id ' ||
			  -- 'JOIN taxonomy_classifications tc ' ||
			  -- 'ON ft.classification_id = tc.classification_id ' ||
			  -- 'WHERE activity_id = a.activity_id AND taxonomy = ''Tipo Presupuesto'' AND classification = ''Ejecutado'') ' ||
			 'FROM activity a ' ||
			 'WHERE a.activity_id =' || $1;
    
	RAISE NOTICE 'Execute statement: %', execute_statement;			

	FOR rec IN EXECUTE 'SELECT row_to_json(j) FROM (' || execute_statement || ')j' LOOP  		
		RETURN NEXT rec;
	END LOOP;
   END IF;
END;$$ LANGUAGE plpgsql;