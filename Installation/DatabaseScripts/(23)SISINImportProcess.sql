/****************************************************************
	Bolivia SISIN Base de Datos Importar
	(Bolivia SISIN Database Import)

Este script contiene la instalación de los componentes personalizados 
para el PMT de Bolivia. Datos son exportados desde la base de datos 
SISIN como CSV en un formato específico e importados a la base de 
datos de la PMT usando una función de base de datos.

 CSV archivo de SISIN debe ser: 
	a. UTF-8 
	b. orden de columna exactamente como tabla de datos_sisin
	c. sin encabezados de columna
****************************************************************/

-- Campos que deben agregarse a la base de datos PMT para apoyar el SISIN 
-- proceso de importación. Esto sólo debe hacerse una vez para su instalación.
ALTER TABLE "activity" ADD COLUMN "objective"   character varying;	

-- Tabla personalizada de SISIN datos de importación CSV. Esto sólo debe 
-- hacerse una vez para su instalación.
DROP TABLE IF EXISTS datos_sisin;
CREATE TABLE datos_sisin
(
	 sector			character varying
	,codigo_sisin		character varying
	,nombre_formal		character varying
	,objetivo_especifico	character varying
	,fecha_inicio_estimada	character varying
	,fecha_fin_estimada	character varying
	,etapa			character varying
	,area_influencia	character varying
	,entidad_ejecutora	character varying
	,depto			character varying
	,prov			character varying
	,mun			character varying
	,latitud		character varying
	,longitud		character varying
	,costo_total		character varying
	,fte			character varying
	,org			character varying
	,convenio		character varying
	,presupuestado		character varying
	,ejecutado		character varying
	
);

