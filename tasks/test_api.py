import requests
import json

base_url = "https://server-1c.rdp.rozarioflowers.ru/exchange/hs/api/prices"
headers = {"Content-Type": "application/json"}

data = {"etag": None, "count": 1}
response = requests.post(base_url, headers=headers, data=json.dumps(data)) # Отправляем первый запрос с count = 1, чтобы получить значение pending

if response.status_code == 200:
  result = response.json()
  pending = result["pending"]
  count = 1
  while count <= pending:
    data = {"etag": None, "count": count}
    response = requests.post(base_url, headers=headers, data=json.dumps(data))
    if response.status_code == 200:
      result = response.json()
      data_objects = len(result["data"])
      if data_objects == count: print(f"Запрос с count = {count} вернул правильное количество объектов ({data_objects}).")
      else:                     print(f"Запрос с count = {count} вернул неправильное количество объектов. Ожидалось {count}, но получено {data_objects}.")
      count += 1
    else:
      print(f"Ошибка при отправке запроса: {response.status_code}")
      break
else:
  print(f"Ошибка при отправке первого запроса: {response.status_code}")