BEGIN;

DELETE FROM public.dashboard_groups
WHERE dashboard_id IN (
    SELECT id FROM public.dashboards
    WHERE index IN ('cleanbike_metrotaipei', 'cleanbike_realdata_metrotaipei', 'cleanbike_route_service_metrotaipei', 'cleanbike_winning_metrotaipei')
);

DELETE FROM public.dashboards
WHERE index IN ('cleanbike_metrotaipei', 'cleanbike_realdata_metrotaipei', 'cleanbike_route_service_metrotaipei', 'cleanbike_winning_metrotaipei');

DELETE FROM public.query_charts
WHERE index IN (
    'cleanbike_route_score',
    'cleanbike_air_risk',
    'cleanbike_low_carbon_benefit',
    'cleanbike_governance_priority',
    'cleanbike_real_youbike_supply',
    'cleanbike_real_bike_network',
    'cleanbike_real_station_density',
    'cleanbike_real_lowcarbon_context',
    'cleanbike_real_short_trip_readiness',
    'cleanbike_planner_recommendation',
    'cleanbike_exposure_compare',
    'cleanbike_public_value',
    'cleanbike_ai_decision_brief',
    'cleanbike_air_grid_layer'
);

DELETE FROM public.component_charts
WHERE index IN (
    'cleanbike_route_score',
    'cleanbike_air_risk',
    'cleanbike_low_carbon_benefit',
    'cleanbike_governance_priority',
    'cleanbike_real_youbike_supply',
    'cleanbike_real_bike_network',
    'cleanbike_real_station_density',
    'cleanbike_real_lowcarbon_context',
    'cleanbike_real_short_trip_readiness',
    'cleanbike_planner_recommendation',
    'cleanbike_exposure_compare',
    'cleanbike_public_value',
    'cleanbike_ai_decision_brief',
    'cleanbike_air_grid_layer'
);

DELETE FROM public.component_maps
WHERE id IN (9901, 9902, 9903)
   OR index IN ('cleanbike_routes_metrotaipei', 'cleanbike_air_points_metrotaipei', 'cleanbike_air_grid_metrotaipei');

DELETE FROM public.components
WHERE index IN (
    'cleanbike_route_score',
    'cleanbike_air_risk',
    'cleanbike_low_carbon_benefit',
    'cleanbike_governance_priority',
    'cleanbike_real_youbike_supply',
    'cleanbike_real_bike_network',
    'cleanbike_real_station_density',
    'cleanbike_real_lowcarbon_context',
    'cleanbike_real_short_trip_readiness',
    'cleanbike_planner_recommendation',
    'cleanbike_exposure_compare',
    'cleanbike_public_value',
    'cleanbike_ai_decision_brief',
    'cleanbike_air_grid_layer'
);

INSERT INTO public.components (id, index, name) VALUES
    (9901, 'cleanbike_route_score', 'CleanBike 清淨路線比較'),
    (9902, 'cleanbike_air_risk', 'YouBike 騎行空品風險'),
    (9903, 'cleanbike_low_carbon_benefit', '低碳健康效益'),
    (9904, 'cleanbike_governance_priority', '政府改善優先區'),
    (9911, 'cleanbike_real_youbike_supply', '真實資料：雙北 YouBike 供給'),
    (9912, 'cleanbike_real_bike_network', '真實資料：雙北自行車道路網'),
    (9913, 'cleanbike_real_station_density', '真實資料：站點與可借車分布'),
    (9914, 'cleanbike_real_lowcarbon_context', '真實資料：低碳運輸背景'),
    (9915, 'cleanbike_real_short_trip_readiness', '真實資料：短程騎乘可用性'),
    (9921, 'cleanbike_planner_recommendation', '我要到某地點：最佳清淨路線'),
    (9922, 'cleanbike_exposure_compare', '最速 vs 清淨：污染暴露比較'),
    (9923, 'cleanbike_public_value', '民眾服務價值'),
    (9924, 'cleanbike_ai_decision_brief', 'AI 政府決策摘要'),
    (9925, 'cleanbike_air_grid_layer', '空品推估格網圖層');

