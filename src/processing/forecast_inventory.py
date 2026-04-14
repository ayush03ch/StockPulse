from __future__ import annotations

import argparse
from dataclasses import dataclass

import numpy as np
import pandas as pd


@dataclass
class InventoryParams:
    service_level_z: float = 1.65
    lead_time_days: int = 7


def compute_forecast_metrics(df: pd.DataFrame, window: int = 4) -> pd.DataFrame:
    ordered = df.sort_values(["product_id", "date"]).copy()

    ordered["forecast_ma"] = (
        ordered.groupby("product_id")["demand"]
        .rolling(window=window, min_periods=1)
        .mean()
        .reset_index(level=0, drop=True)
    )

    ordered["views_lag_1"] = ordered.groupby("product_id")["views"].shift(1)
    ordered["surge_index"] = np.where(
        ordered["views_lag_1"].fillna(0) > 0,
        (ordered["views"] - ordered["views_lag_1"]) / ordered["views_lag_1"],
        0.0,
    )

    ordered["adjusted_demand"] = ordered["forecast_ma"] * (1 + ordered["surge_index"])
    return ordered


def compute_inventory_metrics(df: pd.DataFrame, params: InventoryParams) -> pd.DataFrame:
    stats = (
        df.groupby("product_id", as_index=False)
        .agg(avg_daily_demand=("demand", "mean"), sigma_demand=("demand", lambda s: s.std(ddof=0)))
    )
    stats["sigma_demand"] = stats["sigma_demand"].fillna(0.0)
    stats["safety_stock"] = (
        params.service_level_z * stats["sigma_demand"] * np.sqrt(params.lead_time_days)
    )
    stats["reorder_point"] = (stats["avg_daily_demand"] * params.lead_time_days) + stats["safety_stock"]

    enriched = df.merge(stats[["product_id", "safety_stock", "reorder_point"]], on="product_id", how="left")
    return enriched


def summarize_kpis(df: pd.DataFrame) -> pd.DataFrame:
    latest = df.sort_values("date").groupby("product_id").tail(1)
    kpi = latest[
        [
            "product_id",
            "date",
            "demand",
            "forecast_ma",
            "surge_index",
            "adjusted_demand",
            "safety_stock",
            "reorder_point",
        ]
    ].copy()
    return kpi.sort_values("product_id")


def main() -> None:
    parser = argparse.ArgumentParser(description="Forecast demand and compute inventory metrics.")
    parser.add_argument("--input", required=True, help="Path to daily product demand CSV")
    parser.add_argument("--output", required=True, help="Path to save enriched metrics CSV")
    parser.add_argument("--kpi", required=True, help="Path to save latest KPI snapshot CSV")
    args = parser.parse_args()

    raw = pd.read_csv(args.input, parse_dates=["date"])

    expected_columns = {"date", "product_id", "demand", "views"}
    missing = expected_columns - set(raw.columns)
    if missing:
        raise ValueError(f"Missing required columns: {sorted(missing)}")

    with_forecast = compute_forecast_metrics(raw)
    with_inventory = compute_inventory_metrics(with_forecast, InventoryParams())

    with_inventory.to_csv(args.output, index=False)
    summarize_kpis(with_inventory).to_csv(args.kpi, index=False)

    print(f"Saved detailed metrics to {args.output}")
    print(f"Saved KPI snapshot to {args.kpi}")


if __name__ == "__main__":
    main()
