BEGIN;

DROP TABLE IF EXISTS public.cleanbike_route_scores;
DROP TABLE IF EXISTS public.cleanbike_air_quality;
DROP TABLE IF EXISTS public.cleanbike_governance_priorities;
DROP TABLE IF EXISTS public.cleanbike_route_segments;
DROP TABLE IF EXISTS public.cleanbike_air_grid;
DROP TABLE IF EXISTS public.cleanbike_od_scenarios;

CREATE TABLE public.cleanbike_route_scores (
    route_id text PRIMARY KEY,
    route_name text NOT NULL,
    route_type text NOT NULL,
    scenario_scope text NOT NULL,
    start_area text NOT NULL,
    end_area text NOT NULL,
    city text NOT NULL,
    travel_minutes integer NOT NULL,
    avg_pm25 numeric NOT NULL,
    aqi integer NOT NULL,
    heat_index numeric NOT NULL,
    green_score integer NOT NULL,
    carbon_saved_g integer NOT NULL,
    exposure_reduction_pct integer NOT NULL,
    clean_score integer NOT NULL
);

CREATE TABLE public.cleanbike_od_scenarios (
    scenario_id text PRIMARY KEY,
    scenario_name text NOT NULL,
    start_station text NOT NULL,
    end_station text NOT NULL,
    trip_type text NOT NULL,
    city_scope text NOT NULL,
    start_lat numeric NOT NULL,
    start_lng numeric NOT NULL,
    end_lat numeric NOT NULL,
    end_lng numeric NOT NULL
);

CREATE TABLE public.cleanbike_air_grid (
    grid_id text PRIMARY KEY,
    grid_name text NOT NULL,
    city text NOT NULL,
    center_lat numeric NOT NULL,
    center_lng numeric NOT NULL,
    pm25 numeric NOT NULL,
    aqi integer NOT NULL,
    road_penalty integer NOT NULL,
    green_bonus integer NOT NULL,
    risk_score integer NOT NULL,
    source_note text NOT NULL
);

CREATE TABLE public.cleanbike_route_segments (
    route_id text NOT NULL,
    segment_no integer NOT NULL,
    grid_id text NOT NULL REFERENCES public.cleanbike_air_grid(grid_id),
    segment_name text NOT NULL,
    segment_minutes numeric NOT NULL,
    segment_distance_m integer NOT NULL,
    PRIMARY KEY (route_id, segment_no)
);