INSERT INTO public.component_charts (index, color, types, unit) VALUES
    ('cleanbike_route_score', '{#F65658,#F5C860,#4CB495}', '{BarChart,ColumnChart}', '分'),
    ('cleanbike_air_risk', '{#4CB495,#F5C860,#ED6A45,#F65658}', '{BarChart,ColumnChart}', 'PM2.5'),
    ('cleanbike_low_carbon_benefit', '{#4CB495,#569C9A,#60819C}', '{BarChart,TextUnitChart}', 'g'),
    ('cleanbike_governance_priority', '{#F5C860,#ED6A45,#F65658}', '{BarChart,ColumnChart}', '分'),
    ('cleanbike_real_youbike_supply', '{#4CB495,#F5C860,#60819C}', '{BarChart,ColumnChart}', '輛/格'),
    ('cleanbike_real_bike_network', '{#4CB495,#60819C}', '{BarChart,ColumnChart}', '公里'),
    ('cleanbike_real_station_density', '{#4CB495,#F5C860}', '{BarChart,ColumnChart}', '站/輛'),
    ('cleanbike_real_lowcarbon_context', '{#4CB495,#569C9A,#60819C}', '{BarChart,ColumnChart}', '輛'),
    ('cleanbike_real_short_trip_readiness', '{#4CB495,#F5C860,#F65658}', '{BarChart,ColumnChart}', '站'),
    ('cleanbike_planner_recommendation', '{#4CB495,#F5C860,#F65658}', '{CleanBikePlannerChart,BarChart}', '分'),
    ('cleanbike_exposure_compare', '{#F65658,#4CB495,#F5C860}', '{CleanBikeExposureCompareChart,BarChart,ColumnChart}', '暴露量'),
    ('cleanbike_public_value', '{#4CB495,#F5C860,#60819C}', '{TextUnitChart,BarChart}', ''),
    ('cleanbike_ai_decision_brief', '{#F5C860,#ED6A45,#F65658}', '{BarChart,ColumnChart}', '分'),
    ('cleanbike_air_grid_layer', '{#4CB495,#F5C860,#ED6A45,#F65658}', '{MapLegend}', '風險');

INSERT INTO public.component_maps (id, index, title, type, source, size, icon, paint, property) VALUES
    (
        9901,
        'cleanbike_routes_metrotaipei',
        'CleanBike 候選騎行路線',
        'line',
        'geojson',
        NULL,
        NULL,
        '{"line-color":["match",["get","route_type"],"清淨","#4CB495","最速","#F5C860","平衡","#56CCF2","#9AA0A6"],"line-width":["case",["==",["get","route_type"],"清淨"],["interpolate",["linear"],["zoom"],10,5,15,9],["interpolate",["linear"],["zoom"],10,3,15,6]],"line-opacity":["case",["==",["get","route_type"],"清淨"],0.96,0.72],"line-blur":["case",["==",["get","route_type"],"清淨"],0.2,0]}',
        '[{"key":"pair_id","name":"範例組"},{"key":"od_title","name":"起迄情境"},{"key":"route_name","name":"路線"},{"key":"route_type","name":"類型"},{"key":"scenario_scope","name":"情境範圍"},{"key":"tradeoff_label","name":"時間/暴露取捨"},{"key":"travel_minutes","name":"騎乘時間(分)"},{"key":"avg_pm25","name":"平均PM2.5"},{"key":"exposure_reduction_pct","name":"暴露降低(%)"},{"key":"clean_score","name":"清淨分數"},{"key":"pros","name":"優勢"},{"key":"cons","name":"劣勢"},{"key":"compare_hint","name":"最速vs清淨"},{"key":"route_basis","name":"判斷依據"},{"key":"decision_hint","name":"建議"}]'
    ),
    (
        9902,
        'cleanbike_air_points_metrotaipei',
        '騎行空品風險點',
        'circle',
        'geojson',
        'big',
        NULL,
        '{"circle-color":["interpolate",["linear"],["get","pm25"],12,"#4CB495",18,"#F5C860",24,"#ED6A45",28,"#F65658"],"circle-radius":["interpolate",["linear"],["get","pm25"],12,8,18,12,24,17,28,22],"circle-opacity":0.88,"circle-stroke-color":["case",[">=",["get","pm25"],24],"#FFFFFF","#1F2933"],"circle-stroke-width":2}',
        '[{"key":"station_name","name":"監測代表點"},{"key":"district","name":"行政區"},{"key":"aqi","name":"AQI"},{"key":"pm25","name":"PM2.5"},{"key":"risk_level","name":"騎行風險"},{"key":"sensor_role","name":"監測角色"},{"key":"coverage_gap","name":"資料缺口"},{"key":"bike_context","name":"YouBike 情境"},{"key":"suggestion","name":"騎行建議"}]'
    ),
    (
        9903,
        'cleanbike_air_grid_metrotaipei',
        '短程空品推估格網',
        'circle',
        'geojson',
        'big',
        NULL,
        '{"circle-color":["interpolate",["linear"],["get","deployment_priority"],40,"#4CB495",60,"#F5C860",80,"#ED6A45",92,"#F65658"],"circle-radius":["interpolate",["linear"],["get","deployment_priority"],35,14,60,22,80,31,95,42],"circle-blur":0.45,"circle-opacity":0.62,"circle-stroke-color":["case",[">=",["get","deployment_priority"],85],"#FFFFFF","#2E3A40"],"circle-stroke-width":["case",[">=",["get","deployment_priority"],85],2,1]}',
        '[{"key":"grid_name","name":"風險格網"},{"key":"priority_label","name":"補點優先"},{"key":"deployment_priority","name":"部署分數"},{"key":"pm25","name":"PM2.5"},{"key":"risk_score","name":"暴露風險"},{"key":"road_penalty","name":"道路加權"},{"key":"green_bonus","name":"綠地降權"},{"key":"planning_action","name":"治理動作"},{"key":"evidence_note","name":"推估依據"}]'
    );

