<script setup>
import { computed, onUnmounted, ref, watch } from "vue";
import { useMapStore } from "../../store/mapStore";
import {
	planCleanBikeRoutesFromMapbox,
	summarizePairComparison,
} from "../../assets/utilityFunctions/cleanBikeMapboxRouting.js";

const props = defineProps([
	"chart_config",
	"activeChart",
	"series",
]);

const mapStore = useMapStore();
const liveLoading = ref(false);
const liveError = ref("");
const liveCompare = ref([]);

const liveSummary = computed(() => summarizePairComparison(liveCompare.value));

const routeCards = computed(() => {
	const rows = props.series?.[0]?.data || [];
	return rows.map((item) => {
		const [
			scope = "",
			routeType = "",
			routeName = "",
			minutes = "",
			pm25 = "",
			reduction = "",
			carbon = "",
			reason = "",
		] = String(item.x || "").split("｜");

		return {
			scope,
			routeType,
			routeName,
			minutes,
			pm25,
			reduction,
			carbon,
			reason,
			score: item.y,
			isBest: routeType === "清淨",
		};
	});
});

const scenarios = computed(() => [
	...new Set(routeCards.value.map((route) => route.scope)),
]);

const selectedScenario = ref("");

watch(
	scenarios,
	(value) => {
		if (!value.includes(selectedScenario.value)) {
			selectedScenario.value = value[0] || "";
		}
	},
	{ immediate: true }
);

const filteredRouteCards = computed(() =>
	routeCards.value.filter((route) => route.scope === selectedScenario.value)
);

const bestRoute = computed(() =>
	filteredRouteCards.value.reduce((best, route) => {
		if (!best) return route;
		return route.score > best.score ? route : best;
	}, null)
);

const startSummary = computed(() =>
	mapStore.cleanBikeStartLngLat
		? `${mapStore.cleanBikeStartLngLat[0].toFixed(4)}, ${mapStore.cleanBikeStartLngLat[1].toFixed(4)}`
		: "未設定"
);
const endSummary = computed(() =>
	mapStore.cleanBikeEndLngLat
		? `${mapStore.cleanBikeEndLngLat[0].toFixed(4)}, ${mapStore.cleanBikeEndLngLat[1].toFixed(4)}`
		: "未設定"
);

async function runLivePlan() {
	liveError.value = "";
	const token = import.meta.env.VITE_MAPBOXTOKEN;
	if (!token) {
		liveError.value = "缺少 VITE_MAPBOXTOKEN，無法向 Mapbox 取路徑";
		return;
	}
	if (!mapStore.cleanBikeStartLngLat || !mapStore.cleanBikeEndLngLat) {
		liveError.value = "請先設定起點與終點";
		return;
	}
	liveLoading.value = true;
	try {
		const planned = await planCleanBikeRoutesFromMapbox(
			mapStore.cleanBikeStartLngLat,
			mapStore.cleanBikeEndLngLat,
			token,
		);
		liveCompare.value = planned;
		const features = planned.map((p) => ({
			type: "Feature",
			properties: {
				route_rank: p.route_rank,
				route_label: p.route_label,
				comparison_role: p.comparison_role,
				avg_pm25: p.avg_pm25,
				duration_min: p.duration_min,
				distance_km: p.distance_km,
				exposure: p.exposure,
				exposure_reduction_vs_worst_pct: p.exposure_reduction_vs_worst_pct,
				pm25_reduction_vs_worst_pct: p.pm25_reduction_vs_worst_pct,
			},
			geometry: {
				type: "LineString",
				coordinates: p.coordinates,
			},
		}));
		mapStore.setCleanBikeLiveRoutes(features);
	} catch (e) {
		liveError.value = e?.message || String(e);
	} finally {
		liveLoading.value = false;
	}
}

function clearLiveOverlays() {
	mapStore.clearCleanBikeLiveRoutes();
	mapStore.clearCleanBikeWaypoints();
	liveError.value = "";
	liveCompare.value = [];
}

onUnmounted(() => {
	mapStore.cleanBikePickMode = null;
});
</script>

