<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from "vue";
import { useMapStore } from "../../store/mapStore";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
]);

const mapStore = useMapStore();
const routeFeatures = ref([]);
const selectedPairId = ref("");

/** 簡報動線：先河濱／地標，再生活圈短接 */
const PAIR_ORDER = [
	"tpe_songshan_riverside",
	"ntpc_banqiao_moon",
	"tpe_park_101",
	"tpe_gongguan_ntu",
	"tpe_station_daan",
	"ntpc_yonghe_lehua",
];

const pairIds = computed(() => {
	const ids = new Set();
	for (const f of routeFeatures.value) {
		const id = f.properties?.pair_id;
		if (id) ids.add(id);
	}
	const list = [...ids];
	list.sort((a, b) => {
		const ia = PAIR_ORDER.indexOf(a);
		const ib = PAIR_ORDER.indexOf(b);
		const ra = ia === -1 ? 999 : ia;
		const rb = ib === -1 ? 999 : ib;
		return ra - rb;
	});
	return list;
});

const pairLabel = (id) => {
	const f = routeFeatures.value.find((x) => x.properties?.pair_id === id);
	return f?.properties?.od_title || id;
};

const activePair = computed(() => {
	const id = selectedPairId.value;
	const list = routeFeatures.value.filter((x) => x.properties?.pair_id === id);
	const fast = list.find((x) => x.properties?.route_type === "最速");
	const clean = list.find((x) => x.properties?.route_type === "清淨");
	return { fast, clean, id };
});

/** 相對最速：多花幾分鐘、PM2.5 路徑均值降多少 */
const comparisonDelta = computed(() => {
	const { fast, clean } = activePair.value;
	if (!fast?.properties || !clean?.properties) return null;
	const F = fast.properties;
	const C = clean.properties;
	return {
		extraMin: C.travel_minutes - F.travel_minutes,
		pm25Drop: +((F.avg_pm25 ?? 0) - (C.avg_pm25 ?? 0)).toFixed(1),
		exposurePct: C.exposure_reduction_pct,
	};
});

const themeDataHook = computed(() => {
	const c = activePair.value.clean?.properties?.data_hook;
	const f = activePair.value.fast?.properties?.data_hook;
	return c || f || "";
});

/** 與 DE DAG／競賽聲明一致之官方來源（儀表板 demo 可仍為示範 GeoJSON） */
const officialDataSources = [
	{
		label: "環境部 臺北空品(逐時)",
		url: "https://data.moenv.gov.tw/dataset/detail/aqx_p_432",
	},
	{
		label: "TDX YouBike 站點·北",
		url: "https://tdx.transportdata.tw/api/basic/v2/Bike/Station/City/Taipei?%24format=JSON",
	},
	{
		label: "TDX YouBike 站點·新",
		url: "https://tdx.transportdata.tw/api/basic/v2/Bike/Station/City/NewTaipei?%24format=JSON",
	},
	{
		label: "TDX 自行車道·北",
		url: "https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24format=JSON",
	},
	{
		label: "data.taipei",
		url: "https://data.taipei/",
	},
];

function syncCompareRoutesToMap() {
	if (props.activeChart !== "CleanBikeExposureCompareChart") return;
	const id = selectedPairId.value;
	if (!id || !mapStore.map) return;
	const feats = routeFeatures.value.filter((x) => x.properties?.pair_id === id);
	if (feats.length < 1) return;

	mapStore.setCleanBikeComparePreviewRoutes(feats);
	mapStore.applyCleanBikeRoutePairFilter(id);
	mapStore.fitBoundsFromRouteFeatures(feats);
}

onMounted(async () => {
	try {
		const r = await fetch("/mapData/cleanbike_routes_metrotaipei.geojson");
		const fc = await r.json();
		routeFeatures.value = fc.features || [];
		selectedPairId.value = pairIds.value[0] || "";
		syncCompareRoutesToMap();
	} catch {
		routeFeatures.value = [];
	}
});

watch(selectedPairId, () => {
	syncCompareRoutesToMap();
});

watch(
	() => mapStore.map,
	(m) => {
		if (m) {
			syncCompareRoutesToMap();
		}
	},
	{ immediate: true },
);

watch(
	() => props.activeChart,
	(v) => {
		if (v === "CleanBikeExposureCompareChart") {
			syncCompareRoutesToMap();
		} else {
			mapStore.clearCleanBikeComparePreviewRoutes();
		}
	},
	{ immediate: true },
);

watch(
	() => [...mapStore.currentLayers],
	() => {
		const hasRoutes = mapStore.currentLayers.some((lid) =>
			lid.includes("cleanbike_routes_metrotaipei"),
		);
		if (hasRoutes) {
			syncCompareRoutesToMap();
		}
	},
);

