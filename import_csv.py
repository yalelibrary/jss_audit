import csv
import pandas as pd

images = pd.read_csv("./fedora_server.csv")
pids=pd.read_csv("./jss_page_pids.csv", header=None, squeeze=True)
pattern = '|'.join(pids)

exists = images["/jss_task/fedora_server.csv"].str.contains(pids)
images[~exists].to_csv('New_not_exist.csv')