/******************************************************************
  upd_datos_sisin - disparador en la tabla de datos_sisin, que 
  contiene lógica a empujar los datos en el modelo de datos PMT. 
  Esto sólo debe hacerse una vez para su instalación.
******************************************************************/
CREATE OR REPLACE FUNCTION upd_datos_sisin()
RETURNS trigger AS $upd_datos_sisin$
  DECLARE
    p_id integer;
    a_id integer;
    c_id integer;
    o_id integer;
    f_id integer;
    l_id integer;
    pp_id integer;
    lat numeric;
    long numeric;
    start_date date;
    end_date date;
    rec_count integer;
    message text;
  BEGIN   
  
  IF(lower(NEW.codigo_sisin)='codigo_sisin') THEN
    -- header row, skip this record
  ELSE
    -- get project id
    SELECT INTO p_id project_id FROM project WHERE title = 'Importación de datos de SISIN' LIMIT 1;

    -- get activity id if activity has already been recorded
    SELECT INTO a_id activity_id FROM activity WHERE iati_identifier = NEW.codigo_sisin;
    -- if activity doesn't exist, then create it
    IF a_id IS NULL THEN
      -- cast the date variables      
      start_date := to_date(NEW.fecha_inicio_estimada, 'YYYY/MM/DD');
      -- RAISE NOTICE 'start_date: %', start_date;
      end_date := to_date(NEW.fecha_fin_estimada, 'YYYY/MM/DD');
      -- RAISE NOTICE 'end_date: %', end_date;
      -- create activity record
      EXECUTE 'INSERT INTO activity (project_id, title, start_date, end_date, objective, iati_identifier, created_by, updated_by) ' ||
	'VALUES (' ||
		p_id || ', ' ||
		coalesce(quote_literal(NEW.nombre_formal),'NULL') || ', ' ||		-- title
		coalesce(quote_literal(start_date),'NULL') || ', ' ||			-- start_date
		coalesce(quote_literal(end_date),'NULL') || ', ' ||			-- end_date
		coalesce(quote_literal(NEW.objetivo_especifico),'NULL') || ', ' ||	-- objective
		coalesce(quote_literal(NEW.codigo_sisin),'NULL') || ', ' ||		-- iati_identifier
		quote_literal(E'importar_datos_sisin') || ', ' ||			-- created_by
		quote_literal(E'importar_datos_sisin') || 				-- updated_by
	') RETURNING activity_id;' INTO a_id;
    END IF;
    -- RAISE NOTICE 'activity_id: %', a_id;	
    -- Area Influencia
    IF NEW.area_influencia IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Area Influencia' AND lower(classification) = lower(NEW.area_influencia);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Area Influencia') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.area_influencia from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;
    -- Etapa
    IF NEW.etapa IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Etapa' AND lower(classification) = lower(NEW.etapa);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Etapa') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.etapa from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;    
    -- Sector
    IF NEW.sector IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Sector' AND lower(classification) = lower(NEW.sector);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Sector') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.sector from 1 for 255))),'NULL')  || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;    
    -- Departamento
    IF NEW.depto IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Departamento' AND lower(classification) = lower(NEW.depto);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Departamento') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.depto from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;
    -- Provincia
    IF NEW.prov IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Provincia' AND lower(classification) = lower(NEW.prov);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Provincia') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.prov from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;
    -- Municiple
    IF NEW.mun IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Municiple' AND lower(classification) = lower(NEW.mun);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Municiple') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.mun from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;    
    -- FTE
    IF NEW.fte IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'FTE' AND lower(classification) = lower(NEW.fte);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('FTE') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.fte from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;
    -- Convenio
    IF NEW.convenio IS NOT NULL THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Convenio' AND lower(classification) = lower(NEW.convenio);
      IF c_id IS NOT NULL THEN
        EXECUTE 'SELECT count(*) FROM activity_taxonomy WHERE activity_id = ' || a_id || ' AND classification_id = ' || c_id || ' AND field = ''activity_id''' INTO rec_count;
        IF rec_count = 0 THEN
          -- add the taxonomy to the activity record
	  EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
	END IF;
      ELSE
        -- add the classification to the taxonomy
        EXECUTE 'INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = ' || quote_literal('Convenio') || 
        '),'|| coalesce(quote_literal(trim(substring(NEW.convenio from 1 for 255))),'NULL') || ', ' || quote_literal(E'importar_datos_sisin') || ', ' ||	quote_literal(E'importar_datos_sisin') 
        || ') RETURNING classification_id;' INTO c_id;
        EXECUTE 'INSERT INTO activity_taxonomy(activity_id, classification_id, field) VALUES( ' || a_id || ', ' || c_id || ', ''activity_id'');';
      END IF;
    END IF;

    -- Funding Organization
    IF NEW.org IS NOT NULL THEN
    
      SELECT INTO o_id organization_id FROM organization WHERE lower(name) = lower(NEW.org);
      
      IF o_id IS NULL THEN
        -- create a organization record
	EXECUTE 'INSERT INTO organization(name, created_by, updated_by) VALUES( ' 
		|| coalesce(quote_literal(trim(substring(NEW.org from 1 for 255))),'NULL')|| ', ' 
		|| quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
		|| ') RETURNING organization_id;' INTO o_id;
	-- create a participation record
	EXECUTE 'INSERT INTO participation(project_id, activity_id, organization_id, created_by, updated_by) VALUES( ' 
		|| p_id || ', ' || a_id || ', ' || o_id || ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
		|| ') RETURNING participation_id;' INTO pp_id;        
      ELSE 
        EXECUTE 'SELECT participation_id FROM participation WHERE activity_id = ' || a_id || ' AND organization_id = ' || o_id || ';' INTO pp_id;
        IF pp_id IS NULL THEN
          -- create a participation record
	  EXECUTE 'INSERT INTO participation(project_id, activity_id, organization_id, created_by, updated_by) VALUES( ' 
		|| p_id || ', ' || a_id || ', ' || o_id || ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
		|| ') RETURNING participation_id;' INTO pp_id;
        END IF;
      END IF;
              
      IF pp_id IS NOT NULL THEN
        SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Organisation Role' AND iati_name = 'Funding';
        IF c_id IS NOT NULL THEN
          EXECUTE 'SELECT count(*) FROM participation_taxonomy WHERE participation_id = ' || pp_id || ' AND classification_id = ' || c_id || ' AND field = ''participation_id''' INTO rec_count;
          IF rec_count = 0 THEN
            -- add the taxonomy to the participation record
	    EXECUTE 'INSERT INTO participation_taxonomy(participation_id, classification_id, field) VALUES( ' || pp_id || ', ' || c_id || ', ''participation_id'');';
	  END IF;
        END IF;  
      END IF;     
    END IF;
    
    -- Implementing Organization
    IF NEW.entidad_ejecutora IS NOT NULL THEN
    
      SELECT INTO o_id organization_id FROM organization WHERE lower(name) = lower(NEW.entidad_ejecutora);
      
      IF o_id IS NULL THEN
        -- create a organization record
	EXECUTE 'INSERT INTO organization(name, created_by, updated_by) VALUES( ' 
		|| coalesce(quote_literal(trim(substring(NEW.entidad_ejecutora from 1 for 255))),'NULL')|| ', ' 
		|| quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
		|| ') RETURNING organization_id;' INTO o_id;
	-- create a participation record
	EXECUTE 'INSERT INTO participation(project_id, activity_id, organization_id, created_by, updated_by) VALUES( ' 
		|| p_id || ', ' || a_id || ', ' || o_id || ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
		|| ') RETURNING participation_id;' INTO pp_id;        
      ELSE 
        EXECUTE 'SELECT participation_id FROM participation WHERE activity_id = ' || a_id || ' AND organization_id = ' || o_id || ';' INTO pp_id;
        IF pp_id IS NULL THEN
          -- create a participation record
	  EXECUTE 'INSERT INTO participation(project_id, activity_id, organization_id, created_by, updated_by) VALUES( ' 
		|| p_id || ', ' || a_id || ', ' || o_id || ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
		|| ') RETURNING participation_id;' INTO pp_id;
        END IF;
      END IF;
              
      IF pp_id IS NOT NULL THEN
        SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Organisation Role' AND iati_name = 'Implementing';
        IF c_id IS NOT NULL THEN
          EXECUTE 'SELECT count(*) FROM participation_taxonomy WHERE participation_id = ' || pp_id || ' AND classification_id = ' || c_id || ' AND field = ''participation_id''' INTO rec_count;
          IF rec_count = 0 THEN
            -- add the taxonomy to the participation record
	    EXECUTE 'INSERT INTO participation_taxonomy(participation_id, classification_id, field) VALUES( ' || pp_id || ', ' || c_id || ', ''participation_id'');';
	  END IF;
        END IF;  
      END IF;     
    END IF;
    
    -- Financial (Presupuestado)
    IF (NEW.presupuestado IS NOT NULL) AND (SELECT pmt_isnumeric(NEW.presupuestado)) THEN
    -- RAISE NOTICE 'presupuestado: %', NEW.presupuestado;
    IF ROUND(CAST(NEW.presupuestado as numeric), 2) <> 0.00 THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Tipo Presupuesto' AND classification = 'Presupuestado';
      EXECUTE 'SELECT f.financial_id FROM financial f LEFT JOIN financial_taxonomy ft ON f.financial_id = ft.financial_id WHERE f.amount = '
	|| ROUND(CAST(NEW.presupuestado as numeric), 2) || ' AND classification_id = ' || c_id || ' AND activity_id = ' || a_id || ' LIMIT 1;'  INTO f_id;
      IF f_id IS NULL THEN
        -- add the financial record        
        message := 'INSERT INTO financial(project_id, activity_id, amount, created_by, updated_by) VALUES ( ' || p_id || ',' || a_id || ',' || ROUND(CAST(NEW.presupuestado as numeric), 2) ||
        ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING financial_id;';
        -- RAISE NOTICE 'Message: %', message;
        EXECUTE 'INSERT INTO financial(project_id, activity_id, amount, created_by, updated_by) VALUES ( ' || p_id || ',' || a_id || ',' || ROUND(CAST(NEW.presupuestado as numeric), 2) ||
        ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING financial_id;' INTO f_id;
        -- add the taxonomy to the financial record
	EXECUTE 'INSERT INTO financial_taxonomy(financial_id, classification_id, field) VALUES( ' || f_id || ', ' || c_id || ', ''financial_id'');';
      END IF;
    END IF;
    END IF;
    -- Financial (Costo Total)
    IF (NEW.costo_total IS NOT NULL) AND (SELECT pmt_isnumeric(NEW.costo_total)) THEN
    -- RAISE NOTICE 'costo_total: %', NEW.costo_total;
    IF ROUND(CAST(NEW.costo_total as numeric), 2) <> 0.00 THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Tipo Presupuesto' AND classification = 'Costo Total';
      EXECUTE 'SELECT f.financial_id FROM financial f LEFT JOIN financial_taxonomy ft ON f.financial_id = ft.financial_id WHERE f.amount = '
	|| ROUND(CAST(NEW.costo_total as numeric), 2) || ' AND classification_id = ' || c_id || ' AND activity_id = ' || a_id || ' LIMIT 1;'  INTO f_id;
      IF f_id IS NULL THEN
        -- add the financial record
        message := 'INSERT INTO financial(project_id, activity_id, amount, created_by, updated_by) VALUES ( ' || p_id || ',' || a_id || ',' || ROUND(CAST(NEW.costo_total as numeric), 2) ||
        ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING financial_id;';
        -- RAISE NOTICE 'Message: %', message;
        EXECUTE 'INSERT INTO financial(project_id, activity_id, amount, created_by, updated_by) VALUES ( ' || p_id || ',' || a_id || ',' || ROUND(CAST(NEW.costo_total as numeric), 2) ||
        ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING financial_id;' INTO f_id;
        -- add the taxonomy to the financial record
	EXECUTE 'INSERT INTO financial_taxonomy(financial_id, classification_id, field) VALUES( ' || f_id || ', ' || c_id || ', ''financial_id'');';
      END IF;
    END IF;
    END IF;
    -- Financial (Ejecutado)
    IF (NEW.ejecutado IS NOT NULL) AND (SELECT pmt_isnumeric(NEW.ejecutado)) THEN
    -- RAISE NOTICE 'ejecutado: %', NEW.ejecutado;
    IF ROUND(CAST(NEW.ejecutado as numeric), 2) <> 0.00 THEN
      SELECT INTO c_id classification_id FROM taxonomy_classifications WHERE taxonomy = 'Tipo Presupuesto' AND classification = 'Ejecutado';
      EXECUTE 'SELECT f.financial_id FROM financial f LEFT JOIN financial_taxonomy ft ON f.financial_id = ft.financial_id WHERE f.amount = '
	|| ROUND(CAST(NEW.ejecutado as numeric), 2) || ' AND classification_id = ' || c_id || ' AND activity_id = ' || a_id || ' LIMIT 1;'  INTO f_id;
      IF f_id IS NULL THEN
        -- add the financial record
        message := 'INSERT INTO financial(project_id, activity_id, amount, created_by, updated_by) VALUES ( ' || p_id || ',' || a_id || ',' || ROUND(CAST(NEW.ejecutado as numeric), 2) ||
        ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING financial_id;';
        -- RAISE NOTICE 'Message: %', message;
        EXECUTE 'INSERT INTO financial(project_id, activity_id, amount, created_by, updated_by) VALUES ( ' || p_id || ',' || a_id || ',' || ROUND(CAST(NEW.ejecutado as numeric), 2) ||
        ', ' || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') 
        || ') RETURNING financial_id;' INTO f_id;
        -- add the taxonomy to the financial record
	EXECUTE 'INSERT INTO financial_taxonomy(financial_id, classification_id, field) VALUES( ' || f_id || ', ' || c_id || ', ''financial_id'');';
      END IF;
    END IF;
    END IF;

    -- Location
    IF NEW.latitud IS NOT NULL AND NEW.latitud <> '' AND NEW.longitud IS NOT NULL AND NEW.longitud <> '' AND a_id IS NOT NULL and p_id IS NOT NULL THEN      
      RAISE NOTICE 'lat: %', NEW.latitud;
      lat := NEW.latitud::numeric;
      RAISE NOTICE 'long: %', NEW.longitud;
      long := NEW.longitud::numeric;
      
      IF lat >= -90 AND lat <= 90 AND long >= -180 AND long <= 180 AND lat IS NOT NULL AND long IS NOT NULL THEN
        IF lat = 0 and long = 0 THEN
          -- This is an invalid point for this dataset
        ELSE
          message := 'INSERT INTO location(activity_id, project_id, point, created_by, updated_by) VALUES( ' 
	       || a_id || ', ' || p_id || ', ' || 'ST_GeomFromText(''POINT(' || long || ' ' || lat || ')'', 4326)' || ', ' 
	       || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') || ')RETURNING location_id;';
	  RAISE NOTICE 'message: %', message;
          EXECUTE 'INSERT INTO location(activity_id, project_id, point, created_by, updated_by) VALUES( ' 
	       || a_id || ', ' || p_id || ', ' || 'ST_GeomFromText(''POINT(' || long || ' ' || lat || ')'', 4326)' || ', ' 
	       || quote_literal(E'importar_datos_sisin') || ', ' || quote_literal(E'importar_datos_sisin') || ')RETURNING location_id;' INTO l_id;
	END IF;
      END IF;
    END IF;

  END IF; -- skip if header row
  
  RETURN NEW;
      
  END;
