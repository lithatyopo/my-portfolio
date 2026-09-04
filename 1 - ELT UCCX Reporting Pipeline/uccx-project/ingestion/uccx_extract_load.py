import argparse
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text, URL
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = URL.create(
    drivername="postgresql",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT"),
    database=os.getenv("DB_NAME"),
)

def ingest_files(directory_path: Path, schema: str = 'raw'):
    # Initialize SQLAlchemy Engine
    engine = create_engine(DATABASE_URL)
    
    # Find all CSV files in the target directory
    csv_files = list(directory_path.glob("*.csv"))

    with engine.begin() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema}"))

    if not csv_files:
        print(f"No CSV files found in {directory_path}")
        return

    # Loop through and ingest each file
    for file_path in csv_files:
        # file_path.stem converts 'users.csv' to 'users'
        table_name = file_path.stem
        
        print(f"Ingesting {file_path.name} into table '{table_name}'")
        
        # Read the file into a DataFrame
        df = pd.read_csv(file_path)

     # Drop fully-empty rows/columns that UCCX sometimes exports
        df = df.dropna(how="all")
        df = df.dropna(axis=1, how="all")      
     # Replace spaces with underscores
        df.columns = df.columns.str.replace(' ', '_')

        # Dynamically pass the table name
        df.to_sql(
            name=table_name, 
            con=engine,
            schema=schema,
            if_exists="append", 
            index=False
        )
        
    print("All files ingested successfully.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ingest directory files to Postgres via SQLAlchemy.")
    
    # The required argument when running the file
    parser.add_argument("directory", type=Path, help="Path to the directory containing files")

    args = parser.parse_args()
    
    # Run the ingestion
    ingest_files(args.directory)


