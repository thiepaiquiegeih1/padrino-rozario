import uuid
import re
import difflib
# import mysql.connector
import pandas as pd
import warnings
from sqlalchemy import create_engine, Table, MetaData
from sqlalchemy.orm import sessionmaker

warnings.filterwarnings('ignore', category=UserWarning)

# Подключение к базе данных
# conn = mysql.connector.connect(
#   host="localhost",
#   user="root",
#   password="rT5wAW1h5Q119r$5wAW1h5Q1",
#   database="admin_rozario"
# )

# Подключение к базе данных MySQL через SQLAlchemy
DATABASE_URL = 'mysql+mysqlconnector://root:rT5wAW1h5Q119r$5wAW1h5Q1@localhost/admin_rozario'
engine = create_engine(DATABASE_URL, echo=False)

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
list_of_escaped_complects_headers = [re.escape(row[4].lower()) for row in q3]
complects_headers = {row[0]: row[4] for row in q3} # complects_headers = [(row[0], row[4]) for row in q3]

# for row in q1: # products
#   print('id:',            row[0])
#   print('title:',         row[1])
#   print('rating:',        row[2])
#   print('announce:',      row[3])
#   print('text:',          row[4])
#   print('color:',         row[5])
#   print('created_at:',    row[6])
#   print('updated_at:',    row[7])
#   print('discount:',      row[8])
#   print('trick_price:',   row[9])
#   print('default_image:', row[10])
#   print('default_price:', row[11])
#   print('orderp:',        row[12])
#   print('header:',        row[13])
#   print('description:',   row[14])
#   print('keywords:',      row[15])
#   print('alt:',           row[16])
#   print('seo_id:',        row[17])
#   print('slug:',          row[18])
#   exit(0)

# Загрузка данных из CSV файла в DataFrame
# csv_data = pd.read_csv('Номенклатура.csv', sep='|', header=None, index_col=0)
csv_data = pd.read_csv('Номенклатура_2.csv', sep='|', header=None, index_col=0)
csv_data.index = csv_data.index.map(lambda x: uuid.UUID(x))
csv_data.columns = [chr(i) for i in range(65, 65 + len(csv_data.columns))]
csv_data['A'] = csv_data['A'].str.replace('ё', 'е') # Замена всех "ё" на "е" в столбце 'A'

