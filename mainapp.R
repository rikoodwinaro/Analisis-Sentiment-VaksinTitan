api_key<- "zbwirBAshh2lMwDF2m5N9BOhI"
api_secret<- "2TbvtmVXbcszP1X6zHjfLqWy72dndxk1XGOWv0LsfRyAqGQpSg"
access_token<- "397904324-4Oz0EcoNsXEmmNjXdqqWn5a0Cuk4XwSJ9fjQk7fp"
access_token_secret<- "3eXAWIAqvho5l8FlbdePN5m30i17zrZxzQqQIu7ur7opO"
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)

# Mengumpulkan tweet berdasarkan kata kunci yang kita inginkan.
tweets <- searchTwitter('vaksin+titan', n = 1000, lang="id")
vaksintitan <- twListToDF(tweets)

#Membuat csv berdasarkan tweet yang sudah kita dapatkan
write.csv(vaksintitan, file = "raw-data.csv")

# Memilih Kolom "text" tabel vaksintitan untuk dibersihkan pada tahap selanjutnya
vaksintitan_text <- vaksintitan$text

## Cleaning Dataset
# Menjadikan semua text menjadi lowercase atau huruf kecil
vaksintitan_clean <- tolower(vaksintitan_text)
# replace blank space ("RT")
vaksintitan_clean <- gsub("rt", "", vaksintitan_clean)
# replace twitter @ username handle
vaksintitan_clean <- gsub("@\\w+", "", vaksintitan_clean)
# Menghilangkan tanda baca
vaksintitan_clean <- gsub("[[:punct:]]", "", vaksintitan_clean)
# Menghilangkan link
vaksintitan_clean <- gsub("http\\w+", "", vaksintitan_clean)
# Menghilangkan Tabs
vaksintitan_clean <- gsub("[ |\t]{2,}", "", vaksintitan_clean)
# Menghapus lahan kosong di awal tweet
vaksintitan_clean <- gsub("^ ", "", vaksintitan_clean)
# Menghapus lahan kosong di akhir tweet
vaksintitan_clean <- gsub(" $", "", vaksintitan_clean)

# Simpan dalam format.csv
write.csv(vaksintitan_clean, file = "clean-data.csv")

## Pembuatan Gambar WordCloud
corp <- Corpus(VectorSource(vaksintitan_clean))
vaksintitan_clean.text.corpus <- tm_map(corp, function(x)removeWords(x, stopwords()))
word_cloud_plot <- wordcloud(vaksintitan_clean.text.corpus, min.freq = 10, colors = brewer.pal(8, "Dark2"), random.color = TRUE, max.words = 1000)


# Klasifikasi Emosi
class_emo = classify_emotion(vaksintitan_clean, algorithm="bayes", prior=1.0)
# Mengelompokan Emosi dengan kategori yang pas
emotion = class_emo[,7]
# Mengganti NA's by "unknown"
emotion[is.na(emotion)] = "unknown"


# create and sort dataframe with results
dataframe = data.frame(text=vaksintitan_clean, emotion=emotion, stringsAsFactors=FALSE)

table(dataframe$emotion)

write.csv(dataframe, file = "final-data.csv")
