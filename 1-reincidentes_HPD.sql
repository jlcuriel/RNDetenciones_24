USE [Indicadores_RND]
GO
/****** Object:  StoredProcedure [dbo].[reincidentes_HPD]    Script Date: 17/03/2024 09:08:24 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[reincidentes_HPD]
@fecini  date,
@fecfin date,
@idestad int
WITH EXEC AS CALLER
AS

BEGIN

--Modificacion 05/03/2024
--Autor: JLCR
--Descripción: se cambia el having count(1) por having sum()
/*
declare @fecini date, @fecfin date;
declare @idestad int, @listar int;

set @fecini = '2020-10-01';
set @fecfin = '2024-02-23';
set @idestad = 11;

DECLARE @fecfin date;
SET @FecFin = convert(date, GETDATE() - 1);
*/

IF OBJECT_ID(N'tempdb.dbo.#TemRegTotEdo', N'U') IS NOT NULL  
   DROP TABLE #TemRegTotEdo;

IF OBJECT_ID(N'tempdb.dbo.#regtotedo', N'U') IS NOT NULL  
   DROP TABLE #regtotedo;

IF OBJECT_ID(N'tempdb.dbo.#TopRegDuplicados', N'U') IS NOT NULL  
   DROP TABLE #TopRegDuplicados;

IF OBJECT_ID(N'tempdb.dbo.#TablaNomEstatus', N'U') IS NOT NULL  
   DROP TABLE #TablaNomEstatus;

IF OBJECT_ID(N'tempdb.dbo.#TempRegUnico', N'U') IS NOT NULL  
   DROP TABLE #TempRegUnico;


SELECT ROW_NUMBER() OVER(ORDER BY d.id_detenido ASC) AS reg, e.NOMBRE entidad, m.NOMBRE municipio
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),dt.lugar_detencion),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') lugar_detencion
, d.id_detenido
, d.folio_detenido
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(d.nombre), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as nombre
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(d.apellido_paterno), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as apellido_paterno
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(d.apellido_materno), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as apellido_materno
, dt.fecha_detencion
, dc.curp
, e1.NOMBRE entidad_dom
, m1.NOMBRE mpio_dom
, loc.nombre localidad_dom
, col.NOMBRE colonia_dom
, dc.numero_interio
, dc.numero_exterior
, dc.codigo_postal
, cmc.motivo_conclusion_ri
, d.describe_motivo_conclusion 
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(
     UPPER(p.nombre_oficial_recibe), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' ))))
     ,CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as MP
, (SELECT STUFF(
       (select ', ' + 
          REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(b.apellido_paterno 
                     + ' ' + b.apellido_materno  + ' ' + b.Nombre)
                     , 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ')
          from RNDetenciones.dbo.oficiales b WITH (NOLOCK)
          where b.id_detencion = d.id_detencion
                FOR XML PATH ('')),
          1,2, '')) oficial
, (SELECT STUFF(
       (SELECT ', ' + 
          REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(b.paterno 
                     + ' ' + b.materno  + ' ' + b.Nombre)
                     , 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ')
          from RNDetenciones.dbo.oficiales_PSP b WITH (NOLOCK)
          where b.id_detencion = d.id_detencion
                FOR XML PATH ('')),
          1,2, '')) oficial_psp
, cedf.descripcion_estatus
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),dt.motivo_detencion),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') motivo_detencion
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),ctl.tipo_libertad),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') tipo_libertad
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),tr.causa_libertad),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') causa_libertad
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),ctt.nombre_tipo_traslado),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') nombre_tipo_traslado
, d.fecha_nacimiento
, d.edad
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(dc.nombre_detenido), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as nombre_dc
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(dc.apellido_paterno), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as apellido_paterno_dc
, REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),rtrim(lTRIM(replace(replace(replace(replace(replace(UPPER(dc.apellido_materno), 'Á', 'A' ), 'É', 'E' ), 'Í', 'I' ), 'Ó', 'O' ), 'Ú', 'U' )))),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') as apellido_materno_dc
, dc.fecha_nacimiento Fec_nac_dc
, (SELECT STUFF(
     (SELECT ', ' + ctd1.tipo_delito
            FROM RNDetenciones.dbo.traslados_delitos td1 WITH (NOLOCK)
            LEFT JOIN RNDetenciones.dbo.cat_subtipo_delito csd1 ON td1.id_subtipo_delito = csd1.id_subtipo_delito 
            LEFT JOIN RNDetenciones.dbo.cat_tipo_delito ctd1 ON ctd1.id_tipo_delito = td1.id_tipo_delito AND ctd1.id_bien != 0 
            LEFT JOIN RNDetenciones.dbo.cat_bienes_juridicos cbj1 ON cbj1.id_bien = td1.id_bien 
            WHERE td1.id_traslado = tr.id_traslado 
            FOR XML PATH ('')),
          1,2, '')) delitos
