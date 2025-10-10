import logging
import time
import os
from pathlib import Path
import requests
import json
import uuid
import re
import difflib
# import mysql.connector
import pandas as pd
import warnings
from sqlalchemy import create_engine, MetaData
from sqlalchemy import Table, Column, Boolean, Integer, BigInteger, String, Text, Date, DateTime, DECIMAL, ForeignKey # https://docs.sqlalchemy.org/en/20/core/type_basics.html
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base # moved from: from sqlalchemy.ext.declarative import declarative_base

logging.basicConfig( # Настройка базового логирования
  level=logging.ERROR, # Уровень логирования, например ERROR (будут записываться ошибки и более высокие уровни)
  format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', # Формат вывода сообщений
  handlers=[
    logging.FileHandler('app_errors.log'), # Записывать ошибки в файл
    logging.StreamHandler() # Также выводить ошибки на экран
  ]
)

# # Пример записи ошибок
# try:
#   # Здесь может быть ваш код, который вызывает ошибку
#   result = 10 / 0
# except ZeroDivisionError as e:
#   logging.error(f"Произошла ошибка: {e}")
# logging.info("Это информационное сообщение.") # Пример логирования информации
# logging.warning("Это предупреждающее сообщение.") # Пример предупреждения

warnings.filterwarnings('ignore', category=UserWarning) # Для pansdas

# Подключение к базе данных MySQL через SQLAlchemy
DATABASE_URL = 'mysql+mysqlconnector://root:rT5wAW1h5Q119r$5wAW1h5Q1@localhost/admin_rozario'
engine = create_engine(DATABASE_URL, echo=False)
Base = declarative_base()

images_directory = '/srv/rozarioflowers.ru/public/product_images'

class ProductComplect(Base):
  __tablename__ = 'product_complects'
  id          = Column(Integer, primary_key=True, autoincrement=True)
  product_id  = Column(Integer, nullable=True)
  complect_id = Column(Integer, nullable=True)
  price       = Column(DECIMAL(10, 0), nullable=True)
  image       = Column(String(255), nullable=True)
  created_at  = Column(DateTime, nullable=True)
  updated_at  = Column(DateTime, nullable=True)
  price_1990  = Column(Integer, nullable=True)
  price_2890  = Column(Integer, nullable=True)
  price_3790  = Column(Integer, nullable=True)
  over_1990   = Column(Integer, nullable=True)
  over_2890   = Column(Integer, nullable=True)
  over_3790   = Column(Integer, nullable=True)
  over_1290   = Column(Integer, nullable=True)
  id_1C       = Column(String(36), nullable=True)
  text        = Column(Text, nullable=True)
  size        = Column(String(255), nullable=True)
  package     = Column(String(255), nullable=True)
  components  = Column(String(255), nullable=True)
  color       = Column(String(255), nullable=True)
  categories  = Column(String(255), nullable=True)
  recipient   = Column(String(255), nullable=True)
  reason      = Column(String(255), nullable=True)
  discounts   = Column(Text, nullable=True)
  main_image  = Column(String(255), nullable=True)
  all_images  = Column(Text, nullable=True)

# Создание сессии для работы с БД
Session = sessionmaker(bind=engine)
session = Session()

# Загрузка данных из базы данных MySQL
metadata = MetaData()
table_products          = Table('products',          metadata, autoload_with=engine)
table_product_complects = Table('product_complects', metadata, autoload_with=engine)
table_complects         = Table('complects',         metadata, autoload_with=engine)
q1 = session.query(table_products).all()
q2 = session.query(table_product_complects).all()
q3 = session.query(table_complects).all()

def correct(string):
  if re.search(r'\dст\.', string) or re.search(r'\dст\s', string): string = string.replace('ст.', ' ст.').replace('ст ', ' ст.')
  if 'драцена фрагранс массанжианна' in string.lower(): string = string.replace('ассанжианна', 'ассанжеана')
  if 'маджета' in string.lower(): string = string.replace('аджета', 'аджента')
  if 'cпатифилум' in string.lower(): string = string.replace('патифилум', 'патифиллум')
  if 'мурайя' in string.lower(): string = string.replace('урайя', 'уррайя')
  if 'Замиокулкас' in string: string = string.replace('Замиокулкас', 'Замиокулькас')
  if 'фриканда' in string: string = string.replace('фриканда', 'фрикана')
  if 'хиарт' in string.lower() or 'хеарт' in string.lower(): string = string.replace('иарт', 'арт').replace('еарт', 'арт')
  if 'роус' in string.lower(): string = string.replace('оус', 'оза')
  if 'Д ' in string: string = string.replace('Д ', 'Д')
  if '( ' in string: string = string.replace('( ', '(')
  if ' )' in string: string = string.replace(' )', ')')
  if ' ст ' in string.lower(): string = string.replace(' ст ', ' ст. ')
  string = ' '.join(string.replace('ё', 'е').replace('-', ' ').replace('(', '').replace(')', '').strip().split())
  return string