<template>
  <div
    v-if="activeChart === 'CleanBikePlannerChart'"
    class="cleanbike-planner"
  >
    <div class="cleanbike-planner__toolbar">
      <label for="cleanbike-scenario">我要去哪裡</label>
      <select
        id="cleanbike-scenario"
        v-model="selectedScenario"
      >
        <option
          v-for="scenario in scenarios"
          :key="scenario"
          :value="scenario"
        >
          {{ scenario }}
        </option>
      </select>
    </div>

    <div class="cleanbike-planner__live">
      <p class="cleanbike-planner__live-title">
        即時路徑（Mapbox 腳踏車 + 格網暴露推估）
      </p>
      <p class="cleanbike-planner__live-hint">
        依序按「設起點 / 設終點」，在左側地圖雙擊落點；再按「規劃」。
        會向 Mapbox 要多條候選，並以格網對<strong>沿路</strong>採樣計算「路徑 PM2.5 均值」與「暴露積分」；綠線為暴露最低，黃線為對照（通常較快或繞路）。
      </p>
      <div class="cleanbike-planner__live-row">
        <button
          type="button"
          class="cleanbike-planner__btn"
          @click="mapStore.setCleanBikePickMode('start')"
        >
          設起點
        </button>
        <button
          type="button"
          class="cleanbike-planner__btn"
          @click="mapStore.setCleanBikePickMode('end')"
        >
          設終點
        </button>
      </div>
      <div class="cleanbike-planner__coords">
        <span>起 {{ startSummary }}</span>
        <span>迄 {{ endSummary }}</span>
      </div>
      <div class="cleanbike-planner__live-row">
        <button
          type="button"
          class="cleanbike-planner__btn cleanbike-planner__btn--primary"
          :disabled="liveLoading"
          @click="runLivePlan"
        >
          {{ liveLoading ? "規劃中…" : "規劃路徑" }}
        </button>
        <button
          type="button"
          class="cleanbike-planner__btn"
          :disabled="liveLoading"
          @click="clearLiveOverlays"
        >
          清除
        </button>
      </div>
      <p
        v-if="liveError"
        class="cleanbike-planner__live-error"
      >
        {{ liveError }}
      </p>

      <div
        v-if="liveCompare.length"
        class="cleanbike-planner__compare"
      >
        <p class="cleanbike-planner__compare-title">
          路徑 × 空品比較
        </p>
        <p class="cleanbike-planner__compare-summary">
          {{ liveSummary }}
        </p>
        <table class="cleanbike-planner__table">
          <thead>
            <tr>
              <th>路徑</th>
              <th>分鐘</th>
              <th>公里</th>
              <th>PM2.5</th>
              <th>暴露</th>
              <th>vs 兩條中較差</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in liveCompare"
              :key="row.route_rank"
              :class="{ 'cleanbike-planner__tr--best': row.route_rank === 1 }"
            >
              <td>{{ row.comparison_role }}</td>
              <td>{{ row.duration_min }}</td>
              <td>{{ row.distance_km }}</td>
              <td>{{ row.avg_pm25 }}</td>
              <td>{{ row.exposure }}</td>
              <td>
                暴露 −{{ row.exposure_reduction_vs_worst_pct }}% / PM2.5 −{{ row.pm25_reduction_vs_worst_pct }}%
              </td>
            </tr>
          </tbody>
        </table>
        <p class="cleanbike-planner__compare-foot">
          暴露積分：沿路採樣，加總「格網 risk_score × 路段長度」；數字愈低，這條路徑整體吸入風險愈低。
        </p>
      </div>
    </div>

    <section
      v-if="bestRoute"
      class="cleanbike-planner__summary"
    >
      <span>推薦路線</span>
      <strong>{{ bestRoute.routeName }}</strong>
      <p>
        多看一眼路線，不只省時間，也降低沿途空品暴露。
      </p>
    </section>

    <article
      v-for="route in filteredRouteCards"
      :key="`${route.scope}-${route.routeType}-${route.routeName}`"
      :class="{
        'cleanbike-planner__card': true,
        'cleanbike-planner__card--best': route.isBest,
      }"
    >
      <div class="cleanbike-planner__header">
        <div>
          <p class="cleanbike-planner__scope">
            {{ route.scope }}
          </p>
          <h4>{{ route.routeName }}</h4>
        </div>
        <strong>{{ route.score }} 分</strong>
      </div>

      <div class="cleanbike-planner__badges">
        <span>{{ route.routeType }}</span>
        <span>{{ route.minutes }} 分鐘</span>
        <span>PM2.5 {{ route.pm25 }}</span>
        <span>少吸 {{ route.reduction }}%</span>
        <span>減碳 {{ route.carbon }}g</span>
      </div>

      <p class="cleanbike-planner__reason">
        {{ route.reason }}
      </p>
    </article>
  </div>
</template>

