CREATE OR REPLACE FUNCTION "json_object_set_keys"(
  "json"          json,
  "keys_to_set"   TEXT[],
  "values_to_set" anyarray
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
            WHERE "key" <> ALL ("keys_to_set")
            UNION ALL
           SELECT DISTINCT ON ("keys_to_set"["index"])
                  "keys_to_set"["index"],
                  CASE
                    WHEN "values_to_set"["index"] IS NULL THEN 'null'
                    ELSE to_json("values_to_set"["index"])
                  END
             FROM generate_subscripts("keys_to_set", 1) AS "keys"("index")
             JOIN generate_subscripts("values_to_set", 1) AS "values"("index")
            USING ("index")) AS "fields"),
  '{}'
)::json
$function$;