INSERT INTO public.query_charts
    (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city)
VALUES
    (
        'cleanbike_planner_recommendation',
        NULL,
        '{9901,9902,9903,99,101}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料 + 真實 YouBike/自行車道路網作為落地基礎',
        '民眾輸入目的地後，系統比較候選路線並推薦空氣品質暴露最低的 YouBike 路線。',
        '這是 CleanBike 核心體驗：不做任意導航，而是先針對 5 到 15 分鐘的熱門短程 OD 情境提供最穩定的路線推薦。每條路線同時呈現騎乘時間、PM2.5、污染暴露降低、減碳量與推薦理由，讓評審一眼理解 CleanBike 和 Google Maps 的差異。',
        '民眾端：知道去哪條路線少吸廢氣；政府端：知道哪些通勤廊道需要改善，形成城市儀表板與我的新北 App 服務卡的雙層價值。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://data.moenv.gov.tw/,https://tdx.transportdata.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'WITH route_calc AS (SELECT r.route_id, r.route_name, r.route_type, r.scenario_scope, r.travel_minutes, r.carbon_saved_g, ROUND(SUM(g.risk_score * s.segment_minutes), 1) AS exposure, ROUND(SUM(g.pm25 * s.segment_minutes) / NULLIF(SUM(s.segment_minutes), 0), 1) AS weighted_pm25 FROM public.cleanbike_route_scores r JOIN public.cleanbike_route_segments s ON r.route_id = s.route_id JOIN public.cleanbike_air_grid g ON s.grid_id = g.grid_id WHERE r.scenario_scope <> ''雙北跨市備用'' GROUP BY r.route_id, r.route_name, r.route_type, r.scenario_scope, r.travel_minutes, r.carbon_saved_g), scored AS (SELECT rc.*, MAX(exposure) OVER (PARTITION BY scenario_scope) AS worst_exposure, MIN(exposure) OVER (PARTITION BY scenario_scope) AS best_exposure FROM route_calc rc) SELECT scenario_scope || ''｜'' || route_type || ''｜'' || route_name || ''｜'' || travel_minutes || ''｜'' || weighted_pm25 || ''｜'' || ROUND((worst_exposure - exposure) / NULLIF(worst_exposure, 0) * 100) || ''｜'' || carbon_saved_g || ''｜'' || CASE WHEN exposure = best_exposure THEN ''推薦：依空品格網與路段時間計算，污染暴露最低。'' WHEN route_type = ''最速'' THEN ''對照：時間較短，但主幹道風險格網較多。'' ELSE ''備選：兼顧時間與低風險格網。'' END AS x_axis, GREATEST(0, ROUND(100 - exposure / 20)) AS data FROM scored ORDER BY scenario_scope, exposure',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_exposure_compare',
        NULL,
        '{9901,9902,9903}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料；正式版將以環境部空品格網與路段時間計算',
        '比較候選路線的污染暴露量，找出不是最快、但最健康的路線。',
        '此組件把路線切成多段，每段套上 250m 等級空品推估格網，以「格網風險分數 x 分段騎乘時間」估算暴露量，讓「多花幾分鐘但少吸污染」能被量化。',
        '民眾可比較路線健康成本；政府可檢視哪類路廊雖然低碳，卻仍需要空品或交通改善。',
        '{https://data.moenv.gov.tw/,https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT r.scenario_scope || ''｜'' || r.route_type AS x_axis, ROUND(SUM(g.risk_score * s.segment_minutes)) AS data FROM public.cleanbike_route_scores r JOIN public.cleanbike_route_segments s ON r.route_id = s.route_id JOIN public.cleanbike_air_grid g ON s.grid_id = g.grid_id WHERE r.scenario_scope <> ''雙北跨市備用'' GROUP BY r.scenario_scope, r.route_type ORDER BY r.scenario_scope, data',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_public_value',
        NULL,
        '{}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料 + 雙北 YouBike 開放資料',
        '呈現 CleanBike 對民眾最有感的服務價值。',
        '此組件將路線推薦轉成民眾語言：少吸多少污染、多花幾分鐘、減少多少碳排、是否適合騎乘。它是整合進我的新北 App 的服務卡雛形。',
        '民眾端可每天收到清淨騎行建議；政府端可用匿名使用趨勢回饋路廊改善。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'three_d',
        'WITH route_calc AS (SELECT r.route_id, r.scenario_scope, r.route_type, r.travel_minutes, r.carbon_saved_g, SUM(g.risk_score * s.segment_minutes) AS exposure FROM public.cleanbike_route_scores r JOIN public.cleanbike_route_segments s ON r.route_id = s.route_id JOIN public.cleanbike_air_grid g ON s.grid_id = g.grid_id WHERE r.scenario_scope <> ''雙北跨市備用'' GROUP BY r.route_id, r.scenario_scope, r.route_type, r.travel_minutes, r.carbon_saved_g), scenario_stats AS (SELECT scenario_scope, MAX(exposure) AS worst_exposure, MIN(exposure) AS best_exposure, MIN(travel_minutes) AS fastest_minutes, MIN(travel_minutes) FILTER (WHERE exposure = (SELECT MIN(exposure) FROM route_calc rc2 WHERE rc2.scenario_scope = route_calc.scenario_scope)) AS clean_minutes FROM route_calc GROUP BY scenario_scope) SELECT ''最高少吸污染'' AS y_axis, ''%'' AS icon, ROUND(MAX((worst_exposure - best_exposure) / NULLIF(worst_exposure, 0) * 100))::int AS data, ''x'' AS x_axis FROM scenario_stats UNION ALL SELECT ''最佳清淨分數'', ''分'', 89, ''x'' UNION ALL SELECT ''平均多花時間'', ''分'', ROUND(AVG(clean_minutes - fastest_minutes))::int, ''x'' FROM scenario_stats UNION ALL SELECT ''平均單趟減碳'', ''g'', ROUND(AVG(carbon_saved_g))::int, ''x'' FROM route_calc',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_ai_decision_brief',
        NULL,
        '{9901,9902,9903,99,101}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料；可串台智雲模型產生自然語言決策摘要',
        '將路線暴露與治理優先分數轉成政府可採取的改善排序。',
        '此組件是 AI 加分點的接口：核心分數由資料計算，AI 只負責把數據轉成「今日建議」與「政府週報」。這樣即使現場 AI Key 或 rate limit 不穩，核心 dashboard 仍可正常 demo。',
        '政府端可看到板橋、中正、永和等優先改善區；民眾端可收到不建議路段與替代清淨路線。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://data.moenv.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT district || ''｜'' || issue_type AS x_axis, priority_score AS data FROM public.cleanbike_governance_priorities ORDER BY priority_score DESC',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_route_score',
        NULL,
        '{9901,9902}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料；正式版將接臺北市資料大平臺、新北市政府資料開放平臺、環境部環境資料開放平臺',
        '情境模擬：比較 YouBike 最速、清淨、舒適路線的健康與時間成本。',
        '此組件為 MVP 情境模擬，用來展示 CleanBike 的產品體驗：同一個起訖點不只比較時間，也比較 PM2.5 暴露、熱風險、綠地友善度與清淨分數。正式版會以真實空品、氣象與路網資料替換此處分數。',
        '民眾可理解「多花幾分鐘，少吸多少污染」；政府可用同一套邏輯觀察哪些低碳通勤廊道需要空品改善、遮蔭或交通管理。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://data.moenv.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT scenario_scope || ''｜'' || route_type AS x_axis, clean_score AS data FROM public.cleanbike_route_scores ORDER BY clean_score DESC',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_air_risk',
        NULL,
        '{9902}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料；正式版將接環境部環境資料開放平臺',
        '情境模擬：呈現雙北 YouBike 騎行熱區附近的 PM2.5 風險。',
        '此組件目前使用模擬 PM2.5/AQI 代表值，用來展示「騎 YouBike 也要避開高污染路段」的使用情境。正式版會串接環境部空品資料並依行政區或路廊更新。',
        '民眾可避開高污染區域；政府可識別低碳交通推廣時需要同步改善空品的路段與行政區。',
        '{https://data.moenv.gov.tw/,https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT district AS x_axis, pm25 AS data FROM public.cleanbike_air_quality ORDER BY pm25 DESC',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_low_carbon_benefit',
        NULL,
        '{}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料；正式版將接臺北市資料大平臺、新北市政府資料開放平臺',
        '情境模擬：估算 YouBike 清淨騎行的減碳與健康收益。',
        '以固定係數估算 YouBike 替代短程汽機車移動的減碳效益，並搭配清淨路線降低污染暴露比例。正式版可把這個組件接到個人騎乘紀錄或我的新北 App 服務卡。',
        '可作為我的新北 App 的個人化服務卡片：本次騎乘減碳多少、少暴露多少污染、推薦哪條清淨路線。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT ''平均單趟減碳(g)'' AS x_axis, ROUND(AVG(carbon_saved_g)) AS data FROM public.cleanbike_route_scores UNION ALL SELECT ''最高暴露降低(%)'' AS x_axis, MAX(exposure_reduction_pct) AS data FROM public.cleanbike_route_scores UNION ALL SELECT ''最佳清淨分數'' AS x_axis, MAX(clean_score) AS data FROM public.cleanbike_route_scores',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_governance_priority',
        NULL,
        '{9901,9902}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '情境模擬資料；正式版將接臺北市資料大平臺、新北市政府資料開放平臺、環境部環境資料開放平臺',
        '情境模擬：列出政府應優先改善的清淨騎行廊道與行政區。',
        '此組件目前以模擬分數呈現治理決策邏輯：空品暴露高、YouBike 需求高、路廊條件不足的區域應優先改善。正式版會改以真實空品、站點、路網、交通資料計算。',
        '政府端可用於低碳交通政策與健康城市治理；民眾端則可轉化為「今日不建議騎行路段」與替代路線提醒。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://data.moenv.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT district AS x_axis, priority_score AS data FROM public.cleanbike_governance_priorities ORDER BY priority_score DESC',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_air_grid_layer',
        NULL,
        '{9903}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '環境部空品測站代表值 + 道路/綠地 proxy 推估',
        '將短程騎行區域切成空品風險格網，提供路線暴露計算依據。',
        '此圖層不是宣稱每條巷弄都有真實測站，而是用公開空品資料作基底，加入主幹道與綠地 proxy，形成可用於路線比較的細緻化風險面。',
        '民眾端可理解為什麼系統建議避開某些主幹道；政府端可看到哪些短程生活圈需要改善綠蔭、低排路廊或交通管理。',
        '{https://data.moenv.gov.tw/,https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'map_legend',
        'SELECT unnest(array[''低風險格網'', ''中風險格網'', ''高風險格網'', ''很高風險格網'']) AS name, ''circle'' AS type',
        NULL,
        'metrotaipei'
    );