CREATE TABLE public.cleanbike_air_quality (
    city text NOT NULL,
    district text NOT NULL,
    aqi integer NOT NULL,
    pm25 numeric NOT NULL,
    no2 numeric NOT NULL,
    status text NOT NULL,
    observed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.cleanbike_governance_priorities (
    city text NOT NULL,
    district text NOT NULL,
    issue_type text NOT NULL,
    priority_score integer NOT NULL,
    suggested_action text NOT NULL
);

INSERT INTO public.cleanbike_route_scores
    (route_id, route_name, route_type, scenario_scope, start_area, end_area, city, travel_minutes, avg_pm25, aqi, heat_index, green_score, carbon_saved_g, exposure_reduction_pct, clean_score)
VALUES
    ('tpe_park_fast', '[情境模擬] 大安森林公園到臺北101：市區最速線', '最速', '臺北短程', '大安森林公園', '臺北101', 'taipei', 10, 20.2, 68, 32.1, 52, 280, 0, 66),
    ('tpe_park_clean', '[情境模擬] 大安森林公園到臺北101：綠蔭清淨線', '清淨', '臺北短程', '大安森林公園', '臺北101', 'taipei', 13, 15.6, 55, 29.4, 88, 280, 26, 86),
    ('ntpc_banqiao_fast', '[情境模擬] 板橋站到新月橋：市區最速線', '最速', '新北短程', '板橋站', '新月橋', 'newtaipei', 12, 21.1, 73, 31.6, 50, 320, 0, 64),
    ('ntpc_banqiao_clean', '[情境模擬] 板橋站到新月橋：河濱清淨線', '清淨', '新北短程', '板橋站', '新月橋', 'newtaipei', 16, 14.2, 50, 28.9, 91, 320, 31, 89),
    ('ntpc_yonghe_fast', '[情境模擬] 永安市場到樂華夜市：主幹道最速線', '最速', '新北生活圈', '永安市場', '樂華夜市', 'newtaipei', 7, 24.6, 82, 32.7, 42, 190, 0, 57),
    ('ntpc_yonghe_clean', '[情境模擬] 永安市場到樂華夜市：巷弄清淨線', '清淨', '新北生活圈', '永安市場', '樂華夜市', 'newtaipei', 10, 17.4, 60, 30.1, 72, 190, 29, 80),
    ('cross_city_clean', '[情境模擬] 臺北車站到板橋站：河濱清淨跨市線', '清淨', '雙北跨市備用', '臺北車站', '板橋站', 'metrotaipei', 23, 14.8, 52, 30.2, 86, 690, 34, 88);

INSERT INTO public.cleanbike_od_scenarios
    (scenario_id, scenario_name, start_station, end_station, trip_type, city_scope, start_lat, start_lng, end_lat, end_lng)
VALUES
    ('tpe_park_101', '大安森林公園站 -> 臺北101/世貿站', 'YouBike2.0_大安森林公園', 'YouBike2.0_捷運台北101/世貿站', '5-15 分鐘短程', '臺北市', 25.03375, 121.53545, 25.03397, 121.56456),
    ('ntpc_banqiao_bridge', '板橋車站 -> 新月橋', 'YouBike2.0_板橋車站', 'YouBike2.0_新月橋', '10-20 分鐘短程', '新北市', 25.01381, 121.46472, 25.03223, 121.43592),
    ('ntpc_yongan_lehua', '永安市場站 -> 樂華夜市', 'YouBike2.0_捷運永安市場站', 'YouBike2.0_樂華夜市', '5-10 分鐘生活圈', '新北市', 25.00277, 121.51133, 25.00928, 121.51595);

INSERT INTO public.cleanbike_air_grid
    (grid_id, grid_name, city, center_lat, center_lng, pm25, aqi, road_penalty, green_bonus, risk_score, source_note)
VALUES
    ('G_TPE_DAAPARK', '大安森林公園綠地格', '臺北市', 25.0335, 121.5360, 15.2, 54, 1, 7, 42, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_TPE_XINYI_ARTERY', '信義路主幹道格', '臺北市', 25.0336, 121.5515, 20.8, 69, 8, 1, 72, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_TPE_101_GREEN', '101 周邊退縮人行格', '臺北市', 25.0340, 121.5630, 16.1, 56, 3, 4, 49, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_NTPC_BANQIAO_ARTERY', '板橋車站主幹道格', '新北市', 25.0140, 121.4638, 21.4, 74, 8, 1, 75, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_NTPC_RIVERSIDE', '大漢溪河濱格', '新北市', 25.0268, 121.4467, 14.2, 50, 1, 8, 38, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_NTPC_XINYUE', '新月橋周邊格', '新北市', 25.0322, 121.4359, 15.1, 52, 2, 6, 43, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_NTPC_YONGAN_ARTERY', '永安市場主幹道格', '新北市', 25.0032, 121.5122, 24.6, 82, 9, 1, 84, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_NTPC_YONGHE_ALLEY', '永和巷弄住宅格', '新北市', 25.0065, 121.5113, 15.5, 55, 2, 5, 39, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估'),
    ('G_NTPC_LEHUA', '樂華夜市周邊格', '新北市', 25.0093, 121.5160, 20.2, 68, 6, 1, 70, '以環境測站 PM2.5 代表值加上綠地/主幹道 proxy 推估');

INSERT INTO public.cleanbike_route_segments
    (route_id, segment_no, grid_id, segment_name, segment_minutes, segment_distance_m)
VALUES
    ('tpe_park_fast', 1, 'G_TPE_DAAPARK', '出發站周邊', 2, 300),
    ('tpe_park_fast', 2, 'G_TPE_XINYI_ARTERY', '信義路主幹道', 6, 1100),
    ('tpe_park_fast', 3, 'G_TPE_101_GREEN', '101 周邊', 2, 350),
    ('tpe_park_clean', 1, 'G_TPE_DAAPARK', '公園外緣', 4, 500),
    ('tpe_park_clean', 2, 'G_TPE_101_GREEN', '退縮人行與低車流路段', 6, 900),
    ('tpe_park_clean', 3, 'G_TPE_DAAPARK', '綠蔭銜接段', 3, 450),
    ('ntpc_banqiao_fast', 1, 'G_NTPC_BANQIAO_ARTERY', '板橋車站主幹道', 8, 1300),
    ('ntpc_banqiao_fast', 2, 'G_NTPC_XINYUE', '新月橋銜接段', 4, 650),
    ('ntpc_banqiao_clean', 1, 'G_NTPC_BANQIAO_ARTERY', '板橋出發銜接', 3, 400),
    ('ntpc_banqiao_clean', 2, 'G_NTPC_RIVERSIDE', '大漢溪河濱段', 10, 1500),
    ('ntpc_banqiao_clean', 3, 'G_NTPC_XINYUE', '新月橋周邊', 3, 500),
    ('ntpc_yonghe_fast', 1, 'G_NTPC_YONGAN_ARTERY', '永安市場主幹道', 5, 800),
    ('ntpc_yonghe_fast', 2, 'G_NTPC_LEHUA', '樂華夜市周邊', 2, 300),
    ('ntpc_yonghe_clean', 1, 'G_NTPC_YONGAN_ARTERY', '出發銜接', 1, 180),
    ('ntpc_yonghe_clean', 2, 'G_NTPC_YONGHE_ALLEY', '巷弄低車流路段', 8, 780),
    ('ntpc_yonghe_clean', 3, 'G_NTPC_LEHUA', '夜市周邊', 1, 180);

INSERT INTO public.cleanbike_air_quality
    (city, district, aqi, pm25, no2, status)
VALUES
    ('臺北市', '中正區', 78, 22.4, 24.1, '普通'),
    ('臺北市', '大安區', 61, 17.3, 19.5, '普通'),
    ('臺北市', '文山區', 49, 13.9, 14.2, '良好'),
    ('新北市', '板橋區', 73, 21.1, 22.8, '普通'),
    ('新北市', '新店區', 52, 14.8, 15.0, '普通'),
    ('新北市', '永和區', 82, 24.6, 27.3, '普通');

INSERT INTO public.cleanbike_governance_priorities
    (city, district, issue_type, priority_score, suggested_action)
VALUES
    ('臺北市', '中正區', 'YouBike 高需求但空品暴露偏高', 86, '優先評估低排路廊、增設遮蔭與空品提示'),
    ('新北市', '板橋區', '跨市通勤路線空品暴露偏高', 83, '規劃替代河濱路線與轉乘誘導'),
    ('新北市', '永和區', '路廊狹窄且車流密度高', 79, '增設清淨騎行繞行提示與路口改善'),
    ('臺北市', '文山區', '清淨綠廊條件佳', 42, '作為親子與銀髮友善騎行示範區'),
    ('新北市', '新店區', '河濱清淨路線潛力高', 38, '強化 YouBike 接駁與夜間照明');

COMMIT;
