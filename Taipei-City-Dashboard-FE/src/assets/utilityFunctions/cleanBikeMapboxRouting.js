import {
	along,
	bearing,
	destination,
	distance,
	length,
	lineString,
	midpoint,
	point,
} from "@turf/turf";

const GRID_URL = "/mapData/cleanbike_air_grid_metrotaipei.geojson";

export async function fetchAirGrid() {
	const r = await fetch(GRID_URL);
	if (!r.ok) throw new Error(`格網載入失敗 ${r.status}`);
	return r.json();
}

/**
 * @param {[number, number]} start [lng, lat]
 * @param {[number, number]} end [lng, lat]
 */
export async function fetchMapboxCyclingAlternatives(start, end, token) {
	const coordPath = `${start[0]},${start[1]};${end[0]},${end[1]}`;
	const url =
		`https://api.mapbox.com/directions/v5/mapbox/cycling/${coordPath}` +
		`?alternatives=true&geometries=geojson&overview=full&steps=false` +
		`&access_token=${encodeURIComponent(token)}`;
	const r = await fetch(url);
	const data = await r.json();
	if (!r.ok) {
		throw new Error(data?.message || `Mapbox Directions ${r.status}`);
	}
	if (!data.routes?.length) {
		throw new Error(data?.message || "未取得任何騎行路徑");
	}
	return data.routes;
}

/** 多個經過點，回傳單一路徑（無 alternatives） */
export async function fetchMapboxCyclingVia(waypoints, token) {
	if (waypoints.length < 2) {
		throw new Error("路徑至少需要兩個點");
	}
	const coordPath = waypoints.map((p) => `${p[0]},${p[1]}`).join(";");
	const url =
		`https://api.mapbox.com/directions/v5/mapbox/cycling/${coordPath}` +
		`?geometries=geojson&overview=full&steps=false` +
		`&access_token=${encodeURIComponent(token)}`;
	const r = await fetch(url);
	const data = await r.json();
	if (!r.ok) {
		throw new Error(data?.message || `Mapbox Directions ${r.status}`);
	}
	if (!data.routes?.length) {
		throw new Error(data?.message || "未取得任何騎行路徑");
	}
	return data.routes[0];
}

/**
 * 在起訖中點兩側產生繞行經過點，逼出與直連不同的候選路徑。
 * @param {number[]} offsetKmList
 */
export function perpendicularViaPoints(start, end, offsetKmList = [0.35, 0.55]) {
	const p0 = point(start);
	const p1 = point(end);
	const mid = midpoint(p0, p1);
	const brg = bearing(p0, p1);
	const vias = [];
	for (const km of offsetKmList) {
		vias.push(
			destination(mid, km, brg + 90, { units: "kilometers" })
				.geometry.coordinates,
			destination(mid, km, brg - 90, { units: "kilometers" })
				.geometry.coordinates,
		);
	}
	return vias;
}

function routeSignature(coords) {
	if (!coords?.length) return "empty";
	const n = coords.length;
	const pick = [coords[0], coords[Math.floor(n / 2)], coords[n - 1]];
	return pick.map((c) => `${c[0].toFixed(4)},${c[1].toFixed(4)}`).join("|");
}

function routesRoughlySame(aCoords, bCoords) {
	if (!aCoords?.length || !bCoords?.length) return false;
	const la = length(lineString(aCoords), { units: "kilometers" });
	const lb = length(lineString(bCoords), { units: "kilometers" });
	if (la <= 0 || lb <= 0) return routeSignature(aCoords) === routeSignature(bCoords);
	const lenRatio = Math.abs(la - lb) / Math.max(la, lb);
	if (lenRatio > 0.12) return false;
	const lineA = lineString(aCoords);
	const lineB = lineString(bCoords);
	for (const t of [0, 0.5, 1]) {
		const da = t * la;
		const db = t * lb;
		const pa = along(lineA, da, { units: "kilometers" });
		const pb = along(lineB, db, { units: "kilometers" });
		const kmApart = distance(pa, pb, { units: "kilometers" });
		if (kmApart > 0.12) return false;
	}
	return true;
}

function nearestGridProps(lng, lat, gridFeatures) {
	let best = null;
	let bestD = Infinity;
	for (const f of gridFeatures) {
		if (f.geometry?.type !== "Point") continue;
		const [flng, flat] = f.geometry.coordinates;
		const d = (lng - flng) ** 2 + (lat - flat) ** 2;
		if (d < bestD) {
			bestD = d;
			best = f.properties || {};
		}
	}
	return best || { pm25: 20, risk_score: 50 };
}

/**
 * 沿路每段採樣，對鄰近格網求 PM2.5 / risk_score，回傳路徑加權暴露。
 */
export function scoreRouteAgainstGrid(coordinates, gridFeatureCollection) {
	const features = gridFeatureCollection.features || [];
	if (!coordinates?.length) {
		return { avg_pm25: 0, exposure: 0, km: 0 };
	}
	const line = lineString(coordinates);
	const totalKm = length(line, { units: "kilometers" });
	if (totalKm <= 0) {
		return { avg_pm25: 0, exposure: 0, km: 0 };
	}
	const stepKm = Math.min(0.05, Math.max(totalKm / 100, 0.02));
	let d = 0;
	let sumPmSeg = 0;
	let sumRiskSeg = 0;
	while (d < totalKm - 1e-9) {
		const next = Math.min(d + stepKm, totalKm);
		const mid = (d + next) / 2;
		const pt = along(line, mid, { units: "kilometers" });
		const [lng, lat] = pt.geometry.coordinates;
		const g = nearestGridProps(lng, lat, features);
		const segKm = next - d;
		const pm25 = Number(g.pm25) || 20;
		const risk = Number(g.risk_score) || 50;
		sumPmSeg += pm25 * segKm;
		sumRiskSeg += risk * segKm;
		d = next;
	}
	return {
		avg_pm25: Math.round((sumPmSeg / totalKm) * 10) / 10,
		exposure: Math.round(sumRiskSeg * 10) / 10,
		km: Math.round(totalKm * 100) / 100,
	};
}