<style scoped lang="scss">
.cleanbike-planner {
	display: grid;
	gap: 0.75rem;
	height: 100%;
	overflow-y: auto;
	padding-right: 0.25rem;

	&__toolbar {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		position: sticky;
		top: 0;
		z-index: 1;
		padding-bottom: 0.25rem;
		background: var(--color-component-background);

		label {
			color: var(--color-complement-text);
			font-size: var(--font-s);
			white-space: nowrap;
		}

		select {
			width: 100%;
			border: 1px solid var(--color-border);
			border-radius: 6px;
			padding: 0.35rem 0.5rem;
			background: var(--color-component-background);
			color: var(--color-normal-text);
		}
	}

	&__live {
		border: 1px solid var(--color-border);
		border-radius: 10px;
		padding: 0.65rem 0.75rem;
		background: rgba(86, 204, 242, 0.06);
		display: grid;
		gap: 0.45rem;
	}

	&__live-title {
		margin: 0;
		font-size: var(--font-s);
		font-weight: 700;
		color: #56ccf2;
	}

	&__live-hint {
		margin: 0;
		font-size: var(--font-s);
		color: var(--color-complement-text);
		line-height: 1.45;
	}

	&__live-row {
		display: flex;
		flex-wrap: wrap;
		gap: 0.4rem;
	}

	&__btn {
		flex: 1;
		min-width: 5rem;
		border: 1px solid var(--color-border);
		border-radius: 6px;
		padding: 0.35rem 0.5rem;
		background: var(--color-component-background);
		color: var(--color-normal-text);
		font-size: var(--font-s);
		cursor: pointer;

		&:disabled {
			opacity: 0.5;
			cursor: not-allowed;
		}
	}

	&__btn--primary {
		border-color: rgba(76, 180, 149, 0.7);
		background: rgba(76, 180, 149, 0.18);
		color: #4cb495;
		font-weight: 600;
	}

	&__coords {
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
		font-size: var(--font-s);
		color: var(--color-complement-text);
		word-break: break-all;
	}

	&__live-error {
		margin: 0;
		font-size: var(--font-s);
		color: #ed6a45;
		line-height: 1.4;
	}

	&__compare {
		margin-top: 0.35rem;
		padding-top: 0.5rem;
		border-top: 1px solid var(--color-border);
		display: grid;
		gap: 0.45rem;
	}

	&__compare-title {
		margin: 0;
		font-size: var(--font-s);
		font-weight: 700;
		color: var(--color-normal-text);
	}

	&__compare-summary {
		margin: 0;
		font-size: var(--font-s);
		color: var(--color-complement-text);
		line-height: 1.5;
	}

	&__compare-foot {
		margin: 0;
		font-size: var(--font-s);
		color: var(--color-complement-text);
		line-height: 1.45;
	}

	&__table {
		width: 100%;
		border-collapse: collapse;
		font-size: var(--font-s);

		th,
		td {
			border: 1px solid var(--color-border);
			padding: 0.35rem 0.4rem;
			text-align: left;
			vertical-align: top;
		}

		th {
			background: rgba(255, 255, 255, 0.05);
			color: var(--color-complement-text);
			white-space: nowrap;
		}
	}

	&__tr--best {
		background: rgba(76, 180, 149, 0.12);
	}

	&__summary {
		border: 1px solid rgba(76, 180, 149, 0.55);
		border-radius: 10px;
		padding: 0.75rem;
		background: rgba(76, 180, 149, 0.12);

		span {
			color: #4cb495;
			font-size: var(--font-s);
			font-weight: 700;
		}

		strong {
			display: block;
			margin-top: 0.25rem;
			color: var(--color-normal-text);
			line-height: 1.35;
		}

		p {
			margin: 0.35rem 0 0;
			color: var(--color-complement-text);
			font-size: var(--font-s);
		}
	}

	&__card {
		border: 1px solid var(--color-border);
		border-radius: 10px;
		padding: 0.75rem;
		background: rgba(255, 255, 255, 0.03);
	}

	&__card--best {
		border-color: #4cb495;
		box-shadow: inset 4px 0 0 #4cb495;
	}

	&__header {
		display: flex;
		justify-content: space-between;
		gap: 0.75rem;

		h4 {
			margin: 0.2rem 0 0;
			color: var(--color-normal-text);
			font-size: var(--font-m);
			line-height: 1.35;
		}

		strong {
			color: #4cb495;
			white-space: nowrap;
			font-size: 1.35rem;
		}
	}

	&__scope {
		margin: 0;
		color: var(--color-complement-text);
		font-size: var(--font-s);
	}

	&__badges {
		display: flex;
		flex-wrap: wrap;
		gap: 0.35rem;
		margin: 0.65rem 0;

		span {
			border-radius: 999px;
			padding: 0.18rem 0.5rem;
			background: rgba(76, 180, 149, 0.16);
			color: var(--color-normal-text);
			font-size: var(--font-s);
		}
	}

	&__reason {
		margin: 0;
		color: var(--color-complement-text);
		font-size: var(--font-s);
		line-height: 1.5;
	}
}
</style>