$upd_datos_sisin$ LANGUAGE plpgsql; 
DROP TRIGGER IF EXISTS upd_datos_sisin ON datos_sisin;
CREATE TRIGGER upd_datos_sisin BEFORE INSERT ON datos_sisin
    FOR EACH ROW EXECUTE PROCEDURE upd_datos_sisin();
    
/******************************************************************
 importar_datos_sisin - función para importar datos SISIN de CSV 
 en tabla personalizada datos_sisin. Esto sólo debe hacerse una 
 vez para su instalación.

  Ejemplo de función para importar datos de CSV:

  SELECT * FROM importar_datos_sisin('informacion_oap.csv');   
  
******************************************************************/
CREATE OR REPLACE FUNCTION importar_datos_sisin(ruta_csv text) 
RETURNS SETOF pmt_json_result_type AS 
$$
DECLARE
  rec record;
  purge boolean;
  refresh_taxonomy integer;
  error_msg1 text;
  error_msg2 text;
  error_msg3 text;
BEGIN	

  FOR rec IN (SELECT project_id FROM project) LOOP  
     IF (rec.project_id IS NOT NULL) THEN
	SELECT INTO purge * FROM pmt_purge_project(rec.project_id);	
     END IF;
  END LOOP;
  
  TRUNCATE TABLE datos_sisin;
  
  INSERT INTO project (title, description, created_by, updated_by) VALUES ( 'Importación de datos de SISIN', 'Importación de datos de SISIN', 'importar_datos_sisin', 'importar_datos_sisin');
  INSERT INTO project_taxonomy (project_id, classification_id, field) VALUES ((SELECT project_id FROM project WHERE title = 'Importación de datos de SISIN' LIMIT 1),(SELECT classification_id FROM taxonomy_classifications WHERE taxonomy = 'Data Group' and classification = 'Bolivia' LIMIT 1),'project_id');

  EXECUTE 'COPY datos_sisin FROM ' || quote_literal($1) || ' DELIMITER ''|'' CSV';

  SELECT INTO refresh_taxonomy * FROM refresh_taxonomy_lookup();

  FOR rec IN (SELECT row_to_json(j) FROM(select 'éxito' as message) j) LOOP  RETURN NEXT rec; END LOOP; RETURN;

