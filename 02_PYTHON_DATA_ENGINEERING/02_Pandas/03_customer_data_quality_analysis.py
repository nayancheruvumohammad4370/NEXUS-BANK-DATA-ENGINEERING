
import pandas as pd
from pathlib import Path

# Load extracted customer data
base_path = Path(__file__).resolve().parents[1]
file_path = base_path / "data" / "customers" / "customers_raw.csv"

df = pd.read_csv(file_path)

print("=" * 55)
print("NEXUS BANK - CUSTOMER DATA QUALITY REPORT")
print("=" * 55)

# 1. Basic information
print("\n1. DATASET OVERVIEW")
print("Total rows:", len(df))
print("Total columns:", len(df.columns))

# 2. Null values
print("\n2. NULL VALUE ANALYSIS")
print(df.isnull().sum())

# 3. Blank / whitespace values
print("\n3. BLANK VALUE ANALYSIS")
for col in df.select_dtypes(include="object").columns:
    blanks = df[col].fillna("").str.strip().eq("").sum()
    if blanks > 0:
        print(f"{col}: {blanks} blank values")

# 4. Duplicate records
print("\n4. DUPLICATE ANALYSIS")
print("Duplicate CustomerIDs:", df["CustomerID"].duplicated().sum())
print("Duplicate Emails:", df["Email"].dropna().str.strip().str.lower().duplicated().sum())

# 5. Invalid email format
print("\n5. INVALID EMAIL ANALYSIS")
email = df["Email"].fillna("").str.strip()

valid_email = email.str.match(
    r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"
)

invalid_email = email.ne("") & ~valid_email
print("Invalid email records:", invalid_email.sum())

# 6. Phone number validation
print("\n6. PHONE VALIDATION")
phone = df["Phone"].fillna("").astype(str).str.strip()
phone_digits = phone.str.replace(r"\D", "", regex=True)

invalid_phone = phone.ne("") & ~phone_digits.str.len().between(10, 15)
print("Invalid phone records:", invalid_phone.sum())

# 7. Customer status analysis
print("\n7. CUSTOMER STATUS ANALYSIS")
print(df["CustomerStatus"].value_counts(dropna=False))

print("\nNormalized status categories:")
print(
    df["CustomerStatus"]
    .dropna()
    .astype(str)
    .str.strip()
    .str.lower()
    .value_counts()
)

# 8. Date validation
print("\n8. DATE VALIDATION")
for col in ["DateOfBirth", "RegistrationDate", "CreatedDate"]:
    parsed_dates = pd.to_datetime(df[col], errors="coerce")
    invalid_dates = df[col].notna() & parsed_dates.isna()
    print(f"{col} invalid dates:", invalid_dates.sum())

print("\n" + "=" * 55)
print("DATA QUALITY ANALYSIS COMPLETED")
print("=" * 55)