, (SELECT STUFF(
     (SELECT ', ' + cbj1.bien_juridico
            FROM RNDetenciones.dbo.traslados_delitos td1 WITH (NOLOCK)  
            LEFT JOIN RNDetenciones.dbo.cat_subtipo_delito csd1 ON td1.id_subtipo_delito = csd1.id_subtipo_delito 
            LEFT JOIN RNDetenciones.dbo.cat_tipo_delito ctd1 ON ctd1.id_tipo_delito = td1.id_tipo_delito AND ctd1.id_bien != 0 
            LEFT JOIN RNDetenciones.dbo.cat_bienes_juridicos cbj1 ON cbj1.id_bien = td1.id_bien 
            WHERE td1.id_traslado = tr.id_traslado 
            FOR XML PATH ('')),
          1,2, '')) bien_juridico
, (SELECT STUFF(
     (SELECT ', ' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(max),td1.especifique_delito),CHAR(10),''),CHAR(9),' '),CHAR(13),''),'"',' ') 
            FROM RNDetenciones.dbo.traslados_delitos td1 WITH (NOLOCK) 
            LEFT JOIN RNDetenciones.dbo.cat_subtipo_delito csd1 ON td1.id_subtipo_delito = csd1.id_subtipo_delito 
            LEFT JOIN RNDetenciones.dbo.cat_tipo_delito ctd1 ON ctd1.id_tipo_delito = td1.id_tipo_delito AND ctd1.id_bien != 0 
            LEFT JOIN RNDetenciones.dbo.cat_bienes_juridicos cbj1 ON cbj1.id_bien = td1.id_bien 
            WHERE td1.id_traslado = tr.id_traslado 
            FOR XML PATH ('')),
          1,2, '')) especifique_delito
into #Temregtotedo
FROM RNDetenciones.dbo.detenidos d WITH (NOLOCK)
inner join RNDetenciones.dbo.detenciones dt WITH (NOLOCK) on dt.id_detencion=d.id_detencion
inner join GeoDirecciones.dbo.ENTIDAD e on e.IDENTIDAD = dt.id_entidad
left join RNDetenciones.dbo.puesta_disposiciones p  WITH (NOLOCK) on p.id_detenido=d.id_detenido and p.es_borrado = 0 
left join RNDetenciones.dbo.detenidos_datoscomplementarios dc WITH (NOLOCK) on dc.id_puesta_disposicion=p.id_puesta_disposicion
left join RNDetenciones.dbo.traslados tr WITH (NOLOCK) on tr.id_detenido_complemento = dc.id_detenido_complemento and tr.es_activo = 1
left join RNDetenciones.dbo.cat_tipos_libertades ctl on ctl.id_tipo_libertad = tr.id_tipo_libertad
inner join GeoDirecciones.dbo.MUNICIPIO m on m.IDENTIDAD = dt.id_entidad and m.IDMPIO = dt.id_municipio
inner join RNDetenciones.dbo.cat_estatus_detenidos cedf on cedf.id_estatus_detenido = d.id_estatus_detenido
left join GeoDirecciones.dbo.ENTIDAD e1 on e1.IDENTIDAD = dc.id_entidad
left join GeoDirecciones.dbo.MUNICIPIO m1 on m1.IDENTIDAD = dc.id_entidad and m1.IDMPIO = dc.id_municipio
left join GeoDirecciones.dbo.localidad loc on loc.IDENTIDAD = dc.id_entidad and loc.IDMPIO = dc.id_municipio and loc.idloc = dc.id_localidad
left join GeoDirecciones.dbo.colonia col on col.idcolonia = dc.id_colonia
left join RNDetenciones.dbo.cat_tipos_traslados ctt on ctt.id_tipo_traslado = tr.id_tipo_traslado
left join RNDetenciones.dbo.cat_motivos_conclusiones_ri cmc on cmc.id_motivo_conclusion_ri = d.id_motivo_conclusion_ri

where dt.id_entidad = @idestad
and d.edad > 17
and dt.fecha_detencion >= @fecini and dt.fecha_detencion <= @fecfin
order by apellido_paterno, apellido_materno, nombre,d.fecha_nacimiento;