INSERT INTO public.query_charts
    (index, history_config, map_config_ids, map_filter, time_from, time_to, update_freq, update_freq_unit, source, short_desc, long_desc, use_case, links, contributors, created_at, updated_at, query_type, query_chart, query_history, city)
VALUES
    (
        'cleanbike_real_youbike_supply',
        NULL,
        '{99}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '臺北市資料大平臺、新北市政府資料開放平臺 / TDX YouBike 開放資料',
        '真實資料：比較雙北 YouBike 可借車與可還車供給。',
        '此組件直接使用本機資料庫中的 YouBike 即時資料表，統計臺北市與新北市目前可借車輛與可還車位。這是 CleanBike 真實資料版的供給基礎。',
        '民眾端可判斷是否容易借還車；政府端可觀察雙北站點供給是否均衡，作為調度與站點優化依據。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://tdx.transportdata.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'three_d',
        'SELECT city AS x_axis, metric AS y_axis, value::int AS data FROM (SELECT ''臺北市'' AS city, ''可借車輛'' AS metric, SUM(available_rent_general_bikes) AS value FROM public.tran_ubike_realtime UNION ALL SELECT ''臺北市'', ''可還車位'', SUM(available_return_bikes) FROM public.tran_ubike_realtime UNION ALL SELECT ''新北市'', ''可借車輛'', SUM(available_rent_general_bikes) FROM public.tran_ubike_realtime_new_tpe UNION ALL SELECT ''新北市'', ''可還車位'', SUM(available_return_bikes) FROM public.tran_ubike_realtime_new_tpe) d ORDER BY city, metric',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_real_bike_network',
        NULL,
        '{101}',
        '{"mode":"byParam","byParam":{"xParam":"direction"}}',
        'static',
        NULL,
        0,
        NULL,
        'TDX 自行車道路網開放資料',
        '真實資料：比較雙北自行車道路網里程。',
        '此組件直接使用本機資料庫中的雙北自行車道路網資料，統計臺北市與新北市自行車道長度。這可作為 CleanBike 評估「哪裡有條件推廣清淨騎行」的真實基礎。',
        '政府端可評估自行車路網供給落差；民眾端可透過地圖圖層理解可騎乘路廊分布。',
        '{https://tdx.transportdata.tw/,https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'two_d',
        'SELECT city AS x_axis, ROUND(SUM(km)) AS data FROM (SELECT ''臺北市'' AS city, cycling_length / 1000.0 AS km FROM public.bike_network_tpe UNION ALL SELECT ''新北市'', cycling_length / 1000.0 FROM public.bike_network_new_tpe) d GROUP BY city ORDER BY city',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_real_station_density',
        NULL,
        '{99}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '臺北市資料大平臺、新北市政府資料開放平臺 / TDX YouBike 開放資料',
        '真實資料：比較雙北 YouBike 站點數與可借車規模。',
        '此組件直接統計本機資料庫中的 YouBike 站點數與可借車總量。它不含模擬空品分數，用於呈現 CleanBike 若要落地，已有多少共享單車基礎設施可支撐服務。',
        '政府可用於評估站點密度與服務供給；民眾可理解路線推薦是否能搭配可借可還車站點。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://tdx.transportdata.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'three_d',
        'SELECT city AS x_axis, metric AS y_axis, value::int AS data FROM (SELECT ''臺北市'' AS city, ''站點數'' AS metric, COUNT(*) AS value FROM public.tran_ubike_realtime UNION ALL SELECT ''臺北市'', ''可借車輛'', SUM(available_rent_general_bikes) FROM public.tran_ubike_realtime UNION ALL SELECT ''新北市'', ''站點數'', COUNT(*) FROM public.tran_ubike_realtime_new_tpe UNION ALL SELECT ''新北市'', ''可借車輛'', SUM(available_rent_general_bikes) FROM public.tran_ubike_realtime_new_tpe) d ORDER BY city, metric',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_real_short_trip_readiness',
        NULL,
        '{99}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        '臺北市資料大平臺、新北市政府資料開放平臺 / TDX YouBike 開放資料',
        '真實資料：用站點可借/可還狀態判斷短程騎乘是否可行。',
        '一般民眾不一定跨區騎很遠，短程情境最重要的是附近站點有沒有車、目的地附近能不能還。此組件直接使用本機 YouBike 即時資料，將站點分成「適合出發」、「可用但需注意」、「不適合出發」三類。',
        '民眾端可判斷短程騎乘可不可行；政府端可找出可借車不足或可還車不足的生活圈，做站點調度與車輛補位。',
        '{https://data.taipei/,https://data.ntpc.gov.tw/,https://tdx.transportdata.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'three_d',
        'WITH stations AS (SELECT ''臺北市'' AS city, available_rent_general_bikes AS rent_bikes, available_return_bikes AS return_slots FROM public.tran_ubike_realtime UNION ALL SELECT ''新北市'', available_rent_general_bikes, available_return_bikes FROM public.tran_ubike_realtime_new_tpe), scored AS (SELECT city, CASE WHEN rent_bikes >= 5 AND return_slots >= 5 THEN ''適合短程出發'' WHEN rent_bikes >= 2 AND return_slots >= 2 THEN ''可用但需注意'' ELSE ''不適合出發/還車'' END AS status FROM stations) SELECT city AS x_axis, status AS y_axis, COUNT(*)::int AS data FROM scored GROUP BY city, status ORDER BY city, status',
        NULL,
        'metrotaipei'
    ),
    (
        'cleanbike_real_lowcarbon_context',
        NULL,
        '{}',
        '{}',
        'static',
        NULL,
        0,
        NULL,
        'TDX 公車車輛資料、雙北交通開放資料',
        '真實資料：呈現雙北低碳運輸背景。',
        '此組件使用本機公車車輛資料，統計雙北電動公車與非電動公車數量。它不是 CleanBike 路線推薦本體，但可補強永續環境主題：YouBike 與公共運輸電動化都屬於低碳移動政策的一部分。',
        '政府端可用於說明低碳交通政策脈絡；民眾端可理解 YouBike 與大眾運輸搭配對減碳的價值。',
        '{https://tdx.transportdata.tw/,https://data.taipei/,https://data.ntpc.gov.tw/}',
        '{doit,ntpc}',
        now(),
        now(),
        'three_d',
        'SELECT city AS x_axis, bus_type AS y_axis, value::int AS data FROM (SELECT ''臺北市'' AS city, CASE WHEN plate_numb LIKE ''E%'' THEN ''電動公車'' ELSE ''非電動公車'' END AS bus_type, COUNT(*) AS value FROM public.bus_info_tpe GROUP BY bus_type UNION ALL SELECT ''新北市'', CASE WHEN plate_numb LIKE ''E%'' THEN ''電動公車'' ELSE ''非電動公車'' END, COUNT(*) FROM public.bus_info_new_tpe GROUP BY 2) d ORDER BY city, bus_type',
        NULL,
        'metrotaipei'
    );

INSERT INTO public.dashboards (id, index, name, components, icon, updated_at, created_at)
VALUES
    (9901, 'cleanbike_metrotaipei', '清淨騎行 Demo', '{9901,9902,9903,9904}', 'directions_bike', now(), now()),
    (9911, 'cleanbike_realdata_metrotaipei', 'CleanBike 真實短程資料', '{9915,9911,9913,9912}', 'verified', now(), now()),
    (9921, 'cleanbike_route_service_metrotaipei', 'CleanBike 清淨短程路線', '{9921,9922,9925,9923,9924}', 'directions_bike', now(), now());

INSERT INTO public.dashboard_groups (dashboard_id, group_id)
VALUES
    (9901, 3),
    (9911, 3),
    (9921, 3);

SELECT pg_catalog.setval('public.components_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.components), true);
SELECT pg_catalog.setval('public.component_maps_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.component_maps), true);
SELECT pg_catalog.setval('public.dashboards_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.dashboards), true);

COMMIT;
