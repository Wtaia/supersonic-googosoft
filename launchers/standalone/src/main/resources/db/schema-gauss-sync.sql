CREATE OR REPLACE FUNCTION "sync_ind_model_info_data"()
  RETURNS "pg_catalog"."void"
  LANGUAGE plpgsql VOLATILE
  COST 100
AS $BODY$ BEGIN

    -- 插入基础模型
    INSERT INTO s2_model (NAME,
                          biz_name,
                          domain_id,
                          status,
                          description,
                          viewer,
                          ADMIN,
                          created_by,
                          created_at,
                          updated_by,
                          updated_at,
                          database_id,
                          model_id,
                          model_detail)
SELECT model_name,
       model_code,
       2,
       case
           when is_deleted = 0 then 1
           when is_deleted = 1 then 2
           else 0
           end,
       model_description,
       'admin',
       'admin',
       create_by,
       create_time,
       update_by,
       update_time,
       2,
       model_id,
       (SELECT jsonb_build_object(
                       'fields',
                       json_agg(DISTINCT jsonb_build_object('fieldName', ind_model_column.column_code, 'dataType',
                                                                ind_model_column.column_type)),
                       'queryType',
                       'sql_query',
                       'sqlQuery',
                       'select * from ' || ind_model_info.model_code,
                       'identifiers',
                       json_agg(jsonb_build_object('bizName', 'id', 'fieldName', 'id', 'name', '编号',
                                                   'isCreateDimension', 0, 'type', 'primary'))
               )
        FROM ind_model_column
        WHERE ind_model_info.model_id = ind_model_column.model_id
          and ind_model_column.is_deleted = 0)
FROM ind_model_info
WHERE NOT EXISTS (SELECT 1 FROM s2_model WHERE s2_model.model_id = ind_model_info.model_id)
  and ind_model_info.is_deleted = 0;
--  插入进阶模型
INSERT INTO s2_model (NAME,
                      biz_name,
                      domain_id,
                      status,
                      description,
                      viewer,
                      ADMIN,
                      created_by,
                      created_at,
                      updated_by,
                      updated_at,
                      database_id,
                      model_id,
                      model_detail)
SELECT model_name,
       model_code,
       2,
       case
           when is_deleted = 0 then 1
           when is_deleted = 1 then 2
           else 0
           end,
       model_description,
       'admin',
       'admin',
       create_by,
       create_time,
       update_by,
       update_time,
       2,
       model_id,
       (SELECT jsonb_build_object(
                       'fields',
                       json_agg(DISTINCT
                                    jsonb_build_object('fieldName', ind_agg_model_column.column_code, 'dataType',
                                                       ind_agg_model_column.column_type)),
                       'queryType',
                       'sql_query',
                       'sqlQuery',
                       'select * from ' || ind_agg_model_info.model_code,
                       'identifiers',
                       json_agg(jsonb_build_object('bizName', 'id', 'fieldName', 'id', 'name', '编号',
                                                   'isCreateDimension', 0, 'type', 'primary'))
               )
        FROM ind_agg_model_column
        WHERE ind_agg_model_info.model_id = ind_agg_model_column.model_id
          and ind_agg_model_column.is_deleted = 0)
FROM ind_agg_model_info
WHERE NOT EXISTS (SELECT 1 FROM s2_model WHERE s2_model.model_id = ind_agg_model_info.model_id)
  and ind_agg_model_info.is_deleted = 0;

--  插入单据模型
INSERT INTO s2_model (NAME,
                      biz_name,
                      domain_id,
                      status,
                      description,
                      viewer,
                      ADMIN,
                      created_by,
                      created_at,
                      updated_by,
                      updated_at,
                      database_id,
                      model_id,
                      model_detail)
SELECT receipt_model_name,
       receipt_model_code,
       2,
       case
           when is_deleted = 0 then 1
           when is_deleted = 1 then 2
           else 0
           end,
       receipt_model_description,
       'admin',
       'admin',
       create_by,
       create_time,
       update_by,
       update_time,
       2,
       receipt_model_id,
       (SELECT jsonb_build_object(
                       'fields',
                       json_agg(DISTINCT
                                    jsonb_build_object('fieldName', ind_receipt_model_column.COLUMN_NAME, 'dataType',
                                                       ind_receipt_model_column.column_type)),
                       'queryType',
                       'sql_query',
                       'sqlQuery',
                       'select * from ' || ind_receipt_model_info.receipt_model_code,
                       'identifiers',
                       json_agg(jsonb_build_object('bizName', 'id', 'fieldName', 'id', 'name', '编号',
                                                   'isCreateDimension', 0, 'type', 'primary'))
               )
        FROM ind_receipt_model_column
        WHERE ind_receipt_model_info.receipt_model_id = ind_receipt_model_column.receipt_model_id
          and ind_receipt_model_column.is_deleted = 0)
FROM ind_receipt_model_info
WHERE NOT EXISTS (SELECT 1 FROM s2_model WHERE s2_model.model_id = ind_receipt_model_info.receipt_model_id)
  and ind_receipt_model_info.is_deleted = 0;

-- 插入指标
INSERT INTO s2_metric (NAME,
                       biz_name,
                       description,
                       status,
                       sensitive_level,
                       TYPE,
                       type_params,
                       created_by,
                       created_at,
                       updated_by,
                       updated_at,
                       define_type,
                       metric_id,
                       model_id_char,
                       model_id)
