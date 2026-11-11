import csv
import random
from datetime import datetime, timedelta

NUM_CUSTOMERS = 1000
NUM_TRANSACTIONS = 15000
START_DATE = datetime(2023, 1, 1)

customers = [f"CUST_{i:05d}" for i in range(1, NUM_CUSTOMERS + 1)]
products = [
    ("SKU_101", "Electronics", 120.00),
    ("SKU_102", "Apparel", 45.50),
    ("SKU_103", "Home & Kitchen", 30.00),
    ("SKU_104", "Footwear", 85.00),
    ("SKU_105", "Accessories", 22.00)
]

with open("transactions.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["transaction_id", "customer_id", "order_date", "sku", "category", "amount", "status"])
    
    for tx_id in range(1, NUM_TRANSACTIONS + 1):
        cust = random.choice(customers)
        days_offset = random.randint(0, 365)
        tx_date = START_DATE + timedelta(days=days_offset)
        prod = random.choice(products)
        status = "COMPLETED" if random.random() > 0.05 else "CANCELLED"
        
        writer.writerow([
            f"TX_{tx_id:07d}",
            cust,
            tx_date.strftime("%Y-%m-%d %H:%M:%S"),
            prod[0],
            prod[1],
            round(prod[2] * random.uniform(0.9, 1.2), 2),
            status
        ])

print("Generated transactions.csv successfully!")