--------------------
select d.*
into #regtotedo 
from #Temregtotedo d
where  (d.nombre != 'SIN DATOS'
and  d.nombre != 'X'
and d.nombre != 'N'
and d.nombre not like '%SIN DATO%'
and d.nombre not like '%NO PROPOR%'
and d.nombre not like '%SIN INFOR%')
and LOWER(d.motivo_detencion) NOT LIKE '%pensi%alimenticia'
order by apellido_paterno, apellido_materno, nombre, d.fecha_nacimiento;

--determina detenido duplicados 
select nombre, apellido_paterno ,apellido_materno, isnull(CAST(fecha_nacimiento AS DATE), '') fecha_nacimiento, isnull(CAST(fecha_detencion AS DATE), '')  fecha_detencion, count(1) reg
into #TopRegDuplicados
from #regtotedo
group by nombre, apellido_paterno ,apellido_materno, isnull(CAST(fecha_nacimiento AS DATE), ''), isnull(CAST(fecha_detencion AS DATE), '')
having count(1) > 1
order by 2, 3, 1;


--Tomar registro unico
     select max(a.folio_detenido) folio_detenido
     into #TempRegUnico
     from #regtotedo a
     inner join #TopRegDuplicados b on a.nombre + a.apellido_paterno + a.apellido_materno
                     = b.nombre + b.apellido_paterno + b.apellido_materno
                and isnull(a.fecha_nacimiento, '') = isnull(b.fecha_nacimiento, '')
                and isnull(a.fecha_detencion, '') = isnull(b.fecha_detencion, '')
     group by a.nombre + a.apellido_paterno + a.apellido_materno, isnull(a.fecha_nacimiento, ''), isnull(a.fecha_detencion, '');

-----borra registros duplicados que su fecha de detencion sea exacamente igual, con el nombre completo y su fecha de nacieminto
delete from #regtotedo
where isnull(nombre,'') + isnull(apellido_paterno,'') + isnull(apellido_materno,'')
                + isnull(convert(varchar, fecha_nacimiento, 103),'') + isnull(convert(varchar, fecha_detencion, 103),'')
          in (select isnull(b.nombre,'') + isnull(b.apellido_paterno,'') + isnull(b.apellido_materno,'')
                + isnull(convert(varchar, b.fecha_nacimiento, 103),'')+ isnull(convert(varchar, b.fecha_detencion, 103),'')
          from #regtotedo b
          group by b.nombre, b.apellido_paterno ,b.apellido_materno, b.fecha_nacimiento, b.fecha_detencion
          having count(1) > 1);

--inserta el registro unico de los borrados
insert into #regtotedo 
     select * 
     from #Temregtotedo
     where folio_detenido in (select folio_detenido 
                                     from #TempRegUnico);

--genera listado de los acumulado por nombre y estatus
select a.nombre, a.apellido_paterno, a.apellido_materno, a.descripcion_estatus, a.fecha_nacimiento, count(1) reg
into #TablaNomEstatus
from #regtotedo a
group by a.nombre, a.apellido_paterno, a.apellido_materno, a.descripcion_estatus, a.fecha_nacimiento 
order by 6 desc, 2,3,1;

--listado
--select * from #TopRegDuplicados a order by a.nombre, a.apellido_paterno, a.apellido_materno
select a.nombre, a.apellido_paterno, a.apellido_materno, isnull(CAST(a.fecha_nacimiento AS DATE), '') fecha_nacimiento, sum(a.reg) tot_gral
, isnull(sum(case when a.descripcion_estatus = 'CAPTURA'  
                or a.descripcion_estatus = 'RECIBIDO' 
                or a.descripcion_estatus = 'REGISTRADA' 
                or a.descripcion_estatus = 'POR INCOMPETENCIA' then a.reg end),0) sin_concluir
, isnull(sum(case when a.descripcion_estatus = 'CONCLUIDO' then a.reg end),0) concluir
, isnull(sum(case when a.descripcion_estatus = 'CERRADO POR SISTEMA' then a.reg end),0) Cerrado_x_Sistema
from #TablaNomEstatus a
group by a.nombre, a.apellido_paterno, a.apellido_materno, isnull(CAST(a.fecha_nacimiento AS DATE), '')
having sum(a.reg) > 1
order by 5 desc, 2, 3, 1, 4;

----detalle 2023
--lista Total de detenidos por año
     select a.*
     from #regtotedo a;

END;