# Удалить отсутствующие в БД позиции
#
csv_data = csv_data[~csv_data['A'].str.startswith('Сказочная Красота')]
csv_data.drop(index=uuid.UUID('08f970af-6aba-11e2-8547-0013d4d9289b'), inplace=True) # Суккулент микс в керамике Д15 (EV918), Товар, шт
csv_data.drop(index=uuid.UUID('08f970b1-6aba-11e2-8547-0013d4d9289b'), inplace=True) # Суккулент микс в керамике Д9, Товар, шт
csv_data.drop(index=uuid.UUID('2462987c-c9ba-11e0-a0c9-0013d4d9289b'), inplace=True) # Суккулент микс Д10, Товар, шт
csv_data.drop(index=uuid.UUID('fd91c5f4-0792-11e6-b188-0013d4d9289b'), inplace=True) # Суккулент микс Д15, Товар, шт
csv_data.drop(index=uuid.UUID('11121582-7c8a-11e0-bd11-0013d4d9289b'), inplace=True) # Суккулент микс Д5, Товар, шт
csv_data.drop(index=uuid.UUID('a6e16e46-97e0-11e0-863b-0013d4d9289b'), inplace=True) # Суккулент микс Д9, Товар, шт
csv_data.drop(index=uuid.UUID('a6e16e48-97e0-11e0-863b-0013d4d9289b'), inplace=True) # Суккулент микс Де люкс Д9, Товар, шт
csv_data.drop(index=uuid.UUID('9f454aaf-1023-11e1-8a0f-0013d4d9289b'), inplace=True) # Суккулент Микс с блестками Д5, Товар, шт
# PS. Из суккулентов в наличии только "Суккулент микс в ракушке"
csv_data.drop(index=uuid.UUID('b34cb52f-0d0b-11e9-8172-52540077d4fc'), inplace=True) # Мишка из 3D cтандартный (малиновый), Товар, шт
csv_data.drop(index=uuid.UUID('69047305-3cb8-11e9-8181-52540077d4fc'), inplace=True) # Мишка из 3D cтандартный (розовый), Товар, шт
csv_data.drop(index=uuid.UUID('eef2378a-1731-11e9-8173-52540077d4fc'), inplace=True) # Мишка из 3D люкс (красный), Товар, шт
csv_data.drop(index=uuid.UUID('cdd4fd48-0d0b-11e9-8172-52540077d4fc'), inplace=True) # Мишка из 3D стандартный (белый), Товар, шт
csv_data.drop(index=uuid.UUID('8fccdc99-0d0b-11e9-8172-52540077d4fc'), inplace=True) # Мишка из 3D стандартный (оранжевый), Товар, шт
csv_data.drop(index=uuid.UUID('7021b7b7-0d0b-11e9-8172-52540077d4fc'), inplace=True) # Мишка из 3D стандартный (сиреневый), Товар, шт
csv_data.drop(index=uuid.UUID('560b404e-0d0b-11e9-8172-52540077d4fc'), inplace=True) # Мишка из 3D стандартный (фиолетовый), Товар, шт
# PS. Из 3D мишек в наличии только "Мишка из 3D роз (стандартный)"
csv_data = csv_data[~csv_data['A'].str.startswith('Мишка из 3D')] # PS. В наличии только стандартный комплект.
csv_data = csv_data[~csv_data['A'].str.startswith('Небесный горизонт')]
csv_data = csv_data[~csv_data['A'].str.startswith('Аглаонема')] # Много разных комплектов в 1С, но в БД всего по одному комплекту на 2 продукта, и те отличаются названиями.
csv_data = csv_data[~csv_data['A'].str.startswith('Белая Ночь')]
csv_data = csv_data[~csv_data['A'].str.startswith('Букет Белый бант')]
csv_data = csv_data[~csv_data['A'].str.startswith('Влюбленность')]
csv_data = csv_data[~csv_data['A'].str.startswith('Время Любви')]
csv_data = csv_data[~csv_data['A'].str.startswith('Всегда Рядом')]
csv_data = csv_data[~csv_data['A'].str.startswith('Звук весны')]
csv_data = csv_data[~csv_data['A'].str.startswith('Прекрасная')]
csv_data = csv_data[~csv_data['A'].str.startswith('Самая любимая')]
csv_data = csv_data[~csv_data['A'].str.startswith('Райский Дар')]
csv_data = csv_data[~csv_data['A'].str.startswith('Праздник Души')]
csv_data = csv_data[~csv_data['A'].str.startswith('Нежные слова')]
csv_data = csv_data[~csv_data['A'].str.startswith('Волнующий момент (уменьшенный)')] # В наличии только "стандартный"
csv_data = csv_data[~csv_data['A'].str.startswith('Хорошее Настроение (люкс)')] # В наличии только "стандартный"
csv_data = csv_data[~csv_data['A'].str.startswith('Хорошее Настроение (уменьшенный)')] # В наличии только "стандартный"
csv_data = csv_data[~csv_data['A'].str.startswith('Корзина с шоколадом (уменьшенный)')]
csv_data.drop(index=uuid.UUID('f63009e2-411c-11e7-8109-52540077d4fc'), inplace=True) # Букет 101 роза (белый) (стандартный), Набор, к...
csv_data.drop(index=uuid.UUID('ddce2933-dd2d-11e4-8d90-0013d4d9289b'), inplace=True) # Букет 101 роза (белый) (уменьшенный), Набор, к...
csv_data.drop(index=uuid.UUID('6b3c3d73-dd3c-11e4-8d90-0013d4d9289b'), inplace=True) # Букет 101 роза (красный) (стандартный), Набор,...
#csv_data.drop(index=uuid.UUID('edfc6d54-5e1b-11e6-b43c-0013d4d9289b'), inplace=True) # Букет из 101 розы (красный) (уменьшенный), Наб...
# PS. Вероятно, что несовпавшие букеты из 101 розы имеются с идентичными названиями
csv_data.drop(index=uuid.UUID('aa3242c8-5463-11e8-8132-52540077d4fc'), inplace=True) # Моё сердце  (стандартный), Товар, компл # Дубликат

# for i, x in csv_data[csv_data['A'].str.startswith('Корзина с шоколадом')].iterrows(): print(x)
# exit(0)

keywords = ['стандартный', 'люкс', 'уменьшенный']
list_of_escaped_complects_headers = list(set(list_of_escaped_complects_headers) - set([re.escape(x) for x in keywords]))
mask = csv_data['A'].str.contains('|'.join(keywords), case=False, na=False)
sample_1 = csv_data[mask]
sample_2 = csv_data[~mask]

# print('Sample of sample_1:'); print(sample_1.sample(3))
# print('Sample of sample_2:'); print(sample_2.sample(3))

