import pandas as pd
import numpy as np

def clean_master_data(df):
    """
    Функция для поиска 'Золотой записи' (Master Record).
    Применяется для очистки датасетов от дубликатов с сохранением самых полных данных.
    """
    
    # 1. Сортируем по дате обновления и полноте данных
    # Сначала самые свежие, затем те, где меньше пустых значений (NaN)
    df['null_count'] = df.isnull().sum(axis=1)
    df = df.sort_values(by=['client_id', 'update_date', 'null_count'], 
                       ascending=[True, False, True])
    
    # 2. Удаляем дубликаты, оставляя только первую (лучшую) запись для каждого клиента
    golden_records = df.drop_duplicates(subset=['client_id'], keep='first')
    
    # 3. Валидация: проверяем корректность форматов (например, телефонов)
    golden_records = golden_records[golden_records['phone'].str.contains(r'^\+7|8', na=False)]
    
    return golden_records.drop(columns=['null_count'])

if __name__ == "__main__":
    # Загружаем "грязные" данные
    raw_data = pd.read_csv('raw_dataset_t1.csv')
    clean_data = clean_master_data(raw_data)
    print(f"Очищено записей: {len(raw_data) - len(clean_data)}")
    clean_data.to_csv('final_golden_records.csv', index=False)
