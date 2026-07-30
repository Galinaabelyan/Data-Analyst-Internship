import pandas as pd
import numpy as np

def clean_master_data(df):
    """
    Function to construct the 'Golden Master Record'.
    Cleans datasets by removing duplicates while preserving the most complete and up-to-date data.
    """
    # Create a copy to avoid SettingWithCopyWarning
    cleaned_df = df.copy()
    
    # 1. Calculate missing values per row and sort
    # Priority: Latest update_date first, then fewest NaN values
    cleaned_df['null_count'] = cleaned_df.isnull().sum(axis=1)
    cleaned_df = cleaned_df.sort_values(
        by=['client_id', 'update_date', 'null_count'], 
        ascending=[True, False, True]
    )
    
    # 2. Deduplicate, keeping the first (most complete and recent) record for each client
    golden_records = cleaned_df.drop_duplicates(subset=['client_id'], keep='first').copy()
    
    # 3. Validation: ensure correct phone number format (converts to string first to prevent AttributeError)
    golden_records = golden_records[
        golden_records['phone'].astype(str).str.contains(r'^\+7|8', na=False)
    ]
    
    return golden_records.drop(columns=['null_count'])

if __name__ == "__main__":
    # Load raw dataset
    raw_data = pd.read_csv('raw_dataset_t1.csv')
    clean_data = clean_master_data(raw_data)
    
    print(f"Cleaned records count: {len(raw_data) - len(clean_data)}")
    clean_data.to_csv('final_golden_records.csv', index=False)