EXCEPTION WHEN others THEN
     GET STACKED DIAGNOSTICS error_msg1 = MESSAGE_TEXT,
                          error_msg2 = PG_EXCEPTION_DETAIL,
                          error_msg3 = PG_EXCEPTION_HINT;
    FOR rec IN (SELECT row_to_json(j) FROM(select 'La base de datos experimentó el siguiente error: ' || error_msg1 as message) j) LOOP  RETURN NEXT rec; END LOOP; RETURN;	  
END;$$ LANGUAGE plpgsql;

/****************************************************************
  Precarga la taxonomía SISIN. Esto sólo debe hacerse una vez 
  para su instalación.
****************************************************************/
-- Organisation Role
INSERT INTO taxonomy(name, description, iati_codelist, created_by, updated_by) VALUES ('Organisation Role','IATI Standards. The IATI codelists ensure activity and organisation information is comparable between different publishers.','Organisation Role','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, code, name, description, iati_code, iati_name, iati_description, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE iati_codelist = 'Organisation Role'),'Responsable','Responsable','La agencia del gobierno, la sociedad civil o instituciones del sector privado que es responsable de la aplicación de la actividad.','Accountable','Accountable','The government agency, civil society or private sector institution which is accountable for the implementation of the activity.','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, code, name, description, iati_code, iati_name, iati_description, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE iati_codelist = 'Organisation Role'),'Extendedor','Extendedor','La entidad gubernamental (departamento o agencia del gobierno central, estatal o local), o agencia dentro de una institución, financiamiento de la actividad de su propio presupuesto','Extending','Extending','The government entity (central, state or local government agency or department), or agency within an institution, financing the activity from its own budget','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, code, name, description, iati_code, iati_name, iati_description, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE iati_codelist = 'Organisation Role'),'Financiadores','Financiadores','El país o institución que proporciona los fondos.','Funding','Funding','The country or institution which provides the funds.','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, code, name, description, iati_code, iati_name, iati_description, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE iati_codelist = 'Organisation Role'),'Implementas','Implementas','El intermediario entre la agencia y el beneficiario final. También conocido como organismo de ejecución o en el canal del parto. Pueden ser sector público, organismos no gubernamentales (ONG), las asociaciones público-privadas, o las instituciones multilaterales.','Implementing','Implementing','The intermediary between the extending agency and the ultimate beneficiary. Also known as executing agency or channel of delivery. They can be public sector, non-governmental agencies (NGOs), Public-Private partnerships, or multilateral institutions','Bolivia PMT Setup','Bolivia PMT Setup');

-- Sector
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Sector','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'EDUCACION Y CULTURA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'SALUD Y SEGURIDAD SOCIAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'AGROPECUARIO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'RECURSOS NATURALES Y MEDIO AMBIENTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'COMERCIO Y FINANZAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'ENERGIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'TRANSPORTES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'SANEAMIENTO BASICO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'MULTISECTORIAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'RECURSOS HIDRICOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'URBANISMO Y VIVIENDA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'MINERO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'INDUSTRIA Y TURISMO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'JUSTICIA Y POLICIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'COMUNICACIONES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Sector'),'ADMINISTRACION GENERAL','Bolivia PMT Setup','Bolivia PMT Setup');

-- Etapa
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Etapa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Etapa'),'Ejecución','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Etapa'),'Estudio Técnico Económico Social y Ambiental','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Etapa'),'Estudio de Identificación','Bolivia PMT Setup','Bolivia PMT Setup');

-- Area Influencia
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Area Influencia','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Area Influencia'),'Urbano/Rural','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Area Influencia'),'Urbano','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Area Influencia'),'Rural','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Area Influencia'),'Frontera','Bolivia PMT Setup','Bolivia PMT Setup');