onUnmounted(() => {
	mapStore.clearCleanBikeComparePreviewRoutes();
});
</script>

<template>
  <div
    v-if="activeChart === 'CleanBikeExposureCompareChart'"
    class="cb-exposure"
  >
    <p class="cb-exposure__lead">
      每組皆為<strong>同一個目的地</strong>、兩條<strong>YouBike／短程可及</strong>候選：黃線＝最短路徑思維，綠線＝避開高暴露廊道。左側地圖<strong>直接畫出兩條線</strong>；數值為<strong>示範情境</strong>（沿路格網權重＋騎乘時間估算暴露，非即時單站讀值），正式版可接環境部開放資料與感測網。
    </p>

    <p
      v-if="comparisonDelta"
      class="cb-exposure__delta"
    >
      <strong>清淨線相對最速：</strong>多騎約
      <strong>{{ comparisonDelta.extraMin }}</strong> 分鐘 · 沿路 PM2.5 加權均值約降
      <strong>{{ comparisonDelta.pm25Drop }}</strong> µg/m³ · 示範暴露積分降幅
      <strong>{{ comparisonDelta.exposurePct }}%</strong>
    </p>

    <p
      v-if="themeDataHook"
      class="cb-exposure__theme-hook"
    >
      {{ themeDataHook }}
    </p>

    <label
      class="cb-exposure__select-label"
      for="cb-pair-select"
    >範例情境</label>
    <select
      id="cb-pair-select"
      v-model="selectedPairId"
      class="cb-exposure__select"
    >
      <option
        v-for="pid in pairIds"
        :key="pid"
        :value="pid"
      >
        {{ pairLabel(pid) }}
      </option>
    </select>

    <div
      v-if="activePair.fast && activePair.clean"
      class="cb-exposure__grid"
    >
      <article class="cb-exposure__card cb-exposure__card--fast">
        <h4>最速路線</h4>
        <p class="cb-exposure__route-name">
          {{ activePair.fast.properties.route_name }}
        </p>
        <ul class="cb-exposure__stats">
          <li>騎乘約 <strong>{{ activePair.fast.properties.travel_minutes }}</strong> 分</li>
          <li>路徑 PM2.5 均值 <strong>{{ activePair.fast.properties.avg_pm25 }}</strong> µg/m³</li>
          <li>清淨分數 <strong>{{ activePair.fast.properties.clean_score }}</strong></li>
        </ul>
        <p class="cb-exposure__stats-foot">
          清淨線的「暴露降幅 %」以本組最速路徑為 0% 基準。
        </p>
        <p class="cb-exposure__pros">
          <span>優勢</span>{{ activePair.fast.properties.pros }}
        </p>
        <p class="cb-exposure__cons">
          <span>劣勢</span>{{ activePair.fast.properties.cons }}
        </p>
      </article>
      <article class="cb-exposure__card cb-exposure__card--clean">
        <h4>清淨路線</h4>
        <p class="cb-exposure__route-name">
          {{ activePair.clean.properties.route_name }}
        </p>
        <ul class="cb-exposure__stats">
          <li>騎乘約 <strong>{{ activePair.clean.properties.travel_minutes }}</strong> 分</li>
          <li>路徑 PM2.5 均值 <strong>{{ activePair.clean.properties.avg_pm25 }}</strong> µg/m³</li>
          <li>暴露降幅（示範） <strong>{{ activePair.clean.properties.exposure_reduction_pct }}%</strong></li>
        </ul>
        <p class="cb-exposure__pros">
          <span>優勢</span>{{ activePair.clean.properties.pros }}
        </p>
        <p class="cb-exposure__cons">
          <span>劣勢</span>{{ activePair.clean.properties.cons }}
        </p>
      </article>
    </div>

    <p
      v-if="activePair.fast && activePair.clean"
      class="cb-exposure__compare-hint"
    >
      <strong>比較結論：</strong>{{ activePair.clean.properties.compare_hint }}
    </p>

    <p
      v-if="series?.[0]?.data?.length"
      class="cb-exposure__chart-note"
    >
      下方可再切換「長條圖」檢視同情境暴露量統計；地圖上以
      <span class="cb-exposure__swatch cb-exposure__swatch--fast" /><span class="cb-exposure__legend">最速</span>
      <span class="cb-exposure__swatch cb-exposure__swatch--clean" /><span class="cb-exposure__legend">清淨</span>
      對照。
    </p>

    <div class="cb-exposure__sources">
      <span class="cb-exposure__sources-title">官方開放資料（聲明／擴充正式版）</span>
      <ul>
        <li
          v-for="(row, idx) in officialDataSources"
          :key="idx"
        >
          <a
            :href="row.url"
            target="_blank"
            rel="noopener noreferrer"
          >{{ row.label }}</a>
        </li>
      </ul>
      <p class="cb-exposure__sources-more">
        完整清單與競賽書面稿見專案根目錄 <code>cleanbike-competition-submission.txt</code>。
      </p>
    </div>
  </div>