/**
 * 清淨 vs 時間（或繞路對照）路徑，附空品格網暴露比較欄位。
 * @returns {Promise<Array<{
 *   coordinates: number[][],
 *   duration_min: number,
 *   distance_km: number,
 *   avg_pm25: number,
 *   exposure: number,
 *   route_rank: number,
 *   comparison_role: string,
 *   route_label: string,
 *   exposure_reduction_vs_worst_pct: number,
 *   pm25_reduction_vs_worst_pct: number,
 * }>>}
 */
export async function planCleanBikeRoutesFromMapbox(start, end, token) {
	const grid = await fetchAirGrid();
	const baseRoutes = await fetchMapboxCyclingAlternatives(start, end, token);
	const rawList = [...baseRoutes];

	const vias = perpendicularViaPoints(start, end, [0.32, 0.5, 0.72]);
	for (const via of vias) {
		try {
			const r = await fetchMapboxCyclingVia([start, via, end], token);
			if (r) rawList.push(r);
		} catch {
			/* 單側繞路失敗可忽略 */
		}
	}

	const seen = new Set();
	const scoredRaw = [];
	for (const route of rawList) {
		const coords = route.geometry?.coordinates || [];
		const sig = routeSignature(coords);
		if (seen.has(sig)) continue;
		seen.add(sig);
		const metrics = scoreRouteAgainstGrid(coords, grid);
		const durationMin = Math.max(1, Math.round(route.duration / 60));
		scoredRaw.push({
			coordinates: coords,
			duration_min: durationMin,
			duration_sec: route.duration,
			distance_km: metrics.km,
			avg_pm25: metrics.avg_pm25,
			exposure: metrics.exposure,
		});
	}

	if (!scoredRaw.length) {
		throw new Error("無法計算任何路徑");
	}

	const byExposure = [...scoredRaw].sort((a, b) => a.exposure - b.exposure);
	const byTime = [...scoredRaw].sort(
		(a, b) =>
			a.duration_min - b.duration_min ||
			a.exposure - b.exposure,
	);

	let cleanest = byExposure[0];
	let contrast = byTime[0];

	if (routesRoughlySame(cleanest.coordinates, contrast.coordinates)) {
		contrast =
			byExposure.find(
				(r) => !routesRoughlySame(r.coordinates, cleanest.coordinates),
			) ||
			byTime.find(
				(r) => !routesRoughlySame(r.coordinates, cleanest.coordinates),
			) ||
			byExposure[1] ||
			null;
	}

	const pair = contrast ? [cleanest, contrast] : [cleanest];

	const maxExp = Math.max(...pair.map((p) => p.exposure), 1e-6);
	const maxPm = Math.max(...pair.map((p) => p.avg_pm25), 1e-6);

	return pair.map((s, rank) => {
		const comparisonRole =
			rank === 0
				? "清淨推薦（暴露積分最低）"
				: s.duration_min <= cleanest.duration_min
					? "時間優先（對照）"
					: "繞路／替代（對照）";
		const expRed = Math.round((1 - s.exposure / maxExp) * 100);
		const pmRed = Math.round((1 - s.avg_pm25 / maxPm) * 100);
		return {
			coordinates: s.coordinates,
			duration_min: s.duration_min,
			distance_km: s.distance_km,
			avg_pm25: s.avg_pm25,
			exposure: s.exposure,
			route_rank: rank + 1,
			comparison_role: comparisonRole,
			exposure_reduction_vs_worst_pct: Math.max(0, Math.min(100, expRed)),
			pm25_reduction_vs_worst_pct: Math.max(0, Math.min(100, pmRed)),
			route_label: `${comparisonRole.split("（")[0]} ${s.duration_min}分 · PM2.5 ${s.avg_pm25} · 暴露${s.exposure}`,
		};
	});
}

/**
 * 兩條路徑並排敘述（給 UI）
 * routes[0] = 暴露最低；routes[1] = 對照路徑。
 */
export function summarizePairComparison(routes) {
	if (!routes?.length) return "";
	const low = routes[0];
	const other = routes[1];
	if (!other) {
		return `單一路徑：約 ${low.duration_min} 分鐘，路徑加權 PM2.5 均值 ${low.avg_pm25} µg/m³，風險暴露積分 ${low.exposure}（沿線格網 risk×路長，愈低愈好）。`;
	}
	const dMin = other.duration_min - low.duration_min;
	const timePhrase =
		dMin === 0
			? "兩條預估時間相同"
			: dMin > 0
				? `清淨線多約 ${dMin} 分鐘`
				: `清淨線省約 ${-dMin} 分鐘`;
	const expBetterPct =
		other.exposure > 0
			? Math.round(((other.exposure - low.exposure) / other.exposure) * 100)
			: 0;
	const pmDelta = Math.round((other.avg_pm25 - low.avg_pm25) * 10) / 10;
	const pmPhrase =
		pmDelta > 0
			? `路徑 PM2.5 均值低約 ${pmDelta}`
			: pmDelta < 0
				? `路徑 PM2.5 均值反而高 ${-pmDelta}（格網仍有侷限）`
				: "路徑 PM2.5 均值相近";
	return `${timePhrase}。與對照相比，清淨線暴露積分約低 ${Math.max(0, expBetterPct)}%（對照 ${other.exposure} → 清淨 ${low.exposure}），${pmPhrase}。`;
}