-- Departamento
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Departamento','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'NACIONAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'SANTA CRUZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'LA PAZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'POTOSI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'CHUQUISACA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'COCHABAMBA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'TARIJA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'BENI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'ORURO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Departamento'),'PANDO','Bolivia PMT Setup','Bolivia PMT Setup');

-- Provincia
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Provincia','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial NACIONAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'JOSE MIGUEL DE VELASCO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MURILLO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'TOMAS FRIAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial CHUQUISACA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial LA PAZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial COCHABAMBA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial POTOSI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial TARIJA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial SANTA CRUZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial BENI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ATAHUALLPA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial ORURO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'Multiprovincial PANDO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'EDUARDO ABAROA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SAN PEDRO DE TOTORA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SAUCARI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CERCADO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'NICOLAS SUAREZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'JAIME ZUDAÑEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'PUNATA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'PACAJES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'YAMPARAEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SUD CINTI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'INGAVI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GENERAL NARCISO CAMPERO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'NOR CHICHAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'TIRAQUE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'OROPEZA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MANUEL MARIA CABALLERO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CARRASCO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CHAYANTA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'LOS ANDES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ANDRES IBAÑEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'NOR YUNGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GUALBERTO VILLARROEL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GENERAL ELIODORO CAMACHO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'AROMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'LARECAJA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'INQUISIVI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SUD YUNGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'LOAYZA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'OMASUYOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GENERAL JOSE MANUEL PANDO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CARANAVI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MANCO KAPAC','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ABEL ITURRALDE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'QUILLACOLLO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GERMAN JORDAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'AYOPAYA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ARANI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ARQUE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ESTEBAN ARCE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MIZQUE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SUD CARANGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'LITORAL DE ATACAMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'NOR CARANGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SEBASTIAN PAGADOR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CARANGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ANTONIO QUIJARRO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'RAFAEL BUSTILLO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CHARCAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CORNELIO SAAVEDRA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'JOSE MARIA LINARES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SUR CHICHAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'NOR CINTI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ANICETO ARCE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GRAN CHACO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'BURNET O’CONNOR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'JOSE MARIA AVILES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'EUSTAQUIO MENDEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ÑUFLO DE CHAVEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'OBISPO SANTIESTEBAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GUARAYOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'VALLEGRANDE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MARBAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MADRE DE DIOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MANURIPI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GENERAL FEDERICO ROMAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ABUNA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MAMORE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'BAUTISTA SAAVEDRA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SARA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GERMAN BUSCH','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CHAPARE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MOXOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ITENEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CHIQUITOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'JOSE BALLIVIAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'JUANA AZURDUY DE PADILLA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'TOMINA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'HERNANDO SILES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'LUIS CALVO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'GENERAL BERNARDINO BILBAO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'VACA DIEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SAJAMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CAPINOTA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'TAPACARI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SIMON BOLIVAR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ALONSO DE IBAÑEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'PANTALEON DALENCE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'POOPO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'FRANZ TAMAYO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MODESTO OMISTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'IGNACIO WARNES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'MUÑECAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'BELISARIO BOETO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'LADISLAO CABRERA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'PUERTO DE MEJILLONES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'DANIEL CAMPOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ICHILO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'CORDILLERA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'FLORIDA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'YACUMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'TOMAS BARRON','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'SUR LIPEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ENRIQUE BALDIVIESO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'NOR LIPEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Provincia'),'ANGEL SANDOVAL','Bolivia PMT Setup','Bolivia PMT Setup');

