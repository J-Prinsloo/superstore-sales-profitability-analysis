import requests
import pandas as pd
url='https://fakestoreapi.com/products'
response=requests.get(url)
print(response.status_code)
data=response.json()
df=pd.DataFrame(data)
df.to_csv("Products.csv",index=False)
print(df.head())
print(df.info())
