from __future__ import annotations

import random
from datetime import date, timedelta

import pandas as pd


PRODUCTS = ["P101", "P102", "P103", "P104"]


def main() -> None:
    start = date(2026, 2, 1)
    days = 45

    rows = []
    for day_idx in range(days):
        day = start + timedelta(days=day_idx)
        for product in PRODUCTS:
            base = {"P101": 50, "P102": 80, "P103": 30, "P104": 65}[product]
            demand = max(1, int(random.gauss(base, base * 0.12)))
            views = max(1, int(demand * random.uniform(4.5, 7.0)))

            if product == "P102" and day_idx > 30:
                views = int(views * 1.25)
                demand = int(demand * 1.12)

            rows.append(
                {
                    "date": day.isoformat(),
                    "product_id": product,
                    "demand": demand,
                    "views": views,
                }
            )

    df = pd.DataFrame(rows)
    df.to_csv("data/sales_data.csv", index=False)
    print("Generated data/sales_data.csv")


if __name__ == "__main__":
    main()