SELECT indicator_name,
       indicator_measure_column,
       '',
       case
           when is_deleted = 0 then 1
           when is_deleted = 1 then 2
           else 0
           end,
       0,
       'ATOMIC',
       '{}',
       create_by,
       create_time,
       update_by,
       update_time,
       'MEASURE',
       indicator_id,
       model_id,
       (SELECT ID FROM s2_model WHERE s2_model.model_id = ind_indicator_info.model_id LIMIT 1)
FROM ind_indicator_info
WHERE NOT EXISTS (SELECT 1 FROM s2_metric WHERE s2_metric.metric_id = ind_indicator_info.indicator_id)
  and is_deleted = 0;

-- 插入维度
INSERT INTO s2_dimension (NAME,
                          biz_name,
                          description,
                          status,
                          sensitive_level,
                          TYPE,
                          type_params,
                          expr,
                          created_by,
                          created_at,
                          updated_by,
                          updated_at,
                          semantic_type,
                          is_tag,
                          ext,
                          dimension_id,
                          model_id_char,
                          model_id)
WITH model_ids AS (SELECT DISTINCT model_id FROM s2_model)
SELECT DISTINCT ind_model_column.COLUMN_NAME,
                ind_model_column.column_code,
                ind_model_column.column_description,
                case
                    when ind_model_column.is_deleted = 0 then 1
                    when ind_model_column.is_deleted = 1 then 2
                    else 0
                    end,
                CASE
                    WHEN ind_model_column.dimension_level = '一级维度级次' THEN
                        1
                    WHEN ind_model_column.dimension_level = '二级维度级次' THEN
                        2
                    WHEN ind_model_column.dimension_level = '三级维度级次' THEN
                        3
                    ELSE
                        NULL
                    END AS dimension_level_value,
                'categorical',
                NULL,
                ind_model_column.column_code,
                ind_model_column.create_by,
                ind_model_column.create_time,
                ind_model_column.update_by,
                ind_model_column.update_time,
                'CATEGORY',
                0,
                '{}',
                ind_model_column.model_column_id,
                ind_model_column.model_id,
                s2_model.ID
FROM ind_model_column
         JOIN s2_model ON s2_model.model_id = ind_model_column.model_id
         JOIN model_ids ON model_ids.model_id = ind_model_column.model_id
WHERE ind_model_column.COLUMN_NAME IS NOT NULL
  and ind_model_column.is_deleted = 0
UNION ALL
SELECT DISTINCT ind_agg_model_column.COLUMN_NAME,
                ind_agg_model_column.column_code,
                ind_agg_model_column.column_description,
                case
                    when ind_agg_model_column.is_deleted = 0 then 1
                    when ind_agg_model_column.is_deleted = 1 then 2
                    else 0
                    end,
                CASE
                    WHEN ind_agg_model_column.dimension_level = '一级维度级次' THEN
                        1
                    WHEN ind_agg_model_column.dimension_level = '二级维度级次' THEN
                        2
                    WHEN ind_agg_model_column.dimension_level = '三级维度级次' THEN
                        3
                    ELSE
                        NULL
                    END AS dimension_level_value,
                'categorical',
                NULL,
                ind_agg_model_column.column_code,
                ind_agg_model_column.create_by,
                ind_agg_model_column.create_time,
                ind_agg_model_column.update_by,
                ind_agg_model_column.update_time,
                'CATEGORY',
                0,
                '{}',
                ind_agg_model_column.model_column_id,
                ind_agg_model_column.model_id,
                s2_model.ID
FROM ind_agg_model_column
         JOIN s2_model ON s2_model.model_id = ind_agg_model_column.model_id
         JOIN model_ids ON model_ids.model_id = ind_agg_model_column.model_id
WHERE ind_agg_model_column.COLUMN_NAME IS NOT NULL
  and ind_agg_model_column.is_deleted = 0
UNION ALL
SELECT DISTINCT ind_receipt_model_column.column_description,
                ind_receipt_model_column.COLUMN_NAME,
                ind_receipt_model_column.column_description,
                case
                    when ind_receipt_model_column.is_deleted = 0 then 1
                    when ind_receipt_model_column.is_deleted = 1 then 2
                    else 0
                    end,
                CASE
                    WHEN ind_receipt_model_column.dimension_level = '一级维度级次' THEN
                        1
                    WHEN ind_receipt_model_column.dimension_level = '二级维度级次' THEN
                        2
                    WHEN ind_receipt_model_column.dimension_level = '三级维度级次' THEN
                        3
                    ELSE
                        NULL
                    END AS dimension_level_value,
                'categorical',
                NULL,
                ind_receipt_model_column.COLUMN_NAME,
                ind_receipt_model_column.create_by,
                ind_receipt_model_column.create_time,
                ind_receipt_model_column.update_by,
                ind_receipt_model_column.update_time,
                'CATEGORY',
                0,
                '{}',
                ind_receipt_model_column.receipt_model_column_id,
                ind_receipt_model_column.receipt_model_id,
                s2_model.ID
FROM ind_receipt_model_column
         JOIN s2_model ON s2_model.model_id = ind_receipt_model_column.receipt_model_id
         JOIN model_ids ON model_ids.model_id = ind_receipt_model_column.receipt_model_id
WHERE ind_receipt_model_column.column_description IS NOT NULL
  and ind_receipt_model_column.is_deleted = 0;

-- 更新 student1 表中的记录，更新条件是 id 相同且字段内容发生变化
--     UPDATE student1
--     SET name = singer.singer_name
--     FROM singer
--     WHERE student1.name = singer.singer_name;
-- 删除 student1 表中在 student 表中已不存在的记录
--     DELETE FROM student1
--     WHERE NOT EXISTS (
--         SELECT 1
--         FROM singer
--         WHERE student1.name = singer.singer_name
--     );
END; $BODY$
