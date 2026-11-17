
import pandas as pd
from pathlib import Path

# File paths
base_path = Path(__file__).resolve().parents[1]
input_file = base_path / "data" / "customers" / "customers_raw.csv"
output_file = base_path / "data" / "customers" / "customers_cleaned.csv"

# Load raw data
df = pd.read_csv(input_file)

# 1. Standardize text columns
text_columns = [
    "FirstName", "LastName", "Email", "Phone",
    "Gender", "City", "State", "CustomerSegment",
    "CustomerStatus"
]

for col in text_columns:
    df[col] = df[col].astype("string").str.strip()

# 2. Standardize email
df["Email"] = df["Email"].str.lower()
df.loc[df["Email"].eq(""), "Email"] = pd.NA

# 3. Standardize phone
df["Phone"] = df["Phone"].str.replace(r"\s+", "", regex=True)
df.loc[df["Phone"].eq(""), "Phone"] = pd.NA

# 4. Standardize customer status
df["CustomerStatus"] = df["CustomerStatus"].str.lower()
df["CustomerStatus"] = df["CustomerStatus"].replace({
    "active": "Active",
    "inactive": "Inactive",
    "unknown": "Unknown",
    "": pd.NA
})

# 5. Standardize gender and customer segment
df["Gender"] = df["Gender"].str.title()
df["CustomerSegment"] = df["CustomerSegment"].str.title()

# 6. Validate email format
valid_email = df["Email"].str.match(
    r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$",
    na=False
)
df.loc[~valid_email, "Email"] = pd.NA

# 7. Validate phone length
phone_digits = df["Phone"].str.replace(r"\D", "", regex=True)
valid_phone = phone_digits.str.len().between(10, 15)
df.loc[~valid_phone, "Phone"] = pd.NA

# 8. Convert date columns
date_columns = ["DateOfBirth", "RegistrationDate", "CreatedDate"]

for col in date_columns:
    df[col] = pd.to_datetime(df[col], errors="coerce")

# 9. Remove duplicate CustomerIDs only
df = df.drop_duplicates(subset=["CustomerID"], keep="first")

# 10. Save cleaned data
df.to_csv(output_file, index=False)

# Final verification
print("CUSTOMER DATA CLEANING COMPLETED")
print("Raw rows: 1000")
print("Cleaned rows:", len(df))
print("Duplicate CustomerIDs:", df["CustomerID"].duplicated().sum())
print("Null emails after cleaning:", df["Email"].isna().sum())
print("Null phones after cleaning:", df["Phone"].isna().sum())
print("Customer statuses:")
print(df["CustomerStatus"].value_counts(dropna=False))
print("Saved:", output_file)