def processing(sample, keywords=[], verbose=True):
  cntr = 0; reproc_cntr = 0
  product_complect_ids = []
  result = []
  for i, row in enumerate(q2): # product_complects
    product = session.query(table_products).filter(table_products.c.id == row[1]).first()
    if product: # Если сущестует продукт с id указанным в связующем поле комплекта
      product_header = product[13].replace('ё', 'е').strip()
      escaped_string = re.escape(product_header)
      if keywords == []:
        df = sample[sample['A'].str.lower().str.startswith(product_header.lower(), na=False)]
      else:
        regex = rf'^{escaped_string}\s*({"|".join(keywords)}).*$' # regex = rf'^{escaped_string}\s*\(({"|".join(keywords)})\).*$'
        df = sample[sample['A'].str.contains(regex, case=False, na=False, regex=True)]
      if df.empty: pass # print("DataFrame пуст")
      else:
        for i, x in df.iterrows():
          x = x.values[0]
          if f'({complects_headers[row[2]].lower()})' in x.lower() and product_header != '':
            if (row[0] in product_complect_ids):
              # reproc_cntr = reproc_cntr + 1
              # print(row[1], product_header, x)
              print('Reprocessing ERROR!')
              continue
            else: cntr = cntr + 1
            result.append((row[0], i)) # print((row[2], i))
            sample.drop(index=i, inplace=True)
            if verbose:
              print(f'{cntr} | {product_header} | {complects_headers[row[2]]}')
              print(f'Индекс: {i}, Строка: {x}')
              print('id:',              row[0])
              print('product_id:',      row[1])
              print('product_header:',  product_header)
              print('complect_id:',     row[2])
              print('complect_header:', complects_headers[row[2]])
              # print('image:', row[4])
              # print('price:', row[3]); print('price_1990:', row[7]); print('price_2890:', row[8]); print('price_3790:', row[9])
              # print('over_1990:', row[10]); print('over_2890:', row[11]); print('over_3790:', row[12]); print('over_1290:', row[13])
              # print('created_at:', row[5]); print('updated_at:', row[6])
              print('----------------------------------------------------------------')
            product_complect_ids.append(row[0])
  return result, cntr, reproc_cntr, sample

bound = list()

# Sample 1
result, cntr, reproc_cntr, shank = processing(sample_1.copy(), [re.escape(f'({x})') for x in keywords], verbose=False)
print('Sample 1')
# for i, x in shank.iterrows(): print(x)
print(f'Всего: {len(sample_1)}')
print(f'Обработано: {cntr}')
print(f'Обработано повторно: {reproc_cntr}')
print(f'Остаток: {len(sample_1) - cntr}')

with open('sample_1_bound.csv', 'w', newline='') as f:
  for i in result: f.write(f"{i[0]},{i[1]}\r\n")

# bound += result
del(result) # for i in bound: print(i)

print('----------------------------------------------------------------')

# Sample 2
result, cntr, reproc_cntr, shank = processing(sample_2.copy(), [rf'\({x}\)' for x in list_of_escaped_complects_headers], verbose=False) # pd.concat([shank, sample_2], ignore_index=False)
print('Sample 2')
# for i, x in shank.iterrows(): print(x)
print(f'Всего: {len(sample_2)}')
print(f'Обработано: {cntr}')
print(f'Обработано повторно: {reproc_cntr}')
print(f'Остаток: {len(sample_2) - cntr}')

with open('sample_2_bound.csv', 'w', newline='') as f:
  for i in result: f.write(f"{i[0]},{i[1]}\r\n")

# bound += result
del(result) # for i in bound: print(i)

print('----------------------------------------------------------------')

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

product_headers = []; complect_ids = []
for i, row in enumerate(q2): # product_complects
  product = session.query(table_products).filter(table_products.c.id == row[1]).first()
  if product: # Если сущестует продукт с id указанным в связующем поле комплекта
    product_headers.append(correct(product[13]))
    complect_ids.append(row[1])

# if len(product_headers) == len(set(product_headers)): print("Список `product_headers` уникален")
# else: print("В списке `product_headers` есть дубликаты")

sample_3 = shank.copy(); del shank