</template>

<style scoped lang="scss">
.cb-exposure {
	display: grid;
	gap: 0.65rem;
	height: 100%;
	overflow-y: auto;
	padding-right: 0.25rem;
	font-size: var(--font-s);

	&__lead {
		margin: 0;
		line-height: 1.5;
		color: var(--color-complement-text);
	}

	&__delta {
		margin: 0;
		padding: 0.45rem 0.6rem;
		border-radius: 8px;
		background: rgba(245, 200, 96, 0.08);
		border: 1px solid rgba(245, 200, 96, 0.4);
		line-height: 1.45;
		color: var(--color-normal-text);
		font-size: 0.95em;
	}

	&__theme-hook {
		margin: 0;
		font-size: 0.88em;
		line-height: 1.45;
		color: var(--color-complement-text);
		font-style: italic;
	}

	&__stats-foot {
		margin: 0 0 0.35rem;
		font-size: 0.85em;
		line-height: 1.35;
		color: var(--color-complement-text);
	}

	&__select-label {
		color: var(--color-complement-text);
		font-size: var(--font-s);
	}

	&__select {
		width: 100%;
		border: 1px solid var(--color-border);
		border-radius: 6px;
		padding: 0.35rem 0.5rem;
		background: var(--color-component-background);
		color: var(--color-normal-text);
	}

	&__grid {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.5rem;
	}

	@media (max-width: 520px) {
		&__grid {
			grid-template-columns: 1fr;
		}
	}

	&__card {
		border-radius: 10px;
		padding: 0.65rem 0.75rem;
		border: 1px solid var(--color-border);
		background: rgba(255, 255, 255, 0.03);

		h4 {
			margin: 0 0 0.35rem;
			font-size: var(--font-m);
		}

		&--fast {
			box-shadow: inset 3px 0 0 #f5c860;
		}

		&--clean {
			box-shadow: inset 3px 0 0 #4cb495;
		}
	}

	&__route-name {
		margin: 0 0 0.4rem;
		font-weight: 600;
		color: var(--color-normal-text);
		line-height: 1.35;
	}

	&__stats {
		margin: 0 0 0.5rem;
		padding-left: 1.1rem;
		color: var(--color-complement-text);
		line-height: 1.45;

		strong {
			color: var(--color-normal-text);
		}
	}

	&__pros,
	&__cons {
		margin: 0.25rem 0 0;
		line-height: 1.45;
		color: var(--color-complement-text);

		span {
			display: block;
			font-size: 0.85em;
			font-weight: 700;
			color: var(--color-normal-text);
			margin-bottom: 0.15rem;
		}
	}

	&__compare-hint {
		margin: 0;
		padding: 0.5rem 0.65rem;
		border-radius: 8px;
		background: rgba(86, 204, 242, 0.08);
		border: 1px solid rgba(86, 204, 242, 0.35);
		line-height: 1.5;
		color: var(--color-normal-text);
	}

	&__chart-note {
		margin: 0;
		color: var(--color-complement-text);
		line-height: 1.45;
	}

	&__swatch {
		display: inline-block;
		width: 0.65rem;
		height: 0.65rem;
		border-radius: 2px;
		margin: 0 0.2rem 0 0.35rem;
		vertical-align: middle;

		&--fast {
			background: #f5c860;
		}

		&--clean {
			background: #4cb495;
		}
	}

	&__legend {
		margin-right: 0.35rem;
		vertical-align: middle;
	}

	&__sources {
		margin-top: 0.15rem;
		padding-top: 0.5rem;
		border-top: 1px solid var(--color-border);
		font-size: 0.85em;
		color: var(--color-complement-text);

		&-title {
			display: block;
			font-weight: 600;
			color: var(--color-normal-text);
			margin-bottom: 0.25rem;
		}

		ul {
			margin: 0;
			padding-left: 1.15rem;
			line-height: 1.45;
		}

		a {
			color: #56ccf2;
			text-decoration: underline;
			text-underline-offset: 2px;
		}

		a:hover {
			color: #7ddbff;
		}

		&-more {
			margin: 0.35rem 0 0;
			font-size: 0.92em;
		}

		code {
			font-size: 0.9em;
			word-break: break-all;
		}
	}
}
</style>