-- Municipio
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Municiple','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Ignacio (San I. de Velasco)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Alto de La Paz','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Potosí','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CHUQUISACA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal LA PAZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal COCHABAMBA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal POTOSI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal TARIJA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal SANTA CRUZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal BENI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chipaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal ORURO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal PANDO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'La Paz','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Challapata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal SAN PEDRO DE TOTORA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Toledo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Trinidad','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cobija','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CERCADO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Presto','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal JAIME ZUDAÑEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Punata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Corocoro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yamparáez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Camataqui (Villa Abecia)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Oruro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Guaqui','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Aiquile','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Zudañez (Tacopaya)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cotagaita','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tiraque','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sucre','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Comarapa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Rivero','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Villarroel','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ravelo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pucarani','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Laja','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santa Cruz de La Sierra','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Coripata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yotala','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tiahuanacu','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Desaguadero','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chacarilla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Humanata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Jesús de Machaca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santiago de Callapa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sica Sica (Villa Aroma)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sorata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Achocalla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colquiri','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Caquiaviri','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'La Asunta','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Combaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Calacoto','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Luribay','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Palca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Patacamaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Achacachi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Catacora','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Caranavi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Coroico','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Copacabana','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cairoma','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Carabuco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Charaña','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mecapaca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Umala','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ayo Ayo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Calamarca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Collana','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Waldo Ballivián','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sapahaqui','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pedro de Curahuara','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Papel Pampa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tipuani','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Teoponte','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Buenaventura','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colquencha','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Vinto','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cliza','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Morochata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Totora','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Arani','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pasorapa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ayopaya (Villa de Independencia)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chimoré','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pojo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Entre Ríos','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tacopaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sacabamba','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mizque','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Belén de Andamarca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cruz de Machacamarca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Huayllamarca (Stgo. Huayllamarca)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Totora Oruro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santiago de Huari','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sabaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Corque','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ocurí','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colquechaca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Uyuni (Thola Pampa)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Llallagua','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Uncía','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pedro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pocoata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Betanzos','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puna (Villa Talavera)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yocalla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Toro Toro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tupiza','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Camargo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Bermejo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tarija','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Padcaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Caraparí','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Uriondo (Concepción)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Lorenzo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Puente (Tomayapo)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yunchara','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yacuiba','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villamontes','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Javier (Santa Cruz)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Montero','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Urubichá','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Julián','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Vallegrande','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Fernández Alonso','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cotoca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Andrés','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Loreto','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Bella Flor','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Bolpebra','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Gonzalo Moreno','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Filadelfia','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Nueva Esperanza','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Porvenir','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Rico','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pedro (Conquista)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santa Rosa del Abuná','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santos Mercado','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sena','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Nueva (Loma Alta)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ingavi (Humaita)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Lorenzo Pando','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tarabuco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Omereque','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Javier (Beni)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Joaquín','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Ramón','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Siles','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Acosta','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mocomoco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'General Juan José Pérez (Charazani)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Guanay','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santa Rosa del Sara','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mineros','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Suárez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pedro de Tiquina','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tito Yupanqui','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CHAPARE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cochabamba','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ixiamas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Tunari','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Ignacio','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Baures','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Huacaraje','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Quillacollo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tiquipaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colcapirhua','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sacaba','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Miguel (San M. de Velasco)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Rafael','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San José','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Antonio de Lomerío','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Rurrenabaque','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Azurduy','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tarvita (Villa Orías)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tomina','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sopachuy','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Alcalá','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Villar','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Quiabaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Batallas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Pérez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Anzaldo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pocona','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Alalay','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Choro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Andamarca (Stgo. de Andamarca)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chayanta','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chuquihuta (Ayllu Jucumani)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chaquí','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Vitichi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ckochas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Monteagudo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Machareti','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Acasio','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Torno','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Riberalta','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Puerto Guayaramerín','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Padilla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal SAJAMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cocapata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sicaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tapacarí','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Arque','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Bolivar','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sacaca (Villa de Sacaca)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Caripuyo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Arampampa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal SUD YUNGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal NOR YUNGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal PANTALEON DALENCE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal POOPO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal RAFAEL BUSTILLO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CHAYANTA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal SUR CHICHAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Incahuasi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Inquisivi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ichoca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Apolo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Sipe Sipe','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colomi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tarata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Arbieto','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Toco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Capinota','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santivañez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Vacas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Shinahota','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Alto Beni','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CARANAVI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal ANDRES IBAÑEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villazón','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cuatro Cañadas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'La Guardia','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CHIQUITOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tacacoma','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal OBISPO SANTIESTEBAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Warnes','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pazña','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal MUÑECAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal INQUISIVI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal CORNELIO SAAVEDRA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal NOR CHICHAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal LOS ANDES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal PACAJES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal LOAYZA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chua Cocani','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Poroma','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Mojocoya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Icla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pablo de Huacareta','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Lucas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Serrano','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Culpina','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Vaca Guzmán (Muyupampa)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa Charcas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Viacha','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Quime','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cajuata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Licoma Pampa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ancoraimes','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chuma','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pelechuco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Irupana (Villa de Lanza)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Palos Blancos','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mapiri','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Taraco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Escoma','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Benito (Villa José Quintín Mendoza)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cuchumuela (Villa Gualberto Villarroel)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tolata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Vila Vila','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Caracollo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santuario de Quillacas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Huanuni','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Machacamarca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Poopó (Villa Poopó)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Antequera','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Escara','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yunguyo de Litoral','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Esmeralda','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Salinas de G. Mendoza','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Todos Santos','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Carangas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Coipasa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Soracachi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tinguipaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Urmiri','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tacobamba','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Atocha','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Caiza "D"','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tomave','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tahua','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ayacucho (Porongo)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Buena Vista','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Carlos','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yapacaní','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pailón','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Roboré','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Portachuelo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Charagua','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cabezas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Gutiérrez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Moro Moro','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pampa Grande','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mairana','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Quirusillas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'General Agustín Saavedra','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ascención de Guarayos','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Puente - Santa Cruz','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Okinawa I','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Ramón - Santa Cruz','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Juan','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Reyes','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Borja','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santa Rosa','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Magdalena','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Exaltación','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal EUSTAQUIO MENDEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Saipina','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yaco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Curahuara de Carangas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Villa de Huacaya','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Las Carreras','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Chulumani (Villa de la Libertad)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santiago de Huata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Huarina','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Yanacachi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Ayata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Curva','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Aucapata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Andrés de Machaca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Comanche','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santiago de Machaca','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Malla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Nazacara de Pacajes','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Tacachi','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'La Rivera','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Turco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Eucaliptus','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pampa Aullagas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Huachacalla','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Choque Cota','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pablo de Lípez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Mojinete','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Antonio de Esmoruco','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Agustín','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colcha"K" (Villa Martín)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Llica','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Pedro de Quemes','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Concepción','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Cuevo','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Boyuibe','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Camiri','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Colpa Bélgica','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Trigal','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'El Carmen Rivero Tórrez','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Postrer Valle','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Samaipata','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'San Matías','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Pucara','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Santa Ana','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Lagunillas','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal JOSE BALLIVIAN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal MAMORE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal ABEL ITURRALDE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Municipio'),'Multimunicipal QUILLACOLLO','Bolivia PMT Setup','Bolivia PMT Setup');

-- FTE
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('FTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'FTE'),'','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'FTE'),'DON-EXT','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'FTE'),'CREDEX','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'FTE'),'TRANSF-CREEX','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'FTE'),'TRANSF-DON','Bolivia PMT Setup','Bolivia PMT Setup');