def processing(df):
  for i, x in df.iterrows(): # print(i, x['A'], x['B'])
    try:
      product_complect = session.query(ProductComplect).filter(ProductComplect.id == int(x['A'])).first()
      if product_complect:
        product_id = product_complect.product_id
        complect_id = product_complect.complect_id # print(product_complect.id)
        complect = session.query(table_complects).filter(table_complects.c.id == complect_id).first()
        complect_header = complect[4]
        product = session.query(table_products).filter(table_products.c.id == product_id).first()
        product_header = product[13]
        title = f'{product_header} ({complect_header})'
        url = f"https://server-1c.rdp.rozarioflowers.ru/exchange/hs/api/products?id={x['B']}" # URL для GET-запроса
        response = requests.get(url) # Отправка GET-запроса
        if response.status_code == 200: # Проверка успешности запроса
          data = response.json() # Получение данных в формате JSON
          if (correct(title).lower() == correct(data['title']).lower()) or disable_name_match_checking:
            # print(correct(title).lower()); print(correct(data['title']).lower()); print(x['B'])
            product_complect.id_1C = x['B']
            if 'title' in data:
              if data['title']:
                product_complect.title = correct(data['title'])
            if 'size' in data:
              if data['size']:
                product_complect.size = data['size']
            if 'package' in data:
              if data['package']:
                product_complect.package = data['package']
            if 'color' in data:
              if data['color']:
                product_complect.color = data['color']
            if 'components' in data:
              if data['components']:
                product_complect.components = data['components']
            if 'categories' in data:
              if data['categories']:
                product_complect.categories = data['categories']
            if 'recipient' in data:
              if data['recipient']:
                product_complect.recipient = data['recipient']
            if 'reason' in data:
              if data['reason']:
                product_complect.reason = data['reason']
            if 'discounts' in data:
              if data['discounts']: product_complect.discounts = json.dumps(data['discounts'])
              else:                 product_complect.discounts = None
            if 'main_image' in data:
              if data['main_image']: product_complect.main_image = json.dumps(data['main_image'])
              else:                  product_complect.main_image = None
            if 'all_images' in data:
              if data['all_images']: product_complect.all_images = json.dumps(data['all_images'])
              else:                  product_complect.all_images = None
            if 'price' in data:
              if data['price']:
                product_complect.price = int(data['price'])
            if 'price_1990' in data:
              if data['price_1990']:
                product_complect.price_1990 = int(data['price_1990'])
            if 'price_2890' in data:
              if data['price_2890']:
                product_complect.price_2890 = int(data['price_2890'])
            if 'price_3790' in data:
              if data['price_3790']:
                product_complect.price_3790 = int(data['price_3790'])
            session.commit() # Сохранение изменений в базе данных

            for image in data['all_images']:
              name = image['url'].split('/')[-1] # print(image['url'])
              path = os.path.join(images_directory, x['B'])
              Path(path).mkdir(parents=True, exist_ok=True)
              if os.path.exists(os.path.join(path, name)): logging.info(f"Пропущено: {name} уже существует.")
              else:
                try:
                  response = requests.get(image['url'], stream=True)
                  response.raise_for_status() # Проверка на ошибки HTTP
                  with open(os.path.join(path, name), "wb") as f:
                    for chunk in response.iter_content(1024): f.write(chunk)
                  logging.info(f"Скачано: {name}")
                except requests.exceptions.RequestException as e: logging.error(f"Ошибка при скачивании {file_name}: {e}")
              logging.info(f"Элемент с product_complect_id: {x['A']} и id_1C: {x['B']} обновлен успешно.")
          else:
            logging.error(f"Ошибка для product_complect_id: {x['A']} и id_1C: {x['B']} - '{title}' != '{data['title']}'")
            continue
        else:
          logging.error(f"Ошибка для product_complect_id: {x['A']} и id_1C: {x['B']} - {response.status_code}: {response.text}")
          continue
      else:
        logging.error(f"Ошибка для product_complect_id: {x['A']} и id_1C: Элемент не найден")
        continue
    except Exception as e:
      session.rollback() # Откат изменений в случае ошибки
      print(f"Ошибка при обновлении: {e}")
      print(f"product_complect.id: {product_complect.id}")
      print(json.dumps(data, indent=2))
      # raise
    # if i == 0: break
    if i % 16 == 0: print(f'Processed {i} from {len(csv_data)}')

try:
  disable_name_match_checking = True
  print('Start of processing')
  start_time = time.time() # Начало отсчета времени
  # csv_data = pd.read_csv('sample_1_bound.csv', sep=',', header=None, index_col=None)
  # csv_data = pd.read_csv('sample_1_bound.csv', sep=',', header=None, index_col=None)
  csv_data = pd.read_csv('id_1C.csv', sep=',', header=None, index_col=None)
  csv_data.columns = [chr(i) for i in range(65, 65 + len(csv_data.columns))]
  processing(csv_data)
  # csv_data = pd.read_csv('sample_2_bound.csv', sep=',', header=None, index_col=None)
  # csv_data.columns = [chr(i) for i in range(65, 65 + len(csv_data.columns))]
  # processing(csv_data)
  execution_time = time.time() - start_time
  print(f'Time of execution: {execution_time:.2f} second')
except Exception as e: logging.error(f"Unhandled exception: {e}")
finally: session.close() # Закрытие сессии