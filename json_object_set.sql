CREATE OR REPLACE FUNCTION "json_object_set"(
  "json"   json,
  "to_set" json
)
  RETURNS json
  LANGUAGE sql
  IMMUTABLE
  STRICT
AS $function$
SELECT COALESCE(
  (SELECT ('{' || string_agg(to_json("key") || ':' || "value", ',') || '}')
     FROM (SELECT *
             FROM json_each("json")
            WHERE "key" <> ALL (SELECT * FROM json_object_keys("to_set"))
            UNION ALL
           SELECT *
             FROM json_each("to_set")) AS "fields"),
  '{}'
)::json
$function$;