-- Convenio
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Convenio','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'INFORMACION CIENTIFICA PARA APOYO A LA INVESTIGAC','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO A LA EDUCACION SECUNDARIA COMUNITARIA PRODUC','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PLAN SECTORIAL: DES. PRODUCTIVO CON EMPLEO DIGNO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'HOSPITALES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE ALIANZAS RURALES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FORT. POL. DE SOBERANIA  Y SEGURIDAD ALIMENTARIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA ACCESOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA MULTISECTORIAL DE PREINVERSION - PROMULPR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE ELECTRIFICACION RURAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO A LA PREP DE OPER PROG DE INFRAES AERO, ETAP','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA MAS INVERSIONES PARA EL AGUA  I - FASE 2','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGAMA MAS INVERSIONES PARA AGUA II','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE AGUA Y ALCANTARILLADO PERIURBANO FASE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'Apoyo a la Implementación de SAICM','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'INVEST. EVAL. BIODIVERSIDAD EN EL ANMI EL PALMAR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'OTROS FINANCIADORES EXTERNOS-720','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PARLAMENTO JUVENIL MERCOSUR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG DE AGUA Y RIEGO PARA BOLIVIA - PROAR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PASAP - AGUA Y SANEAMIENTO PERIURBANO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'SUM AGUA POTABLE Y SANEAMIENTO EN PEQ. COM.RURAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'P. DE APOYO AL PLAN SECT DE DESARROLLO PASAR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE APOYO AL SECTOR DE AGUA Y SANEAMIENTO BASICO - PASAAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO PROGRAMA DE ERRADICACION EXTREMA POBREZA (PEEP) FASE I','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'AGUA PARA PEQUEÑAS COMUNIDADES (06/07)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA MIAGUA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. NACIONAL DE RIEGO CON ENFOQUE DE CUENCA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG AGUA POTABLE Y SANEAM PARA PEQUE LOCAL Y COMUNI RURALES DE BOL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROY EXP. ACCESO SS SALUD APL III','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PRG. APOY MODERNIZ. DEL SECT. PUB - PROREFORMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. APOYO RED PROT.SOCIAL/PLAN VIDA (APOYO PNC II)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DONACIONES - HIPC II','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE ERRADICACION DE LA EXTREMA POBREZA (COMPONENTE PRODUCTIVO)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO AL RIEGO COMUNITARIO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG PREINVERSIÓN EN PROYEC ESTRATEG DE TRANSPORTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA SECTORIAL DE TRANSPORTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FONDO GLOBAL DE LUCHA CONTRA EL VIH SIDA, TUBERCULOSIS Y MALARIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FORTALECIM REDES SALUD MUNICP CBBA, CHUQ, PT Y LP','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DESARROLLO INFANTIL TEMPRANO Y EDUC TECNO URBANA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FORTALECIMIENTO DE REDES INTEGRALES DE SALUD','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO VALE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO ALIANZAS RURALES (PAR II)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'MANEJO INT.REC. NAT. TROPICO CBBA Y YUNGAS LA PAZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. DE SANIDAD AGROPECUARIA E INOCUIDAD ALIMENTARIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. APOYO SEC. AGRI. Y PRODUC.- ASAP','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE INVERSION COMUNITARIA EN ÁREAS RURALES - PICAR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FONDO DE ESTUDIOS Y MISIONES DE APOYO TECNICO III','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE GENERACION DE ENERGIAS ALTERNATIVAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE TURISMO COMUNITARIO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONSERVACION DE BIODIVERSIDAD A TRAV D LA  GESTION SOSTENIBLE BOSQUES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'EVALUACION D NECESIDADES D TECNOLOGIAS 1215227-03','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PLAN VIDA - PEEP','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA REGISTRO DE BENEFICIARIOS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG INV. NIÑOS Y JOVENES PROT SOCIAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE APOYO AL EMPLEO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'EMPLEOMIN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'ENERGIAS RENOVABLES BOLIVIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'ELECTRIFICACION CARANAVI - TRINIDAD','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE DESARROLLO MUNICIPAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA NACIONAL DE RIEGO SIRIC II/2006','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE AGUA POTABLE Y ALCANTARILLADO PERIURBANO, FASE I','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'TERC COMUNIC NAL ANTE LA CMNUCC SOBRE CAMBIO CLIIM','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA PILOTO DE RESCILIENCIA CLIMATICA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGR.PILOTO DE RESILIENCIA CLIMATICA-FASEII(PPCR)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONSERV Y USO SOST DE LA TIERRA Y ECOS VERT ANDINO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE AGUA, SANEAMIENTO Y DRENAJE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'INVER PARA LA ADAPT DEL CAMB CLIMAT EN EL SEC HIDR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG AGUA POT Y SANEA PEQUE LOC Y COMU RUR DE BOL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'MANEJO SOSTENIBLE BOSQUES ECOSIST GRAN CHACO AMERI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'GESTIÓN RIESGOS BENI - VIVIR CON EL AGUA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG DE COOP TRILATERAL AMAZONIA SIN FUEGO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG PREVENCION DESASTRES NATURALES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APROVECHAMIENTO RIEGO MONTE VERDE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'REVIT. DEL RIEGO A TRAVES DE ASIST. TECNICA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE RIEGO - SIRIC','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'SIST. DE MICRO RIEGO HUAYLLANI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'TRANSFORMACION DE LA EDUCACION SECUNDARIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA MULTIFASE DE MEJORAMIENTO DE BARRIOS, FASE I','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE DRENAJE EN LOS MUNICIPIOS DE LA PAZ Y','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO A LA EDUCACION','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FORT INSTITUCIONAL DEL MIN.MEDIO AMB Y AGUA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONST. CENTRO INFANTIL COMUNITARIO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'OTROS EXTERNOS5 - Organismo 568','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO PLA NL. DES. INTEGRAL CON COCA 2006-2010','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'REHABILITACIÓN Y MODERNIZACIÓN DE LAS UNIV. NACION','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'Cooperacion Academica Universidad AARHUS ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. APOYO DES. SIS. SOCIOSANITARIO POTOSI - IV','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONS. AULAS U.E. DAVID MENDOZA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'AGUA SANEAMIENTO E HIGIENE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'MEJORAMIENTO TRAMO SANTA BARBARA - RURRENABAQUE DEL CORREDOR NORTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. CARRETERAS DE INTEGRACION DEL SUR-FASE II','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. OBRAS VIALES Y  COMPLEMENTARIAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA  LA "Y"  DE INTEGRACION - FASE II','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'RUTA GUABIRA - CHANE - COLONIA PIRAI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CARRETERA "Y" DE INTEGRACIÓN','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CUARTO PROGRAMA APOYO SECTOR TRANSPORTE PAST IV','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CARRETERAS NACIONALES E INFRAESTRUCTURA AEROPORTUARIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CARR. TARABUCO-ZUDAAÑES-PADILLA Y MONTEAG-IPATI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CORREDOR VIAL NORTE LAPAZ - CARANAVI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FORT.DE LA CAPAC.ESTAD.Y LA BASE DE INF.PARA LA PLANIF.BASADA EN EVID.','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE INNOVACON Y SERVICIOS AGROPECUARIOS - PISA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'Convenio HABITAT','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PRO-JUSTICIA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO AL PROGRAMA DE PROTECCION SOCIAL/2006','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DESARROLLO CONCURRENTE REGIONAL PDCR II','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. SANEAM. BASICO PEQUEÑAS COMUNIDADES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DESARROLLO SOSTENIBLE DEL LAGO TITICACA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'RECUP.DE EMERGENCIAS Y GES.DES.(FINAN.ADICIONAL)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONTINGEN-CONSTR MEDI RIO PIRAI, GRANDE V. TUNARI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE DESARROLLO CONCURRENTE REGIONALPDCRIII','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA DE ATEN. DE EMERGENCIAS III','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'RECUPERACION DE EMERGENCIAS Y GESTION DE DESASTRES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DESARROLLO CONCURRENTE REGIONAL -GESTOR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CARRETERA DOBLE VIA LA PAZ - ORURO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PUENTE BANEGAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CARRETERA  UYUNI-HUANCARANI-CRUCE CONDO K','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONSTRUC.CARRETERA URUGUAITO-STA.ROSA-S.IGNACIO V','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONSTRUCCION CARRETRA CHACAPUCO - RAVELO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONSTRUCCION TUNEL INCAHUASI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DOBLE VIA SACABA-CHIÑATA Y QUILLACOLLO-SUTICOLLO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'TRAMO DOBLE VIA COCHABAMBA ORURO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO CONSTRUCCION CARRETERA UYUNI-TUPIZA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'MANTENIMIENTO VIAL POR ESTANDARES','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE CONSERVACION VIAL DEL CORREDOR ESTE-OESTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA PUESTA A PUNTO DE CARRETERAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'RESTAURACION Y AMPLIACION DEL MUSEO NACIONAL ARTE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'SIST. REGIONAL INTEGRADO DE AREAS PROTEGIDAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO HIDROELECTRICO DE ENERGIA RENOVABLE MISICUNI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'LINEA DE TRANSMISIÓN ELECTRICA LA PAZ - COCHABAMBA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO HIDROELECTRICO SAN JOSE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE TRANSMISIÓN ELEC.CARANAVI-TRINIDAD','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FASA II - PROG. A. DESARR. SOST. RR.NN. MEDIO AMB','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA SATELITAL TUPAC KATARI','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO HIDROELECTRICO MISICUNI - AMBIENTAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG. DE DESARROLLO LOCAL CON RESPONSABILIDAD FISCAL-FASE I','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROGRAMA APOYO PASA  SEGUNDA FASE - III','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'INICIATIVAS RURALES PARA SEGURIDAD ALIMENTARIA (CRIAR)','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'GEST. SOSTENIBLE DE RRNN DE CUENCAS LAGO POOPO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'SISTEMAS DE AGUA POTABLE Y SANEAM. BASICO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROG.DE PROTEC.SOC.EINFRAES.URB.PERIURB.Y RURAL','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DONACION PARA EDUCACION Y SALUD DE JAPON','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE INFRAESTRUCTURA URBANA 2','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROYECTO DE INFRAESTRUCTURA URBANA - 2005','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'ATN.Y DESARROLLO PRIMERA INFANCIA-LA PAZ Y EL ALTO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONSERVACION COMPLEJO ARQUEOLOGICO','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APOYO A LAS UNIDADES EDUCATIVAS','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'SISTEMA DE RIEGO COMUNIDAD K''ANAPATA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CONVENIO WATER FOR PEOPLE','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'DERECHOS DE LA NIÑEZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'FORTAL. CADENA DE PRODUCCION DE QUINUA MARKA AROMA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'CARRETERAS DE INTEGRACION DEL SUR','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'MERCADO MAYORISTA SANTA CRUZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'SEMAFORIZACION CIUDAD DE SANTA CRUZ','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'APC-CONSTRUC EQUIP POSTA SANITA CANTON STO CORAZON','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'MECANISMO ESTRATEGICO DE GOBERNANZA','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Convenio'),'PROT. RIBERAS Y MANEJOS SILVICULTURAL RIO GRANDE','Bolivia PMT Setup','Bolivia PMT Setup');

-- Tipo Presupuesto
INSERT INTO taxonomy(name, created_by, updated_by) VALUES ('Tipo Presupuesto','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Tipo Presupuesto'),'Costo Total','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Tipo Presupuesto'),'Presupuestado','Bolivia PMT Setup','Bolivia PMT Setup');
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Tipo Presupuesto'),'Ejecutado','Bolivia PMT Setup','Bolivia PMT Setup');

-- Data Group
INSERT INTO classification(taxonomy_id, name, created_by, updated_by) VALUES ((SELECT taxonomy_id FROM taxonomy WHERE name = 'Data Group'),'Bolivia','Bolivia PMT Setup','Bolivia PMT Setup');
