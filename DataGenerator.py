from datetime import date, timedelta
import pyodbc
import random
from datetime import datetime


conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};'
                       'Server=LAPTOP-GAA0FGDK\SQLEXPRESS;'
                       'Database=DW;'
                       'Trusted_Connection=yes;')
cursor = conn.cursor()


cursor.execute("INSERT INTO Marketing_Campaigns (Marketing_CampaignID, Start_Date, Finish_Date, Marketing_Campaign_Name, Cost, CompanyID) VALUES ('121', '2023-01-01', '2023-01-31', 'Amazing Journey', '60000', '40')")
for loc_id in range(1, 17):
     values = (loc_id, 121)
     cursor.execute("INSERT INTO Localisations_Marketing_Campaigns (LocalisationID, Marketing_CampaignID) VALUES (?, ?)", values)

start_date = date(2023, 1, 1)
end_date = date(2023, 1, 31)
delta = timedelta(days=1)

# Define range of people for each year
people_ranges = {
    2023: range(40, 101)
}

for j in range(1, 32):
    current_date = start_date + (j - 1) * delta
    year = current_date.year
    for i in range(1, 161):
        # Determine the date and number of people for the current row
        num_people = random.choice(people_ranges[year])
        sql_query = f"INSERT INTO Traffics (TrafficID, Number_Of_People, Traffic_Date, StoreID) VALUES ({i + (j-1)*160 + 584320}, {num_people}, '{current_date}', {i});"
        cursor.execute(sql_query)


start_date = date(2023, 1, 1)
end_date = date(2023, 1, 31)
delta = timedelta(days=1)

sales_per_day = {'2023': 34}

price_range = range(2000, 10000)
ID = 584321

for i in range(1, 32):
    current_date = start_date + (i - 1) * delta
    year = current_date.year
    for x in range(1, 161):

        price = random.choice(price_range)


        query = f"INSERT INTO Sales (SaleID, Sale_Date, Turnover, StoreID) VALUES ({ID}, '{current_date}', {price}, {x});"
        cursor.execute(query)
        ID=ID+1


start_date = datetime(2023, 1, 1)
start_year = start_date.year
start_month = start_date.month
start_day = start_date.day
platform_name = 'TikTok'
advertising_id = 197209
marketing_id = 121
current_year = 2023
current_month = 1

for current_day in range(start_day, start_day+31):
    for daily_adv_no in range(1, 55):
        publication_date = datetime(current_year, current_month, current_day)
        no_of_likes = random.randint(100, 100000)
        no_of_comments = random.randint(20, 5000)
        no_of_views = random.randint(10000, 1000000)
        no_of_followers = random.randint(100, 3000)

        sql = f"INSERT INTO Advertising (AdvertisingID, Publication_Date, No_Of_Likes, No_Of_Comments, No_Of_Followers, " \
                f"No_Of_Views, PlatformName, Marketing_CampaignID) " \
                f"VALUES ({advertising_id}, '{publication_date}', {no_of_likes}, {no_of_comments}, {no_of_followers}, " \
                f"{no_of_views}, '{platform_name}', '{marketing_id}');"

        advertising_id += 1
        cursor.execute(sql)

conn.commit()
cursor.close()
conn.close()