def processing_2(sample, verbose=True):
  w_bound = []; unbound = []
  shank = []
  for i, x in sample.iterrows():
    string = correct(x['A'])
    product_headers_lower = [product_header.lower() for product_header in product_headers]
    closest_matches = difflib.get_close_matches(string.lower(), product_headers_lower, n=5, cutoff=0.6)
    if closest_matches:
      complect_ids_for_closest_matches = [complect_ids[product_headers_lower.index(closest_match)] for closest_match in closest_matches]
      # for closest_match in closest_matches:
      #   print(closest_match)
      #   print(product_headers_lower.index(closest_match))
      #   print(complect_ids[product_headers_lower.index(closest_match)])
      similarities = [difflib.SequenceMatcher(None, string.lower(), closest_match.lower()).ratio() for closest_match in closest_matches] # print(f"Для строки '{string}' наиболее похожая строка: '{best_match}' с оценкой схожести: {similarity:.2f}")
      if similarities[0] != 1.0:
        save = True
        for num, closest_match in enumerate(closest_matches):
          double_ix = next((idx for idx, d in enumerate(w_bound) if d['complect_id'] == complect_ids_for_closest_matches[num]), None)
          if not double_ix:
            w_bound.append({'1C_id': i, 'complect_id': complect_ids_for_closest_matches[num], 'weight': similarities[num]})
            save = False
            break
          elif w_bound[double_ix]['weight'] < similarities[num]:
            unbound.append(w_bound[double_ix]['1C_id'])
            w_bound[double_ix]['1C_id'] = i
            w_bound[double_ix]['weight'] = similarities[num]
            save = False
        if save: shank.append((i, x['A']))
      else: bound.append((complect_ids_for_closest_matches[0], i))
    else: pass # print(f"Для строки '{string}' нет похожих строк.")
  return w_bound, unbound, shank

def wrapper_processing_2(sample, verbose=True, lvl=0):
  lvl += 1
  if verbose: print(f'Start of Level {lvl}')
  w_bound, unbound, shank = processing_2(sample, verbose)
  if len(unbound) > 0:
    sub_sample = pd.DataFrame(columns=sample.columns)
    for i in unbound: sub_sample.loc[i] = sample.loc[i, 'A']
    a, b, c = wrapper_processing_2(sub_sample, verbose, lvl)
    w_bound += a; unbound = b; shank += c
  if verbose:
    print(f'Results of Level {lvl}')
    print(f'shank: {len(shank)}')
    print(f'bound: {len(bound)}')
    print(f'w_bound: {len(w_bound)}')
    print(f'unbound: {len(unbound)}')
  return w_bound, unbound, shank

w_bound, unbound, shank = wrapper_processing_2(sample_3)

w_bound = sorted(w_bound, key=lambda x: x['weight'], reverse=True)

with open('siblings.csv', 'w') as f:
  f.write("1C_id,1C_header,site_complect_id,site_product_header,similarity\r\n")
  for i in w_bound:
    f.write(f"{i['1C_id']},{sample_3.loc[i['1C_id'], 'A']},{i['complect_id']},{product_headers[complect_ids.index(i['complect_id'])]},{i['weight']}\r\n")

# df = pd.read_csv('siblings.csv') # Загрузить CSV в DataFrame
# df = df.sort_values(by='A', ascending=False) # Сортировать DataFrame по столбцу 'A' по уб.
# df.to_csv('sorted_data.csv', index=False) # Сохранить отсортированный DataFrame в новый CSV-файл

with open('shank.csv', 'w', newline='') as f:
  # shank.to_csv(f, index=True) # Записываем DataFrame в CSV с кроссплатформенным переносом строки
  for i in shank: f.write(f"{i[0]},{i[1]}\r\n")

with open('bound.csv', 'w', newline='') as f:
  # bound.to_csv(f, index=True) # Записываем DataFrame в CSV с кроссплатформенным переносом строки
  for i in bound: f.write(f"{i[0]},{i[1]}\r\n")

exit(0)

# # Преобразование данных из базы данных в DataFrame
# db_data = pd.DataFrame([dict(row) for row in query])

# print(db_data.describe())

# Просмотр первых 5 строк
print("Первые 5 строк:")
print(df.head())

# Просмотр статистической информации
print("\nСтатистика:")
print(df.describe())

# Просмотр информации о DataFrame
print("\nИнформация о DataFrame:")
df.info()

# Просмотр случайных 3 строк
print("\nСлучайные 3 строки:")
print(df.sample(3))

# df.to_csv('filtered_products.csv', index=True, encoding='utf-8')

# # Объединение данных по полю 'title'
# merged_data = pd.merge(db_data, csv_data, on='title', how='inner')

# # Для примера: сохраняем результат в новую таблицу БД (или обновляем существующую таблицу)
# # Создаем новую таблицу для результатов
# merged_data.to_sql('merged_products', con=engine, if_exists='replace', index=False)

# print("Данные успешно объединены и сохранены в новую таблицу.")